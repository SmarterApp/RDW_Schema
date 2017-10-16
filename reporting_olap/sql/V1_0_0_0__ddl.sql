/*
Redshift script for the SBAC Aggregate Reporting Data Warehouse 1.0.0 schema
*/

SET SEARCH_PATH to ${schemaName};

SET client_encoding = 'UTF8';

-- staging tables
CREATE TABLE staging_grade (
  id smallint NOT NULL PRIMARY KEY,
  code character varying(2)  NOT NULL UNIQUE,
  name character varying(100) NOT NULL UNIQUE
);

CREATE TABLE staging_completeness (
  id smallint NOT NULL PRIMARY KEY,
  code character varying(10) NOT NULL UNIQUE
);

CREATE TABLE staging_administration_condition (
  id smallint NOT NULL PRIMARY KEY,
  code character varying(20) NOT NULL UNIQUE
);

CREATE TABLE staging_ethnicity (
  id smallint NOT NULL PRIMARY KEY,
  code character varying(120) NOT NULL UNIQUE
);

CREATE TABLE staging_gender (
  id smallint NOT NULL PRIMARY KEY,
  code character varying(80) NOT NULL UNIQUE
);

CREATE TABLE staging_asmt (
  id int PRIMARY KEY NOT NULL,
  grade_id smallint NOT NULL,
  type_id smallint NOT NULL,
  subject_id smallint NOT NULL,
  school_year smallint NOT NULL,
  name character varying(250) NOT NULL,
  deleted boolean NOT NULL,
  migrate_id bigint NOT NULL,
  update_import_id bigint NOT NULL
 );

CREATE TABLE staging_district (
  id int PRIMARY KEY NOT NULL,
  name character varying(100) NOT NULL,
  migrate_id bigint NOT NULL
);

CREATE TABLE staging_school (
  id int PRIMARY KEY NOT NULL,
  district_id int NOT NULL,
  name character varying(100) NOT NULL,
  deleted boolean NOT NULL,
  migrate_id bigint NOT NULL,
  update_import_id bigint NOT NULL
);

CREATE TABLE staging_student (
  id int PRIMARY KEY NOT NULL,
  ssid character varying(65) NOT NULL,
  last_or_surname character varying(60),
  first_name character varying(60),
  middle_name character varying(60),
  gender_id smallint,
  deleted boolean NOT NULL,
  migrate_id bigint NOT NULL,
  update_import_id bigint NOT NULL
 );

CREATE TABLE staging_student_ethnicity (
  ethnicity_id smallint NOT NULL,
  student_id int NOT NULL,
  migrate_id bigint NOT NULL
);

CREATE TABLE staging_exam (
  id bigint PRIMARY KEY NOT NULL,
  student_id int NOT NULL,
  grade_id smallint NOT NULL,
  school_id int NOT NULL,
  iep smallint NOT NULL,
  lep smallint NOT NULL,
  section504 smallint,
  economic_disadvantage smallint NOT NULL,
  migrant_status smallint,
  type_id smallint NOT NULL,
  school_year smallint NOT NULL,
  asmt_id int NOT NULL,
  completeness_id smallint NOT NULL,
  administration_condition_id smallint NOT NULL,
  scale_score float,
  scale_score_std_err float,
  performance_level smallint,
  deleted boolean NOT NULL,
  migrate_id bigint NOT NULL,
  update_import_id bigint NOT NULL
);

CREATE TABLE staging_exam_claim_score (
  id bigint PRIMARY KEY NOT NULL,
  exam_id bigint NOT NULL,
  subject_claim_score_id smallint NOT NULL,
  scale_score float,
  scale_score_std_err float,
  category smallint,
  migrate_id bigint NOT NULL
);

-- configuration

CREATE TABLE exam_claim_score_mapping (
  subject_claim_score_id smallint NOT NULL,
  num smallint NOT NULL
  );

-- dimensions
CREATE TABLE subject (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code character varying(10) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE grade (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code character varying(2)  NOT NULL UNIQUE,
  name character varying(100) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE asmt_type (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code character varying(10) NOT NULL UNIQUE,
  name character varying(24) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE completeness (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code character varying(10) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE administration_condition (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code character varying(20) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE  district (
  id integer PRIMARY KEY SORTKEY,
  name varchar(100) NOT NULL
) DISTSTYLE ALL;

CREATE TABLE school (
  id integer encode raw PRIMARY KEY SORTKEY,
  name varchar(100) NOT NULL,
  district_id integer NOT NULL,
  migrate_id bigint encode delta NOT NULL,
  update_import_id bigint encode delta NOT NULL
) DISTSTYLE ALL;

CREATE TABLE ica_asmt (
  id bigint encode raw  PRIMARY KEY SORTKEY,
  grade_id smallint NOT NULL,
  school_year int NOT NULL,
  subject_id smallint NOT NULL,
  name character varying(250) NOT NULL,
  migrate_id bigint encode delta NOT NULL,
  update_import_id bigint encode delta NOT NULL
) DISTSTYLE ALL;

CREATE TABLE gender (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code character varying(80) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE ethnicity (
  id smallint NOT NULL PRIMARY KEY SORTKEY ,
  code character varying(120) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE student (
  id bigint encode raw PRIMARY KEY SORTKEY DISTKEY,
  gender_id int encode lzo,
  migrate_id bigint encode delta NOT NULL,
  update_import_id bigint encode delta NOT NULL
) DISTSTYLE KEY;

CREATE TABLE student_ethnicity (
  ethnicity_id smallint encode lzo NOT NULL,
  student_id int encode raw  NOT NULL SORTKEY DISTKEY
) DISTSTYLE KEY;

-- facts
CREATE TABLE fact_student_ica_exam (
  id bigint encode delta PRIMARY KEY,
  school_id integer encode raw  NOT NULL,
  student_id bigint encode raw  NOT NULL DISTKEY,
  asmt_id bigint encode raw  NOT NULL,
  grade_id smallint encode lzo NOT NULL,
  asmt_grade_id smallint encode lzo NOT NULL, -- TODO: research if this is needed
  school_year smallint encode raw NOT NULL,
  iep smallint encode lzo NOT NULL,
  lep smallint encode lzo NOT NULL,
  section504 smallint encode lzo,
  economic_disadvantage smallint encode lzo NOT NULL,
  migrant_status smallint encode lzo,
  completeness_id smallint encode lzo NOT NULL,
  administration_condition_id smallint encode lzo NOT NULL,
  scale_score float encode bytedict ,
  scale_score_std_err float encode bytedict ,
  performance_level smallint encode lzo,
  claim1_scale_score float encode bytedict ,
  claim1_scale_score_std_err float encode bytedict ,
  claim1_category smallint encode lzo,
  claim2_scale_score float encode bytedict ,
  claim2_scale_score_std_err float encode bytedict ,
  claim2_category smallint encode lzo,
  claim3_scale_score float encode bytedict,
  claim3_scale_score_std_err float encode bytedict,
  claim3_category smallint encode lzo,
  claim4_scale_score float encode bytedict,
  claim4_scale_score_std_err float encode bytedict,
  claim4_category smallint encode lzo,
  migrate_id bigint encode delta NOT NULL,
  update_import_id bigint encode delta NOT NULL,
  CONSTRAINT fk__fact_student_ica_exam__ica_asmt FOREIGN KEY(asmt_id) REFERENCES ica_asmt(id),
  CONSTRAINT fk__fact_student_ica_exam__school FOREIGN KEY(school_id) REFERENCES school(id),
  CONSTRAINT fk__fact_student_ica_exam__student FOREIGN KEY(student_id) REFERENCES student(id)
)  COMPOUND SORTKEY (asmt_id, school_id, school_year, student_id);

-- TODO: decide if this is needed
CREATE TABLE fact_student_ica_exam_for_longitudinal (
  id bigint encode delta PRIMARY KEY,
  school_id integer encode raw  NOT NULL,
  student_id bigint encode raw  NOT NULL DISTKEY,
  asmt_id bigint encode raw  NOT NULL,
  grade_id smallint encode lzo NOT NULL,
  asmt_grade_id smallint encode lzo NOT NULL,
  school_year smallint encode raw NOT NULL,
  iep smallint encode lzo NOT NULL,
  lep smallint encode lzo NOT NULL,
  section504 smallint encode lzo,
  economic_disadvantage smallint encode lzo NOT NULL,
  migrant_status smallint encode lzo,
  completeness_id smallint encode lzo NOT NULL,
  administration_condition_id smallint encode lzo NOT NULL,
  scale_score float encode bytedict ,
  scale_score_std_err float encode bytedict ,
  performance_level smallint encode lzo,
  claim1_scale_score float encode bytedict ,
  claim1_scale_score_std_err float encode bytedict ,
  claim1_category smallint encode lzo,
  claim2_scale_score float encode bytedict ,
  claim2_scale_score_std_err float encode bytedict ,
  claim2_category smallint encode lzo,
  claim3_scale_score float encode bytedict,
  claim3_scale_score_std_err float encode bytedict,
  claim3_category smallint encode lzo,
  claim4_scale_score float encode bytedict,
  claim4_scale_score_std_err float encode bytedict,
  claim4_category smallint encode lzo,
  migrate_id bigint encode delta NOT NULL,
  update_import_id bigint encode delta NOT NULL,
  CONSTRAINT fk__fact_student_ica_exam__ica_asmt FOREIGN KEY(asmt_id) REFERENCES ica_asmt(id),
  CONSTRAINT fk__fact_student_ica_exam__school FOREIGN KEY(school_id) REFERENCES school(id),
  CONSTRAINT fk__fact_student_ica_exam__student FOREIGN KEY(student_id) REFERENCES student(id)
 )   COMPOUND SORTKEY (school_id, asmt_id);