USE [Shop_Manager]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*************************************************************************
Author:		 	Radosław Deja
Create date:  	2025-06-10
Description:	Funkcja zwraca nazwę obiektu w formacie <schemat>.<nazwa_obiektu>
*************************************************************************/
CREATE OR ALTER FUNCTION [dbo].[GetFullObjectName](@ProcId INT)
	RETURNS VARCHAR(100)
AS
BEGIN
    RETURN FORMATMESSAGE('%s.%s', OBJECT_SCHEMA_NAME(@ProcId), OBJECT_NAME(@ProcId));
END
GO