IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id('FK_EntityPropertiesLink_ReportingEntity_Definitions') AND OBJECTPROPERTY(id, 'IsForeignKey') = 1)
ALTER TABLE EntityPropertiesLink DROP CONSTRAINT FK_EntityPropertiesLink_ReportingEntity_Definitions
;

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id('FK_EntityPropertiesLink_ReportingEntity_Properties') AND OBJECTPROPERTY(id, 'IsForeignKey') = 1)
ALTER TABLE EntityPropertiesLink DROP CONSTRAINT FK_EntityPropertiesLink_ReportingEntity_Properties
;

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id('FK_ReportingCalendar_ReportingEntity_Definitions') AND OBJECTPROPERTY(id, 'IsForeignKey') = 1)
ALTER TABLE ReportingCalendar DROP CONSTRAINT FK_ReportingCalendar_ReportingEntity_Definitions
;

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id('FK_ReportingEntity_Definitions_ReportingEntity_Definitions') AND OBJECTPROPERTY(id, 'IsForeignKey') = 1)
ALTER TABLE ReportingEntity_Definitions DROP CONSTRAINT FK_ReportingEntity_Definitions_ReportingEntity_Definitions
;



IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id('EntityPropertiesLink') AND  OBJECTPROPERTY(id, 'IsUserTable') = 1)
DROP TABLE EntityPropertiesLink
;

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id('EntityReporting_Modules') AND  OBJECTPROPERTY(id, 'IsUserTable') = 1)
DROP TABLE EntityReporting_Modules
;

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id('EntityReporting_Obligations') AND  OBJECTPROPERTY(id, 'IsUserTable') = 1)
DROP TABLE EntityReporting_Obligations
;

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id('ReportingCalendar') AND  OBJECTPROPERTY(id, 'IsUserTable') = 1)
DROP TABLE ReportingCalendar
;

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id('ReportingEntity_Definitions') AND  OBJECTPROPERTY(id, 'IsUserTable') = 1)
DROP TABLE ReportingEntity_Definitions
;

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id('ReportingEntity_Properties') AND  OBJECTPROPERTY(id, 'IsUserTable') = 1)
DROP TABLE ReportingEntity_Properties
;


CREATE TABLE EntityPropertiesLink ( 
	OrderNo bigint NOT NULL,
	REF_Entity_ID bigint NOT NULL,
	REF_Property_ID bigint NOT NULL,
	PropertyValidityTime_Begin datetime NOT NULL,
	PropertyValidityTime_End datetime
)
;

CREATE TABLE EntityReporting_Modules ( 
	ID_Module bigint NOT NULL,
	Name nvarchar(255) NOT NULL
)
;

CREATE TABLE EntityReporting_Obligations ( 
	ID_Obligation bigint NOT NULL,
	Name nvarchar(255) NOT NULL
)
;

CREATE TABLE ReportingCalendar ( 
	ID_Entry bigint NOT NULL,
	REF_ID_Entity bigint NOT NULL,
	ReferenceDate datetime NOT NULL,
	SubmissionDeadline datetime NOT NULL
)
;

CREATE TABLE ReportingEntity_Definitions ( 
	ID_ReportingEntity bigint NOT NULL,
	Name nvarchar(255) NOT NULL,
	RegisteredEUCountry nvarchar(5) NOT NULL,
	REF_ID_ParentReportingEntity bigint,
	ParentReportingEntityPeriodStart datetime,
	ParentReportingEntityPeriodEnd datetime
)
;

CREATE TABLE ReportingEntity_Properties ( 
	ID_ReportingEntity_Property bigint NOT NULL,
	PropertyName nvarchar(255) NOT NULL,
	PropertyValue nvarchar(50) NOT NULL,
	PropertyDataType tinyint NOT NULL
)
;


ALTER TABLE EntityReporting_Modules ADD CONSTRAINT PK_EntityReporting_Modules 
	PRIMARY KEY CLUSTERED (ID_Module)
;

ALTER TABLE EntityReporting_Obligations ADD CONSTRAINT PK_EntityReportingObligations 
	PRIMARY KEY CLUSTERED (ID_Obligation)
;

ALTER TABLE ReportingCalendar ADD CONSTRAINT PK_ReportingCalendar 
	PRIMARY KEY CLUSTERED (ID_Entry)
;

ALTER TABLE ReportingEntity_Definitions ADD CONSTRAINT PK_ReportingEntity 
	PRIMARY KEY CLUSTERED (ID_ReportingEntity)
;

ALTER TABLE ReportingEntity_Properties ADD CONSTRAINT PK_ReportingEntity_Properties 
	PRIMARY KEY CLUSTERED (ID_ReportingEntity_Property)
;



ALTER TABLE EntityPropertiesLink ADD CONSTRAINT FK_EntityPropertiesLink_ReportingEntity_Definitions 
	FOREIGN KEY (REF_Entity_ID) REFERENCES ReportingEntity_Definitions (ID_ReportingEntity)
;

ALTER TABLE EntityPropertiesLink ADD CONSTRAINT FK_EntityPropertiesLink_ReportingEntity_Properties 
	FOREIGN KEY (REF_Property_ID) REFERENCES ReportingEntity_Properties (ID_ReportingEntity_Property)
;

ALTER TABLE ReportingCalendar ADD CONSTRAINT FK_ReportingCalendar_ReportingEntity_Definitions 
	FOREIGN KEY (REF_ID_Entity) REFERENCES ReportingEntity_Definitions (ID_ReportingEntity)
;

ALTER TABLE ReportingEntity_Definitions ADD CONSTRAINT FK_ReportingEntity_Definitions_ReportingEntity_Definitions 
	FOREIGN KEY (REF_ID_ParentReportingEntity) REFERENCES ReportingEntity_Definitions (ID_ReportingEntity)
; 
