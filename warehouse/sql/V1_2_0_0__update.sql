-- Consolidated v1.1 -> v1.2.0 flyway script.
--
-- This script should be run against v1.1.1 installations where the schema_version table looks like:
-- +----------------+---------+------------------------------+--------+------------------------------+-------------+---------+
-- | installed_rank | version | description                  | type   | script                       | checksum    | success |
-- +----------------+---------+------------------------------+--------+------------------------------+-------------+---------+
-- |              1 | NULL    | << Flyway Schema Creation >> | SCHEMA | `warehouse`                  |        NULL |       1 |
-- |              2 | 1.0.0.0 | ddl                          | SQL    | V1_0_0_0__ddl.sql            |   751759817 |       1 |
-- |              3 | 1.0.0.1 | dml                          | SQL    | V1_0_0_1__dml.sql            |  1955603172 |       1 |
-- |              4 | 1.1.0.0 | update                       | SQL    | V1_1_0_0__update.sql         |   518740504 |       1 |
-- |              5 | 1.1.0.1 | audit                        | SQL    | V1_1_0_1__audit.sql          | -1236730527 |       1 |
-- |              6 | 1.1.1.0 | student upsert               | SQL    | V1_1_1_0__student_upsert.sql |  -223870699 |       1 |
-- +----------------+---------+------------------------------+--------+------------------------------+-------------+---------+
--
-- This is a non-trivial script that modifies many tables in the system. It should be run with
-- auto-commit enabled. It will take a while to run ... the applications must be halted while
-- this is being applied.
--
-- When first created, RDW_Schema was on build #371 and this incorporated:
--   V1_2_0_0__elas_gender.sql
--   V1_2_0_1__elas_audit.sql
--   V1_2_0_2__ccs_for_summatives.sql
--   V1_2_0_3__add_grade_order.sql
--   V1_2_0_4__misc.sql
--   V1_2_0_5__unbatch_group.sql
--   V1_2_0_6__exam_target_scores.sql
--   V1_2_0_7__prepare_configurable_subjects.sql
--   V1_2_0_8__adjust_exam_target_scores.sql
--   V1_2_0_9__asmt_target_exclusion.sql
--   V1_2_0_10__trigger_code_migrate.sql
--   V1_2_0_11__trigger_migarte_summative_targets.sql
--   V1_2_0_12__audit_exam_target_scores.sql
--   V1_2_0_13__remove_target_std_err.sql
--   V1_2_0_14__optional_student_data.sql
--   V1_2_0_15__optional_exam_data.sql  (selective)
--   V1_2_0_16__upload_student_group_index.sql (selective)
--   V1_2_0_17__exam_index.sql
--   V1_2_0_18__student_group_index.sql (selective)

USE ${schemaName};

INSERT INTO gender (id, code) VALUES
  (3, 'Nonbinary');

CREATE TABLE IF NOT EXISTS elas (
  id tinyint NOT NULL PRIMARY KEY,
  code varchar(20) NOT NULL UNIQUE
);

INSERT INTO elas (id, code) VALUES
  (1, 'EO'),
  (2, 'EL'),
  (3, 'IFEP'),
  (4, 'RFEP'),
  (5, 'TBD');

-- change fields to be optional and add ELAS
ALTER TABLE exam
  MODIFY COLUMN lep TINYINT NULL,
  MODIFY COLUMN iep TINYINT NULL,
  MODIFY COLUMN economic_disadvantage TINYINT NULL,
  MODIFY COLUMN completeness_id TINYINT NULL,
  MODIFY COLUMN administration_condition_id TINYINT NULL,
  MODIFY COLUMN session_id VARCHAR(128) NULL,
  ADD COLUMN elas_id TINYINT NULL,
  ADD COLUMN elas_start_at DATE NULL,
  ADD INDEX idx__exam__type_deleted_created_and_scores (type_id, deleted, created, scale_score, scale_score_std_err, performance_level),
  ADD INDEX idx__exam__type_deleted_updated_and_scores (type_id, deleted, updated, scale_score, scale_score_std_err, performance_level);


ALTER TABLE audit_exam
  MODIFY COLUMN lep TINYINT NULL,
  MODIFY COLUMN iep TINYINT NULL,
  MODIFY COLUMN economic_disadvantage TINYINT NULL,
  MODIFY COLUMN completeness_id TINYINT NULL,
  MODIFY COLUMN administration_condition_id TINYINT NULL,
  MODIFY COLUMN session_id VARCHAR(128) NULL,
  ADD COLUMN elas_id TINYINT NULL,
  ADD COLUMN elas_start_at DATE NULL;


ALTER TABLE grade
  ADD COLUMN sequence tinyint;

UPDATE grade g
  JOIN ( SELECT 0  AS sequence, 'UG' AS code UNION ALL
         SELECT 1  AS sequence, 'IT' AS code UNION ALL
         SELECT 2  AS sequence, 'PR' AS code UNION ALL
         SELECT 3  AS sequence, 'PK' AS code UNION ALL
         SELECT 4  AS sequence, 'TK' AS code UNION ALL
         SELECT 5  AS sequence, 'KG' AS code UNION ALL
         SELECT 6  AS sequence, '01' AS code UNION ALL
         SELECT 7  AS sequence, '02' AS code UNION ALL
         SELECT 8  AS sequence, '03' AS code UNION ALL
         SELECT 9  AS sequence, '04' AS code UNION ALL
         SELECT 10 AS sequence, '05' AS code UNION ALL
         SELECT 11 AS sequence, '06' AS code UNION ALL
         SELECT 12 AS sequence, '07' AS code UNION ALL
         SELECT 13 AS sequence, '08' AS code UNION ALL
         SELECT 14 AS sequence, '09' AS code UNION ALL
         SELECT 15 AS sequence, '10' AS code UNION ALL
         SELECT 16 AS sequence, '11' AS code UNION ALL
         SELECT 17 AS sequence, '12' AS code UNION ALL
         SELECT 18 AS sequence, '13' AS code UNION ALL
         SELECT 19 AS sequence, 'PS' AS code
       ) grade_order ON grade_order.code = g.code
SET g.sequence = grade_order.sequence;

ALTER TABLE grade
  MODIFY COLUMN sequence tinyint NOT NULL;


-- BEFORE:
-- A record is created in upload_student_group_batch. This table is the record of upload events.
-- The raw CSV is loaded into upload_student_group. The upload_student_group_batch_progress and
-- upload_student_group_import tables are used for interim results and data manipulation. Also
-- during the process, import records are created to trigger migration.
--
-- AFTER:
-- A record is created in the import table. As for other data, this table is the record of import events.
-- The raw CSV is loaded into upload_student_group. All data manipulation happens directly in this table.
-- No additional import records are created (timestamps are used to distribute migration work).
--
-- Copy successful batch upload records into the import table so users can still see their old uploads.
INSERT INTO import (status, content, contentType, digest, batch, creator, created, updated, message)
  SELECT status, 5, 'text/csv', digest, filename, creator, created, updated, message
  FROM upload_student_group_batch
  WHERE status = 1;

ALTER TABLE import
  ADD INDEX idx__import__content_creator_contentType (creator, content, contentType);

-- delete any orphaned uploads (the system should be quiescent so this is safe)
DELETE FROM upload_student_group;

ALTER TABLE upload_student_group
  DROP COLUMN batch_id,
  ADD INDEX idx__upload_student_group__group_import_student(import_id, group_id, student_id);

ALTER TABLE student ADD INDEX idx__student__deleted(deleted);

DROP TABLE upload_student_group_status;
DROP TABLE upload_student_group_import;
DROP TABLE upload_student_group_import_ref_type;
DROP TABLE upload_student_group_batch_progress;
DROP TABLE upload_student_group_batch;


CREATE TABLE exam_target_score (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  exam_id bigint NOT NULL,
  target_id smallint NOT NULL,
  student_relative_residual_score float,
  standard_met_relative_residual_score float,
  UNIQUE KEY idx__exam_target_score__exam_target(exam_id, target_id),
  INDEX idx__exam_target_score__target(target_id),
  CONSTRAINT fk__exam_target_score__exam FOREIGN KEY (exam_id) REFERENCES exam(id),
  CONSTRAINT fk__exam_target_score__target FOREIGN KEY (target_id) REFERENCES target(id)
);

CREATE TABLE IF NOT EXISTS audit_exam_target_score (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  action VARCHAR(8) NOT NULL,
  audited TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL,
  database_user VARCHAR(255) NOT NULL,
  exam_target_score_id BIGINT NOT NULL,
  exam_id BIGINT NOT NULL,
  target_id SMALLINT NOT NULL,
  student_relative_residual_score FLOAT,
  standard_met_relative_residual_score FLOAT
);

CREATE TRIGGER trg__exam_target_score__update
  BEFORE UPDATE ON exam_target_score
  FOR EACH ROW
  INSERT INTO audit_exam_target_score (action, database_user, exam_target_score_id, exam_id, target_id,
                                       student_relative_residual_score, standard_met_relative_residual_score)
    SELECT 'update', USER(), OLD.id, OLD.exam_id, OLD.target_id,
      OLD.student_relative_residual_score, OLD.standard_met_relative_residual_score
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

CREATE TRIGGER trg__exam_target_score__delete
  BEFORE DELETE ON exam_target_score
  FOR EACH ROW
  INSERT INTO audit_exam_target_score (action, database_user, exam_target_score_id, exam_id, target_id,
                                       student_relative_residual_score, standard_met_relative_residual_score)
    SELECT 'delete', USER(), OLD.id, OLD.exam_id, OLD.target_id,
      OLD.student_relative_residual_score, OLD.standard_met_relative_residual_score
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';



-- A configuration table to hold targets to be excluded from the 'Target Report`.
-- This table is assumed to be manually updated.
-- Note: this table is migrated as part of 'PACKAGE' migration.
CREATE TABLE asmt_target_exclusion (
  asmt_id int NOT NULL,
  target_id smallint NOT NULL,
  PRIMARY KEY(asmt_id, target_id),
  INDEX idx__asmt_target__target (target_id),
  CONSTRAINT fk__asmt_target__asmt FOREIGN KEY(asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__asmt_target__target FOREIGN KEY(target_id) REFERENCES target(id)
);


DROP TRIGGER trg__exam__update;
CREATE TRIGGER trg__exam__update
  BEFORE UPDATE ON exam
  FOR EACH ROW
  INSERT INTO audit_exam (action, database_user, exam_id, type_id, school_year, asmt_id, asmt_version,
                          opportunity, oppId, completeness_id, administration_condition_id, session_id, scale_score,
                          scale_score_std_err, performance_level, completed_at, import_id, update_import_id, deleted,
                          created, updated, grade_id, student_id, school_id, iep, lep, section504,
                          economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type, language_code,
                          prim_disability_type, status_date, elas_id, elas_start_at,
                          examinee_id, deliver_mode, hand_score_project, contract, test_reason,
                          assessment_admin_started_at, started_at, force_submitted_at, status,
                          item_count, field_test_count, pause_count, grace_period_restarts, abnormal_starts,
                          test_window_id, test_administrator_id, responsible_organization_name, test_administrator_name,
                          session_platform_user_agent, test_delivery_server, test_delivery_db, window_opportunity_count,
                          theta_score, theta_score_std_err)
    SELECT 'update', USER(), OLD.id, OLD.type_id, OLD.school_year, OLD.asmt_id, OLD.asmt_version,
      OLD.opportunity, OLD.oppId, OLD.completeness_id, OLD.administration_condition_id, OLD.session_id, OLD.scale_score,
      OLD.scale_score_std_err, OLD.performance_level, OLD.completed_at, OLD.import_id, OLD.update_import_id, OLD.deleted,
      OLD.created, OLD.updated, OLD.grade_id, OLD.student_id, OLD.school_id, OLD.iep, OLD.lep, OLD.section504,
      OLD.economic_disadvantage, OLD.migrant_status, OLD.eng_prof_lvl, OLD.t3_program_type, OLD.language_code,
      OLD.prim_disability_type, OLD.status_date, OLD.elas_id, OLD.elas_start_at,
      OLD.examinee_id, OLD.deliver_mode, OLD.hand_score_project, OLD.contract, OLD.test_reason,
      OLD.assessment_admin_started_at, OLD.started_at, OLD.force_submitted_at, OLD.status,
      OLD.item_count, OLD.field_test_count, OLD.pause_count, OLD.grace_period_restarts, OLD.abnormal_starts,
      OLD.test_window_id, OLD.test_administrator_id, OLD.responsible_organization_name, OLD.test_administrator_name,
      OLD.session_platform_user_agent, OLD.test_delivery_server, OLD.test_delivery_db, OLD.window_opportunity_count,
      OLD.theta_score, OLD.theta_score_std_err
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

DROP TRIGGER trg__exam__delete;
CREATE TRIGGER trg__exam__delete
  BEFORE DELETE ON exam
  FOR EACH ROW
  INSERT INTO audit_exam (action, database_user, exam_id, type_id, school_year, asmt_id, asmt_version,
                          opportunity, oppId, completeness_id, administration_condition_id, session_id, scale_score,
                          scale_score_std_err, performance_level, completed_at, import_id, update_import_id, deleted,
                          created, updated, grade_id, student_id, school_id, iep, lep, section504,
                          economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type, language_code,
                          prim_disability_type, status_date, elas_id, elas_start_at,
                          examinee_id, deliver_mode, hand_score_project, contract, test_reason,
                          assessment_admin_started_at, started_at, force_submitted_at, status,
                          item_count, field_test_count, pause_count, grace_period_restarts, abnormal_starts,
                          test_window_id, test_administrator_id, responsible_organization_name, test_administrator_name,
                          session_platform_user_agent, test_delivery_server, test_delivery_db, window_opportunity_count,
                          theta_score, theta_score_std_err)
    SELECT 'delete', USER(), OLD.id, OLD.type_id, OLD.school_year, OLD.asmt_id, OLD.asmt_version,
      OLD.opportunity, OLD.oppId, OLD.completeness_id, OLD.administration_condition_id, OLD.session_id, OLD.scale_score,
      OLD.scale_score_std_err, OLD.performance_level, OLD.completed_at, OLD.import_id, OLD.update_import_id, OLD.deleted,
      OLD.created, OLD.updated, OLD.grade_id, OLD.student_id, OLD.school_id, OLD.iep, OLD.lep, OLD.section504,
      OLD.economic_disadvantage, OLD.migrant_status, OLD.eng_prof_lvl, OLD.t3_program_type, OLD.language_code,
      OLD.prim_disability_type, OLD.status_date, OLD.elas_id, OLD.elas_start_at,
      OLD.examinee_id, OLD.deliver_mode, OLD.hand_score_project, OLD.contract, OLD.test_reason,
      OLD.assessment_admin_started_at, OLD.started_at, OLD.force_submitted_at, OLD.status,
      OLD.item_count, OLD.field_test_count, OLD.pause_count, OLD.grace_period_restarts, OLD.abnormal_starts,
      OLD.test_window_id, OLD.test_administrator_id, OLD.responsible_organization_name, OLD.test_administrator_name,
      OLD.session_platform_user_agent, OLD.test_delivery_server, OLD.test_delivery_db, OLD.window_opportunity_count,
      OLD.theta_score, OLD.theta_score_std_err
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';



INSERT IGNORE INTO common_core_standard (subject_id, natural_id, description) VALUES
  (1,'3.G.A','Reason with shapes and their attributes.'),
  (1,'3.NF.A','Develop understanding of fractions as numbers.'),
  (1,'3.OA.A','Represent and solve problems involving multiplication and division.'),
  (1,'3.OA.B','Understand properties of multiplication and the relationship between multiplication and division.'),
  (1,'3.OA.D','Solve problems involving the four operations, and identify and explain patterns in arithmetic.'),
  (1,'4.G.A','Draw and identify lines and angles, and classify shapes by properties of their lines and angles.'),
  (1,'4.MD.A','Solve problems involving measurement and conversion of measurements.'),
  (1,'4.MD.B','Represent and interpret data.'),
  (1,'4.MD.C','Geometric measurement: understand concepts of angle and measure angles.'),
  (1,'4.NBT.A','Generalize place value understanding for multi-digit whole numbers.'),
  (1,'4.NBT.B','Use place value understanding and properties of operations to perform multi-digit arithmetic.'),
  (1,'4.NF.A','Extend understanding of fraction equivalence and ordering.'),
  (1,'4.NF.B','Build fractions from unit fractions.'),
  (1,'4.NF.C','Understand decimal notation for fractions, and compare decimal fractions.'),
  (1,'4.OA.A','Use the four operations with whole numbers to solve problems.'),
  (1,'4.OA.B','Gain familiarity with factors and multiples.'),
  (1,'4.OA.C','Generate and analyze patterns.'),
  (1,'5.MD.A','Convert like measurement units within a given measurement system.'),
  (1,'5.MD.B','Represent and interpret data.'),
  (1,'5.MD.C','Geometric measurement: understand concepts of volume.'),
  (1,'6.EE.A','Apply and extend previous understandings of arithmetic to algebraic expressions.'),
  (1,'6.EE.B','Reason about and solve one-variable equations and inequalities.'),
  (1,'6.EE.C','Represent and analyze quantitative relationships between dependent and independent variables.'),
  (1,'6.NS.A','Apply and extend previous understandings of multiplication and division to divide fractions by fractions.'),
  (1,'6.NS.B','Compute fluently with multi-digit numbers and find common factors and multiples.'),
  (1,'6.NS.C','Apply and extend previous understandings of numbers to the system of rational numbers.'),
  (1,'8.G.A','Understand congruence and similarity using physical models, transparencies, or geometry software.'),
  (1,'8.G.B','Understand and apply the Pythagorean Theorem.'),
  (1,'8.G.C','Solve real-world and mathematical problems involving volume of cylinders, cones, and spheres.'),
  (1,'8.NS.A','Know that there are numbers that are not rational, and approximate them by rational numbers.'),
  (1,'8.SP.A','Investigate patterns of association in bivariate data.'),
  (1,'A-APR.A','Perform arithmetic operations on polynomials.'),
  (1,'A-APR.B','Understand the relationship between zeros and factors of polynomials.'),
  (1,'A-APR.C','Use polynomial identities to solve problems.'),
  (1,'A-APR.D','Rewrite rational expressions.'),
  (1,'A-CED.A','Create equations that describe numbers or relationships.'),
  (1,'F-BF.A','Build a function that models a relationship between two quantities.'),
  (1,'F-BF.B','Build new functions from existing functions.'),
  (1,'F-LE.A','Construct and compare linear, quadratic, and exponential models and solve problems.'),
  (1,'F-LE.B','Interpret expressions for functions in terms of the situation they model.'),
  (1,'F-TF.A','Extend the domain of trigonometric functions using the unit circle.'),
  (1,'F-TF.B','Model periodic phenomena with trigonometric functions.'),
  (1,'F-TF.C','Prove and apply trigonometric identities.'),
  (1,'S-IC.A','Understand and evaluate random processes underlying statistical experiments.'),
  (1,'S-IC.B','Make inferences and justify conclusions from sample surveys, experiments, and observational studies.'),
  (1,'S-ID.A','Summarize, represent, and interpret data on a single count or measurement variable.'),
  (1,'S-ID.B','Summarize, represent, and interpret data on two categorical and quantitative variables.'),
  (1,'S-ID.C','Interpret linear models.'),
  (2,'3.L.4','Determine or clarify the meaning of unknown and multiple-meaning word and phrases based on grade 3 reading and content, choosing flexibly from a range of strategies.'),
  (2,'3.L.5','Demonstrate understanding of word relationships and nuances in word meanings.'),
  (2,'4.L.4','Determine or clarify the meaning of unknown and multiple-meaning words and phrases based on grade 4 reading and content, choosing flexibly from a range of strategies.'),
  (2,'4.L.5','Demonstrate understanding of figurative language, word relationships, and nuances in word meanings.'),
  (2,'4.W.9','Draw evidence from literary or informational texts to support analysis, reflection, and research.'),
  (2,'5.L.4','Determine or clarify the meaning of unknown and multiple-meaning words and phrases based on grade 5 reading and content, choosing flexibly from a range of strategies.'),
  (2,'5.L.5','Demonstrate understanding of figurative language, word relationships, and nuances in word meanings.'),
  (2,'5.W.9','Draw evidence from literary or informational texts to support analysis, reflection, and research.'),
  (2,'6.L.4','Determine or clarify the meaning of unknown and multiple-meaning words and phrases based on grade 6 reading and content, choosing flexibly from a range of strategies.'),
  (2,'6.L.5','Demonstrate understanding of figurative language, word relationships, and nuances in word meanings.'),
  (2,'7.L.4','Determine or clarify the meaning of unknown and multiple-meaning words and phrases based on grade 7 reading and content, choosing flexibly from a range of strategies.'),
  (2,'7.L.5','Demonstrate understanding of figurative language, word relationships, and nuances in word meanings.'),
  (2,'8.L.4','Determine or clarify the meaning of unknown and multiple-meaning words or phrases based on grade 8 reading and content, choosing flexibly from a range of strategies.'),
  (2,'8.L.5','Demonstrate understanding of figurative language, word relationships, and nuances in word meanings.');


-- Configurable Subjects
-- Prepare for configurable subjects by creating the tables required to ingest and store subject xml payloads.

-- Drop foreign keys to allow for modifying the subject id column
ALTER TABLE asmt DROP FOREIGN KEY fk__asmt__subject;
ALTER TABLE claim DROP FOREIGN KEY fk__claim__subject;
ALTER TABLE common_core_standard DROP FOREIGN KEY fk__common_core_standard__subject;
ALTER TABLE depth_of_knowledge DROP FOREIGN KEY fk__depth_of_knowledge__subject;
ALTER TABLE item_difficulty_cuts DROP FOREIGN KEY fk__item_difficulty_cuts__subject;
ALTER TABLE student_group DROP FOREIGN KEY fk__student_group__subject;
ALTER TABLE subject_claim_score DROP FOREIGN KEY fk__subject_claim_score__subject;

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

ALTER TABLE claim
  MODIFY COLUMN name VARCHAR(250) DEFAULT NULL,
  MODIFY COLUMN description VARCHAR(250) DEFAULT NULL;

ALTER TABLE target
  MODIFY COLUMN code VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN description VARCHAR(500) DEFAULT NULL;

ALTER TABLE item
  DROP FOREIGN KEY fk__item__dok;
ALTER TABLE depth_of_knowledge
  MODIFY COLUMN id TINYINT AUTO_INCREMENT NOT NULL,
  MODIFY COLUMN description VARCHAR(100) DEFAULT NULL;
ALTER TABLE item
  ADD CONSTRAINT fk__item__dok FOREIGN KEY (dok_id) REFERENCES depth_of_knowledge(id);

DELETE FROM item_difficulty_cuts WHERE asmt_type_id != 1;
ALTER TABLE item_difficulty_cuts
  DROP FOREIGN KEY fk__item_difficulty_cuts__asmt_type,
  DROP COLUMN asmt_type_id,
  MODIFY COLUMN id TINYINT AUTO_INCREMENT NOT NULL;

ALTER TABLE subject_claim_score
  MODIFY COLUMN id TINYINT AUTO_INCREMENT NOT NULL,
  MODIFY COLUMN name VARCHAR(250) DEFAULT NULL,
  ADD COLUMN display_order TINYINT;

ALTER TABLE common_core_standard
  MODIFY COLUMN description VARCHAR(1000) DEFAULT NULL;

-- Insert data for Math: 1, ELA: 2; ICA: 1, IAB: 2, SUM: 3
INSERT INTO subject_asmt_type (asmt_type_id, subject_id, performance_level_count, performance_level_standard_cutoff, claim_score_performance_level_count) VALUES
  (1, 1, 4, 3, 3),
  (2, 1, 3, null, null),
  (3, 1, 4, 3, 3),
  (1, 2, 4, 3, 3),
  (2, 2, 3, null, null),
  (3, 2, 4, 3, 3);

UPDATE subject_claim_score SET display_order = 1 WHERE code = '1' AND subject_id = 1;
UPDATE subject_claim_score SET display_order = 2 WHERE code = 'SOCK_2' AND subject_id = 1;
UPDATE subject_claim_score SET display_order = 3 WHERE code = '3' AND subject_id = 1;
UPDATE subject_claim_score SET display_order = 1 WHERE code = 'SOCK_R' AND subject_id = 2;
UPDATE subject_claim_score SET display_order = 2 WHERE code = 'SOCK_LS' AND subject_id = 2;
UPDATE subject_claim_score SET display_order = 3 WHERE code = '2-W' AND subject_id = 2;
UPDATE subject_claim_score SET display_order = 4 WHERE code = '4-CR' AND subject_id = 2;

-- Apply constraints now that data is loaded
ALTER TABLE subject_claim_score
  MODIFY COLUMN display_order TINYINT NOT NULL;


-- Trigger migration of all the codes; the goal is to populate target/natural_id column.
INSERT INTO import(status, content, contentType, digest) VALUES (1, 3, 'reload codes', 'reload codes v1.2');

-- Trigger migration of summative assessments to load asmt_target table in reporting data-mart.
INSERT INTO import (status, content, contentType, digest) VALUES (0, 2, 'reload summatives', 'reload summatives v1.2');
SELECT LAST_INSERT_ID() INTO @import_id;
UPDATE asmt SET update_import_id = @import_id WHERE type_id = 3;
UPDATE import SET status = 1 WHERE id = @import_id;
