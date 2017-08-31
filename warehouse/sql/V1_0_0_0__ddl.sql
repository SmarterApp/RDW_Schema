/*
SQL script for the SBAC Reporting Data Warehouse schema for use with Flyway

NOTES
This schema assumes the following:
  1. one state (aka tenant) per data warehouse
  2. not all data elements from TRT are included, only those that are required for the current reporting
  3. MySQL treats FK this way:
     In the referencing table, there must be an index where the foreign key columns are listed as the first columns in the same order.
     Such an index is created on the referencing table automatically if it does not exist.
     This index is silently dropped later, if you create another index that can be used to enforce the foreign key constraint.
     When restoring a DB from a back up, MySQL does not see an automatically created FK index as such and treats it as a user defined.
     So when running this on the restored DB, you will end up with duplicate indexes.
     To avoid this problem we create all the indexes.

This is a condensed script derived from the initial and incremental scripts created during development. See the
README.md for how to deploy this to an existing database.
*/

ALTER DATABASE ${schemaName} CHARACTER SET utf8 COLLATE utf8_unicode_ci;

USE ${schemaName};

/** Import **/

CREATE TABLE IF NOT EXISTS import_content (
  id tinyint NOT NULL PRIMARY KEY,
  name varchar(20) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS import_status (
  id tinyint NOT NULL PRIMARY KEY,
  name varchar(20) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS import (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  status tinyint NOT NULL,
  content tinyint NOT NULL,
  contentType varchar(250) NOT NULL,
  digest varchar(32) NOT NULL,
  batch varchar(250),
  creator varchar(250),
  created timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  message text,
  INDEX idx__import__digest (digest),
  INDEX idx__import__created (created),
  INDEX idx__import__updated_status (updated, status)
);

/** Reference tables **/

CREATE TABLE IF NOT EXISTS subject (
  id tinyint NOT NULL PRIMARY KEY,
  code varchar(10) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS grade (
  id tinyint NOT NULL PRIMARY KEY,
  code varchar(2)  NOT NULL UNIQUE,
  name varchar(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS asmt_type (
  id tinyint NOT NULL PRIMARY KEY,
  code varchar(10) NOT NULL UNIQUE,
  name varchar(24) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS completeness (
  id tinyint NOT NULL PRIMARY KEY,
  code varchar(10) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS administration_condition (
  id tinyint NOT NULL PRIMARY KEY,
  code varchar(20) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS ethnicity (
  id tinyint NOT NULL PRIMARY KEY,
  code varchar(120) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS gender (
  id tinyint NOT NULL PRIMARY KEY,
  code varchar(80) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS accommodation (
  id smallint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code varchar(25) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS language (
  id tinyint NOT NULL PRIMARY KEY,
  code varchar(3) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS school_year (
  year smallint NOT NULL PRIMARY KEY
);

/** Accommodation Translations **/

CREATE TABLE IF NOT EXISTS accommodation_translation (
  accommodation_id smallint NOT NULL,
  language_id tinyint NOT NULL,
  label varchar(40) NOT NULL,
  UNIQUE INDEX idx__accommodation_translation__accommodation_language (accommodation_id, language_id),
  INDEX idx__accommodation_translation__language (language_id),
  CONSTRAINT fk__accommodation_translation__accommodation FOREIGN KEY (accommodation_id) REFERENCES accommodation(id),
  CONSTRAINT fk__accommodation_translation__language FOREIGN KEY (language_id) REFERENCES language(id)
);

/** Assessment Packages related data **/

CREATE TABLE IF NOT EXISTS asmt (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  natural_id varchar(250) NOT NULL,
  grade_id tinyint NOT NULL,
  type_id tinyint NOT NULL,
  subject_id tinyint NOT NULL,
  school_year smallint NOT NULL,
  name varchar(250) NOT NULL,
  label varchar(255) NOT NULL,
  version varchar(30),
  import_id bigint NOT NULL,
  update_import_id bigint NOT NULL,
  deleted tinyint NOT NULL DEFAULT 0,
  created TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  UNIQUE INDEX idx__asmt__natural_id (natural_id),
  INDEX idx__asmt__grade_type_subject (grade_id, type_id, subject_id),
  INDEX idx__asmt__type (type_id),
  INDEX idx__asmt__subject (subject_id),
  INDEX idx__asmt__import (import_id),
  INDEX idx__asmt__update_import (update_import_id),
  INDEX idx__asmt__created (created),
  INDEX idx__asmt__updated (updated),
  CONSTRAINT fk__asmt__grade FOREIGN KEY (grade_id) REFERENCES grade(id),
  CONSTRAINT fk__asmt__type FOREIGN KEY (type_id) REFERENCES asmt_type(id),
  CONSTRAINT fk__asmt__subject FOREIGN KEY (subject_id) REFERENCES subject(id),
  CONSTRAINT fk__asmt__import FOREIGN KEY (import_id) REFERENCES import(id),
  CONSTRAINT fk__asmt__update_import FOREIGN KEY (update_import_id) REFERENCES import(id),
  CONSTRAINT fk__asmt__school_year FOREIGN KEY (school_year) REFERENCES school_year(year)
);


CREATE TABLE IF NOT EXISTS asmt_score (
  asmt_id int NOT NULL PRIMARY KEY,
  cut_point_1 float,
  cut_point_2 float NOT NULL,
  cut_point_3 float,
  min_score float NOT NULL,
  max_score float NOT NULL,
  UNIQUE INDEX idx__asmt_score__asmt (asmt_id),
  CONSTRAINT fk__asmt_score__asmt FOREIGN KEY (asmt_id) REFERENCES asmt(id)
);

CREATE TABLE IF NOT EXISTS claim (
  id smallint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  subject_id tinyint NOT NULL,
  code varchar(10) NOT NULL,
  name varchar(250) NOT NULL,
  description varchar(250) NOT NULL,
  INDEX idx__claim__subject (subject_id),
  CONSTRAINT fk__claim__subject FOREIGN KEY (subject_id) REFERENCES subject(id)
);

CREATE TABLE IF NOT EXISTS subject_claim_score (
  id tinyint NOT NULL PRIMARY KEY,
  subject_id tinyint NOT NULL,
  asmt_type_id tinyint NOT NULL,
  code varchar(10) NOT NULL,
  name varchar(250) NOT NULL,
  INDEX idx__subject_claim_score__subject (subject_id),
  INDEX idx__subject_claim_score__asmt_type (asmt_type_id),
  CONSTRAINT fk__subject_claim_score__subject FOREIGN KEY (subject_id) REFERENCES subject(id),
  CONSTRAINT fk__subject_claim_score__asmt_type FOREIGN KEY (asmt_type_id) REFERENCES asmt_type(id)
);

CREATE TABLE IF NOT EXISTS target (
  id smallint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  natural_id varchar(20) NOT NULL,
  claim_id smallint NOT NULL,
  code varchar(10) NOT NULL,
  description varchar(500) NOT NULL,
  INDEX idx__target__claim (claim_id),
  CONSTRAINT fk__target__claim FOREIGN KEY (claim_id) REFERENCES claim(id)
);

CREATE TABLE IF NOT EXISTS common_core_standard (
  id smallint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  natural_id varchar(20) NOT NULL,
  subject_id tinyint NOT NULL,
  description varchar(1000) NOT NULL,
  INDEX idx__common_core_standard__subject (subject_id),
  CONSTRAINT fk__common_core_standard__subject FOREIGN KEY (subject_id) REFERENCES subject(id)
);

CREATE TABLE IF NOT EXISTS depth_of_knowledge (
  id tinyint NOT NULL PRIMARY KEY,
  level tinyint NOT NULL,
  subject_id tinyint NOT NULL,
  description varchar(100) NOT NULL,
  reference varchar(1000) NOT NULL,
  INDEX idx__depth_of_knowledge__subject (subject_id),
  CONSTRAINT fk__depth_of_knowledge__subject FOREIGN KEY (subject_id) REFERENCES subject(id)
);

CREATE TABLE IF NOT EXISTS math_practice (
  practice tinyint NOT NULL PRIMARY KEY,
  description varchar(250) NOT NULL,
  code varchar(4) NOT NULL,
  UNIQUE INDEX idx__math_practice_code (code)
);

CREATE TABLE IF NOT EXISTS item (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  claim_id smallint NOT NULL,
  target_id smallint NOT NULL,
  natural_id varchar(40) NOT NULL,
  asmt_id int NOT NULL,
  math_practice tinyint,
  allow_calc tinyint,
  dok_id tinyint NOT NULL,
  difficulty_code varchar(1),
  difficulty float NOT NULL,
  max_points float UNSIGNED NOT NULL,
  position smallint,
  UNIQUE INDEX idx__item__asmt_natural_id (asmt_id, natural_id),
  INDEX idx__item__claim (claim_id),
  INDEX idx__item__target (target_id),
  INDEX idx__item__math_practice (math_practice),
  INDEX idx__item__dok (dok_id),
  CONSTRAINT fk__item__asmt FOREIGN KEY (asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__item__claim FOREIGN KEY (claim_id) REFERENCES claim(id),
  CONSTRAINT fk__item__target FOREIGN KEY (target_id) REFERENCES target(id),
  CONSTRAINT fk__item__math_practice FOREIGN KEY (math_practice) REFERENCES math_practice(practice),
  CONSTRAINT fk__item__dok FOREIGN KEY (dok_id) REFERENCES depth_of_knowledge(id)
);

CREATE TABLE IF NOT EXISTS item_other_target (
  item_id int NOT NULL,
  target_id smallint NOT NULL,
  UNIQUE INDEX idx__item_other_target (item_id, target_id),
  INDEX idx__item_target__target (target_id),
  CONSTRAINT fk__item_target__item FOREIGN KEY (item_id) REFERENCES item(id),
  CONSTRAINT fk__item_target__target FOREIGN KEY (target_id) REFERENCES target(id)
);

CREATE TABLE IF NOT EXISTS item_common_core_standard (
  item_id int NOT NULL,
  common_core_standard_id smallint NOT NULL,
  UNIQUE INDEX idx__item_common_core_standard (item_id, common_core_standard_id),
  INDEX idx__item_common_core_standard__common_core_standard (common_core_standard_id),
  CONSTRAINT fk__item_common_core_standard__item FOREIGN KEY (item_id) REFERENCES item(id),
  CONSTRAINT fk__item_common_core_standard__common_core_standard FOREIGN KEY (common_core_standard_id) REFERENCES common_core_standard(id)
);

CREATE TABLE IF NOT EXISTS item_trait_score (
  id tinyint NOT NULL PRIMARY KEY,
  dimension varchar(100) NOT NULL,
  UNIQUE INDEX idx__item_trait_score__dimension (dimension)
);

CREATE TABLE IF NOT EXISTS item_difficulty_cuts (
  id tinyint NOT NULL PRIMARY KEY,
  asmt_type_id tinyint NOT NULL,
  subject_id tinyint NOT NULL,
  grade_id tinyint NOT NULL,
  moderate_low_end float NOT NULL,
  difficult_low_end float NOT NULL,
  INDEX idx__item_difficulty_cuts__asmt_type (asmt_type_id),
  INDEX idx__item_difficulty_cuts__grade (grade_id),
  INDEX idx__item_difficulty_cuts__subject (subject_id),
  CONSTRAINT fk__item_difficulty_cuts__asmt_type FOREIGN KEY (asmt_type_id) REFERENCES asmt_type(id),
  CONSTRAINT fk__item_difficulty_cuts__grade FOREIGN KEY (grade_id) REFERENCES grade(id),
  CONSTRAINT fk__item_difficulty_cuts__subject FOREIGN KEY (subject_id) REFERENCES subject(id)
);

/** Data derived from the exams delivered via TRT **/

CREATE TABLE IF NOT EXISTS district (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  natural_id varchar(40) NOT NULL,
  name varchar(100) NOT NULL,
  UNIQUE INDEX idx__district__natural_id (natural_id)
);

CREATE TABLE IF NOT EXISTS school (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  district_id int NOT NULL,
  natural_id varchar(40) NOT NULL,
  name varchar(100) NOT NULL,
  import_id bigint NOT NULL,
  update_import_id bigint NOT NULL,
  deleted tinyint NOT NULL DEFAULT 0,
  created TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  UNIQUE INDEX idx__school__natural_id (natural_id),
  INDEX idx__school__district (district_id),
  INDEX idx__school__import (import_id),
  INDEX idx__school__update_import (update_import_id),
  INDEX idx__school__created (created),
  INDEX idx__school__updated (updated),
  CONSTRAINT fk__school__district FOREIGN KEY (district_id) REFERENCES district(id),
  CONSTRAINT fk__school__import FOREIGN KEY (import_id) REFERENCES import(id),
  CONSTRAINT fk__school__update_import FOREIGN KEY (update_import_id) REFERENCES import(id)
);

/** Student Groups */

CREATE TABLE IF NOT EXISTS student (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  ssid varchar(65) NOT NULL,
  last_or_surname varchar(60),
  first_name varchar(60),
  middle_name varchar(60),
  gender_id tinyint,
  first_entry_into_us_school_at date,
  lep_entry_at date,
  lep_exit_at date,
  birthday date,
  import_id bigint NOT NULL,
  update_import_id bigint NOT NULL,
  deleted tinyint NOT NULL DEFAULT 0,
  created TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  UNIQUE INDEX idx__student__ssid (ssid),
  INDEX idx__student__import (import_id),
  INDEX idx__student__update_import (update_import_id),
  INDEX idx__student__created (created),
  INDEX idx__student__updated (updated),
  CONSTRAINT fk__student__import FOREIGN KEY (import_id) REFERENCES import(id),
  CONSTRAINT fk__student__update_import FOREIGN KEY (update_import_id) REFERENCES import(id)
);

CREATE TABLE IF NOT EXISTS student_ethnicity (
  ethnicity_id tinyint NOT NULL,
  student_id int NOT NULL,
  UNIQUE INDEX idx__student_ethnicity (student_id, ethnicity_id)
);

CREATE TABLE IF NOT EXISTS student_group (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name varchar(255) NOT NULL,
  school_id int NOT NULL,
  school_year smallint NOT NULL,
  subject_id tinyint,
  active tinyint NOT NULL,
  creator varchar(250),
  import_id bigint NOT NULL,
  update_import_id bigint NOT NULL,
  deleted tinyint NOT NULL DEFAULT 0,
  created TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  UNIQUE INDEX idx__student_group__school_name_year (school_id, name, school_year),
  INDEX idx__student_group__subject (subject_id),
  INDEX idx__student_group__import (import_id),
  INDEX idx__student_group__update_import (update_import_id),
  INDEX idx__student_group__created (created),
  INDEX idx__student_group__updated(updated),
  CONSTRAINT fk__student_group__school FOREIGN KEY (school_id) REFERENCES school(id),
  CONSTRAINT fk__student_group__subject FOREIGN KEY (subject_id) REFERENCES subject(id),
  CONSTRAINT fk__student_group__import FOREIGN KEY (import_id) REFERENCES import(id),
  CONSTRAINT fk__student_group__update_import FOREIGN KEY (update_import_id) REFERENCES import(id),
  CONSTRAINT fk__student_group__school_year FOREIGN KEY (school_year) REFERENCES school_year(year)
);


CREATE TABLE IF NOT EXISTS student_group_membership (
  student_group_id int NOT NULL,
  student_id int NOT NULL,
  UNIQUE INDEX idx__student_group_membership (student_group_id, student_id),
  INDEX idx_student_group_membership__student (student_id),
  CONSTRAINT fk__student_group_membership__student_group FOREIGN KEY (student_group_id) REFERENCES student_group(id),
  CONSTRAINT fk__student_group_membership__student FOREIGN KEY (student_id) REFERENCES student(id)
);

CREATE TABLE IF NOT EXISTS user_student_group (
  student_group_id int NOT NULL,
  user_login varchar(255) NOT NULL,
  UNIQUE INDEX idx__user_student_group (student_group_id, user_login),
  CONSTRAINT fk__user_student_group__student_group FOREIGN KEY (student_group_id) REFERENCES student_group(id)
);

/** Exams **/

CREATE TABLE IF NOT EXISTS exam_student (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  grade_id tinyint NOT NULL,
  student_id int NOT NULL,
  school_id int NOT NULL,
  iep tinyint NOT NULL,
  lep tinyint NOT NULL,
  section504 tinyint,
  economic_disadvantage tinyint NOT NULL,
  migrant_status tinyint,
  eng_prof_lvl varchar(20),
  t3_program_type varchar(20),
  language_code varchar(3),
  prim_disability_type varchar(3),
  INDEX idx__exam_student__student (student_id),
  INDEX idx__exam_student__school (school_id),
  CONSTRAINT fk__exam_student__student FOREIGN KEY (student_id) REFERENCES student(id),
  CONSTRAINT fk__exam_student__school FOREIGN KEY fk__exam_student__school (school_id) REFERENCES school(id)
);

CREATE TABLE IF NOT EXISTS exam (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  type_id tinyint NOT NULL,
  exam_student_id bigint NOT NULL,
  school_year smallint NOT NULL,
  asmt_id int NOT NULL,
  asmt_version varchar(30),
  opportunity int,
  oppId varchar(60),
  completeness_id tinyint NOT NULL,
  administration_condition_id tinyint NOT NULL,
  session_id varchar(128) NOT NULL,
  scale_score float,
  scale_score_std_err float,
  performance_level tinyint,
  completed_at timestamp(0) NOT NULL,
  import_id bigint NOT NULL,
  update_import_id bigint NOT NULL,
  deleted tinyint NOT NULL DEFAULT 0,
  created TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  INDEX idx__exam__exam_student (exam_student_id),
  INDEX idx__exam__asmt (asmt_id),
  INDEX idx__exam__import (import_id),
  INDEX idx__exam__update_import (update_import_id),
  INDEX idx__exam__created (created),
  INDEX idx__exam__updated (updated),
  CONSTRAINT fk__exam__exam_student FOREIGN KEY (exam_student_id) REFERENCES exam_student(id),
  CONSTRAINT fk__exam__asmt FOREIGN KEY (asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__exam__import FOREIGN KEY (import_id) REFERENCES import(id),
  CONSTRAINT fk__exam__update_import FOREIGN KEY (update_import_id) REFERENCES import(id),
  CONSTRAINT fk__exam__school_year FOREIGN KEY (school_year) REFERENCES school_year(year)
);

CREATE TABLE IF NOT EXISTS exam_item (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  exam_id bigint NOT NULL,
  item_id int NOT NULL,
  score float NOT NULL,
  score_status varchar(50),
  position smallint NOT NULL,
  response text,
  trait_evidence_elaboration_score float,
  trait_evidence_elaboration_score_status varchar(50),
  trait_organization_purpose_score float,
  trait_organization_purpose_score_status varchar(50),
  trait_conventions_score float,
  trait_conventions_score_status varchar(50),
  INDEX idx__exam_item__exam (exam_id),
  CONSTRAINT fk__exam_item__exam FOREIGN KEY (exam_id) REFERENCES exam(id)
);

CREATE TABLE IF NOT EXISTS exam_available_accommodation (
  exam_id bigint NOT NULL,
  accommodation_id smallint NOT NULL,
  INDEX idx__exam_available_accommodation__exam(exam_id),
  CONSTRAINT fk__exam_available_accommodation__exam FOREIGN KEY (exam_id) REFERENCES exam(id)
);

CREATE TABLE IF NOT EXISTS exam_claim_score (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  exam_id bigint NOT NULL,
  subject_claim_score_id smallint NOT NULL,
  scale_score float,
  scale_score_std_err float,
  category tinyint,
  INDEX idx__exam_claim_score__exam (exam_id),
  CONSTRAINT fk__exam_claim_score__exam FOREIGN KEY (exam_id) REFERENCES exam(id)
);


/** Student Group Upload **/

CREATE TABLE IF NOT EXISTS upload_student_group_status (
  id tinyint NOT NULL PRIMARY KEY,
  name varchar(20) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS upload_student_group_batch (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  digest varchar(32) NOT NULL,
  status tinyint NOT NULL,
  creator varchar(250) NOT NULL,
  created timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  filename varchar(255),
  message text,
  INDEX idx__upload_student_group_batch__digest (digest)
);

CREATE TABLE IF NOT EXISTS upload_student_group (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  batch_id bigint NOT NULL,
  group_name varchar(255) NOT NULL,
  group_id int,
  school_natural_id varchar(40) NOT NULL,
  school_id int,
  school_year smallint NOT NULL,
  subject_code varchar(10),
  subject_id tinyint,
  student_ssid varchar(65),
  student_id int,
  group_user_login varchar(255),
  creator varchar(250),
  import_id bigint
);

CREATE TABLE IF NOT EXISTS upload_student_group_batch_progress (
  batch_it bigint,
  created timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  message varchar(256)
);

CREATE TABLE IF NOT EXISTS upload_student_group_import_ref_type (
  id tinyint NOT NULL PRIMARY KEY,
  name varchar(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS upload_student_group_import (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  batch_id  bigint NOT NULL,
  school_id int,
  import_id bigint,
  ref varchar(255) NOT NULL, -- either a student ssid or group name, use this along with the unique index below to de-dupe
  ref_type tinyint,
  UNIQUE INDEX idx__upload_student_group_import__batch_ref_school (batch_id, ref_type, school_id)
);


/************************************* Stored procedures ***************************************/

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
                                IN  p_import_id                     BIGINT,
                                OUT p_id                            int)
  BEGIN

    DECLARE isUpdate TINYINT;

    --  handle duplicate entry: if there are two competing inserts, one will end up here
    DECLARE CONTINUE HANDLER FOR 1062
    BEGIN
      SELECT id INTO p_id FROM student WHERE ssid = p_ssid;
    END;

    SELECT id INTO p_id FROM student WHERE ssid = p_ssid;

    IF (p_id IS NOT NULL)
    THEN
      -- check if there is anything to update
      SELECT CASE WHEN count(*) > 0 THEN 0 ELSE 1 END INTO isUpdate FROM student
      WHERE id = p_id
            AND last_or_surname <=> p_last_or_surname
            AND first_name <=> p_first_name
            AND middle_name <=> p_middle_name
            AND gender_id <=> p_gender_id
            AND first_entry_into_us_school_at <=> p_first_entry_into_us_school_at
            AND lep_entry_at <=> p_lep_entry_at
            AND lep_exit_at <=> p_lep_exit_at
            AND birthday <=>  p_birthday;

      IF (isUpdate = 1)
      THEN
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
          update_import_id                 = p_import_id
        WHERE id = p_id;
      END IF;
    ELSE
      INSERT INTO student (ssid, last_or_surname, first_name, middle_name, gender_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, birthday, import_id, update_import_id)
      VALUES (p_ssid, p_last_or_surname, p_first_name, p_middle_name, p_gender_id, p_first_entry_into_us_school_at, p_lep_entry_at, p_lep_exit_at, p_birthday, p_import_id, p_import_id);

      SELECT id INTO p_id FROM student WHERE ssid = p_ssid;
    END IF;
  END; //
DELIMITER ;


DROP PROCEDURE IF EXISTS district_upsert;
DELIMITER //
CREATE PROCEDURE district_upsert(IN  p_name       VARCHAR(100),
                                 IN  p_natural_id VARCHAR(40),
                                 OUT p_id         INT,
                                 OUT p_updated    TINYINT)
  BEGIN
    DECLARE cur_name VARCHAR(100);

    --  handle duplicate entry: if there are two competing inserts, one will end up here
    DECLARE CONTINUE HANDLER FOR 1062
    BEGIN
      SELECT id, 0 INTO p_id, p_updated FROM district WHERE natural_id = p_natural_id;
    END;

    SELECT id, name, 0 INTO p_id, cur_name, p_updated FROM district WHERE natural_id = p_natural_id;

    IF (p_id IS NULL) THEN
      INSERT INTO district (name, natural_id) VALUES (p_name, p_natural_id);
      SELECT id, 2 INTO p_id, p_updated FROM district WHERE natural_id = p_natural_id;
    ELSEIF (p_name != cur_name) THEN
      UPDATE district SET name = p_name WHERE id = p_id;
      SELECT 1 INTO p_updated;
    END IF;
  END; //
DELIMITER ;


DROP PROCEDURE IF EXISTS school_upsert;
DELIMITER //
CREATE PROCEDURE school_upsert(IN  p_district_name       VARCHAR(100),
                               IN  p_district_natural_id VARCHAR(40),
                               IN  p_name                VARCHAR(100),
                               IN  p_natural_id          VARCHAR(40),
                               IN  p_import_id           BIGINT,
                               OUT p_id                  INT)
  BEGIN
    DECLARE p_district_updated TINYINT;
    DECLARE p_district_id INT;
    DECLARE cur_name VARCHAR(100);
    DECLARE cur_district_id INT;

    --  handle duplicate entry: if there are two competing inserts, one will end up here
    DECLARE CONTINUE HANDLER FOR 1062
    BEGIN
      SELECT id INTO p_id FROM school WHERE natural_id = p_natural_id;
    END;

    -- there is no transaction since the worse that could happen a district will be created without a school
    CALL district_upsert(p_district_name, p_district_natural_id, p_district_id, p_district_updated);
    SELECT p_district_updated, p_district_id;

    SELECT id, name, district_id INTO p_id, cur_name, cur_district_id FROM school WHERE natural_id = p_natural_id;

    IF (p_id IS NULL) THEN
      INSERT INTO school (district_id, name, natural_id, import_id, update_import_id)
      VALUES (p_district_id, p_name, p_natural_id, p_import_id, p_import_id);
      SELECT id INTO p_id FROM school WHERE natural_id = p_natural_id;
    ELSEIF (p_district_updated != 0 OR p_name != cur_name OR p_district_id != cur_district_id) THEN
      UPDATE school SET name = p_name, district_id = p_district_id, update_import_id = p_import_id WHERE id = p_id;
    END IF;
  END; //
DELIMITER ;


DROP PROCEDURE IF EXISTS student_group_upsert;
DELIMITER //
CREATE PROCEDURE student_group_upsert(IN  p_name        VARCHAR(255),
                                      IN  p_school_id   INT,
                                      IN  p_school_year SMALLINT,
                                      IN  p_subject_id  TINYINT,
                                      IN  p_active      TINYINT,
                                      IN  p_creator     VARCHAR(250),
                                      IN  p_import_id   BIGINT,
                                      OUT p_id          INT)
  BEGIN
    DECLARE isUpdate TINYINT;

    --  handle duplicate entry: if there are two competing inserts, one will end up here
    DECLARE CONTINUE HANDLER FOR 1062
    BEGIN
      SELECT id INTO p_id FROM student_group WHERE name = p_name AND school_id = p_school_id AND school_year = p_school_year;
    END;

    SELECT id INTO p_id FROM student_group WHERE name = p_name AND school_id = p_school_id AND school_year = p_school_year;

    IF (p_id IS NOT NULL)
    THEN
      -- check if there is anything to update
      SELECT CASE WHEN count(*) > 0 THEN 0 ELSE 1 END INTO isUpdate FROM student_group
      WHERE name = p_name
            AND school_id = p_school_id
            AND school_year = p_school_year
            AND subject_id = p_subject_id
            AND active = p_active;
      -- creator cannot / should not be updated

      IF (isUpdate = 1)
      THEN
        UPDATE student_group
        SET
          name        = p_name,
          school_id   = p_school_id,
          school_year = p_school_year,
          subject_id  = p_subject_id,
          active       = p_active
        WHERE id = p_id;
      END IF;
    ELSE
      INSERT INTO student_group (name, school_id, school_year, subject_id, active, creator, import_id, update_import_id)
      VALUES (p_name, p_school_id, p_school_year, p_subject_id, p_active, p_creator, p_import_id, p_import_id);

      SELECT id INTO p_id FROM student_group WHERE name = p_name AND school_id = p_school_id AND school_year = p_school_year;
    END IF;
  END; //
DELIMITER ;
