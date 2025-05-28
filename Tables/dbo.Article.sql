USE [Shop_Manager]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS(SELECT NULL FROM sys.tables WHERE object_id = OBJECT_ID(N'dbo.Article'))
	CREATE TABLE [dbo].[Article]
	(
		[IdArticle] [int] NOT NULL CONSTRAINT PK_Article_IdArticle PRIMARY KEY CLUSTERED,
		[Name] [nvarchar](128) NOT NULL,
		[Price] [decimal](6,2) NOT NULL CONSTRAINT DF_Article_Price DEFAULT 0,
		[CreateDate] [datetime] NOT NULL CONSTRAINT DF_Article_CreateDate DEFAULT GETDATE(),
		[ModifyDate] [datetime],
		[ProductGroupId] [int] NOT NULL CONSTRAINT FK_Article_ProductGroupId REFERENCES [dbo].[ProductGroup]([IdProductGroup]),
		[IsActive] [bit] NOT NULL CONSTRAINT DF_Article_IsActive DEFAULT 0,
		[ValidFrom] datetime2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
		[ValidTo] datetime2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
		PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
	) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.ArticleHistory));
GO

IF NOT EXISTS(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = OBJECT_ID('dbo.Article') AND [name] = N'IdArticle' AND [minor_id] = 0)
	EXEC sys.sp_addextendedproperty @name=N'IdArticle', @value=N'PK of table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Article';
GO