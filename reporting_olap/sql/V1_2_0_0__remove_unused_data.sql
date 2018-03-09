-- Remove unused columns from the tables
-- IMPORTANT: run VACUUM and ANALYZE after this migration

SET SEARCH_PATH to ${schemaName};

-- Redshift does not support altering the table; need to backup the data (if needed), drop the table, re-create and reload the data

-- remove scale_score_std_err from staging table
DROP TABLE staging_exam;
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
  performance_level smallint NOT NULL ,
  deleted boolean NOT NULL,
  completed_at timestamptz NOT NULL,
  migrate_id bigint NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint NOT NULL,
  latest boolean
);

-- alter fact_student_exam: remove scale_score_std_err and claim data
CREATE TABLE fact_student_exam_backup (
  id bigint encode delta NOT NULL PRIMARY KEY,
  school_id integer encode raw NOT NULL,
  student_id bigint encode raw NOT NULL DISTKEY,
  asmt_id int encode raw NOT NULL,
  grade_id smallint encode lzo NOT NULL,
  school_year smallint encode raw NOT NULL,
  iep smallint encode lzo NOT NULL,
  lep smallint encode lzo NOT NULL,
  section504 smallint encode lzo NOT NULL,
  economic_disadvantage smallint encode lzo NOT NULL,
  migrant_status smallint encode lzo NOT NULL,
  completeness_id smallint encode lzo NOT NULL,
  administration_condition_id smallint encode lzo NOT NULL,
  scale_score float NOT NULL encode bytedict ,
  performance_level smallint NOT NULL encode lzo,
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
);

INSERT INTO fact_student_exam_backup
    SELECT id, school_id, student_id, asmt_id, grade_id, school_year, iep, lep, section504, economic_disadvantage, migrant_status, completeness_id, administration_condition_id, scale_score, performance_level, completed_at, migrate_id, updated, update_import_id
 FROM fact_student_exam;

DROP TABLE fact_student_exam;

CREATE TABLE fact_student_exam (
  id bigint encode delta NOT NULL PRIMARY KEY,
  school_id integer encode raw NOT NULL,
  student_id bigint encode raw NOT NULL DISTKEY,
  asmt_id int encode raw NOT NULL,
  grade_id smallint encode lzo NOT NULL,
  school_year smallint encode raw NOT NULL,
  iep smallint encode lzo NOT NULL,
  lep smallint encode lzo NOT NULL,
  section504 smallint encode lzo NOT NULL,
  economic_disadvantage smallint encode lzo NOT NULL,
  migrant_status smallint encode lzo NOT NULL,
  completeness_id smallint encode lzo NOT NULL,
  administration_condition_id smallint encode lzo NOT NULL,
  scale_score float NOT NULL encode bytedict ,
  performance_level smallint NOT NULL encode lzo,
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
) COMPOUND SORTKEY (school_year, asmt_id, school_id, student_id);

INSERT INTO fact_student_exam SELECT * FROM fact_student_exam_backup;

DROP TABLE fact_student_exam_backup;