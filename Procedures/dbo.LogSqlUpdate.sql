USE [Shop_Manager]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************
 Author:		Radosław Deja
 Create date:	2025-06-10
 Description:	Update log data
****************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[LogSqlUpdate]
(
	@IfError BIT = 0,
	@Description VARCHAR(5000) = '',
	@ActionDetails XML = NULL,
	@ErrorMessage VARCHAR(5000) = NULL,
	@IdLog INT
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE
			[dbo].[LogSql]
		SET
			[IfError] = @IfError,
			[End] = GETDATE(),
			[Description] = IIF(@Description = '', [Description], CONCAT([Description], ' .', @Description)),
			[ErrorMessage] = @ErrorMessage,
			[ActionDetails] = @ActionDetails
		WHERE
			[IdLog] = @IdLog

	END TRY
	BEGIN CATCH

		PRINT ERROR_MESSAGE();

	END CATCH
END