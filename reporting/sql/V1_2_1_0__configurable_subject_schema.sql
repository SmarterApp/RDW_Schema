-- Prepare for configurable subjects:
-- Modify subject table to hold import references
-- Create a subject_asmt_type table to hold subject/assessment-type definitions
-- Make display text columns nullable in preparation for removal
-- Create a subject_translation table to hold subject-scoped display text
-- Change subject.id, depth_of_knowledge.id, subject_claim_score.id from TINYINT to SMALLINT
-- Create a staging_subject_claim_score to support migration

USE ${schemaName};

-- Drop FK references on subject.id for modification
ALTER TABLE asmt
  DROP FOREIGN KEY fk__asmt__subject,
  MODIFY COLUMN subject_id SMALLINT NOT NULL;
ALTER TABLE staging_asmt MODIFY COLUMN subject_id SMALLINT NOT NULL;
ALTER TABLE claim
  DROP FOREIGN KEY fk__claim__subject,
  MODIFY COLUMN subject_id SMALLINT NOT NULL;
ALTER TABLE staging_claim MODIFY COLUMN subject_id SMALLINT NOT NULL;
ALTER TABLE common_core_standard
  DROP FOREIGN KEY fk__common_core_standard__subject,
  MODIFY COLUMN subject_id SMALLINT NOT NULL;
ALTER TABLE staging_common_core_standard MODIFY COLUMN subject_id SMALLINT NOT NULL;
ALTER TABLE depth_of_knowledge
  DROP FOREIGN KEY fk__depth_of_knowledge__subject,
  MODIFY COLUMN subject_id SMALLINT NOT NULL;
ALTER TABLE staging_depth_of_knowledge MODIFY COLUMN subject_id SMALLINT NOT NULL;
ALTER TABLE student_group
  DROP FOREIGN KEY fk__student_group__subject,
  MODIFY COLUMN subject_id SMALLINT;
ALTER TABLE staging_student_group MODIFY COLUMN subject_id SMALLINT;
ALTER TABLE subject_claim_score
  DROP FOREIGN KEY fk__subject_claim_score__subject,
  MODIFY COLUMN subject_id SMALLINT NOT NULL;
ALTER TABLE teacher_student_group
  DROP FOREIGN KEY fk__teacher_student_group__subject,
  MODIFY COLUMN subject_id SMALLINT;

-- Alter subject table to hold import references
-- TODO should we initialize import_id and update_import_id to -1 here and in warehouse?
ALTER TABLE subject
  MODIFY COLUMN id SMALLINT NOT NULL,
  ADD COLUMN updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ADD COLUMN update_import_id BIGINT,
  ADD COLUMN migrate_id BIGINT;

-- Re-add FK references on subject.id
ALTER TABLE asmt ADD CONSTRAINT fk__asmt__subject FOREIGN KEY (subject_id) REFERENCES subject(id);
ALTER TABLE claim ADD CONSTRAINT fk__claim__subject FOREIGN KEY (subject_id) REFERENCES subject(id);
ALTER TABLE common_core_standard ADD CONSTRAINT fk__common_core_standard__subject FOREIGN KEY (subject_id) REFERENCES subject(id);
ALTER TABLE depth_of_knowledge ADD CONSTRAINT fk__depth_of_knowledge__subject FOREIGN KEY (subject_id) REFERENCES subject(id);
ALTER TABLE student_group ADD CONSTRAINT fk__student_group__subject FOREIGN KEY (subject_id) REFERENCES subject(id);
ALTER TABLE subject_claim_score ADD CONSTRAINT fk__subject_claim_score__subject FOREIGN KEY (subject_id) REFERENCES subject(id);
ALTER TABLE teacher_student_group ADD CONSTRAINT fk__teacher_student_group__subject FOREIGN KEY (subject_id) REFERENCES subject(id);

CREATE TABLE staging_subject (
  id SMALLINT NOT NULL,
  code VARCHAR(10) NOT NULL,
  updated TIMESTAMP NOT NULL,
  update_import_id BIGINT NOT NULL,
  migrate_id BIGINT NOT NULL,
  PRIMARY KEY (id)
);

-- Create a subject display text table
CREATE TABLE subject_translation (
  subject_id SMALLINT NOT NULL,
  label_code VARCHAR(128) NOT NULL,
  label TEXT,
  PRIMARY KEY(subject_id, label_code),
  CONSTRAINT fk__subject_translation__subject FOREIGN KEY (subject_id) REFERENCES subject(id)
);
CREATE TABLE staging_subject_translation (
  subject_id SMALLINT NOT NULL,
  label_code VARCHAR(128) NOT NULL,
  label TEXT,
  PRIMARY KEY(subject_id, label_code)
);

-- Make name and description nullable for organizational claims
ALTER TABLE claim
  MODIFY COLUMN name VARCHAR(250) DEFAULT NULL,
  MODIFY COLUMN description VARCHAR(250) DEFAULT NULL;
ALTER TABLE staging_claim
  MODIFY COLUMN name VARCHAR(250) DEFAULT NULL,
  MODIFY COLUMN description VARCHAR(250) DEFAULT NULL;

-- Make code and description nullable for targets
ALTER TABLE target
  MODIFY COLUMN code VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN description VARCHAR(500) DEFAULT NULL;
ALTER TABLE staging_target
  MODIFY COLUMN code VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN description VARCHAR(500) DEFAULT NULL;

-- Make description nullable for depths of knowledge
ALTER TABLE item
  DROP FOREIGN KEY fk__item__dok,
  MODIFY COLUMN dok_id SMALLINT;
ALTER TABLE staging_item MODIFY COLUMN dok_id SMALLINT;
ALTER TABLE depth_of_knowledge
  MODIFY COLUMN id SMALLINT NOT NULL,
  MODIFY COLUMN description VARCHAR(100) DEFAULT NULL;
ALTER TABLE item ADD CONSTRAINT fk__item__dok FOREIGN KEY (dok_id) REFERENCES depth_of_knowledge(id);
ALTER TABLE staging_depth_of_knowledge
  MODIFY COLUMN id SMALLINT NOT NULL,
  MODIFY COLUMN description VARCHAR(100) DEFAULT NULL;

-- Make description nullable for common_core_standard
ALTER TABLE common_core_standard
  MODIFY COLUMN description VARCHAR(1000) DEFAULT NULL;
ALTER TABLE staging_common_core_standard
  MODIFY COLUMN description VARCHAR(1000) DEFAULT NULL;

-- Table for holding subject configurations in the context of an assessment type
CREATE TABLE subject_asmt_type (
  asmt_type_id TINYINT NOT NULL,
  subject_id SMALLINT NOT NULL,
  performance_level_count TINYINT NOT NULL,
  performance_level_standard_cutoff TINYINT,
  claim_score_performance_level_count TINYINT,
  PRIMARY KEY(asmt_type_id, subject_id),
  INDEX idx__subject_asmt_type__subject (subject_id),
  CONSTRAINT fk__subject_asmt_type__asmt_type FOREIGN KEY (asmt_type_id) REFERENCES asmt_type(id),
  CONSTRAINT fk__subject_asmt_type__subject FOREIGN KEY (subject_id) REFERENCES subject(id)
);
CREATE TABLE staging_subject_asmt_type (
  asmt_type_id TINYINT NOT NULL,
  subject_id SMALLINT NOT NULL,
  performance_level_count TINYINT NOT NULL,
  performance_level_standard_cutoff TINYINT,
  claim_score_performance_level_count TINYINT,
  PRIMARY KEY(asmt_type_id, subject_id)
);

-- Insert data for Math: 1, ELA: 2
-- ICA: 1, IAB: 2, SUM: 3
INSERT INTO subject_asmt_type (asmt_type_id, subject_id, performance_level_count, performance_level_standard_cutoff, claim_score_performance_level_count) VALUES
  (1, 1, 4, 3, 3),
  (2, 1, 3, null, null),
  (3, 1, 4, 3, 3),
  (1, 2, 4, 3, 3),
  (2, 2, 3, null, null),
  (3, 2, 4, 3, 3);

-- Make name nullable for subject_claim_score
-- and add display_order column
ALTER TABLE exam_claim_score_mapping
  DROP FOREIGN KEY fk__exam_claim_score_mapping__subject_claim_score,
  MODIFY COLUMN subject_claim_score_id SMALLINT NOT NULL;
ALTER TABLE subject_claim_score
  ADD COLUMN display_order TINYINT,
  MODIFY COLUMN id SMALLINT NOT NULL,
  MODIFY COLUMN name VARCHAR(250) DEFAULT NULL;
ALTER TABLE exam_claim_score_mapping ADD CONSTRAINT fk__exam_claim_score_mapping__subject_claim_score FOREIGN KEY (subject_claim_score_id) REFERENCES subject_claim_score(id);
CREATE TABLE staging_subject_claim_score (
  id SMALLINT NOT NULL,
  subject_id SMALLINT NOT NULL,
  asmt_type_id TINYINT NOT NULL,
  code varchar(10) NOT NULL,
  display_order TINYINT NOT NULL,
  PRIMARY KEY (id)
);

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