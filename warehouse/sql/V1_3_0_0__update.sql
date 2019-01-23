-- Consolidated v1.2.1 -> v1.3.0 flyway script.
--
-- This script should be run against v1.2.1 installations where the schema_version table looks like:
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
-- +----------------+---------+------------------------------+--------+------------------------------+-------------+---------+
--
-- This is a non-trivial script that modifies many tables in the system. It should be run with
-- auto-commit enabled. It will take a while to run ... the applications must be halted while
-- this is being applied.
--
-- NOTE: this update includes a table of valid language codes. The values included here correspond
-- to those languages endorsed by CALPADS. For installations with a different set of valid codes,
-- the table should be populated accordingly. This should be done during the upgrade process.
--
-- When first created, RDW_Schema was on build #403 and this incorporated:
--   V1_3_0_0__target_report.sql
--   V1_3_0_1__language.sql
--   V1_3_0_2__school_year.sql
--   V1_3_0_3__acc_school_year.sql
--   V1_3_0_4__language_order.sql
--   V1_3_0_5__alias_name.sql
--   military_connected was added during consolidation


use ${schemaName};

INSERT IGNORE INTO school_year (year) VALUES (2019);

CREATE TABLE IF NOT EXISTS military_connected (
  id tinyint NOT NULL PRIMARY KEY,
  code varchar(30) NOT NULL UNIQUE
);

INSERT INTO military_connected (id, code) VALUES
(1, 'NotMilitaryConnected'),
(2, 'ActiveDuty'),
(3, 'NationalGuardOrReserve');


-- add without constraint, set default values, add constraint
ALTER TABLE subject_asmt_type ADD COLUMN target_report tinyint;
UPDATE subject_asmt_type SET target_report = IF(asmt_type_id = 3, 1, 0);
ALTER TABLE subject_asmt_type MODIFY COLUMN target_report tinyint NOT NULL;


-- add without constraint, set default values copying for all previous years, add constraint
ALTER TABLE accommodation_translation
  ADD COLUMN school_year smallint,
  DROP PRIMARY KEY,
  ADD PRIMARY KEY (accommodation_id, language_code, school_year);

UPDATE accommodation_translation SET school_year = 2019;

INSERT INTO accommodation_translation (accommodation_id, label, language_code, school_year, updated)
SELECT accommodation_id, label, language_code, year, updated FROM accommodation_translation JOIN school_year ON year != 2019;

ALTER TABLE accommodation_translation
  MODIFY COLUMN school_year smallint NOT NULL;


CREATE TABLE IF NOT EXISTS language (
  id smallint NOT NULL PRIMARY KEY,
  code char(3) NOT NULL UNIQUE   COMMENT 'CEDS / ISO 639-2 code',
  altcode char(2) NULL           COMMENT 'optional (CALPADS) code',
  name varchar(100) NOT NULL UNIQUE,
  display_order smallint NULL
);

-- The code is ISO 639-2, lowercase. For some entries, there is no ISO 639-2
-- mapping so an unofficial code was used; this is noted by comment.
-- The altcode is from CALPADS. Only entries with a CALPADS value are included.
-- The display_order is English first, unknown last, alphabetical by name in between.
INSERT INTO language (id, code, altcode, name, display_order) VALUES
(0,  'eng', '00', 'English', 0),
(1,  'spa', '01', 'Spanish', 51),
(2,  'vie', '02', 'Vietnamese', 65),
(3,  'chi', '03', 'Chinese; Cantonese', 14),
(4,  'kor', '04', 'Korean', 32),
(5,  'fil', '05', 'Filipino; Pilipino', 16),
(6,  'por', '06', 'Portuguese', 44),
(7,  'mnd', '07', 'Mandarin', 36),  -- code is unofficial
(8,  'jpn', '08', 'Japanese', 28),
(9,  'mkh', '09', 'Mon-Khmer languages', 39),
(10, 'lao', '10', 'Lao', 35),
(11, 'ara', '11', 'Arabic', 4),
(12, 'arm', '12', 'Armenian', 5),
(13, 'bur', '13', 'Burmese', 10),
(15, 'dut', '15', 'Dutch', 15),
(16, 'per', '16', 'Persian; Farsi', 42),
(17, 'fre', '17', 'French', 17),
(18, 'ger', '18', 'German', 18),
(19, 'gre', '19', 'Greek', 19),
(20, 'cha', '20', 'Chamorro', 12),
(21, 'heb', '21', 'Hebrew', 21),
(22, 'hin', '22', 'Hindi', 22),
(23, 'hmn', '23', 'Hmong; Mong', 23),
(24, 'hun', '24', 'Hungarian', 24),
(25, 'ilo', '25', 'Iloko; Ilocano', 25),
(26, 'ind', '26', 'Indonesian', 26),
(27, 'ita', '27', 'Italian', 27),
(28, 'pan', '28', 'Panjabi; Punjabi', 41),
(29, 'rus', '29', 'Russian', 47),
(30, 'smo', '30', 'Samoan', 48),
(32, 'tha', '32', 'Thai', 57),
(33, 'tur', '33', 'Turkish', 61),
(34, 'ton', '34', 'Tongan', 60),
(35, 'urd', '35', 'Urdu', 63),
(36, 'ceb', '36', 'Cebuano; Visayan', 11),
(37, 'sgn', '37', 'Sign Languages', 49),
(38, 'ukr', '38', 'Ukrainian', 62),
(39, 'chz', '39', 'Chaozhou; Chiuchow; Teochew', 13),  -- code is unofficial
(40, 'pus', '40', 'Pushto; Pashto', 45),
(41, 'pol', '41', 'Polish', 43),
(42, 'syr', '42', 'Syriac; Assyrian', 53),
(43, 'guj', '43', 'Gujarati', 20),
(44, 'yao', '44', 'Yao; Mien', 66),
(45, 'rum', '45', 'Romanian; Moldavian; Moldovan', 46),
(46, 'taw', '46', 'Taiwanese', 54),  -- code is unofficial
(47, 'lau', '47', 'Lahu', 34),  -- code is unofficial
(48, 'mah', '48', 'Marshallese', 38),
(49, 'oto', '49', 'Otomian languages; Mixteco', 40),
(50, 'map', '50', 'Austronesian languages; Khmu', 6),
(51, 'kur', '51', 'Kurdish', 33),
(52, 'bat', '52', 'Baltic languages', 7),
(53, 'toi', '53', 'Toishanese', 59),  -- code is unofficial
(54, 'afa', '54', 'Afro-Asiatic languages; Chaldean', 1),
(56, 'alb', '56', 'Albanian', 2),
(57, 'tir', '57', 'Tigrinya', 58),
(60, 'som', '60', 'Somali', 50),
(61, 'ben', '61', 'Bengali', 8),
(62, 'tel', '62', 'Telugu', 56),
(63, 'tam', '63', 'Tamil', 55),
(64, 'mar', '64', 'Marathi', 37),
(65, 'kan', '65', 'Kannada', 29),
(66, 'amh', '66', 'Amharic', 3),
(67, 'bul', '67', 'Bulgarian', 9),
(68, 'kik', '68', 'Kikuyu; Gikuyu', 31),
(69, 'kas', '69', 'Kashmiri', 30),
(70, 'swe', '70', 'Swedish', 52),
(71, 'zap', '71', 'Zapotec', 67),
(72, 'uzb', '72', 'Uzbek', 64),
(99, 'mis', '99', 'Uncoded languages', 99),
(98, 'und', 'UU', 'Undetermined', 99);


-- To update the exam table, we're going to do two things:
-- 1. Drop the audit triggers (which we need to change anyway).
-- 2. Partition the updates to avoid blowing memory.

-- create helper
DROP PROCEDURE IF EXISTS loop_by_exam_id;
DELIMITER //
CREATE PROCEDURE loop_by_exam_id(IN p_sql VARCHAR(1000))
BEGIN
  DECLARE batch, iter INTEGER;
  SET batch = 500000;
  SET iter = 0;

  SELECT 1 + FLOOR(MAX(id) / batch) INTO @max_iter FROM exam;

  partition_loop: LOOP
    SET @stmt = CONCAT(p_sql, ' AND e.id >= ', iter * batch, ' AND e.id < ', (iter + 1) * batch);
    PREPARE stmt FROM @stmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SELECT CONCAT('executed partition:', iter);

    SET iter = iter + 1;
    IF iter < @max_iter THEN
      ITERATE partition_loop;
    END IF;
    LEAVE partition_loop;
  END LOOP partition_loop;
END;
//
DELIMITER ;

-- drop exam audit triggers and disable auditing (just in case)
DROP TRIGGER trg__exam__update;
DROP TRIGGER trg__exam__delete;
SELECT value INTO @audit_setting FROM setting WHERE name = 'AUDIT_TRIGGER_ENABLE';
UPDATE setting SET value = 'FALSE' WHERE name = 'AUDIT_TRIGGER_ENABLE' AND value != 'FALSE';

-- do the work
ALTER TABLE exam
  ADD COLUMN language_id smallint,
  ADD COLUMN military_connected_id tinyint;

CALL loop_by_exam_id('UPDATE exam e JOIN language l ON LOWER(e.language_code) = l.code SET e.language_id = l.id, e.updated = e.updated WHERE e.language_code IS NOT NULL AND e.language_id IS NULL');
CALL loop_by_exam_id('UPDATE exam e JOIN language l ON l.altcode IS NOT NULL AND e.language_code = l.altcode SET e.language_id = l.id, e.updated = e.updated WHERE e.language_code IS NOT NULL AND e.language_id IS NULL');

ALTER TABLE audit_exam
  ADD COLUMN language_id smallint,
  ADD COLUMN military_connected_id tinyint;

UPDATE audit_exam e JOIN language l ON LOWER(e.language_code) = l.code SET e.language_id = l.id WHERE e.language_id IS NULL;
UPDATE audit_exam e JOIN language l ON l.altcode IS NOT NULL AND e.language_code = l.altcode SET e.language_id = l.id WHERE e.language_id IS NULL;

ALTER TABLE exam DROP COLUMN language_code;
ALTER TABLE audit_exam DROP COLUMN language_code;

-- drop helper
DROP PROCEDURE loop_by_exam_id;

-- recreate triggers (with language_id change)
CREATE TRIGGER trg__exam__update
  BEFORE UPDATE ON exam
  FOR EACH ROW
  INSERT INTO audit_exam (action, database_user, exam_id, type_id, school_year, asmt_id, asmt_version,
                          opportunity, oppId, completeness_id, administration_condition_id, session_id, scale_score,
                          scale_score_std_err, performance_level, completed_at, import_id, update_import_id, deleted,
                          created, updated, grade_id, student_id, school_id, iep, lep, section504,
                          economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type, language_id,
                          prim_disability_type, status_date, elas_id, elas_start_at, military_connected_id,
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
         OLD.economic_disadvantage, OLD.migrant_status, OLD.eng_prof_lvl, OLD.t3_program_type, OLD.language_id,
         OLD.prim_disability_type, OLD.status_date, OLD.elas_id, OLD.elas_start_at, OLD.military_connected_id,
         OLD.examinee_id, OLD.deliver_mode, OLD.hand_score_project, OLD.contract, OLD.test_reason,
         OLD.assessment_admin_started_at, OLD.started_at, OLD.force_submitted_at, OLD.status,
         OLD.item_count, OLD.field_test_count, OLD.pause_count, OLD.grace_period_restarts, OLD.abnormal_starts,
         OLD.test_window_id, OLD.test_administrator_id, OLD.responsible_organization_name, OLD.test_administrator_name,
         OLD.session_platform_user_agent, OLD.test_delivery_server, OLD.test_delivery_db, OLD.window_opportunity_count,
         OLD.theta_score, OLD.theta_score_std_err
  FROM setting s
  WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

CREATE TRIGGER trg__exam__delete
  BEFORE DELETE ON exam
  FOR EACH ROW
  INSERT INTO audit_exam (action, database_user, exam_id, type_id, school_year, asmt_id, asmt_version,
                          opportunity, oppId, completeness_id, administration_condition_id, session_id, scale_score,
                          scale_score_std_err, performance_level, completed_at, import_id, update_import_id, deleted,
                          created, updated, grade_id, student_id, school_id, iep, lep, section504,
                          economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type, language_id,
                          prim_disability_type, status_date, elas_id, elas_start_at, military_connected_id,
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
         OLD.economic_disadvantage, OLD.migrant_status, OLD.eng_prof_lvl, OLD.t3_program_type, OLD.language_id,
         OLD.prim_disability_type, OLD.status_date, OLD.elas_id, OLD.elas_start_at, OLD.military_connected_id,
         OLD.examinee_id, OLD.deliver_mode, OLD.hand_score_project, OLD.contract, OLD.test_reason,
         OLD.assessment_admin_started_at, OLD.started_at, OLD.force_submitted_at, OLD.status,
         OLD.item_count, OLD.field_test_count, OLD.pause_count, OLD.grace_period_restarts, OLD.abnormal_starts,
         OLD.test_window_id, OLD.test_administrator_id, OLD.responsible_organization_name, OLD.test_administrator_name,
         OLD.session_platform_user_agent, OLD.test_delivery_server, OLD.test_delivery_db, OLD.window_opportunity_count,
         OLD.theta_score, OLD.theta_score_std_err
  FROM setting s
  WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';


-- student table change is easy, but let's do it while auditing is disabled

ALTER TABLE student
  ADD COLUMN alias_name VARCHAR(60) NULL COMMENT 'optional alias for first name';

ALTER TABLE audit_student
  ADD COLUMN alias_name VARCHAR(60) NULL;

DROP TRIGGER trg__student__update;
CREATE TRIGGER trg__student__update
  BEFORE UPDATE ON student
  FOR EACH ROW
  INSERT INTO audit_student (action, database_user, student_id, ssid, last_or_surname, first_name, middle_name, alias_name,
                             gender_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, birthday,
                             inferred_school_id, import_id, update_import_id, deleted, created, updated)
  SELECT 'update', USER(), OLD.id, OLD.ssid, OLD.last_or_surname, OLD.first_name, OLD.middle_name, OLD.alias_name,
         OLD.gender_id, OLD.first_entry_into_us_school_at, OLD.lep_entry_at, OLD.lep_exit_at, OLD.birthday,
         OLD.inferred_school_id, OLD.import_id, OLD.update_import_id, OLD.deleted, OLD.created, OLD.updated
  FROM setting s
  WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

DROP TRIGGER trg__student__delete;
CREATE TRIGGER trg__student__delete
  BEFORE DELETE ON student
  FOR EACH ROW
  INSERT INTO audit_student (action, database_user, student_id, ssid, last_or_surname, first_name, middle_name, alias_name,
                             gender_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, birthday,
                             inferred_school_id, import_id, update_import_id, deleted, created, updated)
  SELECT 'delete', USER(), OLD.id, OLD.ssid, OLD.last_or_surname, OLD.first_name, OLD.middle_name, OLD.alias_name,
         OLD.gender_id, OLD.first_entry_into_us_school_at, OLD.lep_entry_at, OLD.lep_exit_at, OLD.birthday,
         OLD.inferred_school_id, OLD.import_id, OLD.update_import_id, OLD.deleted, OLD.created, OLD.updated
  FROM setting s
  WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

DROP PROCEDURE IF EXISTS student_upsert;
DELIMITER //
CREATE PROCEDURE student_upsert(IN  p_ssid                          VARCHAR(65),
                                IN  p_last_or_surname               VARCHAR(60),
                                IN  p_first_name                    VARCHAR(60),
                                IN  p_middle_name                   VARCHAR(60),
                                IN  p_alias_name                    VARCHAR(60),
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
      AND alias_name <=> p_alias_name
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
        alias_name                    = p_alias_name,
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
    INSERT INTO student (ssid, last_or_surname, first_name, middle_name, alias_name, gender_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, birthday, inferred_school_id, import_id, update_import_id)
    VALUES (p_ssid, p_last_or_surname, p_first_name, p_middle_name, p_alias_name, p_gender_id, p_first_entry_into_us_school_at, p_lep_entry_at, p_lep_exit_at, p_birthday, p_exam_school_id, p_import_id, p_import_id);

    SELECT id, 2 INTO p_id, p_updated FROM student WHERE ssid = p_ssid;
  END IF;
END;
//
DELIMITER ;


-- reset auditing
UPDATE setting SET value = @audit_setting WHERE name = 'AUDIT_TRIGGER_ENABLE' AND value != @audit_setting;


-- trigger CODES migration
INSERT INTO import (status, content, contentType, digest) VALUES
(1, 3, 'reload codes V1_3_0_0__update.sql', REPLACE(UUID(), '-', ''));

