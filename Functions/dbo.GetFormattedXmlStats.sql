USE [Shop_Manager]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*************************************************************************
Author:		 	Radosław Deja
Create date:  	2025-06-10
Description:	Funkcja odpowiednio formatuje xml dla statyskyk zapisywanych w logach
*************************************************************************/
CREATE OR ALTER FUNCTION [dbo].[GetFormattedXmlStats]
(
    @XmlDetails XML
)
RETURNS XML
AS
BEGIN
	IF (@XmlDetails.exist('/ExecutionStatistics/Stats') = 1)
	BEGIN
		-- usuwamy element <End> z każdego węzła <Stats>
		SET @XmlDetails.modify('delete //Stats/End');
	END

    RETURN @XmlDetails;
END
GO