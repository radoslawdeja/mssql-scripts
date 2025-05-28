USE [Shop_Manager]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS(SELECT NULL FROM sys.tables WHERE object_id = OBJECT_ID(N'dbo.ProductGroup'))
	CREATE TABLE [dbo].[ProductGroup]
	(
		[IdProductGroup] [int] NOT NULL CONSTRAINT PK_ProductGroup_IdProductGroup PRIMARY KEY CLUSTERED,
		[Name] [nvarchar](256) NOT NULL CONSTRAINT UQ_ProductGroup_Name UNIQUE,
		[CreateDate] [datetime] NOT NULL CONSTRAINT DF_ProductGroup_CreateDate DEFAULT GETDATE(),
		[ModifyDate] [datetime],
		[ModifyUserId] [int] CONSTRAINT FK_ProductGroup_ModifyUserId REFERENCES [dbo].[User]([IdUser]),
		[ValidFrom] datetime2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
		[ValidTo] datetime2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
		PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo]),

		CONSTRAINT CK_ProductGroup_ModifyDateUserId CHECK (([ModifyDate] IS NULL AND [ModifyUserId] IS NULL) OR ([ModifyDate] IS NOT NULL AND [ModifyUserId] IS NOT NULL))

	) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.ProductGroupHistory));
GO

-- Add columns (ModifyDate, ModifyUserId) if not exists
IF NOT EXISTS(SELECT NULL FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ProductGroup') AND [name] = N'ModifyDate')
	ALTER TABLE [dbo].[ProductGroup] ADD [ModifyDate] [datetime];
GO
IF NOT EXISTS(SELECT NULL FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ProductGroup') AND [name] = N'ModifyUserId')
	ALTER TABLE [dbo].[ProductGroup] ADD [ModifyUserId] [int] CONSTRAINT FK_ProductGroup_ModifyUserId REFERENCES [dbo].[User]([IdUser]);
GO