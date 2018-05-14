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

CREATE TABLE staging_asmt (
  id int NOT NULL PRIMARY KEY,
  grade_id smallint NOT NULL,
  school_year smallint NOT NULL,
  subject_id smallint NOT NULL,
  type_id smallint NOT NULL,
  name varchar(250) NOT NULL,
  label varchar(255) NOT NULL,
  cut_point_1 smallint,
  cut_point_2 smallint NOT NULL,
  cut_point_3 smallint,
  min_score float NOT NULL,
  max_score float NOT NULL,
  deleted boolean NOT NULL,
  migrate_id bigint NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint NOT NULL
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
  iep smallint NOT NULL,
  lep smallint,
  elas_id smallint,
  section504 smallint,
  economic_disadvantage smallint NOT NULL,
  migrant_status smallint,
  type_id smallint NOT NULL,
  school_year smallint NOT NULL,
  asmt_id int NOT NULL,
  completeness_id smallint NOT NULL,
  administration_condition_id smallint NOT NULL,
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

CREATE TABLE staging_school_year (
  year smallint NOT NULL PRIMARY KEY
);

-- configuration
CREATE TABLE school_year (
  year smallint NOT NULL PRIMARY KEY SORTKEY 
) DISTSTYLE ALL;

CREATE TABLE exam_claim_score_mapping (
  subject_claim_score_id smallint NOT NULL,
  num smallint NOT NULL
);

-- dimensions
CREATE TABLE strict_boolean (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code varchar(10) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE boolean (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code varchar(10) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE subject (
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
  cut_point_2 smallint NOT NULL,
  cut_point_3 smallint,
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

-- ICA and Summative fact data for custom aggregate report
CREATE TABLE fact_student_exam (
  id bigint encode delta NOT NULL PRIMARY KEY,
  school_id integer encode raw NOT NULL,
  student_id bigint encode raw NOT NULL DISTKEY,
  asmt_id int encode raw NOT NULL,
  grade_id smallint encode lzo NOT NULL,
  school_year smallint encode raw NOT NULL,
  iep smallint encode lzo NOT NULL,
  lep smallint encode lzo NOT NULL,
  elas_id smallint encode lzo NOT NULL,
  section504 smallint encode lzo NOT NULL,
  economic_disadvantage smallint encode lzo NOT NULL,
  migrant_status smallint encode lzo NOT NULL,
  completeness_id smallint encode lzo NOT NULL,
  administration_condition_id smallint encode lzo NOT NULL,
  scale_score float encode bytedict NOT NULL,
  performance_level smallint encode lzo NOT NULL,
  completed_at timestamptz encode lzo NOT NULL,
  migrate_id bigint encode delta NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint encode delta NOT NULL,
  CONSTRAINT fk__fact_student_exam__asmt FOREIGN KEY(asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__fact_student_exam__school_year FOREIGN KEY(school_year) REFERENCES school_year(year),
  CONSTRAINT fk__fact_student_exam__school FOREIGN KEY(school_id) REFERENCES school(id),
  CONSTRAINT fk__fact_student_exam__student FOREIGN KEY(student_id) REFERENCES student(id),
  CONSTRAINT fk__fact_student_exam__iep FOREIGN KEY(iep) REFERENCES strict_boolean(id),
  CONSTRAINT fk__fact_student_exam__lep FOREIGN KEY(lep) REFERENCES strict_boolean(id),
  CONSTRAINT fk__fact_student_exam__elas FOREIGN KEY(elas_id) REFERENCES elas(id),
  CONSTRAINT fk__fact_student_exam__completeness FOREIGN KEY(completeness_id) REFERENCES completeness(id),
  CONSTRAINT fk__fact_student_exam__administration_comdition FOREIGN KEY(administration_condition_id) REFERENCES administration_condition(id),
  CONSTRAINT fk__fact_student_exam__section504 FOREIGN KEY(section504) REFERENCES boolean(id),
  CONSTRAINT fk__fact_student_exam__economic_disadvantage FOREIGN KEY(economic_disadvantage) REFERENCES strict_boolean(id),
  CONSTRAINT fk__fact_student_exam__migrant_status FOREIGN KEY(migrant_status) REFERENCES boolean(id)
)  COMPOUND SORTKEY (school_year, asmt_id, school_id, student_id);

-- IAB fact data for custom aggregate report
CREATE TABLE fact_student_iab_exam (
  id bigint encode delta NOT NULL PRIMARY KEY,
  school_id integer encode raw NOT NULL,
  student_id bigint encode raw NOT NULL DISTKEY,
  asmt_id int encode raw NOT NULL,
  grade_id smallint encode lzo NOT NULL,
  school_year smallint encode raw NOT NULL,
  iep smallint encode lzo NOT NULL,
  lep smallint encode lzo NOT NULL,
  elas_id smallint encode lzo NOT NULL,
  section504 smallint encode lzo NOT NULL,
  economic_disadvantage smallint encode lzo NOT NULL,
  migrant_status smallint encode lzo NOT NULL,
  completeness_id smallint encode lzo NOT NULL,
  administration_condition_id smallint encode lzo NOT NULL,
  scale_score float encode bytedict NOT NULL,
  performance_level smallint encode lzo NOT NULL,
  completed_at timestamptz encode lzo NOT NULL,
  migrate_id bigint encode delta NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint encode delta NOT NULL,
  CONSTRAINT fk__fact_student_iab_exam__asmt FOREIGN KEY(asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__fact_student_iab_exam__school_year FOREIGN KEY(school_year) REFERENCES school_year(year),
  CONSTRAINT fk__fact_student_iab_exam__school FOREIGN KEY(school_id) REFERENCES school(id),
  CONSTRAINT fk__fact_student_iab_exam__student FOREIGN KEY(student_id) REFERENCES student(id),
  CONSTRAINT fk__fact_student_iab_exam__iep FOREIGN KEY(iep) REFERENCES strict_boolean(id),
  CONSTRAINT fk__fact_student_iab_exam__lep FOREIGN KEY(lep) REFERENCES strict_boolean(id),
  CONSTRAINT fk__fact_student_iab_exam__elas FOREIGN KEY(elas_id) REFERENCES elas(id),
  CONSTRAINT fk__fact_student_exam__completeness FOREIGN KEY(completeness_id) REFERENCES completeness(id),
  CONSTRAINT fk__fact_student_exam__administration_comdition FOREIGN KEY(administration_condition_id) REFERENCES administration_condition(id),
  CONSTRAINT fk__fact_student_iab_exam__section504 FOREIGN KEY(section504) REFERENCES boolean(id),
  CONSTRAINT fk__fact_student_iab_exam__economic_disadvantage FOREIGN KEY(economic_disadvantage) REFERENCES strict_boolean(id),
  CONSTRAINT fk__fact_student_iab_exam__migrant_status FOREIGN KEY(migrant_status) REFERENCES boolean(id)
)  COMPOUND SORTKEY (school_year, asmt_id, school_id, student_id);

-- Exams data for the longitudinal report.
-- While the tables structure is similar to the other tables, the loaded data is filtered based on the different rules
CREATE TABLE fact_student_exam_longitudinal (
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
  section504 smallint encode lzo NOT NULL,
  economic_disadvantage smallint encode lzo NOT NULL,
  migrant_status smallint encode lzo NOT NULL,
  completeness_id smallint encode lzo NOT NULL,
  administration_condition_id smallint encode lzo NOT NULL,
  scale_score float encode bytedict NOT NULL,
  performance_level smallint encode lzo NOT NULL,
  completed_at timestamptz encode lzo NOT NULL,
  migrate_id bigint encode delta NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint encode delta NOT NULL,
  CONSTRAINT fk__fact_student_exam_longitudinal__asmt FOREIGN KEY(asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__fact_student_exam_longitudinal__subject_id FOREIGN KEY(subject_id) REFERENCES subject(id),
  CONSTRAINT fk__fact_student_exam_longitudinal__asmt_grade_id FOREIGN KEY(asmt_grade_id) REFERENCES grade(id),
  CONSTRAINT fk__fact_student_exam_longitudinal__grade_id FOREIGN KEY(grade_id) REFERENCES grade(id),
  CONSTRAINT fk__fact_student_exam_longitudinal__school_year FOREIGN KEY(school_year) REFERENCES school_year(year),
  CONSTRAINT fk__fact_student_exam_longitudinal__school FOREIGN KEY(school_id) REFERENCES school(id),
  CONSTRAINT fk__fact_student_exam_longitudinal__student FOREIGN KEY(student_id) REFERENCES student(id),
  CONSTRAINT fk__fact_student_exam_longitudinal__iep FOREIGN KEY(iep) REFERENCES strict_boolean(id),
  CONSTRAINT fk__fact_student_exam_longitudinal__lep FOREIGN KEY(lep) REFERENCES strict_boolean(id),
  CONSTRAINT fk__fact_student_exam_longitudinal__elas FOREIGN KEY(elas_id) REFERENCES elas(id),
  CONSTRAINT fk__fact_student_exam_longitudinal__completeness FOREIGN KEY(completeness_id) REFERENCES completeness(id),
  CONSTRAINT fk__fact_student_exam_longitudinal__administration_comdition FOREIGN KEY(administration_condition_id) REFERENCES administration_condition(id),
  CONSTRAINT fk__fact_student_exam_longitudinal__section504 FOREIGN KEY(section504) REFERENCES boolean(id),
  CONSTRAINT fk__fact_student_exam_longitudinal__economic_disadvantage FOREIGN KEY(economic_disadvantage) REFERENCES strict_boolean(id),
  CONSTRAINT fk__fact_student_exam_longitudinal__migrant_status FOREIGN KEY(migrant_status) REFERENCES boolean(id)
)  COMPOUND SORTKEY (student_id, subject_id, school_year, asmt_grade_id, school_id);

-- ICA and Summative claim data
CREATE TABLE fact_exam_claim_score (
  id bigint encode delta NOT NULL PRIMARY KEY,
  exam_id bigint encode delta NOT NULL,
  subject_claim_score_id int encode raw NOT NULL,
  asmt_id int encode raw NOT NULL,
  school_id integer encode raw NOT NULL,
  student_id bigint encode raw NOT NULL DISTKEY,
  grade_id smallint encode lzo NOT NULL,
  school_year smallint encode raw NOT NULL,
  iep smallint encode lzo NOT NULL,
  lep smallint encode lzo NOT NULL,
  elas_id smallint encode lzo NOT NULL,
  section504 smallint encode lzo NOT NULL,
  economic_disadvantage smallint encode lzo NOT NULL,
  migrant_status smallint encode lzo NOT NULL,
  completeness_id smallint encode lzo NOT NULL,
  administration_condition_id smallint encode lzo NOT NULL,
  category smallint encode lzo NOT NULL,
  completed_at timestamptz encode lzo NOT NULL,
  migrate_id bigint encode delta NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint encode delta NOT NULL,
  CONSTRAINT fk__fact_exam_claim_score__subject_claim_score FOREIGN KEY(subject_claim_score_id) REFERENCES subject_claim_score(id),
  CONSTRAINT fk__fact_exam_claim_score__asmt FOREIGN KEY(asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__fact_exam_claim_score__school_year FOREIGN KEY(school_year) REFERENCES school_year(year),
  CONSTRAINT fk__fact_exam_claim_score__school FOREIGN KEY(school_id) REFERENCES school(id),
  CONSTRAINT fk__fact_exam_claim_score__student FOREIGN KEY(student_id) REFERENCES student(id),
  CONSTRAINT fk__fact_exam_claim_score__iep FOREIGN KEY(iep) REFERENCES strict_boolean(id),
  CONSTRAINT fk__fact_exam_claim_score__lep FOREIGN KEY(lep) REFERENCES strict_boolean(id),
  CONSTRAINT fk__fact_exam_claim_score__elas FOREIGN KEY(elas_id) REFERENCES elas(id),
  CONSTRAINT fk__fact_exam_claim_score__completeness FOREIGN KEY(completeness_id) REFERENCES completeness(id),
  CONSTRAINT fk__fact_exam_claim_score__administration_comdition FOREIGN KEY(administration_condition_id) REFERENCES administration_condition(id),
  CONSTRAINT fk__fact_exam_claim_score__section504 FOREIGN KEY(section504) REFERENCES boolean(id),
  CONSTRAINT fk__fact_exam_claim_score__economic_disadvantage FOREIGN KEY(economic_disadvantage) REFERENCES strict_boolean(id),
  CONSTRAINT fk__fact_exam_claim_score__migrant_status FOREIGN KEY(migrant_status) REFERENCES boolean(id)
)  COMPOUND SORTKEY (subject_claim_score_id, school_year, asmt_id, school_id, student_id);

-- helper table used by the diagnostic API
CREATE TABLE status_indicator (
  id smallint encode delta NOT NULL PRIMARY KEY,
  updated timestamptz DEFAULT current_timestamp
);
