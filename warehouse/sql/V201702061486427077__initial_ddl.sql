/**
** 	Initial script for the SBAC Reporting Data Warehouse schema for use with Flyway
**
**  NOTES
**  This schema assumes the following:
**     1. one state (aka tenant) per data warehouse
**     2. not all data elements from TRT are included, only those that are required for the current reporting
**/

ALTER DATABASE `${schemaName}` CHARACTER SET utf8 COLLATE utf8_unicode_ci;

USE `${schemaName}`;

CREATE TABLE application_schema_version (
   major_version int UNIQUE NOT NULL
);

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
  message text,
  INDEX idx__import__digest (digest)
);

/** Reference tables **/

CREATE TABLE IF NOT EXISTS subject (
  id tinyint NOT NULL PRIMARY KEY,
  name varchar(10) NOT NULL UNIQUE
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
  name varchar(10) NOT NULL UNIQUE
 );

CREATE TABLE IF NOT EXISTS administration_condition (
  id tinyint NOT NULL PRIMARY KEY,
  name varchar(20) NOT NULL UNIQUE
 );

CREATE TABLE IF NOT EXISTS ethnicity (
  id tinyint NOT NULL PRIMARY KEY,
  name varchar(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS gender (
  id tinyint NOT NULL PRIMARY KEY,
  name varchar(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS accommodation (
  id smallint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code varchar(25) NOT NULL UNIQUE
);

/** Assessment Packages related data **/

CREATE TABLE IF NOT EXISTS asmt (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  natural_id varchar(250) NOT NULL UNIQUE,
  grade_id tinyint NOT NULL,
  type_id tinyint NOT NULL,
  subject_id tinyint NOT NULL,
  school_year smallint NOT NULL,
  name varchar(250),
  label varchar(255), -- TODO: change this to NOT NULL when we do not need a hack code that creates assmt
  version varchar(30),
  import_id bigint NOT NULL,
  deleted tinyint NOT NULL DEFAULT 0,
  CONSTRAINT fk__asmt__grade FOREIGN KEY (grade_id) REFERENCES grade(id),
  CONSTRAINT fk__asmt__type FOREIGN KEY (type_id) REFERENCES asmt_type(id),
  CONSTRAINT fk__asmt__subject FOREIGN KEY (subject_id) REFERENCES subject(id),
  CONSTRAINT fk__asmt__import FOREIGN KEY (import_id) REFERENCES import(id)
);

CREATE TABLE IF NOT EXISTS asmt_score (
  asmt_id int NOT NULL PRIMARY KEY,
  cut_point_1 float NOT NULL,
  cut_point_2 float NOT NULL,
  cut_point_3 float NOT NULL,
  min_score float NOT NULL,
  max_score float NOT NULL,
  CONSTRAINT fk__asmt_score__asmt FOREIGN KEY (asmt_id) REFERENCES asmt(id)
);

CREATE TABLE IF NOT EXISTS claim (
  id smallint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  subject_id tinyint NOT NULL,
  code varchar(10) NOT NULL,
  name varchar(250) NOT NULL,
  description varchar(250) NOT NULL,
  CONSTRAINT fk__claim__subject FOREIGN KEY (subject_id) REFERENCES subject(id)
);

CREATE TABLE IF NOT EXISTS subject_claim_score (
  id tinyint NOT NULL PRIMARY KEY,
  subject_id tinyint NOT NULL,
  asmt_type_id tinyint NOT NULL,
  code varchar(10) NOT NULL,
  name varchar(250) NOT NULL,
  CONSTRAINT fk__subject_claim_score__subject FOREIGN KEY (subject_id) REFERENCES subject(id),
  CONSTRAINT fk__subject_claim_score__asmt_type FOREIGN KEY (asmt_type_id) REFERENCES asmt_type(id)
);

CREATE TABLE IF NOT EXISTS target (
  id smallint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  claim_id smallint NOT NULL,
  code varchar(10) NOT NULL,
  description varchar(500) NOT NULL,
  CONSTRAINT fk__target__claim FOREIGN KEY (claim_id) REFERENCES claim(id)
);

CREATE TABLE IF NOT EXISTS depth_of_knowledge (
  id tinyint NOT NULL PRIMARY KEY,
  level tinyint NOT NULL,
  subject_id tinyint NOT NULL,
  description varchar(100) NOT NULL,
  reference varchar(1000) NOT NULL,
  CONSTRAINT fk_depth_of_knowledge__subject FOREIGN KEY (subject_id) REFERENCES subject(id)
);

CREATE TABLE IF NOT EXISTS math_practice (
  practice tinyint NOT NULL PRIMARY KEY,
  description varchar(250) NOT NULL
);

CREATE TABLE IF NOT EXISTS item (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  claim_id smallint, -- TODO: change this to NOT NULL when we do not need a hack code that creates assmt
  target_id smallint, -- TODO: change this to NOT NULL  when we do not need a hack code that creates assmt
  natural_id varchar(40) NOT NULL,
  asmt_id int NOT NULL,
  math_practice tinyint,
  allow_calc tinyint,
  dok_id tinyint NOT NULL,
  difficulty float NOT NULL,
  max_points float UNSIGNED NOT NULL,
  CONSTRAINT fk__item__claim FOREIGN KEY (claim_id) REFERENCES claim(id),
  CONSTRAINT fk__item__target FOREIGN KEY (target_id) REFERENCES target(id),
  CONSTRAINT fk__item__asmt FOREIGN KEY (asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__item__math_practice FOREIGN KEY (math_practice) REFERENCES math_practice(practice), 
  CONSTRAINT fk__item__dok FOREIGN KEY (dok_id) REFERENCES depth_of_knowledge(id)
);

CREATE TABLE IF NOT EXISTS item_trait_score (
  id tinyint NOT NULL PRIMARY KEY,
  dimension varchar(100) NOT NULL UNIQUE
 );

CREATE TABLE IF NOT EXISTS item_difficulty_cuts (
  id tinyint NOT NULL PRIMARY KEY,
  asmt_type_id tinyint NOT NULL,
  subject_id tinyint NOT NULL,
  grade_id tinyint NOT NULL,
  moderate_low_end float NOT NULL,
  difficult_low_end float NOT NULL,
  CONSTRAINT fk__item_difficulty_cuts__asmt_type FOREIGN KEY (asmt_type_id) REFERENCES asmt_type(id),
  CONSTRAINT fk__item_difficulty_cuts__grade FOREIGN KEY (grade_id) REFERENCES grade(id),
  CONSTRAINT fk__item_difficulty_cuts__subject FOREIGN KEY (subject_id) REFERENCES subject(id)
);

/** Data derived from the exams delivered via TRT **/

CREATE TABLE IF NOT EXISTS district (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  natural_id varchar(40) NOT NULL UNIQUE,
  name varchar(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS school (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  district_id int NOT NULL,
  natural_id varchar(40) NOT NULL UNIQUE,
  name varchar(100) NOT NULL,
  import_id bigint NOT NULL,
  deleted tinyint NOT NULL DEFAULT 0,
  CONSTRAINT fk__school__district FOREIGN KEY (district_id) REFERENCES district(id),
  CONSTRAINT fk__school__import FOREIGN KEY (import_id) REFERENCES import(id)
);

CREATE TABLE IF NOT EXISTS state (
  code varchar(2) NOT NULL UNIQUE
 );


/** Student Groups */

CREATE TABLE IF NOT EXISTS student (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  ssid varchar(65) NOT NULL UNIQUE,
  last_or_surname varchar(60) NOT NULL,
  first_name varchar(60) NOT NULL,
  middle_name varchar(60),
  gender_id tinyint NOT NULL,
  first_entry_into_us_school_at date,
  lep_entry_at date,
  lep_exit_at date,
  birthday date NOT NULL,
  import_id bigint NOT NULL,
  deleted tinyint NOT NULL DEFAULT 0,
  CONSTRAINT fk__student__import FOREIGN KEY (import_id) REFERENCES import(id)
 );

CREATE TABLE IF NOT EXISTS student_ethnicity (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  ethnicity_id tinyint NOT NULL,
  student_id int NOT NULL
);

CREATE TABLE IF NOT EXISTS student_group (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name varchar(255) NOT NULL,
  school_id int NOT NULL,
  school_year smallint NOT NULL,
  subject_id tinyint,
  active tinyint NOT NULL,
  creator varchar(250),
  created timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  import_id bigint NOT NULL,
  deleted tinyint NOT NULL DEFAULT 0,
  CONSTRAINT uk__name__school__year UNIQUE INDEX (name, school_id, school_year),
  CONSTRAINT fk__student_group__school FOREIGN KEY (school_id) REFERENCES school(id),
  CONSTRAINT fk__student_group__subject FOREIGN KEY (subject_id) REFERENCES subject(id),
  CONSTRAINT fk__student_group__import FOREIGN KEY (import_id) REFERENCES import(id)
);

CREATE TABLE IF NOT EXISTS student_group_membership (
  student_group_id int NOT NULL,
  student_id int NOT NULL,
  CONSTRAINT uk__student_group_id__student_id UNIQUE KEY (student_group_id, student_id),
  CONSTRAINT fk__student_group_membership__student_group FOREIGN KEY (student_group_id) REFERENCES student_group(id),
  CONSTRAINT fk__student_group_membership__student FOREIGN KEY (student_id) REFERENCES student(id)
);

CREATE TABLE IF NOT EXISTS user_student_group (
  student_group_id int NOT NULL,
  user_login varchar(255) NOT NULL,
  CONSTRAINT uk__student_group_id__user_login UNIQUE KEY (student_group_id, user_login),
  CONSTRAINT fk__user_student_group__student_group FOREIGN KEY (student_group_id) REFERENCES student_group(id)
);

/** IAB exams **/

CREATE TABLE IF NOT EXISTS iab_exam_student (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  grade_id tinyint NOT NULL,
  student_id int NOT NULL,
  school_id int NOT NULL,
  iep tinyint NOT NULL,
  lep tinyint NOT NULL,
  section504 tinyint NOT NULL,
  economic_disadvantage tinyint NOT NULL,
  migrant_status tinyint,
  eng_prof_lvl varchar(20),
  t3_program_type varchar(20),
  language_code varchar(3),
  prim_disability_type varchar(3),
  CONSTRAINT fk__iab_exam_student__student FOREIGN KEY (student_id) REFERENCES student(id),
  CONSTRAINT fk__iab_exam_student__school FOREIGN KEY (school_id) REFERENCES school(id)
 );

CREATE TABLE IF NOT EXISTS iab_exam (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  iab_exam_student_id bigint NOT NULL,
  school_year smallint NOT NULL,
  asmt_id int NOT NULL,
  asmt_version varchar(30),
  opportunity int,
  status varchar(50),
  completeness_id tinyint NOT NULL,
  administration_condition_id tinyint NOT NULL,
  session_id varchar(128), -- TODO: change to NOT NULL when data generator has it
  category tinyint,
  scale_score float,
  scale_score_std_err float,
  completed_at timestamp(0) NOT NULL,
  import_id bigint NOT NULL,
  deleted tinyint NOT NULL DEFAULT 0,
  CONSTRAINT fk__iab_exam__iab_exam_student FOREIGN KEY (iab_exam_student_id) REFERENCES iab_exam_student(id),
  CONSTRAINT fk__iab_exam__asmt FOREIGN KEY (asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__iab_exam__import FOREIGN KEY (import_id) REFERENCES import(id)
);

CREATE TABLE IF NOT EXISTS iab_exam_item (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  iab_exam_id bigint NOT NULL,
  item_id int NOT NULL,
  score float NOT NULL,
  score_status varchar(50),
  position int NOT NULL,
  response text,
  trait_evidence_elaboration_score float,
  trait_evidence_elaboration_score_status varchar(50),
  trait_organization_purpose_score float,
  trait_organization_purpose_score_status varchar(50),
  trait_conventions_score float,
  trait_conventions_score_status varchar(50),
  CONSTRAINT fk__iab_exam_item__exam FOREIGN KEY (iab_exam_id) REFERENCES iab_exam(id)
);

CREATE TABLE IF NOT EXISTS iab_exam_available_accommodation (
  iab_exam_id bigint NOT NULL,
  accommodation_id smallint NOT NULL,
  CONSTRAINT fk__iab_exam_available_accommodation__iab_exam FOREIGN KEY (iab_exam_id) REFERENCES iab_exam(id)
);

/** ICA and Summative exams **/

CREATE TABLE IF NOT EXISTS exam_student (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  grade_id tinyint NOT NULL,
  student_id int NOT NULL,
  school_id int NOT NULL,
  iep tinyint NOT NULL,
  lep tinyint NOT NULL,
  section504 tinyint NOT NULL,
  economic_disadvantage tinyint NOT NULL,
  migrant_status tinyint,
  eng_prof_lvl varchar(20),
  t3_program_type varchar(20),
  language_code varchar(3),
  prim_disability_type varchar(3),
  CONSTRAINT fk__exam_student__student FOREIGN KEY (student_id) REFERENCES student(id),
  CONSTRAINT fk__exam_student__school FOREIGN KEY (school_id) REFERENCES school(id)
 );

CREATE TABLE IF NOT EXISTS exam (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  exam_student_id bigint NOT NULL,
  school_year smallint NOT NULL,
  asmt_id int NOT NULL,
  asmt_version varchar(30),
  opportunity int,
  status varchar(50),
  completeness_id tinyint NOT NULL,
  administration_condition_id tinyint NOT NULL,
  session_id varchar(128),  -- TODO: change to NOT NULL when data generator has it
  scale_score float,
  scale_score_std_err float,
  achievement_level tinyint,
  completed_at timestamp(0) NOT NULL,
  import_id bigint NOT NULL,
  deleted tinyint NOT NULL DEFAULT 0,
  CONSTRAINT fk__exam__exam_student FOREIGN KEY (exam_student_id) REFERENCES exam_student(id),
  CONSTRAINT fk__exam__asmt FOREIGN KEY (asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__exam__import FOREIGN KEY (import_id) REFERENCES import(id)
);

CREATE TABLE IF NOT EXISTS exam_item (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  exam_id bigint NOT NULL,
  item_id int NOT NULL,
  score float NOT NULL,
  score_status varchar(50),
  position int NOT NULL,
  response text,
  trait_evidence_elaboration_score float,
  trait_evidence_elaboration_score_status varchar(50),
  trait_organization_purpose_score float,
  trait_organization_purpose_score_status varchar(50),
  trait_conventions_score float,
  trait_conventions_score_status varchar(50),
  CONSTRAINT fk__exam_item__exam FOREIGN KEY (exam_id) REFERENCES exam(id)
);

CREATE TABLE IF NOT EXISTS exam_available_accommodation (
  exam_id bigint NOT NULL,
  accommodation_id smallint NOT NULL,
  CONSTRAINT fk__exam_available_accommodation__exam FOREIGN KEY (exam_id) REFERENCES exam(id)
);

CREATE TABLE IF NOT EXISTS exam_claim_score (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  exam_id bigint NOT NULL,
  subject_claim_score_id smallint NOT NULL,
  scale_score float,
  scale_score_std_err float,
  category tinyint,
  CONSTRAINT fk__exam_claim_score__exam FOREIGN KEY (exam_id) REFERENCES exam(id)
);


/************************************* Stored procedures ***************************************/

/** Student upsert **/
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
            AND last_or_surname = p_last_or_surname
            AND first_name = p_first_name
            AND middle_name = p_middle_name
            AND gender_id = p_gender_id
            AND first_entry_into_us_school_at <=> p_first_entry_into_us_school_at
            AND lep_entry_at <=> p_lep_entry_at
            AND lep_exit_at <=> p_lep_exit_at
            AND birthday = p_birthday;

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
          import_id                     = p_import_id
        WHERE id = p_id;
      END IF;
    ELSE
      INSERT INTO student (ssid, last_or_surname, first_name, middle_name, gender_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, birthday, import_id)
      VALUES (p_ssid, p_last_or_surname, p_first_name, p_middle_name, p_gender_id, p_first_entry_into_us_school_at, p_lep_entry_at, p_lep_exit_at, p_birthday, p_import_id);

      SELECT id INTO p_id FROM student WHERE ssid = p_ssid;
    END IF;
  END; //
DELIMITER ;

/** District upsert **/

DROP PROCEDURE IF EXISTS district_upsert;

DELIMITER //
CREATE PROCEDURE district_upsert(IN  p_name       VARCHAR(100),
                                 IN  p_natural_id VARCHAR(40),
                                 OUT p_id         MEDIUMINT)
  BEGIN

    --  handle duplicate entry: if there are two competing inserts, one will end up here
    DECLARE CONTINUE HANDLER FOR 1062
    BEGIN
      SELECT id INTO p_id FROM district WHERE natural_id = p_natural_id;
    END;

    SELECT id INTO p_id FROM district WHERE natural_id = p_natural_id;

    IF (p_id IS NOT NULL)
    THEN
    -- TODO: this needs to be revisited; afraid it is an overkill to do an update here
      UPDATE district SET name = p_name WHERE id = p_id;
    ELSE
      INSERT INTO district (name, natural_id)
      VALUES (p_name, p_natural_id);

      SELECT id INTO p_id FROM district WHERE natural_id = p_natural_id;
    END IF;
  END; //
DELIMITER ;

/** School upsert **/

DROP PROCEDURE IF EXISTS school_upsert;

DELIMITER //
CREATE PROCEDURE school_upsert(IN  p_district_name       VARCHAR(100),
                               IN  p_district_natural_id VARCHAR(40),
                               IN  p_name                VARCHAR(100),
                               IN  p_natural_id          VARCHAR(40),
                               IN  p_import_id           BIGINT,
                               OUT p_id                  MEDIUMINT)
  BEGIN
    DECLARE p_district_id MEDIUMINT;
    DECLARE isUpdate TINYINT;

    --  handle duplicate entry: if there are two competing inserts, one will end up here
    DECLARE CONTINUE HANDLER FOR 1062
    BEGIN
      SELECT id INTO p_id FROM school WHERE natural_id = p_natural_id;
    END;

    -- there is no transaction since the worse that could happen a district will be created without a school
    CALL district_upsert(p_district_name, p_district_natural_id, p_district_id);
    SELECT p_district_id;

    SELECT id INTO p_id FROM school WHERE natural_id = p_natural_id;

    IF (p_id IS NOT NULL)
    THEN
      -- check if there is anything to update
      SELECT CASE WHEN count(*) > 0 THEN 0 ELSE 1 END INTO isUpdate
       FROM school s JOIN district d
      WHERE s.id = p_id
            AND s.name = p_name
            AND d.natural_id = p_district_natural_id
            AND d.name = p_district_name;

      IF (isUpdate = 1)
      THEN
        UPDATE school
        SET
          name        = p_name,
          natural_id  = p_natural_id,
          district_id = p_district_id,
          import_id   = p_import_id
        WHERE id = p_id;

      END IF;

    ELSE
      INSERT INTO school (district_id, name, natural_id, import_id)
      VALUES (p_district_id, p_name, p_natural_id, p_import_id);

      SELECT id INTO p_id FROM school WHERE natural_id = p_natural_id;

    END IF;
  END; //
DELIMITER ;