-- Flyway script to add ELAS (English Language Acquisition Status) and unknown gender
--
-- ELAS: this is a new attribute for students. It overlaps with LEP but will be treated as
-- an independent, optional attribute. LEP will be changed to be optional as well.

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

-- change LEP to be optional and add ELAS
ALTER TABLE exam
  MODIFY COLUMN lep TINYINT NULL,
  ADD COLUMN elas_id TINYINT NULL,
  ADD COLUMN elas_start_at DATE NULL
