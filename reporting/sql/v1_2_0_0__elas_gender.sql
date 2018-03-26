-- Flyway script to add ELAS (English Language Acquisition Status) and unknown gender
--
-- ELAS: this is a new attribute for students. It overlaps with LEP but will be treated as
-- an independent, optional attribute. LEP will be changed to be optional as well.
--
-- As part of this change, remove the ids for denormalized exam/student fields where only the code is used.
-- This includes elas, completeness and administration_condition.
--
-- NOTE: instead of migrating CODES, which would require multiple scripts, just make the changes directly.

USE ${schemaName};

INSERT INTO gender (id, code) VALUES
  (3, 'Nonbinary');

CREATE TABLE IF NOT EXISTS elas (
  id tinyint NOT NULL PRIMARY KEY,
  code varchar(20) NOT NULL UNIQUE
);

INSERT INTO elas (id, code) VALUES
  (1, 'EO'),
  (2, 'EL'),
  (3, 'IFEP'),
  (4, 'RFEP'),
  (5, 'TBD');

CREATE TABLE IF NOT EXISTS staging_elas (
  id tinyint NOT NULL PRIMARY KEY,
  code varchar(20) NOT NULL UNIQUE
);

ALTER TABLE exam
  MODIFY COLUMN lep TINYINT NULL,
  ADD COLUMN elas_code VARCHAR(20) NULL,
  DROP COLUMN completeness_id,
  DROP COLUMN administration_condition_id;

ALTER TABLE staging_exam
  MODIFY COLUMN lep TINYINT NULL,
  ADD COLUMN elas_id TINYINT NULL;