USE [Shop_Manager]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************
 Author:		Radosław Deja
 Create date:	2025-06-10
 Description:	Insert log data
****************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[LogSqlInsert]
(
	@Description Varchar(5000),
	@UserName Varchar(100),
	@ProcedureName varchar(100),
	@IdLog INT  OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		INSERT INTO [dbo].[LogSql]([Description],ExecuteByUser,ProcedureName)
		VALUES (@Description,@UserName,@ProcedureName)

		SET @IdLog = @@IDENTITY;

	END TRY
	BEGIN CATCH

		PRINT ERROR_MESSAGE();

	END CATCH
END