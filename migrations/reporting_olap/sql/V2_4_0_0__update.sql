-- v1.4.0 -> v2.4.0 flyway script
--
-- Adds tables for migrating, storing, and reporting alt scores.

SET SEARCH_PATH to ${schemaName};

SET client_encoding = 'UTF8';

-- add scale_score for alt-score entries
ALTER TABLE staging_exam_score
    ADD COLUMN scale_score FLOAT NULL;

-- ICA and Summative alt score data
CREATE TABLE exam_alt_score (
  id bigint encode delta NOT NULL PRIMARY KEY,
  exam_id bigint encode delta NOT NULL,
  subject_score_id int encode raw NOT NULL,
  student_id bigint encode raw NOT NULL DISTKEY,
  asmt_id int encode raw NOT NULL,
  school_year smallint encode raw NOT NULL,
  scale_score float encode bytedict NOT NULL,
  performance_level smallint encode lzo NOT NULL,
  completed_at timestamptz encode lzo NOT NULL,
  migrate_id bigint encode delta NOT NULL,
  updated timestamptz NOT NULL,
  update_import_id bigint encode delta NOT NULL,
  UNIQUE (school_year, asmt_id, student_id, subject_score_id),
  CONSTRAINT fk__exam_alt_score__exam FOREIGN KEY(exam_id) REFERENCES exam(id),
  CONSTRAINT fk__exam_alt_score__subject_score FOREIGN KEY (subject_score_id) REFERENCES subject_score(id),
  CONSTRAINT fk__exam_alt_score__student FOREIGN KEY(student_id) REFERENCES student(id),
  CONSTRAINT fk__exam_alt_score__asmt FOREIGN KEY(asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__exam_alt_score__school_year FOREIGN KEY(school_year) REFERENCES school_year(year)
)  COMPOUND SORTKEY (subject_score_id, exam_id);
