-- Consolidated v1.0 -> v1.1.0 flyway script.
--
-- This script should be run against v1.0.x installations where the schema_version table looks like:
-- +----------------+---------+------------------------------+--------+-------------------+------------+---------+
-- | installed_rank | version | description                  | type   | script            | checksum   | success |
-- +----------------+---------+------------------------------+--------+-------------------+------------+---------+
-- |              1 | NULL    | << Flyway Schema Creation >> | SCHEMA | `warehouse`       |       NULL |       1 |
-- |              2 | 1.0.0.0 | ddl                          | SQL    | V1_0_0_0__ddl.sql |  751759817 |       1 |
-- |              3 | 1.0.0.1 | dml                          | SQL    | V1_0_0_1__dml.sql | 1955603172 |       1 |
-- +----------------+---------+------------------------------+--------+-------------------+------------+---------+
--
-- This is a non-trivial script that modifies many tables in the system. It should be run with
-- auto-commit enabled. It will take a while to run ... the applications must be halted while
-- this is being applied. The changes for audit tables are in a different script, just to keep
-- the script length not completely unreasonably long.
--
-- When first created, RDW_Schema was on build #273 and this incorporated:
--   V1_0_0_2__add_index_to_import.sql
--   V1_1_0_1__add_school_groups.sql
--   ...
--   V1_1_0_26__embargo_cleanup.sql

USE ${schemaName};

-- TODO - there is already a (updated, status) index; can one of these be removed?
ALTER TABLE import ADD INDEX idx__import__status_updated (status, updated);


-- Helper to run partitions in a loop (NOTE p.partition_id)
DROP PROCEDURE IF EXISTS loop_by_partition;
DELIMITER //
CREATE PROCEDURE loop_by_partition(IN p_sql VARCHAR(1000), IN p_count INTEGER)
  BEGIN
    DECLARE iteration INTEGER;
    SET iteration = 0;

    partition_loop: LOOP
      SET @stmt = concat(p_sql, ' and p.partition_id =', iteration);
      PREPARE stmt FROM @stmt;
      EXECUTE stmt;
      DEALLOCATE PREPARE stmt;
      SELECT concat('executed partition:', iteration);

      SET iteration = iteration + 1;
      IF iteration < p_count THEN
        ITERATE partition_loop;
      END IF;
      LEAVE partition_loop;
    END LOOP partition_loop;
  END;
//
DELIMITER ;


-- exam -----------------------------------------------------------------------------------------

-- merge exam_student table into exam table -----------------------------------------------------

ALTER TABLE exam
  -- disable auto-updated while copying data
  MODIFY COLUMN updated TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  -- add exam_student columns without constraints
  ADD COLUMN grade_id tinyint,
  ADD COLUMN student_id int,
  ADD COLUMN school_id int,
  ADD COLUMN iep tinyint,
  ADD COLUMN lep tinyint,
  ADD COLUMN section504 tinyint,
  ADD COLUMN economic_disadvantage tinyint,
  ADD COLUMN migrant_status tinyint,
  ADD COLUMN eng_prof_lvl varchar(20),
  ADD COLUMN t3_program_type varchar(30),
  ADD COLUMN language_code varchar(3),
  ADD COLUMN prim_disability_type varchar(3),
  -- add columns for new data from TRT
  ADD COLUMN examinee_id bigint,
  ADD COLUMN deliver_mode varchar(10),
  ADD COLUMN hand_score_project int,
  ADD COLUMN contract varchar(100),
  ADD COLUMN test_reason varchar(255),
  ADD COLUMN assessment_admin_started_at date,
  ADD COLUMN started_at timestamp(6),
  ADD COLUMN force_submitted_at timestamp(6),
  ADD COLUMN status_date timestamp(6),
  ADD COLUMN status varchar(50),
  ADD COLUMN item_count smallint,
  ADD COLUMN field_test_count smallint,
  ADD COLUMN pause_count  smallint, --
  ADD COLUMN grace_period_restarts smallint,
  ADD COLUMN abnormal_starts smallint,
  ADD COLUMN test_window_id varchar(50),
  ADD COLUMN test_administrator_id varchar(128),
  ADD COLUMN responsible_organization_name varchar(60),
  ADD COLUMN test_administrator_name varchar(128),
  ADD COLUMN session_platform_user_agent varchar(512),
  ADD COLUMN test_delivery_server varchar(128),
  ADD COLUMN test_delivery_db varchar(128),
  ADD COLUMN window_opportunity_count varchar(8),
  ADD COLUMN theta_score float,
  ADD COLUMN theta_score_std_err float,
  -- modify completed_at to have the same precision as other timestamps
  MODIFY COLUMN completed_at TIMESTAMP(6) NOT NULL;

-- add and set partition
-- TODO - how many partitions for production?
SET @exam_partitions = 50;

-- TODO - would it be faster to add index *after* setting all the values? enough faster?
ALTER TABLE exam_student
  ADD COLUMN partition_id int,
  ADD INDEX idx__exam_student__partition_id (partition_id);
UPDATE exam_student SET partition_id = MOD(id, @exam_partitions);

CALL loop_by_partition(
    'UPDATE exam e
          JOIN exam_student p ON e.exam_student_id = p.id
        SET e.grade_id            = p.grade_id,
          e.student_id            = p.student_id,
          e.school_id             = p.school_id,
          e.iep                   = p.iep,
          e.lep                   = p.lep,
          e.section504            = p.section504,
          e.economic_disadvantage = p.economic_disadvantage,
          e.migrant_status        = p.migrant_status,
          e.eng_prof_lvl          = p.eng_prof_lvl,
          e.t3_program_type       = p.t3_program_type,
          e.language_code         = p.language_code,
          e.prim_disability_type  = p.prim_disability_type
        WHERE 1=1', @exam_partitions);

ALTER TABLE exam
  -- enable constraints on columns from exam_student
  MODIFY COLUMN grade_id tinyint NOT NULL,
  MODIFY COLUMN student_id int NOT NULL,
  MODIFY COLUMN school_id int NOT NULL,
  MODIFY COLUMN iep tinyint NOT NULL,
  MODIFY COLUMN lep tinyint NOT NULL,
  MODIFY COLUMN economic_disadvantage tinyint NOT NULL,
  ADD INDEX idx__exam__student (student_id),
  ADD INDEX idx__exam__school (school_id),
  ADD CONSTRAINT fk__exam__student FOREIGN KEY (student_id) REFERENCES student(id),
  ADD CONSTRAINT fk__exam__school FOREIGN KEY (school_id) REFERENCES school(id),
  DROP FOREIGN KEY fk__exam__exam_student,
  DROP INDEX idx__exam__exam_student,
  DROP COLUMN exam_student_id,
  -- add partition column and index for next step (oppId conflicts), leave auto-updated disabled
  ADD COLUMN partition_id int,
  ADD INDEX idx__exam__oppId_asmt (oppId, asmt_id);

DROP TABLE exam_student;

-- correct oppId conflicts for legacy exams -----------------------------------------------------

UPDATE exam e SET e.partition_id = MOD(e.id, @exam_partitions);

-- dissociate duplicates (based on oppId and asmt)
CALL loop_by_partition(
    'UPDATE exam p
       JOIN exam e ON e.id != p.id
         AND e.asmt_id = p.asmt_id
         AND e.oppId = p.oppId
     SET p.oppId = CONCAT(CAST(p.id as CHAR), ''_'', p.oppId)
     WHERE p.oppId IS NOT NULL', @exam_partitions);

-- populate null values
CALL loop_by_partition(
    'UPDATE exam p
       SET p.oppId = CONCAT(\'legacy_\', CAST(p.id as CHAR))
       WHERE p.oppId IS NULL', @exam_partitions);

ALTER TABLE exam
  DROP COLUMN partition_id,
  DROP INDEX idx__exam__oppId_asmt,
  ADD UNIQUE INDEX idx__exam__oppId_asmt (oppId, asmt_id),
  MODIFY COLUMN updated TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6);


-- additional changes to exam-related tables

CREATE TABLE IF NOT EXISTS response_type (
  id tinyint NOT NULL PRIMARY KEY,
  code varchar(10) NOT NULL UNIQUE
);

INSERT INTO response_type (id, code) VALUES
  (1, 'value'),
  (2, 'reference');

ALTER TABLE item
  ADD COLUMN field_test tinyint,
  ADD COLUMN active tinyint,
  ADD COLUMN type varchar(40),
  ADD COLUMN options_count tinyint,
  ADD COLUMN answer_key varchar(50);

ALTER TABLE exam_claim_score
  ADD COLUMN theta_score float,
  ADD COLUMN theta_score_std_err float,
  ADD COLUMN created timestamp(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL;

ALTER TABLE exam_item
  ADD COLUMN administered_at timestamp(6),
  ADD COLUMN submitted tinyint,
  ADD COLUMN submitted_at timestamp(6),
  ADD COLUMN number_of_visits smallint,
  ADD COLUMN response_duration float,
  ADD COLUMN response_content_type varchar(50),
  ADD COLUMN page_number smallint,
  ADD COLUMN page_visits smallint,
  ADD COLUMN page_time int,
  ADD COLUMN response_type_id tinyint,
  ADD COLUMN created timestamp(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL,
  ADD INDEX idx__exam_item__response_type (response_type_id),
  ADD CONSTRAINT fk__exam_item__response_type FOREIGN KEY (response_type_id) REFERENCES response_type(id);

ALTER TABLE exam_available_accommodation
  ADD COLUMN created timestamp(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL;



-- organization ---------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS district_group (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  natural_id varchar(40) NOT NULL,
  name varchar(100) NOT NULL,
  external_id varchar(40),
  UNIQUE INDEX idx__district_group__natural_id (natural_id)
);

CREATE TABLE IF NOT EXISTS school_group (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  natural_id varchar(40) NOT NULL,
  name varchar(100) NOT NULL,
  external_id varchar(40),
  UNIQUE INDEX idx__school_group__natural_id (natural_id)
);

ALTER TABLE district
  ADD COLUMN external_id varchar(40);

ALTER TABLE school
  ADD COLUMN district_group_id int,
  ADD COLUMN school_group_id int,
  ADD COLUMN external_id varchar(40),
  ADD INDEX idx__school__district_group (district_group_id),
  ADD INDEX idx__school__school_group (school_group_id),
  ADD CONSTRAINT fk__school__district_group FOREIGN KEY (district_group_id) REFERENCES district_group (id),
  ADD CONSTRAINT fk__school__school_group FOREIGN KEY (school_group_id) REFERENCES school_group (id);

-- code no longer uses these
DROP PROCEDURE IF EXISTS school_upsert;
DROP PROCEDURE IF EXISTS district_upsert;


-- accommodation (language) ---------------------------------------------------------------------

-- add updated timestamp to keep track of the updates; this is meant to help with finding the import id that updated the records
ALTER TABLE accommodation
  ADD COLUMN updated TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6);

-- remove language table and its dependencies; instead all available languages are loaded
ALTER TABLE accommodation_translation
  ADD COLUMN language_code varchar(3);

UPDATE accommodation_translation acct
  JOIN language l ON l.id = acct.language_id
SET acct.language_code = l.code;

ALTER TABLE accommodation_translation
  ADD COLUMN updated TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  DROP FOREIGN KEY fk__accommodation_translation__language,
  DROP INDEX idx__accommodation_translation__language,
  DROP INDEX idx__accommodation_translation__accommodation_language,
  DROP COLUMN language_id,
  MODIFY COLUMN language_code varchar(3) NOT NULL,
  ADD INDEX idx__accommodation_translation__language_code (language_code),
  ADD PRIMARY KEY (accommodation_id, language_code);

DROP TABLE language;


-- embargo --------------------------------------------------------------------------------------

INSERT INTO import_content (id, name) VALUES (6, 'EMBARGO');

CREATE TABLE IF NOT EXISTS district_embargo (
  district_id int NOT NULL,
  school_year smallint NOT NULL,
  individual tinyint,
  aggregate tinyint,
  updated TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) NOT NULL,
  updated_by varchar(255),
  PRIMARY KEY(district_id, school_year),
  INDEX idx__district_embargo__district (district_id),
  CONSTRAINT fk__district_embargo__district FOREIGN KEY (district_id) REFERENCES district(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS state_embargo (
  school_year smallint NOT NULL,
  individual tinyint,
  aggregate tinyint,
  updated TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) NOT NULL,
  updated_by varchar(255),
  PRIMARY KEY(school_year)
);


-- student --------------------------------------------------------------------------------------

-- add inferred-school and populate using existing exams
ALTER TABLE student
  ADD COLUMN inferred_school_id INT,
  MODIFY COLUMN updated TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  ADD COLUMN partition_id INT,
  ADD INDEX idx__student__partition_id (partition_id);

SET @student_partitions = 100;
UPDATE student s SET s.partition_id = MOD(s.id, @student_partitions);

-- one import record per student
INSERT INTO import (status, content, contentType, digest, batch)
  SELECT 0, 1, 'initial load of inferred schools', 'initial load of inferred schools', id FROM student;
SELECT max(id) into @maxImportId from import;

-- find school for student's most recent exam
CALL loop_by_partition(
    'UPDATE student p
       JOIN (SELECT id, cast(batch AS UNSIGNED) student_id FROM import where digest = ''initial load of inferred schools'' and status = 0) i ON p.id = i.student_id
       JOIN exam AS e1 ON p.id = e1.student_id
       LEFT OUTER JOIN exam AS e2 ON e1.student_id = e2.student_id
           AND (e1.completed_at < e2.completed_at OR (e1.completed_at = e2.completed_at AND e1.id < e2.id))
     SET
       p.inferred_school_id = e1.school_id,
       p.update_import_id = i.id
     WHERE e2.student_id IS NULL ', @student_partitions);

-- distribute imports for migrate to have smaller chunks
UPDATE import
SET status = 1,
    created = DATE_ADD(created, INTERVAL (@maxImportId -id)  MICROSECOND),
    updated = DATE_ADD(updated, INTERVAL (@maxImportId -id)  MICROSECOND)
WHERE status = 0 and content = 1 and digest = 'initial load of inferred schools';

-- update date to match imports
UPDATE student s
  JOIN import i ON i.id = s.update_import_id
SET s.updated = i.updated
WHERE i.status = 1 and content = 1 and digest = 'initial load of inferred schools';

-- revert temporary changes and add index for inferred school
ALTER TABLE student
  MODIFY COLUMN updated TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  DROP INDEX idx__student__partition_id,
  DROP COLUMN partition_id,
  ADD INDEX idx__student__inferred_school (inferred_school_id),
  ADD CONSTRAINT fk__student__inferred_school FOREIGN KEY fk__student__inferred_school (inferred_school_id) REFERENCES school(id);


ALTER TABLE student_ethnicity
  ADD COLUMN created TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL;

ALTER TABLE student_group_membership
  ADD COLUMN created timestamp(6) default CURRENT_TIMESTAMP(6) NOT NULL;
UPDATE student_group_membership sgm
  JOIN student_group sg ON sg.id = sgm.student_group_id
SET sgm.created = sg.created;

ALTER TABLE user_student_group
  ADD COLUMN created timestamp(6) default CURRENT_TIMESTAMP(6) NOT NULL;
UPDATE user_student_group usg
  JOIN student_group sg ON sg.id = usg.student_group_id
SET usg.created = sg.created;


DROP PROCEDURE IF EXISTS student_upsert;
DELIMITER //
CREATE PROCEDURE student_upsert(IN  p_ssid                          VARCHAR(65),
                                IN  p_last_or_surname               VARCHAR(60),
                                IN  p_first_name                    VARCHAR(60),
                                IN  p_middle_name                   VARCHAR(60),
                                IN  p_gender_id                     TINYINT,
                                IN  p_first_entry_into_us_school_at DATE,
                                IN  p_lep_entry_at                  DATE,
                                IN  p_lep_exit_at                   DATE,
                                IN  p_birthday                      DATE,
                                IN  p_exam_school_id                INT,
                                IN  p_exam_completed_at             TIMESTAMP(6),
                                IN  p_import_id                     BIGINT,
                                OUT p_id                            INT,
                                OUT p_updated                       TINYINT)
  BEGIN
    --  handle duplicate entry: if there are two competing inserts, one will end up here
    DECLARE CONTINUE HANDLER FOR 1062
    BEGIN
      SELECT id, 0 INTO p_id, p_updated FROM student  WHERE ssid = p_ssid;
    END;

    SELECT id, 0 INTO p_id, p_updated FROM student WHERE ssid = p_ssid;

    IF (p_id IS NOT NULL) THEN
      -- infer a school based on the given effective date and  existing exams
      SELECT CASE WHEN p_exam_completed_at IS NULL OR completed_at > p_exam_completed_at THEN school_id ELSE p_exam_school_id END INTO p_exam_school_id
      FROM exam WHERE student_id = p_id AND deleted = 0
      ORDER BY completed_at DESC LIMIT 1;

      -- check if there is anything to update
      SELECT CASE WHEN count(*) > 0 THEN 0 ELSE 1 END INTO p_updated
      FROM student
      WHERE id = p_id
            AND last_or_surname <=> p_last_or_surname
            AND first_name <=> p_first_name
            AND middle_name <=> p_middle_name
            AND gender_id <=> p_gender_id
            AND first_entry_into_us_school_at <=> p_first_entry_into_us_school_at
            AND lep_entry_at <=> p_lep_entry_at
            AND lep_exit_at <=> p_lep_exit_at
            AND birthday <=> p_birthday
            AND inferred_school_id <=> p_exam_school_id;

      IF (p_updated = 1) THEN
        UPDATE student
        SET
          last_or_surname               = p_last_or_surname,
          first_name                    = p_first_name,
          middle_name                   = p_middle_name,
          gender_id                     = p_gender_id,
          first_entry_into_us_school_at = p_first_entry_into_us_school_at,
          lep_entry_at                  = p_lep_entry_at,
          lep_exit_at                   = p_lep_exit_at,
          birthday                      = p_birthday,
          inferred_school_id            = p_exam_school_id,
          update_import_id              = p_import_id
        WHERE id = p_id;
      END IF;
    ELSE
      INSERT INTO student (ssid, last_or_surname, first_name, middle_name, gender_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, birthday, inferred_school_id, import_id, update_import_id)
      VALUES (p_ssid, p_last_or_surname, p_first_name, p_middle_name, p_gender_id, p_first_entry_into_us_school_at, p_lep_entry_at, p_lep_exit_at, p_birthday, p_exam_school_id, p_import_id, p_import_id);

      SELECT LAST_INSERT_ID(), 2 INTO p_id, p_updated;
    END IF;
  END;
//
DELIMITER ;


-- clean up helper
DROP PROCEDURE loop_by_partition;
