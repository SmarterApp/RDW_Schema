-- Add student alias

USE ${schemaName};

ALTER TABLE student
  ADD COLUMN alias_name VARCHAR(60) NULL COMMENT 'optional alias for first name';

ALTER TABLE staging_student
  ADD COLUMN alias_name VARCHAR(60) NULL;
