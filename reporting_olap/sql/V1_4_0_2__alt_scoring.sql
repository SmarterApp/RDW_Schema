-- Modify schema for enhancements to configurable subjects
--
-- The alt scores are not used in aggregate reporting ... yet. Because of that, the schema and
-- data changes only go to the subject level. Once new aggregate functionality is defined, more
-- changes will be needed to push things down to the asmt and exam level for real reporting.

SET SEARCH_PATH to ${schemaName};

SET client_encoding = 'UTF8';


CREATE TABLE score_type (
  id SMALLINT NOT NULL PRIMARY KEY SORTKEY,
  code VARCHAR(10) NOT NULL UNIQUE
) DISTSTYLE ALL;

INSERT INTO score_type (id, code) VALUES
  (1, 'Overall'),
  (2, 'Alt'),
  (3, 'Claim');


-- Note that we are keeping with the philosophy of the staging_ tables reflecting the warehouse
-- tables, and doing the data transformations during the staging-to-reporting step.

CREATE TABLE staging_subject_asmt_scoring (
  subject_id SMALLINT NOT NULL,
  asmt_type_id SMALLINT NOT NULL,
  score_type_id SMALLINT NOT NULL,
  min_score FLOAT,
  max_score FLOAT,
  performance_level_count SMALLINT NOT NULL,
  performance_level_standard_cutoff SMALLINT,
  migrate_id BIGINT NOT NULL
);

-- remove scoring fields
-- (not adding printed_report because aggregate is the antithesis of ISR)
DROP TABLE staging_subject_asmt_type;
CREATE TABLE staging_subject_asmt_type (
  asmt_type_id SMALLINT NOT NULL,
  subject_id SMALLINT NOT NULL,
  target_report BOOLEAN NOT NULL,
  migrate_id BIGINT NOT NULL
);

-- rename table, add score_type_id
DROP TABLE staging_subject_claim_score;
CREATE TABLE staging_subject_score (
  id SMALLINT NOT NULL PRIMARY KEY,
  subject_id SMALLINT NOT NULL,
  asmt_type_id SMALLINT NOT NULL,
  score_type_id SMALLINT NOT NULL,
  code VARCHAR(10) NOT NULL,
  migrate_id BIGINT NOT NULL
);

-- rename table and a couple columns
DROP TABLE staging_exam_claim_score;
CREATE TABLE staging_exam_score (
  id BIGINT NOT NULL PRIMARY KEY,
  exam_id BIGINT NOT NULL,
  subject_score_id SMALLINT NOT NULL,
  performance_level SMALLINT NOT NULL,
  migrate_id BIGINT NOT NULL
);


-- As noted above, the changes only go to the subject level for now

ALTER TABLE subject_asmt_type
  ADD COLUMN alt_score_performance_level_count SMALLINT NULL;

-- rename table, add score_type_id
-- have to work around Redshift restrictions on modifying things
CREATE TABLE subject_score (
  id SMALLINT NOT NULL PRIMARY KEY SORTKEY,
  subject_id SMALLINT NOT NULL,
  asmt_type_id SMALLINT NOT NULL,
  score_type_id SMALLINT NOT NULL,
  code VARCHAR(10) NOT NULL,
  CONSTRAINT fk__subject_score__asmt_type FOREIGN KEY(asmt_type_id) REFERENCES asmt_type(id),
  CONSTRAINT fk__subject_score__subject FOREIGN KEY(subject_id) REFERENCES subject(id),
  CONSTRAINT fk__subject_score__score_type FOREIGN KEY(score_type_id) REFERENCES score_type(id)
) DISTSTYLE ALL;

INSERT INTO subject_score (id, subject_id, asmt_type_id, score_type_id, code)
  SELECT id, subject_id, asmt_type_id, 3, code FROM subject_claim_score;

ALTER TABLE exam_claim_score
  DROP CONSTRAINT fk__exam_claim_score__subject_claim_score;
ALTER TABLE exam_claim_score
  ADD CONSTRAINT fk__exam_claim_score__subject_score FOREIGN KEY (subject_claim_score_id) REFERENCES subject_score(id);

DROP TABLE subject_claim_score;
