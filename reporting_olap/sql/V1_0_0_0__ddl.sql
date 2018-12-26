/*
Redshift script for the SBAC Aggregate Reporting Data Warehouse 1.0.0 schema
*/

SET SEARCH_PATH to ${schemaName};

SET client_encoding = 'UTF8';

-- staging tables
CREATE TABLE staging_grade (
  id smallint NOT NULL PRIMARY KEY,
  code varchar(2) NOT NULL UNIQUE,
  sequence smallint NOT NULL
);

CREATE TABLE staging_completeness (
  id smallint NOT NULL PRIMARY KEY,
  code varchar(10) NOT NULL UNIQUE
);

CREATE TABLE staging_administration_condition (
  id smallint NOT NULL PRIMARY KEY,
  code varchar(20) NOT NULL UNIQUE
);

CREATE TABLE staging_ethnicity (
  id smallint NOT NULL PRIMARY KEY,
  code varchar(120) NOT NULL UNIQUE
);

CREATE TABLE staging_gender (
  id smallint NOT NULL PRIMARY KEY,
  code varchar(80) NOT NULL UNIQUE
);

CREATE TABLE staging_elas (
  id smallint NOT NULL PRIMARY KEY,
  code varchar(20) NOT NULL UNIQUE
);

CREATE TABLE staging_language (
  id smallint NOT NULL PRIMARY KEY,
  code varchar(8) NOT NULL UNIQUE
);

CREATE TABLE staging_subject (
  id smallint NOT NULL PRIMARY KEY,
  code varchar(10) NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint NOT NULL,
  migrate_id bigint NOT NULL
);

CREATE TABLE staging_subject_asmt_type (
  asmt_type_id smallint NOT NULL,
  subject_id smallint NOT NULL,
  performance_level_count smallint NOT NULL,
  performance_level_standard_cutoff smallint,
  claim_score_performance_level_count smallint,
  target_report boolean NOT NULL,
  migrate_id bigint NOT NULL
);

CREATE TABLE staging_subject_claim_score (
  id smallint NOT NULL PRIMARY KEY,
  subject_id smallint NOT NULL,
  asmt_type_id smallint NOT NULL,
  code varchar(10) NOT NULL,
  migrate_id bigint NOT NULL
);

CREATE TABLE staging_target (
  id smallint NOT NULL PRIMARY KEY,
  subject_id smallint NOT NULL,
  natural_id varchar(20) NOT NULL,
  claim_code varchar(10) NOT NULL,
  migrate_id bigint NOT NULL
);

CREATE TABLE staging_asmt (
  id int NOT NULL PRIMARY KEY,
  grade_id smallint NOT NULL,
  school_year smallint NOT NULL,
  subject_id smallint NOT NULL,
  type_id smallint NOT NULL,
  name varchar(250) NOT NULL,
  label varchar(255) NOT NULL,
  cut_point_1 smallint,
  cut_point_2 smallint,
  cut_point_3 smallint,
  cut_point_4 smallint,
  cut_point_5 smallint,
  min_score float NOT NULL,
  max_score float NOT NULL,
  deleted boolean NOT NULL,
  migrate_id bigint NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint NOT NULL
);

CREATE TABLE staging_asmt_target_exclusion (
  target_id int encode raw NOT NULL,
  asmt_id int encode raw NOT NULL,
  migrate_id bigint NOT NULL
);

CREATE TABLE staging_asmt_target (
  target_id int encode raw NOT NULL,
  asmt_id int encode raw NOT NULL,
  migrate_id bigint NOT NULL
);

CREATE TABLE staging_district (
  id int NOT NULL PRIMARY KEY,
  name varchar(100) NOT NULL,
  natural_id varchar(40) NOT NULL,
  external_id varchar(40),
  migrate_id bigint NOT NULL
);

CREATE TABLE staging_school (
  id int NOT NULL PRIMARY KEY,
  district_id int NOT NULL,
  name varchar(100) NOT NULL,
  natural_id varchar(40) NOT NULL,
  external_id varchar(40),
  school_group_id integer,
  district_group_id integer,
  deleted boolean NOT NULL,
  migrate_id bigint NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint NOT NULL
);

CREATE TABLE staging_district_group (
  id integer encode raw NOT NULL PRIMARY KEY,
  natural_id varchar(40) NOT NULL,
  name varchar(100) NOT NULL,
  external_id varchar(40),
  migrate_id bigint NOT NULL
);

CREATE TABLE staging_school_group (
  id integer encode raw NOT NULL PRIMARY KEY,
  natural_id varchar(40) NOT NULL,
  name varchar(100) NOT NULL,
  external_id varchar(40),
  migrate_id bigint NOT NULL
);

CREATE TABLE staging_district_embargo (
  district_id integer NOT NULL,
  aggregate boolean NOT NULL,
  migrate_id bigint NOT NULL
);

CREATE TABLE staging_state_embargo (
  aggregate boolean NOT NULL,
  migrate_id bigint NOT NULL
);

CREATE TABLE staging_student (
  id int NOT NULL PRIMARY KEY,
  gender_id smallint,
  deleted boolean NOT NULL,
  migrate_id bigint NOT NULL,
  updated timestamptz  NOT NULL,
  update_import_id bigint NOT NULL
 );

CREATE TABLE staging_student_ethnicity (
  ethnicity_id smallint NOT NULL,
  student_id int NOT NULL,
  migrate_id bigint NOT NULL
);

-- only exams with not NULL scores are loaded into this database
CREATE TABLE staging_exam (
  id bigint NOT NULL PRIMARY KEY,
  student_id int NOT NULL,
  grade_id smallint NOT NULL,
  subject_id smallint,        -- this is updated later, not as part of loading into the staging
  asmt_grade_id smallint,     -- this is updated later, not as part of loading into the staging
  asmt_grade_code varchar(2), -- this is updated later, not as part of loading into the staging
  school_id int NOT NULL,
  iep smallint,
  lep smallint,
  elas_id smallint,
  language_id smallint,
  section504 smallint,
  economic_disadvantage smallint,
  migrant_status smallint,
  type_id smallint NOT NULL,
  school_year smallint NOT NULL,
  asmt_id int NOT NULL,
  completeness_id smallint,
  administration_condition_id smallint,
  scale_score float NOT NULL,
  performance_level smallint NOT NULL,
  deleted boolean NOT NULL,
  completed_at timestamptz NOT NULL,
  migrate_id bigint NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint NOT NULL,
  latest boolean
);

-- only not NULL scores are loaded into this database
CREATE TABLE staging_exam_claim_score (
  id bigint NOT NULL PRIMARY KEY,
  exam_id bigint NOT NULL,
  subject_claim_score_id smallint NOT NULL,
  category smallint NOT NULL,
  migrate_id bigint NOT NULL
);

-- only not NULL scores are loaded into this database
CREATE TABLE staging_exam_target_score (
  id bigint NOT NULL PRIMARY KEY,
  exam_id bigint NOT NULL,
  target_id smallint NOT NULL,
  student_relative_residual_score float NOT NULL,
  standard_met_relative_residual_score float NOT NULL,
  migrate_id bigint NOT NULL
);

CREATE TABLE staging_school_year (
  year smallint NOT NULL PRIMARY KEY
);

-- configuration
CREATE TABLE school_year (
  year smallint NOT NULL PRIMARY KEY SORTKEY 
) DISTSTYLE ALL;

-- dimensions
CREATE TABLE strict_boolean (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code varchar(10) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE boolean (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code varchar(10) NOT NULL UNIQUE
) DISTSTYLE ALL;


CREATE TABLE grade (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code varchar(2) NOT NULL UNIQUE,
  sequence smallint NOT NULL
) DISTSTYLE ALL;

CREATE TABLE asmt_type (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code varchar(10) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE completeness (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code varchar(10) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE administration_condition (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code varchar(20) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE subject (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code varchar(10) NOT NULL UNIQUE,
  updated timestamptz NOT NULL,
  update_import_id bigint encode delta NOT NULL,
  migrate_id bigint NOT NULL
) DISTSTYLE ALL;

CREATE TABLE subject_asmt_type (
  asmt_type_id smallint NOT NULL,
  subject_id smallint NOT NULL SORTKEY,
  performance_level_count smallint NOT NULL,
  performance_level_standard_cutoff smallint,
  claim_score_performance_level_count smallint,
  target_report boolean NOT NULL,
  UNIQUE (asmt_type_id, subject_id),
  CONSTRAINT fk__subject_asmt_type__type FOREIGN KEY(asmt_type_id) REFERENCES asmt_type(id),
  CONSTRAINT fk__subject_asmt_type__subject FOREIGN KEY(subject_id) REFERENCES subject(id)
) DISTSTYLE ALL;

CREATE TABLE subject_claim_score (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  subject_id smallint NOT NULL,
  asmt_type_id smallint NOT NULL,
  code varchar(10) NOT NULL,
  CONSTRAINT fk__subject_claim_score__type FOREIGN KEY(asmt_type_id) REFERENCES asmt_type(id),
  CONSTRAINT fk__subject_claim_score__subject FOREIGN KEY(subject_id) REFERENCES subject(id)
) DISTSTYLE ALL;

CREATE TABLE district_group (
  id integer encode raw NOT NULL PRIMARY KEY SORTKEY,
  natural_id varchar(40) NOT NULL,
  name varchar(100) NOT NULL,
  external_id varchar(40),
  migrate_id bigint NOT NULL
) DISTSTYLE ALL;

CREATE TABLE school_group (
  id integer encode raw NOT NULL PRIMARY KEY SORTKEY,
  natural_id varchar(40) NOT NULL,
  name varchar(100) NOT NULL,
  external_id varchar(40),
  migrate_id bigint NOT NULL
) DISTSTYLE ALL;

CREATE TABLE district (
  id integer NOT NULL PRIMARY KEY SORTKEY,
  name varchar(100) NOT NULL,
  natural_id varchar(40) NOT NULL,
  external_id varchar(40),
  migrate_id bigint NOT NULL
) DISTSTYLE ALL;

CREATE TABLE school (
  id integer encode raw NOT NULL PRIMARY KEY SORTKEY,
  name varchar(100) NOT NULL,
  natural_id varchar(40) NOT NULL,
  external_id varchar(40),
  district_id integer NOT NULL,
  school_group_id integer,
  district_group_id integer,
  embargo_enabled boolean NOT NULL,
  migrate_id bigint encode delta NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint encode delta NOT NULL,
  CONSTRAINT fk__school__district FOREIGN KEY (district_id) REFERENCES district (id),
  CONSTRAINT fk__school__district_group FOREIGN KEY (district_group_id) REFERENCES district_group (id),
  CONSTRAINT fk__school__school_group FOREIGN KEY (school_group_id) REFERENCES school_group (id)
) DISTSTYLE ALL;

CREATE TABLE state_embargo (
  aggregate boolean NOT NULL,
  migrate_id bigint NOT NULL
) DISTSTYLE ALL;

CREATE TABLE asmt (
  id int encode raw NOT NULL PRIMARY KEY,
  grade_id smallint NOT NULL,
  school_year smallint NOT NULL,
  subject_id smallint NOT NULL,
  type_id smallint NOT NULL,
  name varchar(250) NOT NULL,
  label varchar(255) NOT NULL,
  cut_point_1 smallint,
  cut_point_2 smallint,
  cut_point_3 smallint,
  cut_point_4 smallint,
  cut_point_5 smallint,
  min_score float NOT NULL,
  max_score float NOT NULL,
  migrate_id bigint encode delta NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint encode delta NOT NULL,
  CONSTRAINT fk__asmt__type FOREIGN KEY(type_id) REFERENCES asmt_type(id),
  CONSTRAINT fk__asmt__subject FOREIGN KEY(subject_id) REFERENCES subject(id),
  CONSTRAINT fk__asmt__grade FOREIGN KEY(grade_id) REFERENCES grade(id),
  CONSTRAINT fk__asmt__school_year FOREIGN KEY(school_year) REFERENCES school_year(year)
) DISTSTYLE ALL COMPOUND SORTKEY (id, type_id, grade_id, subject_id);

CREATE TABLE target (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  subject_id smallint NOT NULL,
  natural_id varchar(20) NOT NULL,
  claim_code varchar(10) NOT NULL
) DISTSTYLE ALL;

CREATE TABLE asmt_target (
  target_id int encode raw NOT NULL,
  asmt_id int encode raw NOT NULL SORTKEY,
  include_in_report boolean NOT NULL,
  CONSTRAINT fk__asmt_target__target FOREIGN KEY(target_id) REFERENCES target(id),
  CONSTRAINT fk__asmt_target__asmt FOREIGN KEY(asmt_id) REFERENCES asmt(id)
) DISTSTYLE ALL;

CREATE TABLE asmt_active_year (
  asmt_id int NOT NULL,
  school_year smallint NOT NULL,
  CONSTRAINT fk__active_asmt_per_yeart__asmt FOREIGN KEY(asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__active_asmt_per_year__school_year FOREIGN KEY(school_year) REFERENCES school_year(year)
) DISTSTYLE ALL;

CREATE TABLE gender (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code varchar(80) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE ethnicity (
  id smallint NOT NULL PRIMARY KEY SORTKEY ,
  code varchar(120) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE elas (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code varchar(20) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE language (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code varchar(8) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE student (
  id bigint encode raw NOT NULL PRIMARY KEY SORTKEY DISTKEY,
  gender_id int encode lzo,
  migrate_id bigint encode delta NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint encode delta NOT NULL
) DISTSTYLE KEY;

CREATE TABLE student_ethnicity (
  ethnicity_id smallint encode lzo NOT NULL,
  student_id int encode raw NOT NULL SORTKEY DISTKEY
) DISTSTYLE KEY;

-- Holds ICA and Summative data.
-- This table has a double purpose: it is used as a fact table for the custom aggregate
-- report, as well as a dimension table for the claim and target reports.
CREATE TABLE exam (
  id bigint encode delta NOT NULL PRIMARY KEY,
  school_id integer encode raw NOT NULL,
  student_id bigint encode raw NOT NULL DISTKEY,
  asmt_id int encode raw NOT NULL,
  grade_id smallint encode lzo NOT NULL,
  school_year smallint encode raw NOT NULL,
  iep smallint encode lzo NOT NULL,
  lep smallint encode lzo NOT NULL,
  elas_id smallint encode lzo NOT NULL,
  language_id smallint encode lzo NOT NULL,
  section504 smallint encode lzo NOT NULL,
  economic_disadvantage smallint encode lzo NOT NULL,
  migrant_status smallint encode lzo NOT NULL,
  completeness_id smallint encode lzo,
  administration_condition_id smallint encode lzo,
  scale_score float encode bytedict NOT NULL,
  performance_level smallint encode lzo NOT NULL,
  completed_at timestamptz encode lzo NOT NULL,
  migrate_id bigint encode delta NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint encode delta NOT NULL,
  UNIQUE (school_year, asmt_id, student_id), -- one latest exam per student and assessment within a school year
  CONSTRAINT fk__exam__asmt FOREIGN KEY(asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__exam__school_year FOREIGN KEY(school_year) REFERENCES school_year(year),
  CONSTRAINT fk__exam__school FOREIGN KEY(school_id) REFERENCES school(id),
  CONSTRAINT fk__exam__student FOREIGN KEY(student_id) REFERENCES student(id),
  CONSTRAINT fk__exam__iep FOREIGN KEY(iep) REFERENCES strict_boolean(id),
  CONSTRAINT fk__exam__lep FOREIGN KEY(lep) REFERENCES strict_boolean(id),
  CONSTRAINT fk__exam__elas FOREIGN KEY(elas_id) REFERENCES elas(id),
  CONSTRAINT fk__exam__language FOREIGN KEY(language_id) REFERENCES language(id),
  CONSTRAINT fk__exam__completeness FOREIGN KEY(completeness_id) REFERENCES completeness(id),
  CONSTRAINT fk__exam__administration_comdition FOREIGN KEY(administration_condition_id) REFERENCES administration_condition(id),
  CONSTRAINT fk__exam__section504 FOREIGN KEY(section504) REFERENCES boolean(id),
  CONSTRAINT fk__exam__economic_disadvantage FOREIGN KEY(economic_disadvantage) REFERENCES strict_boolean(id),
  CONSTRAINT fk__exam__migrant_status FOREIGN KEY(migrant_status) REFERENCES boolean(id)
)  COMPOUND SORTKEY (school_year, asmt_id, school_id, student_id);

-- IAB fact data for custom aggregate report
CREATE TABLE iab_exam (
  id bigint encode delta NOT NULL PRIMARY KEY,
  school_id integer encode raw NOT NULL,
  student_id bigint encode raw NOT NULL DISTKEY,
  asmt_id int encode raw NOT NULL,
  grade_id smallint encode lzo NOT NULL,
  school_year smallint encode raw NOT NULL,
  iep smallint encode lzo NOT NULL,
  lep smallint encode lzo NOT NULL,
  elas_id smallint encode lzo NOT NULL,
  language_id smallint encode lzo NOT NULL,
  section504 smallint encode lzo NOT NULL,
  economic_disadvantage smallint encode lzo NOT NULL,
  migrant_status smallint encode lzo NOT NULL,
  completeness_id smallint encode lzo,
  administration_condition_id smallint encode lzo,
  scale_score float encode bytedict NOT NULL,
  performance_level smallint encode lzo NOT NULL,
  completed_at timestamptz encode lzo NOT NULL,
  migrate_id bigint encode delta NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint encode delta NOT NULL,
  UNIQUE (school_year, asmt_id, student_id), -- one latest exam per student and assessment within a school year
  CONSTRAINT fk__iab_exam__asmt FOREIGN KEY(asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__iab_exam__school_year FOREIGN KEY(school_year) REFERENCES school_year(year),
  CONSTRAINT fk__iab_exam__school FOREIGN KEY(school_id) REFERENCES school(id),
  CONSTRAINT fk__iab_exam__student FOREIGN KEY(student_id) REFERENCES student(id),
  CONSTRAINT fk__iab_exam__iep FOREIGN KEY(iep) REFERENCES strict_boolean(id),
  CONSTRAINT fk__iab_exam__lep FOREIGN KEY(lep) REFERENCES strict_boolean(id),
  CONSTRAINT fk__iab_exam__elas FOREIGN KEY(elas_id) REFERENCES elas(id),
  CONSTRAINT fk__iab_exam__language FOREIGN KEY(language_id) REFERENCES language(id),
  CONSTRAINT fk__iab_exam__completeness FOREIGN KEY(completeness_id) REFERENCES completeness(id),
  CONSTRAINT fk__iab_exam__administration_comdition FOREIGN KEY(administration_condition_id) REFERENCES administration_condition(id),
  CONSTRAINT fk__iab_exam__section504 FOREIGN KEY(section504) REFERENCES boolean(id),
  CONSTRAINT fk__iab_exam__economic_disadvantage FOREIGN KEY(economic_disadvantage) REFERENCES strict_boolean(id),
  CONSTRAINT fk__iab_exam__migrant_status FOREIGN KEY(migrant_status) REFERENCES boolean(id)
)  COMPOUND SORTKEY (school_year, asmt_id, school_id, student_id);

-- Exams data for the longitudinal report.
-- While the tables structure is similar to the other tables, the loaded data is filtered based on the different rules
-- and includes Summative assessments only
CREATE TABLE exam_longitudinal (
  id bigint encode delta NOT NULL PRIMARY KEY,
  school_id integer encode raw NOT NULL,
  student_id bigint encode raw NOT NULL DISTKEY,
  asmt_id int encode raw NOT NULL,
  subject_id smallint NOT NULL,
  asmt_grade_id smallint NOT NULL,
  grade_id smallint encode lzo NOT NULL,
  school_year smallint encode raw NOT NULL,
  school_year_asmt_grade_code varchar(7) encode raw NOT NULL,
  iep smallint encode lzo NOT NULL,
  lep smallint encode lzo NOT NULL,
  elas_id smallint encode lzo NOT NULL,
  language_id smallint encode lzo NOT NULL,
  section504 smallint encode lzo NOT NULL,
  economic_disadvantage smallint encode lzo NOT NULL,
  migrant_status smallint encode lzo NOT NULL,
  completeness_id smallint encode lzo,
  administration_condition_id smallint encode lzo,
  scale_score float encode bytedict NOT NULL,
  performance_level smallint encode lzo NOT NULL,
  completed_at timestamptz encode lzo NOT NULL,
  migrate_id bigint encode delta NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint encode delta NOT NULL,
  UNIQUE (student_id, subject_id, asmt_grade_id), -- one latest exam per student and assessment subject/grade
  CONSTRAINT fk__exam_longitudinal__asmt FOREIGN KEY(asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__exam_longitudinal__subject_id FOREIGN KEY(subject_id) REFERENCES subject(id),
  CONSTRAINT fk__exam_longitudinal__asmt_grade_id FOREIGN KEY(asmt_grade_id) REFERENCES grade(id),
  CONSTRAINT fk__exam_longitudinal__grade_id FOREIGN KEY(grade_id) REFERENCES grade(id),
  CONSTRAINT fk__exam_longitudinal__school_year FOREIGN KEY(school_year) REFERENCES school_year(year),
  CONSTRAINT fk__exam_longitudinal__school FOREIGN KEY(school_id) REFERENCES school(id),
  CONSTRAINT fk__exam_longitudinal__student FOREIGN KEY(student_id) REFERENCES student(id),
  CONSTRAINT fk__exam_longitudinal__iep FOREIGN KEY(iep) REFERENCES strict_boolean(id),
  CONSTRAINT fk__exam_longitudinal__lep FOREIGN KEY(lep) REFERENCES strict_boolean(id),
  CONSTRAINT fk__exam_longitudinal__elas FOREIGN KEY(elas_id) REFERENCES elas(id),
  CONSTRAINT fk__exam_longitudinal__language FOREIGN KEY(language_id) REFERENCES language(id),
  CONSTRAINT fk__exam_longitudinal__completeness FOREIGN KEY(completeness_id) REFERENCES completeness(id),
  CONSTRAINT fk__exam_longitudinal__administration_comdition FOREIGN KEY(administration_condition_id) REFERENCES administration_condition(id),
  CONSTRAINT fk__exam_longitudinal__section504 FOREIGN KEY(section504) REFERENCES boolean(id),
  CONSTRAINT fk__exam_longitudinal__economic_disadvantage FOREIGN KEY(economic_disadvantage) REFERENCES strict_boolean(id),
  CONSTRAINT fk__exam_longitudinal__migrant_status FOREIGN KEY(migrant_status) REFERENCES boolean(id)
)  COMPOUND SORTKEY (student_id, subject_id, school_year, asmt_grade_id, school_id);

-- ICA and Summative claim data
CREATE TABLE exam_claim_score (
  id bigint encode delta NOT NULL PRIMARY KEY,
  exam_id bigint encode delta NOT NULL,
  subject_claim_score_id int encode raw NOT NULL,
  student_id bigint encode raw NOT NULL DISTKEY,
  asmt_id int encode raw NOT NULL,
  school_year smallint encode raw NOT NULL,
  category smallint encode lzo NOT NULL,
  completed_at timestamptz encode lzo NOT NULL,
  migrate_id bigint encode delta NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint encode delta NOT NULL,
  UNIQUE (school_year, asmt_id, student_id, subject_claim_score_id), -- claims of the latest exam per student and assessment within a school year
  CONSTRAINT fk__exam_claim_score__exam FOREIGN KEY(exam_id) REFERENCES exam(id),
  CONSTRAINT fk__exam_claim_score__subject_claim_score FOREIGN KEY(subject_claim_score_id) REFERENCES subject_claim_score(id),
  CONSTRAINT fk__exam_claim_score__student FOREIGN KEY(student_id) REFERENCES student(id),
  CONSTRAINT fk__exam_claim_score__asmt FOREIGN KEY(asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__exam_claim_score__school_year FOREIGN KEY(school_year) REFERENCES school_year(year)
)  COMPOUND SORTKEY (subject_claim_score_id, exam_id);

--  Summative target scores
CREATE TABLE exam_target_score (
  id bigint encode delta NOT NULL PRIMARY KEY,
  exam_id bigint encode delta NOT NULL,
  target_id int encode raw NOT NULL,
  student_id bigint encode raw NOT NULL DISTKEY,
  asmt_id int encode raw NOT NULL,
  school_year smallint encode raw NOT NULL,
  student_relative_residual_score float encode bytedict NOT NULL,
  standard_met_relative_residual_score float encode bytedict NOT NULL,
  completed_at timestamptz encode lzo NOT NULL,
  migrate_id bigint encode delta NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint encode delta NOT NULL,
  UNIQUE (school_year, asmt_id, student_id, target_id), -- targets of the latest exam per student and assessment within a school year
  CONSTRAINT fk__exam_target_score__exam FOREIGN KEY(exam_id) REFERENCES exam(id),
  CONSTRAINT fk__exam_target_score__target FOREIGN KEY(target_id) REFERENCES target(id),
  CONSTRAINT fk__exam_target_score__student FOREIGN KEY(student_id) REFERENCES student(id),
  CONSTRAINT fk__exam_target_score__asmt FOREIGN KEY(asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__exam_target_score__school_year FOREIGN KEY(school_year) REFERENCES school_year(year)
)  COMPOUND SORTKEY (target_id, exam_id);

-- helper table used by the diagnostic API
CREATE TABLE status_indicator (
  id smallint encode delta NOT NULL PRIMARY KEY,
  updated timestamptz DEFAULT current_timestamp
);
