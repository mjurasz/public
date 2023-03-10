--  -------------------------------------------------- 
--  Generated by Enterprise Architect Version 7.5.844
--  Created On : ?roda, 10 marzec, 2010 
--  DBMS       : SQL Server 2005 
--  -------------------------------------------------- 

CREATE TABLE TMSDBDetails ( 
	iOrderNo bigint NOT NULL,
	DBVersion int NOT NULL,    -- version of database 
	AppVersion varchar(50) NOT NULL,    -- application version 
	UpdatingScriptName varchar(255) NOT NULL,    -- script used to update database 
	UpdatingTime datetime NOT NULL,    -- the time the script was executed 
	Successfull tinyint NOT NULL,    -- 1 - successfull 0 - not successfull 
);

ALTER TABLE TMSDBDetails ADD CONSTRAINT PK_TMSDBVersionInformation 
	PRIMARY KEY CLUSTERED (iOrderNo);

EXEC sp_addextendedproperty 'MS_Description', 'This table is provided to store version information etc. This table will be updated every time any script has been executed.', 'Schema', dbo, 'table', TMSDBDetails;
EXEC sp_addextendedproperty 'MS_Description', 'version of database', 'Schema', dbo, 'table', TMSDBDetails, 'column', DBVersion;
EXEC sp_addextendedproperty 'MS_Description', 'application version', 'Schema', dbo, 'table', TMSDBDetails, 'column', AppVersion;
EXEC sp_addextendedproperty 'MS_Description', 'script used to update database', 'Schema', dbo, 'table', TMSDBDetails, 'column', UpdatingScriptName;
EXEC sp_addextendedproperty 'MS_Description', 'the time the script was executed', 'Schema', dbo, 'table', TMSDBDetails, 'column', UpdatingTime;
EXEC sp_addextendedproperty 'MS_Description', '1 - successfull, 0 - not successfull', 'Schema', dbo, 'table', TMSDBDetails, 'column', Successfull;

CREATE TABLE TMSNamePlate ( 
	DBName varchar(50) NOT NULL,    -- name of database (spatial, tee, geotec etc) 
	GUIDName varchar(255) NOT NULL,    -- guid of db 
	DBCreatedTime datetime NOT NULL    -- Timestamp of the DB has been created 
);

EXEC sp_addextendedproperty 'MS_Description', 'This table is provided to store basic information etc. There would be only one row with basic info.', 'Schema', dbo, 'table', TMSNamePlate;
EXEC sp_addextendedproperty 'MS_Description', 'name of database (spatial, tee, geotec etc)', 'Schema', dbo, 'table', TMSNamePlate, 'column', DBName;
EXEC sp_addextendedproperty 'MS_Description', 'guid of db', 'Schema', dbo, 'table', TMSNamePlate, 'column', GUIDName;
EXEC sp_addextendedproperty 'MS_Description', 'Timestamp of the DB has been created', 'Schema', dbo, 'table', TMSNamePlate, 'column', DBCreatedTime;