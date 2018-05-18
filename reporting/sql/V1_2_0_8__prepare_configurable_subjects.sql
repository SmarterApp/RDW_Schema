-- Prepare for configurable subjects by modifying the tables that have been modified
-- in the warehouse due to configurable subject ingest.

USE ${schemaName};

-- Table for holding subject configurations in the context of an assessment type
CREATE TABLE subject_asmt_type (
  asmt_type_id TINYINT NOT NULL,
  subject_id TINYINT NOT NULL,
  performance_level_count TINYINT NOT NULL,
  performance_level_standard_cutoff TINYINT,
  sub_score_performance_level_count TINYINT,
  sub_score_performance_level_standard_cutoff TINYINT,
  created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(asmt_type_id, subject_id),
  CONSTRAINT fk__subject_asmt_type__asmt_type FOREIGN KEY (asmt_type_id) REFERENCES asmt_type(id),
  CONSTRAINT fk__subject_asmt_type__subject FOREIGN KEY (subject_id) REFERENCES subject(id)
);

-- Insert data for Math: 1, ELA: 2
-- ICA: 1, IAB: 2, SUM: 3
INSERT INTO subject_asmt_type (asmt_type_id, subject_id, performance_level_count, performance_level_standard_cutoff, sub_score_performance_level_count, sub_score_performance_level_standard_cutoff) VALUES
  (1, 1, 4, 3, 3, null),
  (2, 1, 3, null, null, null),
  (3, 1, 4, 3, 3, null),
  (1, 2, 4, 3, 3, null),
  (2, 2, 3, null, null, null),
  (3, 2, 4, 3, 3, null);

-- Remove subject_claim_score asmt_type_id column
-- add display_order column
-- make display string columns nullable
DELETE escm FROM exam_claim_score_mapping escm
  JOIN subject_claim_score scs ON scs.id = escm.subject_claim_score_id
WHERE scs.asmt_type_id != 1;

DELETE FROM subject_claim_score WHERE asmt_type_id != 1;
ALTER TABLE subject_claim_score
  DROP FOREIGN KEY fk__subject_claim_score__asmt_type,
  DROP COLUMN asmt_type_id,
  ADD COLUMN display_order TINYINT,
  MODIFY COLUMN name VARCHAR(250) DEFAULT NULL;

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

