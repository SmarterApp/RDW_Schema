/*
Redshift script for the SBAC Aggregate Reporting Data Warehouse 1.0.0 schema
*/

SET SEARCH_PATH to ${schemaName};

SET client_encoding = 'UTF8';

-- staging tables
CREATE TABLE staging_grade (
  id smallint NOT NULL PRIMARY KEY,
  code character varying(2) NOT NULL UNIQUE
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
  id int NOT NULL PRIMARY KEY,
  grade_id smallint NOT NULL,
  school_year smallint NOT NULL,
  subject_id smallint NOT NULL,
  type_id smallint NOT NULL,
  name character varying(250) NOT NULL,
  label character varying(255) NOT NULL,
  deleted boolean NOT NULL,
  migrate_id bigint NOT NULL,
  updated timestamp without time zone NOT NULL,
  update_import_id bigint NOT NULL
) DISTSTYLE ALL;

CREATE TABLE staging_district (
  id int NOT NULL PRIMARY KEY,
  name character varying(100) NOT NULL,
  natural_id varchar(40) NOT NULL,
  external_id varchar(40),
  migrate_id bigint NOT NULL
);

CREATE TABLE staging_school (
  id int NOT NULL PRIMARY KEY,
  district_id int NOT NULL,
  name character varying(100) NOT NULL,
  natural_id varchar(40) NOT NULL,
  external_id varchar(40),
  school_group_id integer,
  district_group_id integer,
  deleted boolean NOT NULL,
  migrate_id bigint NOT NULL,
  updated timestamp without time zone NOT NULL,
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
  updated timestamp without time zone NOT NULL,
  update_import_id bigint NOT NULL
 );

CREATE TABLE staging_student_ethnicity (
  ethnicity_id smallint NOT NULL,
  student_id int NOT NULL,
  migrate_id bigint NOT NULL
);

CREATE TABLE staging_exam (
  id bigint NOT NULL PRIMARY KEY,
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
  scale_score float NOT NULL ,
  scale_score_std_err float NOT NULL,
  performance_level smallint NOT NULL ,
  deleted boolean NOT NULL,
  completed_at timestamp without time zone NOT NULL,
  migrate_id bigint NOT NULL,
  updated timestamp without time zone NOT NULL,
  update_import_id bigint NOT NULL,
  latest boolean
);

CREATE TABLE staging_exam_claim_score (
  id bigint NOT NULL PRIMARY KEY,
  exam_id bigint NOT NULL,
  subject_claim_score_id smallint NOT NULL,
  scale_score float,
  scale_score_std_err float,
  category smallint,
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
  code character varying(10) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE boolean (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code character varying(10) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE subject (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code character varying(10) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE grade (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code character varying(2) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE asmt_type (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code character varying(10) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE completeness (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code character varying(10) NOT NULL UNIQUE
) DISTSTYLE ALL;

CREATE TABLE administration_condition (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  code character varying(20) NOT NULL UNIQUE
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
);

CREATE TABLE asmt (
  id int encode raw NOT NULL PRIMARY KEY SORTKEY,
  grade_id smallint NOT NULL,
  school_year smallint NOT NULL,
  subject_id smallint NOT NULL,
  type_id smallint NOT NULL,
  name character varying(250) NOT NULL,
  label character varying(255) NOT NULL,
  migrate_id bigint encode delta NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint encode delta NOT NULL,
  CONSTRAINT fk__asmt__type FOREIGN KEY(type_id) REFERENCES asmt(id),
  CONSTRAINT fk__asmt__subject FOREIGN KEY(subject_id) REFERENCES subject(id),
  CONSTRAINT fk__asmt__grade FOREIGN KEY(grade_id) REFERENCES grade(id),
  CONSTRAINT fk__asmt__school_year FOREIGN KEY(school_year) REFERENCES school_year(year)
) DISTSTYLE ALL;

CREATE TABLE asmt_active_year (
  asmt_id int NOT NULL,
  school_year smallint NOT NULL,
  CONSTRAINT fk__active_asmt_per_yeart__asmt FOREIGN KEY(asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__active_asmt_per_year__school_year FOREIGN KEY(school_year) REFERENCES school_year(year)
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

-- facts
CREATE TABLE fact_student_exam (
  id bigint encode delta NOT NULL PRIMARY KEY,
  school_id integer encode raw NOT NULL,
  student_id bigint encode raw NOT NULL DISTKEY,
  asmt_id bigint encode raw NOT NULL,
  grade_id smallint encode lzo NOT NULL,
  asmt_grade_id smallint encode lzo NOT NULL, -- TODO: research if this is needed
  school_year smallint encode raw NOT NULL,
  iep smallint encode lzo NOT NULL,
  lep smallint encode lzo NOT NULL,
  section504 smallint encode lzo NOT NULL,
  economic_disadvantage smallint encode lzo NOT NULL,
  migrant_status smallint encode lzo NOT NULL,
  completeness_id smallint encode lzo NOT NULL,
  administration_condition_id smallint encode lzo NOT NULL,
  scale_score float NOT NULL encode bytedict ,
  scale_score_std_err float NOT NULL encode bytedict ,
  performance_level smallint NOT NULL encode lzo,
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
  CONSTRAINT fk__fact_student_exam__section504 FOREIGN KEY(section504) REFERENCES boolean(id),
  CONSTRAINT fk__fact_student_exam__economic_disadvantage FOREIGN KEY(economic_disadvantage) REFERENCES strict_boolean(id),
  CONSTRAINT fk__fact_student_exam__migrant_status FOREIGN KEY(migrant_status) REFERENCES boolean(id)
)  COMPOUND SORTKEY (asmt_id, school_id, school_year, student_id);

-- helper table used by the diagnostic API
CREATE TABLE status_indicator (
  id smallint encode delta NOT NULL PRIMARY KEY,
  updated timestamp DEFAULT current_timestamp
);

-- Views to support filling in missing data in the aggregate reports.
CREATE VIEW asmt_active(id, grade_id, school_year, subject_id, type_id) AS
  SELECT
    ay.asmt_id      AS id,
    a.grade_id AS grade_id,
    ay.school_year,
    a.subject_id,
    a.type_id
  FROM asmt_active_year ay
    JOIN asmt a ON a.id = ay.asmt_id;

-- Note that all three views below have the same structure so that they could be used interchangeably in the final query.
CREATE VIEW state_subject_grade_school_year(organization_id, organization_name, organization_type, organization_natural_id, subject_id, grade_id, school_year, asmt_id, asmt_type_id) AS
  SELECT
    -1          AS id,
    'State'     AS name,
    'State'     AS organization_type,
    null        AS organization_natural_id,
    s.id,
    g.id,
    year,
    a.id,
    a.type_id
  FROM subject s
    CROSS JOIN grade g
    CROSS JOIN school_year y
    JOIN asmt_active a  on a.grade_id = g.id and a.subject_id = s.id and a.school_year = y.year;

CREATE VIEW school_subject_grade_school_year(organization_id, organization_name, organization_type, organization_natural_id, subject_id, grade_id, school_year, asmt_id, asmt_type_id) AS
  SELECT
    sch.id,
    sch.name,
    'School' AS organization_type,
    sch.natural_id,
    s.id,
    g.id,
    year,
    a.id as asmt_id,
    a.type_id
  FROM school sch
    CROSS JOIN subject s
    CROSS JOIN grade g
    CROSS JOIN school_year y
    JOIN asmt_active a  on a.grade_id = g.id and a.subject_id = s.id and a.school_year = y.year;

CREATE VIEW district_subject_grade_school_year(organization_id, organization_name, organization_type, organization_natural_id, subject_id, grade_id, school_year, asmt_id, asmt_type_id) AS
  SELECT
    d.id,
    d.name,
    'District' AS organization_type,
    d.natural_id,
    s.id,
    g.id,
    year,
    a.id as asmt_id,
    a.type_id
  FROM district d
    CROSS JOIN subject s
    CROSS JOIN grade g
    CROSS JOIN school_year y
    JOIN asmt_active a  on a.grade_id = g.id and a.subject_id = s.id and a.school_year = y.year;