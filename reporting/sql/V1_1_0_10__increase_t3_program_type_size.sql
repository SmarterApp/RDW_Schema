-- Increase the size of the t3_program_type column to account for all valid values

USE ${schemaName};

ALTER TABLE exam
  MODIFY COLUMN t3_program_type varchar(30);

ALTER TABLE staging_exam
  MODIFY COLUMN t3_program_type varchar(30);
