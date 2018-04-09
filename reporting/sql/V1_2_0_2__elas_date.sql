-- Flyway script to add ELAS (English Language Acquisition Status) date
--

USE ${schemaName};

ALTER TABLE exam
  ADD COLUMN elas_start_at DATE NULL;

ALTER TABLE staging_exam
  ADD COLUMN elas_start_at DATE NULL;
