CREATE TABLE staging_state_subject_grade_school_year (
  organization_id         INT                    NOT NULL,
  organization_name       CHARACTER VARYING(100) NOT NULL,
  organization_type       CHARACTER VARYING(10)  NOT NULL,
  organization_natural_id VARCHAR(40),
  subject_id              SMALLINT               NOT NULL,
  subject_code            CHARACTER VARYING(10)  NOT NULL,
  grade_id                SMALLINT               NOT NULL,
  school_year             SMALLINT               NOT NULL,
  asmt_id                 INT                    NOT NULL,
  asmt_label              CHARACTER VARYING(255) NOT NULL,
  asmt_type_id            SMALLINT               NOT NULL
) ;

CREATE TABLE staging_school_subject_grade_school_year (
  organization_id         INT                    NOT NULL,
  organization_name       CHARACTER VARYING(100) NOT NULL,
  organization_type       CHARACTER VARYING(10)  NOT NULL,
  organization_natural_id VARCHAR(40)            NOT NULL,
  subject_id              SMALLINT               NOT NULL,
  subject_code            CHARACTER VARYING(10)  NOT NULL,
  grade_id                SMALLINT               NOT NULL,
  school_year             SMALLINT               NOT NULL,
  asmt_id                 INT                    NOT NULL,
  asmt_label              CHARACTER VARYING(255) NOT NULL,
  asmt_type_id            SMALLINT               NOT NULL
);

CREATE TABLE staging_district_subject_grade_school_year (
  organization_id         INT                    NOT NULL,
  organization_name       CHARACTER VARYING(100) NOT NULL,
  organization_type       CHARACTER VARYING(10)  NOT NULL,
  organization_natural_id VARCHAR(40)            NOT NULL,
  subject_id              SMALLINT               NOT NULL,
  subject_code            CHARACTER VARYING(10)  NOT NULL,
  grade_id                SMALLINT               NOT NULL,
  school_year             SMALLINT               NOT NULL,
  asmt_id                 INT                    NOT NULL,
  asmt_label              CHARACTER VARYING(255) NOT NULL,
  asmt_type_id            SMALLINT               NOT NULL
);


INSERT INTO staging_state_subject_grade_school_year (organization_id, organization_name, organization_type, organization_natural_id, subject_id, subject_code, grade_id, school_year, asmt_id, asmt_label, asmt_type_id)
  SELECT
    organization_id,
    organization_name,
    organization_type,
    organization_natural_id,
    subject_id,
    subject_code,
    grade_id,
    school_year,
    asmt_id,
    asmt_label,
    asmt_type_id
  FROM state_subject_grade_school_year;

INSERT INTO staging_school_subject_grade_school_year (organization_id, organization_name, organization_type, organization_natural_id, subject_id, subject_code, grade_id, school_year, asmt_id, asmt_label, asmt_type_id)
  SELECT
    organization_id,
    organization_name,
    organization_type,
    organization_natural_id,
    subject_id,
    subject_code,
    grade_id,
    school_year,
    asmt_id,
    asmt_label,
    asmt_type_id
  FROM school_subject_grade_school_year;

INSERT INTO staging_district_subject_grade_school_year (organization_id, organization_name, organization_type, organization_natural_id, subject_id, subject_code, grade_id, school_year, asmt_id, asmt_label, asmt_type_id)
  SELECT
    organization_id,
    organization_name,
    organization_type,
    organization_natural_id,
    subject_id,
    subject_code,
    grade_id,
    school_year,
    asmt_id,
    asmt_label,
    asmt_type_id
  FROM district_subject_grade_school_year;

DROP VIEW state_subject_grade_school_year;
DROP VIEW school_subject_grade_school_year;
DROP VIEW district_subject_grade_school_year;


CREATE TABLE state_subject_grade_school_year (
  organization_id         INT                    NOT NULL,
  organization_name       CHARACTER VARYING(100) NOT NULL,
  organization_type       CHARACTER VARYING(10)  NOT NULL,
  organization_natural_id VARCHAR(40),
  subject_id              SMALLINT               NOT NULL,
  subject_code            CHARACTER VARYING(10)  NOT NULL,
  grade_id                SMALLINT               NOT NULL,
  school_year             SMALLINT               NOT NULL,
  asmt_id                 INT                    NOT NULL,
  asmt_label              CHARACTER VARYING(255) NOT NULL,
  asmt_type_id            SMALLINT               NOT NULL
) DISTSTYLE ALL COMPOUND SORTKEY (school_year, grade_id, subject_id, asmt_type_id
);

CREATE TABLE school_subject_grade_school_year (
  organization_id         INT                    NOT NULL,
  organization_name       CHARACTER VARYING(100) NOT NULL,
  organization_type       CHARACTER VARYING(10)  NOT NULL,
  organization_natural_id VARCHAR(40)            NOT NULL,
  subject_id              SMALLINT               NOT NULL,
  subject_code            CHARACTER VARYING(10)  NOT NULL,
  grade_id                SMALLINT               NOT NULL,
  school_year             SMALLINT               NOT NULL,
  asmt_id                 INT                    NOT NULL,
  asmt_label              CHARACTER VARYING(255) NOT NULL,
  asmt_type_id            SMALLINT               NOT NULL
) DISTSTYLE ALL COMPOUND SORTKEY (organization_id, grade_id, school_year, subject_id, asmt_type_id
);

CREATE TABLE district_subject_grade_school_year (
  organization_id         INT                    NOT NULL,
  organization_name       CHARACTER VARYING(100) NOT NULL,
  organization_type       CHARACTER VARYING(10)  NOT NULL,
  organization_natural_id VARCHAR(40)            NOT NULL,
  subject_id              SMALLINT               NOT NULL,
  subject_code            CHARACTER VARYING(10)  NOT NULL,
  grade_id                SMALLINT               NOT NULL,
  school_year             SMALLINT               NOT NULL,
  asmt_id                 INT                    NOT NULL,
  asmt_label              CHARACTER VARYING(255) NOT NULL,
  asmt_type_id            SMALLINT               NOT NULL
) DISTSTYLE ALL COMPOUND SORTKEY (organization_id, grade_id, school_year, subject_id, asmt_type_id);


INSERT INTO state_subject_grade_school_year (organization_id, organization_name, organization_type, organization_natural_id, subject_id, subject_code, grade_id, school_year, asmt_id, asmt_label, asmt_type_id)
  SELECT
    organization_id,
    organization_name,
    organization_type,
    organization_natural_id,
    subject_id,
    subject_code,
    grade_id,
    school_year,
    asmt_id,
    asmt_label,
    asmt_type_id
  FROM staging_state_subject_grade_school_year;

INSERT INTO school_subject_grade_school_year (organization_id, organization_name, organization_type, organization_natural_id, subject_id, subject_code, grade_id, school_year, asmt_id, asmt_label, asmt_type_id)
  SELECT
    organization_id,
    organization_name,
    organization_type,
    organization_natural_id,
    subject_id,
    subject_code,
    grade_id,
    school_year,
    asmt_id,
    asmt_label,
    asmt_type_id
  FROM staging_school_subject_grade_school_year;

INSERT INTO district_subject_grade_school_year (organization_id, organization_name, organization_type, organization_natural_id, subject_id, subject_code, grade_id, school_year, asmt_id, asmt_label, asmt_type_id)
  SELECT
    organization_id,
    organization_name,
    organization_type,
    organization_natural_id,
    subject_id,
    subject_code,
    grade_id,
    school_year,
    asmt_id,
    asmt_label,
    asmt_type_id
  FROM staging_district_subject_grade_school_year;

DROP TABLE staging_state_subject_grade_school_year;
DROP TABLE staging_school_subject_grade_school_year;
DROP TABLE staging_district_subject_grade_school_year;

INSERT INTO staging_asmt (id, grade_id, school_year, subject_id, type_id, name, label, migrate_id, updated, update_import_id, deleted)
  SELECT
    id,
    grade_id,
    school_year,
    subject_id,
    type_id,
    name,
    label,
    migrate_id,
    updated,
    update_import_id,
    FALSE
  FROM asmt;

DROP VIEW asmt_active;
ALTER TABLE asmt_active_year
  DROP CONSTRAINT fk__active_asmt_per_yeart__asmt;
ALTER TABLE fact_student_exam
  DROP CONSTRAINT fk__fact_student_exam__asmt;
DROP TABLE asmt;

CREATE TABLE asmt (
  id               INT ENCODE RAW NOT NULL PRIMARY KEY,
  grade_id         SMALLINT               NOT NULL,
  school_year      SMALLINT               NOT NULL,
  subject_id       SMALLINT               NOT NULL,
  type_id          SMALLINT               NOT NULL,
  name             CHARACTER VARYING(250) NOT NULL,
  label            CHARACTER VARYING(255) NOT NULL,
  migrate_id       BIGINT ENCODE DELTA NOT NULL,
  updated          TIMESTAMPTZ            NOT NULL,
  update_import_id BIGINT ENCODE DELTA NOT NULL,
  CONSTRAINT fk__asmt__type FOREIGN KEY (type_id) REFERENCES asmt (id),
  CONSTRAINT fk__asmt__subject FOREIGN KEY (subject_id) REFERENCES subject (id),
  CONSTRAINT fk__asmt__grade FOREIGN KEY (grade_id) REFERENCES grade (id),
  CONSTRAINT fk__asmt__school_year FOREIGN KEY (school_year) REFERENCES school_year (year)
) DISTSTYLE ALL COMPOUND SORTKEY (id, grade_id, subject_id, type_id
);

INSERT INTO asmt (id, grade_id, school_year, subject_id, type_id, name, label, migrate_id, updated, update_import_id)
  SELECT
    id,
    grade_id,
    school_year,
    subject_id,
    type_id,
    name,
    label,
    migrate_id,
    updated,
    update_import_id
  FROM staging_asmt;

DELETE FROM staging_asmt;

CREATE VIEW asmt_active(id, grade_id, school_year, subject_id, type_id, label) AS
  SELECT
    ay.asmt_id AS id,
    a.grade_id AS grade_id,
    ay.school_year,
    a.subject_id,
    a.type_id,
    a.label
  FROM asmt_active_year ay
    JOIN asmt a ON a.id = ay.asmt_id;

ALTER TABLE asmt_active_year
  ADD CONSTRAINT fk__active_asmt_per_yeart__asmt FOREIGN KEY (asmt_id) REFERENCES asmt (id);
ALTER TABLE fact_student_exam
  ADD CONSTRAINT fk__fact_student_exam__asmt FOREIGN KEY (asmt_id) REFERENCES asmt (id);

ANALYZE;
