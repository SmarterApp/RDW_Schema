-- Increase the size of the t3_program_type column in the exam audit table to account for all valid values

USE ${schemaName};

ALTER TABLE audit_exam
  MODIFY COLUMN t3_program_type varchar(30);