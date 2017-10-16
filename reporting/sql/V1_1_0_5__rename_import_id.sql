-- Rename import_id columns to update_import_id to represent the warehouse value being migrated

USE ${schemaName};

ALTER TABLE asmt
  CHANGE import_id update_import_id BIGINT NOT NULL;

ALTER TABLE school
  CHANGE import_id update_import_id BIGINT NOT NULL;

ALTER TABLE student
  CHANGE import_id update_import_id BIGINT NOT NULL;

ALTER TABLE student_group
  CHANGE import_id update_import_id BIGINT NOT NULL;

ALTER TABLE exam
  CHANGE import_id update_import_id BIGINT NOT NULL;

ALTER TABLE staging_school
  CHANGE import_id update_import_id BIGINT NOT NULL;

ALTER TABLE staging_student
  CHANGE import_id update_import_id BIGINT NOT NULL;

ALTER TABLE staging_student_group
  CHANGE import_id update_import_id BIGINT NOT NULL;

ALTER TABLE staging_asmt
  CHANGE import_id update_import_id BIGINT NOT NULL;

ALTER TABLE staging_exam
  CHANGE import_id update_import_id BIGINT NOT NULL;