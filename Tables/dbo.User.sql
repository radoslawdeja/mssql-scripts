USE [Shop_Manager];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS(SELECT NULL FROM sys.tables WHERE object_id = OBJECT_ID(N'dbo.User'))
	CREATE TABLE [dbo].[User]
		([IdUser] [int] NOT NULL IDENTITY(1,1) CONSTRAINT PK_User_IdUser PRIMARY KEY CLUSTERED,
		[Guid] [uniqueidentifier] NOT NULL,
		[Name] [nvarchar](128) NOT NULL,
		[Login] [nvarchar](128) NOT NULL,
		[CreateDate] [datetime] NOT NULL CONSTRAINT DF_User_CreateDate DEFAULT GETDATE(),
		[ValidFrom] datetime2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
		[ValidTo] datetime2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
		PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.UserHistory));
GO
IF NOT EXISTS(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = OBJECT_ID('dbo.User') AND [name] = N'TableDescription' AND [minor_id] = 0)
	EXEC sys.sp_addextendedproperty @name=N'TableDescription', @value=N'Table contains Users.',
	@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'User';
GO
IF NOT EXISTS(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = OBJECT_ID('dbo.User') AND [name] = N'IdUser' AND [minor_id] = 0)
    EXEC sys.sp_addextendedproperty @name = N'IdUser', @value = N'PK of table.',
	@level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'User';
GO
IF NOT EXISTS(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = OBJECT_ID('dbo.User') AND [name] = N'Guid' AND [minor_id] = 0)
    EXEC sys.sp_addextendedproperty @name = N'Guid', @value = N'Unique identifier of an user.',
	@level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'User';
GO
IF NOT EXISTS(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = OBJECT_ID('dbo.User') AND [name] = N'Name' AND [minor_id] = 0)
    EXEC sys.sp_addextendedproperty @name = N'Name', @value = N'User name.',
	@level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'User';
GO
IF NOT EXISTS(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = OBJECT_ID('dbo.User') AND [name] = N'Login' AND [minor_id] = 0)
    EXEC sys.sp_addextendedproperty @name = N'Login', @value = N'User login.',
	@level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'User';
GO
IF NOT EXISTS(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = OBJECT_ID('dbo.User') AND [name] = N'CreateDate' AND [minor_id] = 0)
    EXEC sys.sp_addextendedproperty @name = N'CreateDate', @value = N'Date of row creation.',
	@level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'User';
GO
IF NOT EXISTS(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = OBJECT_ID('dbo.User') AND [name] = N'ValidFrom' AND [minor_id] = 0)
    EXEC sys.sp_addextendedproperty @name = N'ValidFrom', @value = N'Date since when row is valid.',
	@level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'User';
GO
IF NOT EXISTS(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = OBJECT_ID('dbo.User') AND [name] = N'ValidTo' AND [minor_id] = 0)
    EXEC sys.sp_addextendedproperty @name = N'ValidTo', @value = N'Date until row is valid.',
	@level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'User';
GO