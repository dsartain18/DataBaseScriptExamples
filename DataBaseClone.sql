USE [Testing]
GO

/****** Object:  StoredProcedure [dbo].[DataBaseClone]    Script Date: 4/17/2018 9:09:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DataBaseClone]') AND type in (N'P', N'PC'))
BEGIN
	DROP PROCEDURE [dbo].[DataBaseClone]
END
GO



-- =============================================
-- Author:		Don Sartain
-- Create date: 03/15/2018
-- Description:	Clone a Database given a database name to copy, a new name, and a backup path
-- =============================================
CREATE PROCEDURE [dbo].[DataBaseClone]
	-- Add the parameters for the stored procedure here
	@DBToCopy VARCHAR(100), 
	@NewName VARCHAR(100),
	@BackupPath VARCHAR(MAX),
	@DataPath VARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE 
		@FileName NVARCHAR(MAX),
		@NewMDF NVARCHAR(MAX),
		@NewLDF NVARCHAR(MAX),		
		@MDFLogicalName NVARCHAR(128),
		@LDFLogicalName NVARCHAR(128)
	
	SET @FileName = @BackupPath + '\' + @DBToCopy + '.bak'
	
	SET @NewMDF = @DataPath + '\' + @NewName + '.mdf';
	SET @NewLDF = @DataPath + '\' + @NewName + '.ldf';

    -- Insert statements for procedure here
	backup database @DBToCopy
	to disk = @FileName
	with copy_only;

	CREATE TABLE #restoreFields
		 (		
		LogicalName nvarchar(128) 
		,PhysicalName nvarchar(260) 
		,Type char(1) 
		,FileGroupName nvarchar(128) 
		,Size numeric(20,0) 
		,MaxSize numeric(20,0),
		Fileid tinyint,
		CreateLSN numeric(25,0),
		DropLSN numeric(25, 0),
		UniqueID uniqueidentifier,
		ReadOnlyLSN numeric(25,0),
		ReadWriteLSN numeric(25,0),
		BackupSizeInBytes bigint,
		SourceBlocSize int,
		FileGroupId int,
		LogGroupGUID uniqueidentifier,
		DifferentialBaseLSN numeric(25,0),
		DifferentialBaseGUID uniqueidentifier,
		IsReadOnly bit,
		IsPresent bit,
		TDEThumbprint VARCHAR,
		SnapshotUrl VARCHAR
		)

		INSERT INTO #restoreFields EXEC ('RESTORE FILELISTONLY FROM DISK = ''' + @FileName + '''')
	
	SELECT @MDFLogicalName = LogicalName FROM #restoreFields WHERE [Type] = 'D' 
	SELECT @LDFLogicalName = LogicalName FROM #restoreFields WHERE [Type] = 'L'

	SELECT * FROM #restoreFields

	DROP TABLE #restoreFields

	--RESTORE FILELISTONLY FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER2017\MSSQL\Backup\Testing.bak'

	RESTORE DATABASE @NewName FROM  DISK = @FileName WITH  FILE = 1,  
	MOVE @MDFLogicalName TO @NewMDF,  
	MOVE @LDFLogicalName TO @NewLDF,  NOUNLOAD,  STATS = 5

END

GO


