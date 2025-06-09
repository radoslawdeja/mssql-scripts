USE [Shop_Manager]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*************************************************************************
Author:		 	Radosław Deja
Create date:  	2025-06-10
Description:	Procedura służy do zapisywania statystyk logów w xml (Operation/Duration).
				Dodaje nowy wiersz <Stats></Stats> do istniejącego już xml w postaci:
				<ExecutionStatistics>
				  <Stats>
					<Operation></Operation>
					<Duration></Duration>
					<End></End>
				  </Stats>
				</ExecutionStatistics>
*************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[AddStatsToXml]
(
    @XmlDetails XML OUT,		-- istniejący dokument XML
    @Operation NVARCHAR(2000),	-- nowa operacja do dodania
	@StartDate DATETIME = NULL	-- czas rozpoczęcia zadania (domyślnie NULL)
)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
		@NewStats XML,
		@Start DATETIME;

	IF (@StartDate IS NOT NULL)
		SET @Start = @StartDate;
	ELSE IF (@XmlDetails.exist('/ExecutionStatistics/Stats') = 1)
	BEGIN
		SELECT
			@Start = MAX(CAST(Stats.value('(End)[1]', 'DATETIME') AS DATETIME))
		FROM
			@XmlDetails.nodes('/ExecutionStatistics/Stats') AS T(Stats);
	END
	ELSE
		SET @Start = GETDATE();

    -- Tworzenie nowego elementu <Stats> do dodania
    SET @NewStats = 
        (
			SELECT
				@Operation AS [Operation],
                CONVERT(NVARCHAR(20), [dbo].[CalculateElapsedTime](@Start), 108) AS [Duration],
				CONVERT(NVARCHAR(20), GETDATE(), 120) AS [End]
         FOR XML PATH('Stats'), TYPE);

    -- Połączenie istniejących elementów <Stats> i nowego elementu <Stats>
    SET @XmlDetails =
    (
        SELECT 
            @XmlDetails.query('/ExecutionStatistics/Stats') AS [*],
            @NewStats AS [*]
        FOR XML PATH('ExecutionStatistics'), TYPE
    );
END
GO