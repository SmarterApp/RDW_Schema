-- Consolidated v1.1 -> v1.2.0 flyway script.
--
-- This script should be run against v1.1 installations where the schema_version table looks like:
-- +----------------+---------+------------------------------+--------+----------------------+-------------+---------+
-- | installed_rank | version | description                  | type   | script               | checksum    | success |
-- +----------------+---------+------------------------------+--------+----------------------+-------------+---------+
-- |              1 | NULL    | << Flyway Schema Creation >> | SCHEMA | `reporting`          |        NULL |       1 |
-- |              2 | 1.0.0.0 | ddl                          | SQL    | V1_0_0_0__ddl.sql    |   986463590 |       1 |
-- |              3 | 1.0.0.1 | dml                          | SQL    | V1_0_0_1__dml.sql    | -1123132459 |       1 |
-- |              4 | 1.1.0.0 | update                       | SQL    | V1_1_0_0__update.sql | -1706757701 |       1 |
-- +----------------+---------+------------------------------+--------+----------------------+-------------+---------+
--
-- When first created, RDW_Schema was on build #371 and this incorporated:
--   V1_2_0_0__elas_gender.sql
--   V1_2_0_1__add_user_report_type.sql
--   V1_2_0_2__elas_date.sql
--   V1_2_0_3__iab_dashboard_exam_index.sql
--   V1_2_0_4__add_grade_order.sql
--   V1_2_0_5__remove_translation_namespace.sql
--   V1_2_0_6__add_teacher_student_groups.sql
--   V1_2_0_7__remove_school_from_teacher_student_groups.sql
--   V1_2_0_8__exam_target_scores.sql
--   V1_2_0_9__target_migrate.sql
--   V1_2_0_10__teacher_student_groups-drop-unique_index.sql
--   V1_2_0_11__user_groups-index.sql
--   V1_2_0_12__exam_index.sql
--   V1_2_0_13__optional_data.sql

USE ${schemaName};


INSERT INTO gender (id, code) VALUES
  (3, 'Nonbinary');

CREATE TABLE IF NOT EXISTS elas (
  id tinyint NOT NULL PRIMARY KEY,
  code varchar(20) NOT NULL UNIQUE
);

INSERT INTO elas (id, code) VALUES
  (1, 'EO'),
  (2, 'EL'),
  (3, 'IFEP'),
  (4, 'RFEP'),
  (5, 'TBD');

CREATE TABLE IF NOT EXISTS staging_elas (
  id tinyint NOT NULL PRIMARY KEY,
  code varchar(20) NOT NULL UNIQUE
);

ALTER TABLE user_report
  ADD COLUMN report_type VARCHAR(100);

ALTER TABLE exam
  DROP FOREIGN KEY fk__exam__student,
  DROP INDEX idx__exam__student;

ALTER TABLE exam
  ADD COLUMN elas_code VARCHAR(20) NULL,
  ADD COLUMN elas_start_at DATE NULL,
  DROP COLUMN completeness_id,
  DROP COLUMN administration_condition_id,
  MODIFY COLUMN lep TINYINT NULL,
  MODIFY COLUMN iep TINYINT NULL,
  MODIFY COLUMN economic_disadvantage TINYINT NULL,
  MODIFY COLUMN completeness_code VARCHAR(10) NULL,
  MODIFY COLUMN administration_condition_code VARCHAR(20) NULL,
  MODIFY COLUMN session_id VARCHAR(128) NULL,
  -- new index for the dashboard query
  ADD INDEX idx__exam__student_type_school_year_scores (student_id, school_year, type_id, scale_score, scale_score_std_err, performance_level),
  -- replace foreign key index with the new one
  ADD INDEX idx__exam__student_school_completed_at (student_id, school_id, completed_at),
  ADD CONSTRAINT fk__exam__student FOREIGN KEY (student_id) REFERENCES student(id);

ALTER TABLE staging_exam
  ADD COLUMN elas_id TINYINT NULL,
  ADD COLUMN elas_start_at DATE NULL,
  MODIFY COLUMN lep TINYINT NULL,
  MODIFY COLUMN completeness_id TINYINT NULL,
  MODIFY COLUMN administration_condition_id TINYINT NULL,
  MODIFY COLUMN session_id VARCHAR(128) NULL,
  MODIFY COLUMN iep TINYINT NULL,
  MODIFY COLUMN economic_disadvantage TINYINT NULL;


ALTER TABLE grade ADD COLUMN sequence tinyint;
UPDATE grade g
  JOIN (
         SELECT 0  AS sequence, 'UG' AS code UNION ALL
         SELECT 1  AS sequence, 'IT' AS code UNION ALL
         SELECT 2  AS sequence, 'PR' AS code UNION ALL
         SELECT 3  AS sequence, 'PK' AS code UNION ALL
         SELECT 4  AS sequence, 'TK' AS code UNION ALL
         SELECT 5  AS sequence, 'KG' AS code UNION ALL
         SELECT 6  AS sequence, '01' AS code UNION ALL
         SELECT 7  AS sequence, '02' AS code UNION ALL
         SELECT 8  AS sequence, '03' AS code UNION ALL
         SELECT 9  AS sequence, '04' AS code UNION ALL
         SELECT 10 AS sequence, '05' AS code UNION ALL
         SELECT 11 AS sequence, '06' AS code UNION ALL
         SELECT 12 AS sequence, '07' AS code UNION ALL
         SELECT 13 AS sequence, '08' AS code UNION ALL
         SELECT 14 AS sequence, '09' AS code UNION ALL
         SELECT 15 AS sequence, '10' AS code UNION ALL
         SELECT 16 AS sequence, '11' AS code UNION ALL
         SELECT 17 AS sequence, '12' AS code UNION ALL
         SELECT 18 AS sequence, '13' AS code UNION ALL
         SELECT 19 AS sequence, 'PS' AS code
       ) grade_order ON grade_order.code = g.code
SET g.sequence = grade_order.sequence;
ALTER TABLE grade MODIFY COLUMN sequence tinyint NOT NULL;

ALTER TABLE staging_grade
  ADD COLUMN sequence tinyint NOT NULL;


ALTER TABLE translation
  DROP PRIMARY KEY,
  ADD PRIMARY KEY(language_code, label_code),
  DROP COLUMN namespace;
RENAME TABLE translation TO accommodation_translation;

DELETE FROM accommodation_translation WHERE label_code = 'html.system-news';

ALTER TABLE staging_translation
  DROP COLUMN namespace;
RENAME TABLE staging_translation TO staging_accommodation_translation;


CREATE TABLE teacher_student_group (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name varchar(255) NOT NULL,
  school_year smallint NOT NULL,
  subject_id tinyint,
  user_login varchar(255) NOT NULL,
  INDEX idx__teacher_student_group__user_login_name_school_year (user_login, name, school_year),
  INDEX idx__teacher_student_group__subject (subject_id),
  INDEX idx__teacher_student_group__school_year (school_year),
  CONSTRAINT fk__teacher_student_group__subject FOREIGN KEY (subject_id) REFERENCES subject(id),
  CONSTRAINT fk__teacher_student_group__school_year FOREIGN KEY (school_year) REFERENCES school_year(year)
);

CREATE TABLE teacher_student_group_membership (
  teacher_student_group_id int NOT NULL,
  student_id int NOT NULL,
  UNIQUE INDEX idx__teacher_student_group_membership (teacher_student_group_id, student_id),
  INDEX idx__teacher_student_group_membership__student (student_id),
  CONSTRAINT fk__teacher_student_group_membership__student_group FOREIGN KEY (teacher_student_group_id) REFERENCES teacher_student_group(id),
  CONSTRAINT fk__teacher_student_group_membership__student FOREIGN KEY (student_id) REFERENCES student(id)
);


ALTER TABLE target
  ADD natural_id varchar(20);

CREATE TABLE asmt_target (
  asmt_id int NOT NULL,
  target_id smallint NOT NULL,
  include_in_report tinyint NOT NULL,
  PRIMARY KEY(asmt_id, target_id),
  INDEX idx__asmt_target__target (target_id),
  CONSTRAINT fk__asmt_target__asmt FOREIGN KEY(asmt_id) REFERENCES asmt(id),
  CONSTRAINT fk__asmt_target__target FOREIGN KEY(target_id) REFERENCES target(id)
);

CREATE TABLE exam_target_score (
  id bigint NOT NULL PRIMARY KEY,
  exam_id bigint NOT NULL,
  target_id smallint NOT NULL,
  student_relative_residual_score float,
  standard_met_relative_residual_score float,
  INDEX idx__exam_target_score__targer (target_id),
  UNIQUE INDEX idx__exam_target_score__exam_target (exam_id, target_id),
  CONSTRAINT fk__exam_target_score__exam FOREIGN KEY (exam_id) REFERENCES exam(id),
  CONSTRAINT fk__exam_target_score__target FOREIGN KEY (target_id) REFERENCES target(id)
);

ALTER TABLE staging_target ADD natural_id varchar(20) NOT NULL;

CREATE TABLE staging_asmt_target_exclusion (
  asmt_id int NOT NULL,
  target_id smallint NOT NULL,
  migrate_id bigint NOT NULL
);

CREATE TABLE staging_asmt_target (
  asmt_id int NOT NULL,
  target_id smallint NOT NULL,
  migrate_id bigint NOT NULL
);

CREATE TABLE staging_exam_target_score (
  id bigint NOT NULL PRIMARY KEY,
  exam_id bigint NOT NULL,
  target_id smallint NOT NULL,
  student_relative_residual_score float,
  standard_met_relative_residual_score float
);


ALTER TABLE user_student_group
  DROP FOREIGN KEY fk__user_student_group__student_group,
  DROP INDEX idx__user_student_group;

ALTER TABLE user_student_group
  ADD UNIQUE KEY idx__user_student_group(user_login, student_group_id),
  ADD INDEX idx__user_student_group__student_group(student_group_id),
  ADD CONSTRAINT fk__user_student_group__student_group FOREIGN KEY (student_group_id) REFERENCES student_group(id);
