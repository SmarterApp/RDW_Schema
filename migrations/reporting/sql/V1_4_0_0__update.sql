-- Consolidated v1.3.0 -> v1.4.0 flyway script.
--
-- This script should be run against v1.3.x installations where the schema_version table looks like:
-- +----------------+---------+------------------------------+--------+----------------------+-------------+---------+
-- | installed_rank | version | description                  | type   | script               | checksum    | success |
-- +----------------+---------+------------------------------+--------+----------------------+-------------+---------+
-- |              1 | NULL    | << Flyway Schema Creation >> | SCHEMA | `reporting`          |        NULL |       1 |
-- |              2 | 1.0.0.0 | ddl                          | SQL    | V1_0_0_0__ddl.sql    |   986463590 |       1 |
-- |              3 | 1.0.0.1 | dml                          | SQL    | V1_0_0_1__dml.sql    | -1123132459 |       1 |
-- |              4 | 1.1.0.0 | update                       | SQL    | V1_1_0_0__update.sql | -1706757701 |       1 |
-- |              5 | 1.2.0.0 | update                       | SQL    | V1_2_0_0__update.sql |  1999355730 |       1 |
-- |              6 | 1.2.1.0 | update                       | SQL    | V1_2_1_0__update.sql |  1586448759 |       1 |
-- |              7 | 1.3.0.0 | update                       | SQL    | V1_3_0_0__update.sql |  -518988024 |       1 |
-- +----------------+---------+------------------------------+--------+----------------------+-------------+---------+
--
-- When first created, RDW_Schema was on build #422 and this incorporated:
--   V1_4_0_1__add_user_query_table.sql
--   V1_4_0_2__alt_scoring.sql
--   V1_4_0_3__translation_label.sql
-- Changes made during consolidation:
--   add school year 2019

USE ${schemaName};

INSERT IGNORE INTO school_year VALUES (2019);

CREATE TABLE IF NOT EXISTS user_query (
    id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_login varchar(255) NOT NULL,
    label varchar(255) NOT NULL,
    query text NOT NULL,
    query_type varchar(100) NOT NULL,
    created timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    INDEX idx__user_query__user_login (user_login)
);

CREATE TABLE IF NOT EXISTS score_type (
    id tinyint NOT NULL PRIMARY KEY,
    code varchar(10) NOT NULL UNIQUE
);

INSERT INTO score_type (id, code) VALUES
(1, 'Overall'),
(2, 'Alt'),
(3, 'Claim');

-- Note that we are keeping with the philosophy of the staging_ tables reflecting the warehouse
-- tables, and doing the data transformations during the staging-to-reporting step.

CREATE TABLE staging_subject_asmt_scoring (
    subject_id SMALLINT NOT NULL,
    asmt_type_id TINYINT NOT NULL,
    score_type_id TINYINT NOT NULL,
    min_score FLOAT,
    max_score FLOAT,
    performance_level_count TINYINT NOT NULL,
    performance_level_standard_cutoff TINYINT,
    PRIMARY KEY(asmt_type_id, subject_id, score_type_id)
    );

ALTER TABLE staging_subject_asmt_type
    DROP COLUMN performance_level_count,
    DROP COLUMN performance_level_standard_cutoff,
    DROP COLUMN claim_score_performance_level_count,
    ADD COLUMN printed_report TINYINT NOT NULL;

ALTER TABLE staging_subject_claim_score
    RENAME staging_subject_score,
    ADD COLUMN score_type_id TINYINT NOT NULL;

ALTER TABLE staging_asmt_score
    DROP PRIMARY KEY,
    ADD COLUMN subject_score_id SMALLINT NULL  COMMENT 'link to subject_score, null for OVERALL score',
    ADD UNIQUE INDEX idx__asmt_score__asmt_scoring(asmt_id, subject_score_id);

ALTER TABLE staging_exam_claim_score
    RENAME staging_exam_score,
    CHANGE subject_claim_score_id subject_score_id SMALLINT NOT NULL,
    CHANGE category performance_level TINYINT(4) DEFAULT NULL;


-- subject, assessment and exam table changes
-- these tables are denormalized for reporting performance

ALTER TABLE subject_asmt_type
    ADD COLUMN alt_score_performance_level_count TINYINT NULL   COMMENT 'NULL indicates subject asmt does not have alt scores',
    ADD COLUMN printed_report TINYINT;
UPDATE subject_asmt_type SET printed_report = IF(subject_id IN (1,2), 1, 0);
ALTER TABLE subject_asmt_type MODIFY COLUMN printed_report TINYINT NOT NULL;

ALTER TABLE subject_claim_score
    RENAME subject_score,
    ADD COLUMN score_type_id TINYINT;
UPDATE subject_score SET score_type_id=3;
ALTER TABLE subject_score
    MODIFY COLUMN score_type_id TINYINT NOT NULL,
    ADD UNIQUE INDEX idx__subject_score__subject_asmt_score_code(subject_id, asmt_type_id, score_type_id, code),
    DROP INDEX idx__subject_claim_score__subject_asmt_code,
    ADD CONSTRAINT fk__subject_score__score_type FOREIGN KEY (score_type_id) REFERENCES score_type(id);

ALTER TABLE asmt
    ADD COLUMN alt1_score_code VARCHAR(10) NULL,
    ADD COLUMN alt2_score_code VARCHAR(10) NULL,
    ADD COLUMN alt3_score_code VARCHAR(10) NULL,
    ADD COLUMN alt4_score_code VARCHAR(10) NULL,
    ADD COLUMN alt5_score_code VARCHAR(10) NULL,
    ADD COLUMN alt6_score_code VARCHAR(10) NULL;

-- this table isn't needed/used; its columns are denormalized into the asmt table
DROP TABLE asmt_score;

ALTER TABLE exam
    ADD COLUMN alt1_scale_score SMALLINT,
    ADD COLUMN alt1_scale_score_std_err FLOAT,
    ADD COLUMN alt1_performance_level TINYINT,
    ADD COLUMN alt2_scale_score SMALLINT,
    ADD COLUMN alt2_scale_score_std_err FLOAT,
    ADD COLUMN alt2_performance_level TINYINT,
    ADD COLUMN alt3_scale_score SMALLINT,
    ADD COLUMN alt3_scale_score_std_err FLOAT,
    ADD COLUMN alt3_performance_level TINYINT,
    ADD COLUMN alt4_scale_score SMALLINT,
    ADD COLUMN alt4_scale_score_std_err FLOAT,
    ADD COLUMN alt4_performance_level TINYINT,
    ADD COLUMN alt5_scale_score SMALLINT,
    ADD COLUMN alt5_scale_score_std_err FLOAT,
    ADD COLUMN alt5_performance_level TINYINT,
    ADD COLUMN alt6_scale_score SMALLINT,
    ADD COLUMN alt6_scale_score_std_err FLOAT,
    ADD COLUMN alt6_performance_level TINYINT;

ALTER TABLE staging_accommodation_translation
    MODIFY COLUMN label TEXT NOT NULL;
