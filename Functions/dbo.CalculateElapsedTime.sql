USE [Shop_Manager]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*****************************************************************************************
Author:		 	Radosław Deja
Create date:  	2025-06-10
Description:	Funkcja oblicza czas trwania od podanej daty początkowej (@Start)
				do chwili obecnej (GETDATE()), a następnie zwróci wynik w formacie TIME(2)
*****************************************************************************************/
CREATE OR ALTER FUNCTION [dbo].[CalculateElapsedTime] (@Start DATETIME)
	RETURNS TIME(2)
AS
BEGIN
	DECLARE
		@Result TIME(2),
		@End DATETIME = GETDATE();

	IF (@Start > @End)
		SET @Result = '00:00:00.00';
	ELSE
		SET @Result = CONVERT(TIME(2), DATEADD(ms, DATEDIFF(MILLISECOND, @Start, @End), 0));

	RETURN @Result;
END
GO