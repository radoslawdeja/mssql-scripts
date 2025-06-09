USE [Shop_Manager]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*************************************************************************
Author:		 	Radosław Deja
Create date:  	2025-06-10
Description:	Procedura czyści dane z tabel na podstawie konfiguracji w dbo.DataRetentionConfig
*************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[ClearHistoricalData]
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		/* Zmienne do logów */
		DECLARE
			@IdLog INT,
			@ProcedureName VARCHAR(100) = [dbo].[GetFullObjectName](@@PROCID),
			@XmlInput XML = (SELECT TableSchema, TableName, FilterCondition FROM [dbo].[DataRetentionConfig] FOR XML PATH('Values'), ROOT('Input') ,BINARY BASE64),
			@UserName NVARCHAR(128) = (SELECT [Name] FROM [dbo].[User] WHERE [IdUser] = 0),
			@XmlDetails XML,
			@XmlAll XML,
			@Message NVARCHAR(200),
			@ErrorMessage VARCHAR(1000);
		
		/* Zmienne pomocnicze */
		DECLARE
			@IdDataRetentionConfig INT,
			@TableSchema NVARCHAR(128),
			@TableName NVARCHAR(128),
			@FilterCondition NVARCHAR(500),
			@SQL NVARCHAR(MAX),
			@IsHistoricalTable BIT,
			@IsTemporalTable BIT,
			@MainTableName NVARCHAR(128),
			@MainTableSchema NVARCHAR(128),
			@HistorySchemaName NVARCHAR(128),
			@HistoryTableName NVARCHAR(128);

		EXEC [dbo].[LogSqlInsert] @ProcedureName = @ProcedureName, @UserName = @UserName, @Description = 'Kasowanie danych z tabel znajdujących się w konfiguracji dbo.DataRetentionConfig', @IdLog = @IdLog OUTPUT;

		/*******************************************************************************************************************************************
		 Przygotowanie danych dla kursora - pobranie danych z tabeli [dbo].[DataRetentionConfig]
		*******************************************************************************************************************************************/
		DECLARE RetentionCursor CURSOR FOR
		SELECT
			IdDataRetentionConfig,
			TableSchema,
			TableName,
			FilterCondition
		FROM
			[dbo].[DataRetentionConfig]
		WHERE
			IsActive = 1

		/*******************************************************************************************************************************************
		 Kasowanie danych z tabel
		*******************************************************************************************************************************************/
		EXEC [dbo].[AddStatsToXml] @XmlDetails OUT, 'Uruchomienie procesu kasowania';

		OPEN RetentionCursor;
		FETCH NEXT FROM RetentionCursor INTO @IdDataRetentionConfig, @TableSchema, @TableName, @FilterCondition;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			/*******************************************************************************************************************************************
			 Sprawdzamy czy istnieje tabela
			*******************************************************************************************************************************************/
			IF EXISTS (SELECT NULL FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @TableSchema AND TABLE_NAME = @TableName)
			BEGIN
				/*******************************************************************************************************************************************
				 Sprawdzamy jaki jest rodzaj tabeli: temporalna (wersjonowana), historyczna, zwykła
				*******************************************************************************************************************************************/
				SELECT
					@IsTemporalTable = IIF(t.temporal_type = 2, 1, 0),
					@IsHistoricalTable = IIF(t.temporal_type = 1, 1, 0),
					@MainTableName = IIF(t.temporal_type = 1, mt.name, NULL),
					@MainTableSchema = IIF(t.temporal_type = 1, ms.name, NULL),
					@HistorySchemaName = IIF(t.temporal_type = 1, @TableSchema, ms.name),
					@HistoryTableName = IIF(t.temporal_type = 1, @TableName, mt.name)
				FROM sys.tables t
				LEFT JOIN sys.tables mt ON (t.temporal_type = 1 AND mt.history_table_id = t.object_id) OR (t.temporal_type = 2 AND mt.object_id = t.history_table_id)
				LEFT JOIN sys.schemas ms ON ms.schema_id = mt.schema_id
				INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
				WHERE
					t.name = @TableName
					AND s.name = @TableSchema;

				DECLARE
					@DeleteRecordsCount INT = 1000000,	-- maks. liczba rekordów usuwana w jednym kroku (tabela historyczna)
					@RowCount INT = -1,					-- ilość usuniętych rekordów z tabeli (tabela zwykła i temporalna) bądź usuniętych w jednym kroku (tabela historyczna)
					@RowCountSum INT = 0;				-- suma usuniętych rekordów (tabela historyczna)

				BEGIN TRY
					/*******************************************************************************************************************************************
					 Jeżeli tabela jest historyczna to usuwamy dane w paczkach po 1 mln rekordów wraz z opóźnieniem czasowym 2 sek.
					 Na czas trwania usuwania jest wyłączone wersjonowanie (SYSTEM_VERSIONING = OFF).
					*******************************************************************************************************************************************/
					IF @IsHistoricalTable = 1
					BEGIN
						WHILE (@RowCount > (@DeleteRecordsCount-1) OR @RowCount = -1)
						BEGIN
							BEGIN TRANSACTION
							SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

							SET @SQL = CONCAT('ALTER TABLE ', QUOTENAME(@MainTableSchema), '.', QUOTENAME(@MainTableName), ' SET (SYSTEM_VERSIONING = OFF);');
							EXEC sp_executesql @SQL;

							SET @SQL = CONCAT('DELETE TOP(', @DeleteRecordsCount,') FROM ', QUOTENAME(@TableSchema), '.', QUOTENAME(@TableName), ' WHERE ', @FilterCondition, ';');
							EXEC sp_executesql @SQL;
							SET @RowCount = @@ROWCOUNT;
							SET @RowCountSum += @RowCount;

							SET @SQL = CONCAT('ALTER TABLE ', QUOTENAME(@MainTableSchema), '.', QUOTENAME(@MainTableName), ' SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = ', QUOTENAME(@HistorySchemaName), '.', QUOTENAME(@HistoryTableName), ', DATA_CONSISTENCY_CHECK = OFF));');
							EXEC sp_executesql @SQL;

							COMMIT TRANSACTION
							WAITFOR DELAY '00:00:02';
						END
					END
					/*******************************************************************************************************************************************
					 Jeżeli tabela jest temporalna to wyłączamy tylko wersjonowanie (SYSTEM_VERSIONING = OFF).
					*******************************************************************************************************************************************/
					ELSE IF @IsTemporalTable = 1
					BEGIN
						BEGIN TRANSACTION
						SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

						SET @SQL = CONCAT('ALTER TABLE ', QUOTENAME(@TableSchema), '.', QUOTENAME(@TableName), ' SET (SYSTEM_VERSIONING = OFF);');
						EXEC sp_executesql @SQL;

						SET @SQL = CONCAT('DELETE FROM ', QUOTENAME(@TableSchema), '.', QUOTENAME(@TableName), ' WHERE ', @FilterCondition, ';');
						EXEC sp_executesql @SQL;
						SET @RowCountSum = @@ROWCOUNT;

						SET @SQL = CONCAT('ALTER TABLE ', QUOTENAME(@TableSchema), '.', QUOTENAME(@TableName), ' SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = ', QUOTENAME(@HistorySchemaName), '.', QUOTENAME(@HistoryTableName), ', DATA_CONSISTENCY_CHECK = OFF));');
						EXEC sp_executesql @SQL;

						COMMIT TRANSACTION
					END
					/*******************************************************************************************************************************************
					 Jeżeli zwykła tabela to usuwamy dane i wyłączenie wersjonowania nie jest potrzebne.
					*******************************************************************************************************************************************/
					ELSE
					BEGIN
						BEGIN TRANSACTION
						SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

						SET @SQL = CONCAT('DELETE FROM ', QUOTENAME(@TableSchema), '.', QUOTENAME(@TableName), ' WHERE ', @FilterCondition, ';');
						EXEC sp_executesql @SQL;
						SET @RowCountSum = @@ROWCOUNT;

						COMMIT TRANSACTION
					END

					/*******************************************************************************************************************************************
					 Aktualizujemy [LastRefreshDate] w konfiguracji
					*******************************************************************************************************************************************/
					UPDATE [dbo].[DataRetentionConfig]
					SET
						[LastRefreshDate] = GETDATE()
					WHERE
						[IdDataRetentionConfig] = @IdDataRetentionConfig

					SET @Message = CONCAT(QUOTENAME(@TableSchema), '.', QUOTENAME(@TableName), '.', ' Ilość usuniętych rekordów: ', @RowCountSum);
					EXEC [dbo].[AddStatsToXml] @XmlDetails OUT, @Message;

				END TRY
				BEGIN CATCH
					
					IF(@@TRANCOUNT > 0)
						ROLLBACK TRANSACTION

					SET @ErrorMessage = CONCAT(QUOTENAME(@TableSchema), '.', QUOTENAME(@TableName), ' - ', LEFT(ERROR_MESSAGE(),1000));
					EXEC [dbo].[AddStatsToXml] @XmlDetails OUT, @ErrorMessage;

				END CATCH
			END
			ELSE
			BEGIN
				SET @Message = CONCAT('Tabela ', QUOTENAME(@TableSchema), '.', QUOTENAME(@TableName), ' nie istnieje');
				EXEC [dbo].[AddStatsToXml] @XmlDetails OUT, @Message;
			END

			FETCH NEXT FROM RetentionCursor INTO @IdDataRetentionConfig, @TableSchema, @TableName, @FilterCondition;
		END

		CLOSE RetentionCursor;
		DEALLOCATE RetentionCursor;

		/*******************************************************************************************************************************************
		 Zapis do logów
		*******************************************************************************************************************************************/
		EXEC [dbo].[AddStatsToXml] @XmlDetails OUT, 'Kasowanie danych zostało zakończone';

		SET @XmlAll = (SELECT @XmlInput, [dbo].[GetFormattedXmlStats](@XmlDetails) FOR XML path(''), root('AllLogs'), BINARY base64);
		EXEC [dbo].[LogSqlUpdate] @ActionDetails = @XmlAll, @IdLog = @IdLog;

	END TRY

	BEGIN CATCH

		SET @ErrorMessage = LEFT(ERROR_MESSAGE(),1000);
        EXEC [dbo].[LogSqlUpdate] @IfError = 1, @ActionDetails = @XmlAll, @IdLog = @IdLog, @ErrorMessage = @ErrorMessage;

	END CATCH
END
GO