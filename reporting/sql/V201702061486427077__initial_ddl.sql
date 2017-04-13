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
  subject_id tinyint NOT NULL,
  code varchar(10) NOT NULL,
  name varchar(250) NOT NULL,
  description varchar(250) NOT NULL,
  CONSTRAINT fk__claim__subject FOREIGN KEY (subject_id) REFERENCES subject(id)
);

CREATE TABLE IF NOT EXISTS subject_claim_score (
  id smallint NOT NULL AUTO_INCREMENT PRIMARY KEY,
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
  level tinyint NOT NULL PRIMARY KEY,
  description varchar(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS math_practice (
  practice tinyint NOT NULL PRIMARY KEY,
  description varchar(250) NOT NULL
);

CREATE TABLE IF NOT EXISTS item (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  claim_id smallint,
  target_id smallint,
  natural_id varchar(40) NOT NULL,
  asmt_id bigint NOT NULL,
  math_practice tinyint,
  allow_calc boolean,
  dok tinyint NOT NULL,
  difficulty float NOT NULL,
  max_points float UNSIGNED NOT NULL,
  CONSTRAINT fk__item__claim FOREIGN KEY (claim_id) REFERENCES claim(id),
  CONSTRAINT fk__item__target FOREIGN KEY (target_id) REFERENCES target(id),
  CONSTRAINT fk__item__asmt FOREIGN KEY (asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__item__math_practice FOREIGN KEY (math_practice) REFERENCES math_practice(practice), 
  CONSTRAINT fk__item__dok FOREIGN KEY (dok) REFERENCES depth_of_knowledge(level)
);

CREATE TABLE IF NOT EXISTS item_trait_score (
  id tinyint NOT NULL PRIMARY KEY,
  dimension varchar(100) NOT NULL UNIQUE
 );

CREATE TABLE IF NOT EXISTS item_difficulty_cuts (
  id tinyint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  type_id tinyint NOT NULL,
  subject_id tinyint NOT NULL,
  grade_id tinyint NOT NULL,
  moderate_low_end float NOT NULL,
  difficult_low_end float NOT NULL,
  CONSTRAINT fk__item_difficulty_cuts__type FOREIGN KEY (type_id) REFERENCES asmt_type(id),
  CONSTRAINT fk__item_difficulty_cuts__grade FOREIGN KEY (grade_id) REFERENCES grade(id),
  CONSTRAINT fk__item_difficulty_cuts__subject FOREIGN KEY (subject_id) REFERENCES subject(id)
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
  ssid varchar(65) NOT NULL UNIQUE,
  last_or_surname varchar(35) NOT NULL,
  first_name varchar(35) NOT NULL,
  middle_name varchar(35),
  gender_id tinyint NOT NULL,
  first_entry_into_us_school_at date,
  lep_entry_at date,
  lep_exit_at date,
  is_demo tinyint,
  birthday date NOT NULL
 );

CREATE TABLE IF NOT EXISTS student_ethnicity (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  ethnicity_id tinyint NOT NULL,
  student_id bigint NOT NULL
);


CREATE TABLE IF NOT EXISTS student_group (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  created_by varchar(255) NOT NULL,
  school_id mediumint,
  name varchar(255) NOT NULL UNIQUE,
  exam_from date,
  exam_to date NOT NULL,
  subject_id tinyint,
  CONSTRAINT fk__student_group__school FOREIGN KEY (school_id) REFERENCES school(id),
  CONSTRAINT fk__student_group__subject FOREIGN KEY (subject_id) REFERENCES subject(id)
);

CREATE TABLE IF NOT EXISTS student_group_membership (
  student_group_id int NOT NULL,
  student_id bigint NOT NULL,
  CONSTRAINT fk__student_group_membership__student_group FOREIGN KEY (student_group_id) REFERENCES student_group(id),
  CONSTRAINT fk__student_group_membership__student FOREIGN KEY (student_id) REFERENCES student(id)
);

CREATE TABLE IF NOT EXISTS user_student_group (
  student_group_id int NOT NULL,
  user_login varchar(255) NOT NULL,
  CONSTRAINT fk__user_student_group__student_group FOREIGN KEY (student_group_id) REFERENCES student_group(id)
);

/** IAB exams **/

CREATE TABLE IF NOT EXISTS iab_exam_student (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  grade_id tinyint NOT NULL,
  student_id bigint NOT NULL,
  school_id mediumint NOT NULL,
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
  asmt_id bigint NOT NULL,
  asmt_version varchar(30),
  opportunity int,
  status varchar(50),
  completeness_id tinyint NOT NULL,
  administration_condition_id tinyint NOT NULL,
  session_id varchar(128),
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
  item_natural_id varchar(40) NOT NULL,
  score float,
  score_status varchar(50),
  max_score float,
  position int,
  response text,
  trait_evidence_elaboration_score float,
  trait_evidence_elaboration_score_status varchar(50),
  trait_evidence_elaboration_max_score float,
  trait_organization_purpose_score float,
  trait_organization_purpose_score_status varchar(50),
  trait_organization_purpose_max_score float,
  trait_conventions_score float,
  trait_conventions_score_status varchar(50),
  trait_conventions_max_score float,
  CONSTRAINT fk__iab_exam_item__exam FOREIGN KEY (iab_exam_id) REFERENCES iab_exam(id)
);

CREATE TABLE IF NOT EXISTS iab_exam_available_accommodation (
  iab_exam_id bigint NOT NULL,
  accommodation_id int NOT NULL,
  CONSTRAINT fk__iab_exam_available_accommodation__iab_exam FOREIGN KEY (iab_exam_id) REFERENCES iab_exam(id),
  CONSTRAINT fk__iab_exam_available_accommodation__accomodation FOREIGN KEY (accommodation_id) REFERENCES accommodation(id)
);

/** ICA and Summative exams **/

CREATE TABLE IF NOT EXISTS exam_student (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  grade_id tinyint NOT NULL,
  student_id bigint NOT NULL,
  school_id mediumint NOT NULL,
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
  asmt_id bigint NOT NULL,
  asmt_version varchar(30),
  opportunity int,
  status varchar(50),
  completeness_id tinyint NOT NULL,
  administration_condition_id tinyint NOT NULL,
  session_id varchar(128),
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
  item_natural_id varchar(40) NOT NULL,
  score float,
  score_status varchar(50),
  max_score float,
  position int,
  response text,
  trait_evidence_elaboration_score float,
  trait_evidence_elaboration_score_status varchar(50),
  trait_evidence_elaboration_max_score float,
  trait_organization_purpose_score float,
  trait_organization_purpose_score_status varchar(50),
  trait_organization_purpose_max_score float,
  trait_conventions_score float,
  trait_conventions_score_status varchar(50),
  trait_conventions_max_score float,
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

