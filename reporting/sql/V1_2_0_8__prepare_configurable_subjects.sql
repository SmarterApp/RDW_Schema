-- Prepare for configurable subjects:
-- Introduce a subject_asmt_type table to hold subject/assessment-type definitions
-- Re-bind subject_claim_score values from subject/assessment-type to just subject
-- Use subject/ICA subject_claim_score values as the subject-scoped subject_claim_score values

USE ${schemaName};

-- Table for holding subject configurations in the context of an assessment type
CREATE TABLE subject_asmt_type (
  asmt_type_id TINYINT NOT NULL,
  subject_id TINYINT NOT NULL,
  performance_level_count TINYINT NOT NULL,
  performance_level_standard_cutoff TINYINT,
  sub_score_performance_level_count TINYINT,
  sub_score_performance_level_standard_cutoff TINYINT,
  PRIMARY KEY(asmt_type_id, subject_id),
  INDEX idx__subject_asmt_type__subject (subject_id),
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

-- Re-bind exam_claim_score_mapping records to de-duped subject_claim_score
-- records when we remove subject_claim_score.asmt_type_id
DELETE escm FROM exam_claim_score_mapping escm
  JOIN subject_claim_score scs ON scs.id = escm.subject_claim_score_id
WHERE scs.asmt_type_id != 1;

-- Remove future duplicate subject_claim_score records when we remove
-- the asmt_type_id column.
DELETE FROM subject_claim_score WHERE asmt_type_id != 1;

-- Make name nullable for subject_claim_score
-- and add display_order column
-- Remove asmt_type_id column since scorable claims are bound to a subject
-- rather than a subject-assessment-type pair.
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

