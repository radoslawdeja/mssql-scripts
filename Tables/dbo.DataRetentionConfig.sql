USE [Shop_Manager]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS(SELECT NULL FROM sys.tables WHERE object_id = OBJECT_ID(N'dbo.DataRetentionConfig'))
	CREATE TABLE [dbo].[DataRetentionConfig] (
		[IdDataRetentionConfig] INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_DataRetentionConfig_IdDataRetentionConfig PRIMARY KEY CLUSTERED,
		[TableSchema] NVARCHAR(128) NOT NULL,
		[TableName] NVARCHAR(128) NOT NULL,
		[FilterCondition] NVARCHAR(500) NOT NULL,
		[Description] NVARCHAR(500),
		[LastRefreshDate] DATETIME NULL,
		[IsActive] BIT NOT NULL CONSTRAINT DF_DataRetentionConfig_IsActive DEFAULT(1),
		CONSTRAINT CK_DataRetentionConfig_FilterCondition CHECK ([FilterCondition] IS NOT NULL AND LEN(LTRIM(RTRIM([FilterCondition]))) > 0),
		CONSTRAINT UQ_DataRetentionConfig_TableSchemaTableName UNIQUE (TableSchema, TableName),

		[ValidFrom] DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
		[ValidTo] DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
		PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])

	) ON [PRIMARY] WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.DataRetentionConfigHistory))
GO

IF NOT EXISTS(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = OBJECT_ID('dbo.DataRetentionConfig') AND [name] = N'IdDataRetentionConfig' AND [minor_id] = 0)
	EXEC sys.sp_addextendedproperty @name=N'IdDataRetentionConfig', @value=N'PK of table.',@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DataRetentionConfig';
GO
IF NOT EXISTS(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = OBJECT_ID('dbo.DataRetentionConfig') AND [name] = N'TableSchema' AND [minor_id] = 0)
	EXEC sys.sp_addextendedproperty @name=N'TableSchema', @value=N'Table schema.',@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DataRetentionConfig';
GO
IF NOT EXISTS(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = OBJECT_ID('dbo.DataRetentionConfig') AND [name] = N'TableName' AND [minor_id] = 0)
	EXEC sys.sp_addextendedproperty @name=N'TableName', @value=N'Table name.',@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DataRetentionConfig';
GO
IF NOT EXISTS(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = OBJECT_ID('dbo.DataRetentionConfig') AND [name] = N'FilterCondition' AND [minor_id] = 0)
	EXEC sys.sp_addextendedproperty @name=N'FilterCondition', @value=N'Filter table in clausule where by condition.',@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DataRetentionConfig';
GO
IF NOT EXISTS(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = OBJECT_ID('dbo.DataRetentionConfig') AND [name] = N'Description' AND [minor_id] = 0)
	EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Description.',@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DataRetentionConfig';
GO
IF NOT EXISTS(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = OBJECT_ID('dbo.DataRetentionConfig') AND [name] = N'LastRefreshDate' AND [minor_id] = 0)
	EXEC sys.sp_addextendedproperty @name=N'LastRefreshDate', @value=N'Date of the last data refresh.',@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DataRetentionConfig';
GO
IF NOT EXISTS(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = OBJECT_ID('dbo.DataRetentionConfig') AND [name] = N'IsActive' AND [minor_id] = 0)
	EXEC sys.sp_addextendedproperty @name=N'IsActive', @value=N'Flag indicating whether the table deletion configuration is active.',@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DataRetentionConfig';
GO