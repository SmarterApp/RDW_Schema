-- Prepare for configurable subjects:
-- Modify subject table to hold import references
-- Create a subject_asmt_type table to hold subject/assessment-type definitions
-- Make display text columns nullable in preparation for removal
-- Create a subject_translation table to hold subject-scoped display text

USE ${schemaName};

-- Alter subject table to hold import references
-- TODO should we initialize import_id and update_import_id to -1 here and in warehouse?
ALTER TABLE subject
  ADD COLUMN created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ADD COLUMN import_id BIGINT,
  ADD COLUMN update_import_id BIGINT;
CREATE TABLE staging_subject (
  id TINYINT NOT NULL,
  code VARCHAR(10) NOT NULL,
  updated TIMESTAMP NOT NULL,
  import_id BIGINT NOT NULL,
  update_import_id BIGINT NOT NULL,
  PRIMARY KEY (id)
);

-- Create a subject display text table
CREATE TABLE subject_translation (
  subject_id TINYINT NOT NULL,
  label_code VARCHAR(128) NOT NULL,
  label TEXT,
  PRIMARY KEY(subject_id, label_code),
  CONSTRAINT fk__subject_translation__subject FOREIGN KEY (subject_id) REFERENCES subject(id)
);
CREATE TABLE staging_subject_translation (
  subject_id TINYINT NOT NULL,
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
ALTER TABLE depth_of_knowledge
  MODIFY COLUMN description VARCHAR(100) DEFAULT NULL;
ALTER TABLE staging_depth_of_knowledge
  MODIFY COLUMN description VARCHAR(100) DEFAULT NULL;

-- Make description nullable for common_core_standard
ALTER TABLE common_core_standard
  MODIFY COLUMN description VARCHAR(1000) DEFAULT NULL;
ALTER TABLE staging_common_core_standard
  MODIFY COLUMN description VARCHAR(1000) DEFAULT NULL;

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
CREATE TABLE staging_subject_asmt_type (
  asmt_type_id TINYINT NOT NULL,
  subject_id TINYINT NOT NULL,
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
ALTER TABLE subject_claim_score
  ADD COLUMN display_order TINYINT,
  MODIFY COLUMN name VARCHAR(250) DEFAULT NULL;
CREATE TABLE staging_subject_claim_score (
  id tinyint NOT NULL,
  subject_id tinyint NOT NULL,
  asmt_type_id tinyint NOT NULL,
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