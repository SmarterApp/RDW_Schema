/**
** 	Initial script for the SBAC Reportind Data Warehouse schema
**
**  NOTES
**  This schema assumes the following:
**     1. one state (aka tenant) per data warehouse
**     2. not all data elements from TRT are included, only those that are required for the current reporting
**/

ALTER DATABASE reporting CHARACTER SET utf8 COLLATE utf8_unicode_ci;

USE reporting;

CREATE TABLE application_schema_version (
   major_version int UNIQUE NOT NULL
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
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code varchar(25) NOT NULL UNIQUE
);

/** Assessment Packages related data **/

CREATE TABLE IF NOT EXISTS asmt (
  id  bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  natural_id varchar(250) NOT NULL UNIQUE,
  grade_id tinyint NOT NULL,
  type_id tinyint NOT NULL,
  subject_id tinyint NOT NULL,
  academic_year smallint NOT NULL,
  name varchar(250),
  label varchar(255),
  version varchar(30),
  CONSTRAINT fk__asmt__grade FOREIGN KEY (grade_id) REFERENCES grade(id),
  CONSTRAINT fk__asmt__type FOREIGN KEY (type_id) REFERENCES asmt_type(id),
  CONSTRAINT fk__asmt__subject FOREIGN KEY (subject_id) REFERENCES subject(id)
);

CREATE TABLE IF NOT EXISTS asmt_score (
  asmt_id bigint NOT NULL PRIMARY KEY,
  cut_point_1 float NOT NULL,
  cut_point_2 float NOT NULL,
  cut_point_3 float NOT NULL,
  min_score float NOT NULL,
  max_score float NOT NULL,
  CONSTRAINT fk__asmt_score__asmt FOREIGN KEY (asmt_id) REFERENCES asmt(id)
);

CREATE TABLE IF NOT EXISTS claim (
  id smallint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  asmt_id bigint NOT NULL,
  code varchar(255) NOT NULL,
  CONSTRAINT fk__claim__asmt FOREIGN KEY (asmt_id) REFERENCES asmt(id)
);

CREATE TABLE IF NOT EXISTS subject_claim_score (
  id smallint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  subject_id tinyint NOT NULL,
  asmt_type_id tinyint NOT NULL,
  code varchar(10) NOT NULL,
  CONSTRAINT fk__subject_claim_score__subject FOREIGN KEY (subject_id) REFERENCES subject(id),
  CONSTRAINT fk__subject_claim_score__asmt_type FOREIGN KEY (asmt_type_id) REFERENCES asmt_type(id)
);

CREATE TABLE IF NOT EXISTS target (
  id smallint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  claim_id smallint NOT NULL,
  name varchar(255) NOT NULL,
  CONSTRAINT fk__target__claim FOREIGN KEY (claim_id) REFERENCES claim(id)
);

CREATE TABLE IF NOT EXISTS item (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  claim_id smallint,
  target_id smallint,
  item_key bigint NOT NULL,
  bank_key varchar(40) NOT NULL,
  CONSTRAINT fk__item__claim FOREIGN KEY (claim_id) REFERENCES claim(id),
  CONSTRAINT fk__item__target FOREIGN KEY (target_id) REFERENCES target(id)
);

CREATE TABLE IF NOT EXISTS item_trait_score (
  id tinyint NOT NULL PRIMARY KEY,
  dimension varchar(100) NOT NULL UNIQUE
 );

/** Data derived from the exams delivered via TRT **/

CREATE TABLE IF NOT EXISTS district (
  id mediumint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name varchar(60) NOT NULL,
  natural_id varchar(40) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS school (
  id mediumint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  district_id mediumint NOT NULL,
  name varchar(60) NOT NULL,
  natural_id varchar(40) NOT NULL UNIQUE,
  CONSTRAINT fk__school__district FOREIGN KEY (district_id) REFERENCES district(id)
);

CREATE TABLE IF NOT EXISTS state (
  code varchar(2) NOT NULL UNIQUE
 );

/** Student Groups */

CREATE TABLE IF NOT EXISTS student (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  ssid varchar(40) NOT NULL UNIQUE,
  last_or_surname varchar(35) NOT NULL,
  first_name varchar(35) NOT NULL,
  middle_name varchar(35),
  gender_id tinyint NOT NULL,
  ethnicity_id tinyint NOT NULL,
  first_entry_into_us_school_at date,
  lep_entry_at date,
  lep_exit_at date,
  is_demo tinyint,
  birthday date NOT NULL
 );

CREATE TABLE IF NOT EXISTS roster (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  created_by varchar(255) NOT NULL,
  school_id mediumint,
  name varchar(255) NOT NULL UNIQUE,
  exam_from date,
  exam_to date NOT NULL,
  subject_id tinyint,
  CONSTRAINT fk__roster__school FOREIGN KEY (school_id) REFERENCES school(id),
  CONSTRAINT fk__roster__subject FOREIGN KEY (subject_id) REFERENCES subject(id)
);

CREATE TABLE IF NOT EXISTS roster_membership (
  roster_id int NOT NULL,
  student_id bigint NOT NULL,
  CONSTRAINT fk__roster_membership__roster FOREIGN KEY (roster_id) REFERENCES roster(id),
  CONSTRAINT fk__roster_membership__student FOREIGN KEY (student_id) REFERENCES student(id)
);

CREATE TABLE IF NOT EXISTS user_roster (
  roster_id int NOT NULL,
  user_login varchar(255) NOT NULL,
  CONSTRAINT fk__user_roster__roster FOREIGN KEY (roster_id) REFERENCES roster(id)
);

/** IAB exams **/

CREATE TABLE IF NOT EXISTS iab_exam_student (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  grade_id tinyint NOT NULL,
  student_id bigint NOT NULL,
  school_id mediumint NOT NULL,
  iep tinyint,
  lep tinyint,
  section504 tinyint,
  economic_disadvantage tinyint,
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
  asmt_id bigint NOT NULL,
  asmt_version varchar(30),
  opportunity int NOT NULL,
  status varchar(50) NOT NULL,
  validity tinyint(1) NOT NULL,
  completeness_id tinyint NOT NULL,
  administration_condition_id tinyint NOT NULL,
  session_id varchar(128) NULL,
  category tinyint NOT NULL,
  scale_score float NOT NULL,
  scale_score_std_err float NOT NULL,
  completed_at date NOT NULL,
  CONSTRAINT fk__iab_exam__iab_exam_student FOREIGN KEY (iab_exam_student_id) REFERENCES iab_exam_student(id),
  CONSTRAINT fk__iab_exam__asmt FOREIGN KEY (asmt_id) REFERENCES asmt(id)
);

CREATE TABLE IF NOT EXISTS iab_exam_item (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  iab_exam_id bigint NOT NULL,
  item_key bigint NOT NULL,
  bank_key varchar(40) NOT NULL,
  score float NOT NULL,
  score_status varchar(50),
  response text,
  CONSTRAINT fk__iab_exam_item__exam FOREIGN KEY (iab_exam_id) REFERENCES iab_exam(id)
);

CREATE TABLE IF NOT EXISTS iab_exam_available_accommodation (
  iab_exam_id bigint NOT NULL,
  accommodation_id int NOT NULL,
  CONSTRAINT fk__iab_exam_available_accommodation__iab_exam FOREIGN KEY (iab_exam_id) REFERENCES iab_exam(id),
  CONSTRAINT fk__iab_exam_available_accommodation__accomodation FOREIGN KEY (accommodation_id) REFERENCES accommodation(id)
);

CREATE TABLE IF NOT EXISTS iab_exam_item_trait_score (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  iab_exam_item_id bigint NOT NULL,
  item_trait_score_id tinyint NOT NULL,
  score float NOT NULL,
  score_status varchar(50),
  CONSTRAINT fk__iab_exam_item_trait_score__iab_exam_item FOREIGN KEY (iab_exam_item_id) REFERENCES iab_exam_item(id),
  CONSTRAINT fk__iab_exam_item_trait_score__item_trait_score FOREIGN KEY (item_trait_score_id) REFERENCES item_trait_score(id)
);

/** ICA and Summative exams **/

CREATE TABLE IF NOT EXISTS exam_student (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  grade_id tinyint NOT NULL,
  student_id bigint NOT NULL,
  school_id mediumint NOT NULL,
  iep tinyint,
  lep tinyint,
  section504 tinyint,
  economic_disadvantage tinyint,
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
  asmt_id bigint NOT NULL,
  asmt_version varchar(30),
  opportunity int NOT NULL,
  status varchar(50) NOT NULL,
  validity tinyint(1) NOT NULL,
  completeness_id tinyint NOT NULL,
  administration_condition_id tinyint NOT NULL,
  session_id varchar(128) NULL,
  scale_score float NOT NULL,
  scale_score_std_err float NOT NULL,
  achievement_level tinyint NOT NULL,
  completed_at date NOT NULL,
  CONSTRAINT fk__exam__exam_student FOREIGN KEY (exam_student_id) REFERENCES exam_student(id),
  CONSTRAINT fk__exam__asmt FOREIGN KEY (asmt_id) REFERENCES asmt(id)
);

CREATE TABLE IF NOT EXISTS exam_item (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  exam_id bigint NOT NULL,
  item_key bigint NOT NULL,
  bank_key varchar(40) NOT NULL,
  score float NOT NULL,
  score_status varchar(50),
  response text,
  CONSTRAINT fk__exam_item__exam FOREIGN KEY (exam_id) REFERENCES exam(id)
);

CREATE TABLE IF NOT EXISTS exam_available_accommodation (
  exam_id bigint NOT NULL,
  accommodation_id int NOT NULL,
  CONSTRAINT fk__exam_available_accommodation__exam FOREIGN KEY (exam_id) REFERENCES exam(id),
  CONSTRAINT fk__exam_available_accommodation_accomodation FOREIGN KEY (accommodation_id) REFERENCES accommodation(id)
);

CREATE TABLE IF NOT EXISTS exam_claim_score (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  exam_id bigint NOT NULL,
  subject_claim_score_id smallint NOT NULL,
  scale_score float NOT NULL,
  scale_score_std_err float NOT NULL,
  category tinyint NOT NULL,
  CONSTRAINT fk__exam_claim_score__exam FOREIGN KEY (exam_id) REFERENCES exam(id)
);

CREATE TABLE IF NOT EXISTS exam_item_trait_score (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  exam_item_id bigint NOT NULL,
  item_trait_score_id tinyint NOT NULL,
  score float NOT NULL,
  score_status varchar(50),
  CONSTRAINT fk__exam_item_trait_score__exam_item FOREIGN KEY (exam_item_id) REFERENCES exam_item(id),
  CONSTRAINT fk__exam_item_trait_score__item_trait_score FOREIGN KEY (item_trait_score_id) REFERENCES item_trait_score(id)
);
