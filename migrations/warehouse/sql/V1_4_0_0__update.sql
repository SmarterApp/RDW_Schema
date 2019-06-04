-- Consolidated v1.3.0 -> v1.4.0 flyway script.
--
-- This script should be run against v1.3.x installations where the schema_version table looks like:
-- +----------------+---------+------------------------------+--------+------------------------------+-------------+---------+
-- | installed_rank | version | description                  | type   | script                       | checksum    | success |
-- +----------------+---------+------------------------------+--------+------------------------------+-------------+---------+
-- |              1 | NULL    | << Flyway Schema Creation >> | SCHEMA | `warehouse`                  |        NULL |       1 |
-- |              2 | 1.0.0.0 | ddl                          | SQL    | V1_0_0_0__ddl.sql            |   751759817 |       1 |
-- |              3 | 1.0.0.1 | dml                          | SQL    | V1_0_0_1__dml.sql            |  1955603172 |       1 |
-- |              4 | 1.1.0.0 | update                       | SQL    | V1_1_0_0__update.sql         |   518740504 |       1 |
-- |              5 | 1.1.0.1 | audit                        | SQL    | V1_1_0_1__audit.sql          | -1236730527 |       1 |
-- |              6 | 1.1.1.0 | student upsert               | SQL    | V1_1_1_0__student_upsert.sql |  -223870699 |       1 |
-- |              7 | 1.2.0.0 | update                       | SQL    | V1_2_0_0__update.sql         |  -680448587 |       1 |
-- |              8 | 1.2.1.0 | update                       | SQL    | V1_2_1_0__update.sql         |   518721551 |       1 |
-- |              9 | 1.3.0.0 | update                       | SQL    | V1_3_0_0__update.sql         |   884309511 |       1 |
-- +----------------+---------+------------------------------+--------+------------------------------+-------------+---------+
--
-- This is a non-trivial script that modifies many tables in the system. It should be run with
-- auto-commit enabled. It will take a while to run ... the applications must be halted while
-- this is being applied.
--
-- When first created, RDW_Schema was on build #422 and this incorporated:
--   V1_4_0_2__alt_scoring.sql
--   V1_4_0_3__translation_label.sql
--   V1_4_0_4__pipeline.sql
--   V1_4_0_5__pipeline_input_type.sql
--   V1_4_0_6__pipeline_active_version.sql
-- Changes made during consolidation:
--   pipeline.active_version was changed from an int to varchar(8)
--   add school year 2019

use ${schemaName};

INSERT IGNORE INTO school_year VALUES (2019);

CREATE TABLE IF NOT EXISTS score_type (
    id tinyint NOT NULL PRIMARY KEY,
    code varchar(10) NOT NULL UNIQUE
);

INSERT INTO score_type (id, code) VALUES
(1, 'Overall'),
(2, 'Alt'),
(3, 'Claim');

-- create table for storing subject assessment scoring info
CREATE TABLE subject_asmt_scoring (
    subject_id SMALLINT NOT NULL,
    asmt_type_id TINYINT NOT NULL,
    score_type_id TINYINT NOT NULL,
    min_score FLOAT,
    max_score FLOAT,
    performance_level_count TINYINT NOT NULL,
    performance_level_standard_cutoff TINYINT,
    PRIMARY KEY(asmt_type_id, subject_id, score_type_id),
    INDEX idx__subject_asmt_scoring__subject (subject_id),
    CONSTRAINT fk__subject_asmt_scoring__subject_asmt_type FOREIGN KEY (asmt_type_id, subject_id)
        REFERENCES subject_asmt_type(asmt_type_id, subject_id)
        ON DELETE CASCADE,
    CONSTRAINT fk__subject_asmt_scoring__subject FOREIGN KEY (subject_id) REFERENCES subject(id),
    CONSTRAINT fk__subject_asmt_scoring__asmt_type FOREIGN KEY (asmt_type_id) REFERENCES asmt_type(id),
    CONSTRAINT fk__subject_asmt_scoring__score_type FOREIGN KEY (score_type_id) REFERENCES score_type(id)
);

-- copy Overall scoring into new table
INSERT INTO subject_asmt_scoring (subject_id, asmt_type_id, score_type_id, min_score, max_score, performance_level_count, performance_level_standard_cutoff)
SELECT subject_id, asmt_type_id, 1, 1000, 3500, performance_level_count, performance_level_standard_cutoff
FROM subject_asmt_type;

-- copy Claim scoring into the new table
INSERT INTO subject_asmt_scoring (subject_id, asmt_type_id, score_type_id, performance_level_count)
SELECT subject_id, asmt_type_id, 3, claim_score_performance_level_count
FROM subject_asmt_type
WHERE claim_score_performance_level_count IS NOT NULL;

-- remove scoring columns, add printed-report flag (default to true for SB tests, false for others)
ALTER TABLE subject_asmt_type
    DROP COLUMN performance_level_count,
    DROP COLUMN performance_level_standard_cutoff,
    DROP COLUMN claim_score_performance_level_count,
    ADD COLUMN printed_report TINYINT;
UPDATE subject_asmt_type SET printed_report = IF(subject_id IN (1,2), 1, 0);
ALTER TABLE subject_asmt_type MODIFY COLUMN printed_report TINYINT NOT NULL;

-- modify the subject claim score table to hold alt and claim score details
-- all the current entries are Claim so set the score type for them
ALTER TABLE subject_claim_score
    RENAME subject_score,
    ADD COLUMN score_type_id TINYINT;
UPDATE subject_score SET score_type_id=3;
ALTER TABLE subject_score
    MODIFY COLUMN score_type_id TINYINT NOT NULL,
    ADD UNIQUE INDEX idx__subject_score__subject_asmt_score_code(subject_id, asmt_type_id, score_type_id, code),
    DROP INDEX idx__subject_claim_score__subject_asmt_code,
    ADD CONSTRAINT fk__subject_score__score_type FOREIGN KEY (score_type_id) REFERENCES score_type(id);

-- add subject-score discriminator
-- so we can store cut-points for overall and alt-scoring (and claim scoring in theory)
-- enforce only one row per asmt per scoring
ALTER TABLE asmt_score
    DROP PRIMARY KEY,
    DROP INDEX idx__asmt_score__asmt,
    ADD COLUMN subject_score_id SMALLINT NULL  COMMENT 'link to subject_score, null for OVERALL score',
    ADD UNIQUE INDEX idx__asmt_score__asmt_scoring(asmt_id, subject_score_id),
    ADD CONSTRAINT fk__asmt_score__subject_score FOREIGN KEY (subject_score_id) REFERENCES subject_score(id);

-- drop exam audit triggers that will be changed
DROP TRIGGER trg__exam_claim_score__update;
DROP TRIGGER trg__exam_claim_score__delete;

-- modify the exam claim score table to hold both alt and claim score details
-- (note that overall score is still stored in the exam table to enforce 1-to-1)
ALTER TABLE exam_claim_score
    RENAME exam_score,
    CHANGE subject_claim_score_id subject_score_id SMALLINT NOT NULL,
    CHANGE category performance_level TINYINT(4) DEFAULT NULL;

-- similar changes for audit_exam_claim_score
ALTER TABLE audit_exam_claim_score
    RENAME audit_exam_score,
    CHANGE exam_claim_score_id exam_score_id BIGINT NOT NULL,
    CHANGE subject_claim_score_id subject_score_id SMALLINT NOT NULL,
    CHANGE category performance_level TINYINT(4) DEFAULT NULL;

-- recreate audit triggers for exam_score
CREATE TRIGGER trg__exam_score__update
    BEFORE UPDATE ON exam_score
    FOR EACH ROW
    INSERT INTO audit_exam_score (action, database_user, exam_score_id, exam_id, subject_score_id,
                                  scale_score, scale_score_std_err, performance_level, theta_score, theta_score_std_err,
                                  created)
    SELECT 'update', USER(), OLD.id, OLD.exam_id, OLD.subject_score_id,
           OLD.scale_score, OLD.scale_score_std_err, OLD.performance_level, OLD.theta_score, OLD.theta_score_std_err,
           OLD.created
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

CREATE TRIGGER trg__exam_score__delete
    BEFORE DELETE ON exam_score
    FOR EACH ROW
    INSERT INTO audit_exam_score (action, database_user, exam_score_id, exam_id, subject_score_id,
                                  scale_score, scale_score_std_err, performance_level, theta_score, theta_score_std_err,
                                  created)
    SELECT 'delete', USER(), OLD.id, OLD.exam_id, OLD.subject_score_id,
           OLD.scale_score, OLD.scale_score_std_err, OLD.performance_level, OLD.theta_score, OLD.theta_score_std_err,
           OLD.created
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';


ALTER TABLE accommodation_translation
    MODIFY COLUMN label TEXT NOT NULL;

CREATE TABLE IF NOT EXISTS pipeline (
    id tinyint NOT NULL PRIMARY KEY,
    code varchar(20) NOT NULL UNIQUE,
    input_type varchar(20) NOT NULL,
    active_version varchar(8)
);

CREATE TABLE IF NOT EXISTS pipeline_script (
    id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    pipeline_id tinyint NOT NULL,
    body text NOT NULL,
    created timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    updated_by varchar(255) NOT NULL,
    INDEX idx__pipeline_script__pipeline (pipeline_id),
    CONSTRAINT fk__pipeline_script__pipeline FOREIGN KEY (pipeline_id) REFERENCES pipeline(id)
);

CREATE TABLE IF NOT EXISTS pipeline_test (
    id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    pipeline_id tinyint NOT NULL,
    name text,
    example_input text NOT NULL,
    expected_output text NOT NULL,
    created timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    updated_by varchar(255) NOT NULL,
    INDEX idx__pipeline_test__pipeline (pipeline_id),
    CONSTRAINT fk__pipeline_test__pipeline FOREIGN KEY (pipeline_id) REFERENCES pipeline(id)
);

INSERT INTO pipeline (id, code, input_type) VALUES
(1, 'exam', 'xml'),
(2, 'group', 'csv'),
(3, 'assessment', 'csv');
