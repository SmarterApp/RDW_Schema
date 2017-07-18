-- add index to student_ethnicity to improve ingest performance of students

USE ${schemaName};

ALTER TABLE student_ethnicity
  ADD UNIQUE INDEX idx__student_ethnicity (student_id, ethnicity_id);
