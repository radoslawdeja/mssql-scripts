USE [Shop_Manager]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS(SELECT NULL FROM sys.tables WHERE object_id = OBJECT_ID(N'dbo.LogSql'))
	CREATE TABLE [dbo].[LogSql]
	(
		[IdLog] [int] IDENTITY(1,1) NOT NULL,
		[IfError] [bit] NOT NULL CONSTRAINT DF_LogSql_IfError DEFAULT(0),
		[Start] [datetime] NOT NULL CONSTRAINT DF_LogSql_Start DEFAULT(GETDATE()),
		[End] [datetime] NULL,
		[During] AS (CONVERT([time](3),DATEADD(MILLISECOND,DATEDIFF(MILLISECOND,[Start],[End]),(0)))),
		[ExecuteByUser] [varchar](100) NULL,
		[Description] [varchar](5000) NULL,
		[ActionDetails] [xml] NULL,
		[ErrorMessage] [varchar](5000) NULL,
		[ProcedureName] [varchar](100) NULL,

		CONSTRAINT [PK_LogSql] PRIMARY KEY CLUSTERED
		(
			[IdLog] ASC
		) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

--ALTER TABLE [dbo].[LogSql] ADD CONSTRAINT DF_LogSql_Start DEFAULT(GETDATE()) FOR [Start]
--GO

--ALTER TABLE [dbo].[LogSql] ADD CONSTRAINT DF_LogSql_IfError DEFAULT(0) FOR [IfError]
--GO