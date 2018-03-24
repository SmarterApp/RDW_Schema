-- Flyway script to add ELAS (English Language Acquisition Status) and unknown gender
--
-- NOTE: instead of migrating CODES, which would require multiple scripts, just make the changes directly.

USE ${schemaName};

INSERT INTO gender (id, code) VALUES
  (3, 'NonBinary');

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
  ADD COLUMN elas_id TINYINT NULL,
  ADD COLUMN elas_code VARCHAR(20) NULL,
-- ??? i don't see FKs for completeness_id or administration_condition_id, do we want these?
  ADD CONSTRAINT fk__exam__elas FOREIGN KEY (elas_id) REFERENCES elas(id);

ALTER TABLE staging_exam
  MODIFY COLUMN lep TINYINT NULL,
  ADD COLUMN elas_id TINYINT NULL;