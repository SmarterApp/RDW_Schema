-- Prepare for configurable subjects by creating the tables required to ingest and store
-- subject xml payloads.

USE ${schemaName};

-- Drop foreign keys to allow for modifying the subject id column
ALTER TABLE asmt DROP FOREIGN KEY fk__asmt__subject;
ALTER TABLE claim DROP FOREIGN KEY fk__claim__subject;
ALTER TABLE common_core_standard DROP FOREIGN KEY fk__common_core_standard__subject;
ALTER TABLE depth_of_knowledge DROP FOREIGN KEY fk__depth_of_knowledge__subject;
ALTER TABLE item_difficulty_cuts DROP FOREIGN KEY fk__item_difficulty_cuts__subject;
ALTER TABLE student_group DROP FOREIGN KEY fk__student_group__subject;
ALTER TABLE subject_claim_score DROP FOREIGN KEY fk__subject_claim_score__subject;

-- Modify subject table to act as import/migration root
-- TODO make import_id, update_import_id non-null during migration implementation
ALTER TABLE subject
  MODIFY COLUMN id TINYINT AUTO_INCREMENT NOT NULL,
  ADD COLUMN created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ADD COLUMN import_id BIGINT,
  ADD COLUMN update_import_id BIGINT;

-- Replace foreign keys after modifying the subject id column
ALTER TABLE asmt ADD CONSTRAINT fk__asmt__subject FOREIGN KEY (subject_id) REFERENCES subject(id);
ALTER TABLE claim ADD CONSTRAINT fk__claim__subject FOREIGN KEY (subject_id) REFERENCES subject(id);
ALTER TABLE common_core_standard ADD CONSTRAINT fk__common_core_standard__subject FOREIGN KEY (subject_id) REFERENCES subject(id);
ALTER TABLE depth_of_knowledge ADD CONSTRAINT fk__depth_of_knowledge__subject FOREIGN KEY (subject_id) REFERENCES subject(id);
ALTER TABLE item_difficulty_cuts ADD CONSTRAINT fk__item_difficulty_cuts__subject FOREIGN KEY (subject_id) REFERENCES subject(id);
ALTER TABLE student_group ADD CONSTRAINT fk__student_group__subject FOREIGN KEY (subject_id) REFERENCES subject(id);
ALTER TABLE subject_claim_score ADD CONSTRAINT fk__subject_claim_score__subject FOREIGN KEY (subject_id) REFERENCES subject(id);

-- Warehouse label table for holding Subject-scoped English label key/value pairs.
-- Functionally, these should be migrated to reporting as "eng" translation values.
CREATE TABLE subject_translation (
  subject_id TINYINT NOT NULL,
  label_code VARCHAR(128) NOT NULL,
  label TEXT,
  PRIMARY KEY(subject_id, label_code),
  CONSTRAINT fk__subject_translation__subject FOREIGN KEY (subject_id) REFERENCES subject(id)
);

-- Table for holding subject configurations in the context of an assessment type
CREATE TABLE subject_asmt_type (
  asmt_type_id TINYINT NOT NULL,
  subject_id TINYINT NOT NULL,
  performance_level_count TINYINT NOT NULL,
  performance_level_standard_cutoff TINYINT,
  claim_score_performance_level_count TINYINT,
  PRIMARY KEY(asmt_type_id, subject_id),
  INDEX idx__subject_asmt_type__subject (subject_id),
  CONSTRAINT fk__subject_asmt_type__asmt_type FOREIGN KEY (asmt_type_id) REFERENCES asmt_type(id),
  CONSTRAINT fk__subject_asmt_type__subject FOREIGN KEY (subject_id) REFERENCES subject(id)
);

-- Make name and description nullable for organizational claims
-- Name and description will come from subject_translation
ALTER TABLE claim
  MODIFY COLUMN name VARCHAR(250) DEFAULT NULL,
  MODIFY COLUMN description VARCHAR(250) DEFAULT NULL;

-- Make code and description nullable for targets
-- Code (display name) and Description will come from subject_translation
ALTER TABLE target
  MODIFY COLUMN code VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN description VARCHAR(500) DEFAULT NULL;

-- Drop foreign keys to allow for modifying the depth_of_knowledge id column
ALTER TABLE item DROP FOREIGN KEY fk__item__dok;

-- Make description nullable for depths of knowledge
-- and alter primary key column to auto-increment
ALTER TABLE depth_of_knowledge
  MODIFY COLUMN id TINYINT AUTO_INCREMENT NOT NULL,
  MODIFY COLUMN description VARCHAR(100) DEFAULT NULL;

-- Replace foreign keys on depth_of_knowledge id column
ALTER TABLE item ADD CONSTRAINT fk__item__dok FOREIGN KEY (dok_id) REFERENCES depth_of_knowledge(id);

-- Modify difficulty cut points to remove reference to assessment type
-- Per Matt they should be the same cut points per subject for all assessment types
DELETE FROM item_difficulty_cuts WHERE asmt_type_id != 1;
ALTER TABLE item_difficulty_cuts
  DROP FOREIGN KEY fk__item_difficulty_cuts__asmt_type,
  DROP COLUMN asmt_type_id,
  MODIFY COLUMN id TINYINT AUTO_INCREMENT NOT NULL;

-- Make name nullable for subject_claim_score
-- and make primary id column auto-incrementing
-- and add display_order column
ALTER TABLE subject_claim_score
  MODIFY COLUMN id TINYINT AUTO_INCREMENT NOT NULL,
  MODIFY COLUMN name VARCHAR(250) DEFAULT NULL,
  ADD COLUMN display_order TINYINT;

-- Make description nullable for common_core_standard
ALTER TABLE common_core_standard
  MODIFY COLUMN description VARCHAR(1000) DEFAULT NULL;

-- Insert data for Math: 1, ELA: 2
-- ICA: 1, IAB: 2, SUM: 3
INSERT INTO subject_asmt_type (asmt_type_id, subject_id, performance_level_count, performance_level_standard_cutoff, claim_score_performance_level_count) VALUES
  (1, 1, 4, 3, 3),
  (2, 1, 3, null, null),
  (3, 1, 4, 3, 3),
  (1, 2, 4, 3, 3),
  (2, 2, 3, null, null),
  (3, 2, 4, 3, 3);

UPDATE subject_claim_score
SET display_order = 1
WHERE
  code = '1' AND
  subject_id = 1;

UPDATE subject_claim_score
SET display_order = 2
WHERE
  code = 'SOCK_2' AND
  subject_id = 1;

UPDATE subject_claim_score
SET display_order = 3
WHERE
  code = '3' AND
  subject_id = 1;

UPDATE subject_claim_score
SET display_order = 1
WHERE
  code = 'SOCK_R' AND
  subject_id = 2;

UPDATE subject_claim_score
SET display_order = 2
WHERE
  code = 'SOCK_LS' AND
  subject_id = 2;

UPDATE subject_claim_score
SET display_order = 3
WHERE
  code = '2-W' AND
  subject_id = 2;

UPDATE subject_claim_score
SET display_order = 4
WHERE
  code = '4-CR' AND
  subject_id = 2;

-- Apply constraints now that data is loaded
ALTER TABLE subject_claim_score
  MODIFY COLUMN display_order TINYINT NOT NULL;

-- TODO after Feature completion:
-- drop names, descriptions from tables, display text should come from translation table
-- drop target.code (display-name) in favor of target.natural_id
-- rebind reporting item migration from item.target_code to item.target_natural_id
