-- Remove unused columns from the tables
-- IMPORTANT: run VACUUM and ANALYZE after this migration

SET SEARCH_PATH to ${schemaName};

ALTER TABLE staging_exam DROP COLUMN scale_score_std_err;

-- it's not possible to add or change distkey and sort key after creating a table;
-- instead we need to recreate a table and copy all data to the new table.
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
) COMPOUND SORTKEY (school_year, asmt_id, school_id, student_id);;

INSERT INTO fact_student_exam_backup
    SELECT id, school_id, student_id, asmt_id, grade_id, school_year, iep, lep, section504, economic_disadvantage, migrant_status, completeness_id, administration_condition_id, scale_score, performance_level, completed_at, migrate_id, updated, update_import_id
 FROM fact_student_exam;

DROP TABLE fact_student_exam;

ALTER TABLE fact_student_exam_backup RENAME TO fact_student_exam;

