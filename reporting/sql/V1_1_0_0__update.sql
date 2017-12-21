-- Consolidated v1.0 -> v1.1.0 flyway script.
--
-- This script should be run against v1.0.x installations where the schema_version table looks like:
-- +----------------+---------+------------------------------+--------+-------------------+-------------+---------+
-- | installed_rank | version | description                  | type   | script            | checksum    | success |
-- +----------------+---------+------------------------------+--------+-------------------+-------------+---------+
-- |              1 | NULL    | << Flyway Schema Creation >> | SCHEMA | `warehouse`       |        NULL |       1 |
-- |              2 | 1.0.0.0 | ddl                          | SQL    | V1_0_0_0__ddl.sql |   986463590 |       1 |
-- |              3 | 1.0.0.1 | dml                          | SQL    | V1_0_0_1__dml.sql | -1123132459 |       1 |
-- +----------------+---------+------------------------------+--------+-------------------+-------------+---------+
--
-- When first created, RDW_Schema was on build #273 and this incorporated:
--   V1_0_0_2__add_index_to_import.sql
--   V1_0_2_0__remove_wer_warning.sql   <-- not incorporated because it was deployed manually
--   V1_1_0_1__add_user_report_chunk_tracking.sql
--   ...
--   V1_1_0_16__migrate_embargo.sql

USE ${schemaName};

ALTER TABLE migrate
  ADD INDEX idx__migrate_status_created (status, created),
  MODIFY COLUMN size int,
  ADD COLUMN migrate_embargo tinyint;


ALTER TABLE user_report
  ADD COLUMN total_chunk_count INT NOT NULL DEFAULT 0,
  ADD COLUMN complete_chunk_count INT NOT NULL DEFAULT 0;


CREATE TABLE IF NOT EXISTS staging_district_group (
  id int NOT NULL PRIMARY KEY,
  natural_id varchar(40) NOT NULL,
  name varchar(100) NOT NULL,
  external_id varchar(40),
  migrate_id bigint NOT NULL
);

CREATE TABLE IF NOT EXISTS staging_school_group (
  id int NOT NULL PRIMARY KEY,
  natural_id varchar(40) NOT NULL,
  name varchar(100) NOT NULL,
  external_id varchar(40),
  migrate_id bigint NOT NULL
);

ALTER TABLE staging_district
  ADD COLUMN external_id varchar(40);

ALTER TABLE staging_school
  ADD COLUMN district_group_id int,
  ADD COLUMN school_group_id int,
  ADD COLUMN external_id varchar(40),
  CHANGE import_id update_import_id BIGINT NOT NULL;


CREATE TABLE IF NOT EXISTS district_group (
  id int NOT NULL PRIMARY KEY,
  natural_id varchar(40) NOT NULL,
  name varchar(100) NOT NULL,
  external_id varchar(40),
  UNIQUE INDEX idx__district_group__natural_id (natural_id)
);

CREATE TABLE IF NOT EXISTS school_group (
  id int NOT NULL PRIMARY KEY,
  natural_id varchar(40) NOT NULL,
  name varchar(100) NOT NULL,
  external_id varchar(40),
  UNIQUE INDEX idx__school_group__natural_id (natural_id)
);

ALTER TABLE district
  ADD COLUMN external_id varchar(40);

ALTER TABLE school
  ADD COLUMN district_group_id int,
  ADD COLUMN school_group_id int,
  ADD COLUMN external_id varchar(40),
  CHANGE import_id update_import_id BIGINT NOT NULL,
  ADD embargo_enabled tinyint NOT NULL DEFAULT 0,
  ADD INDEX idx__school__district_group (district_group_id),
  ADD INDEX idx__school__school_group (school_group_id),
  ADD CONSTRAINT fk__school__district_group FOREIGN KEY (district_group_id) REFERENCES district_group(id),
  ADD CONSTRAINT fk__school__school_group FOREIGN KEY (school_group_id) REFERENCES school_group(id);

CREATE TABLE IF NOT EXISTS staging_district_embargo (
  district_id int NOT NULL,
  individual tinyint,
  aggregate tinyint,
  migrate_id bigint NOT NULL
);


ALTER TABLE exam
  MODIFY COLUMN completed_at TIMESTAMP(6) NOT NULL,
  MODIFY COLUMN t3_program_type varchar(30),
  CHANGE import_id update_import_id BIGINT NOT NULL;

ALTER TABLE staging_exam
  ADD COLUMN grade_id tinyint NOT NULL,
  ADD COLUMN student_id int NOT NULL,
  ADD COLUMN school_id int NOT NULL,
  ADD COLUMN iep tinyint NOT NULL,
  ADD COLUMN lep tinyint NOT NULL,
  ADD COLUMN section504 tinyint,
  ADD COLUMN economic_disadvantage tinyint NOT NULL,
  ADD COLUMN migrant_status tinyint,
  ADD COLUMN eng_prof_lvl varchar(20),
  ADD COLUMN t3_program_type varchar(30),
  ADD COLUMN language_code varchar(3),
  ADD COLUMN prim_disability_type varchar(3),
  CHANGE import_id update_import_id BIGINT NOT NULL,
  MODIFY COLUMN completed_at TIMESTAMP(6) NOT NULL,
  DROP COLUMN exam_student_id;

DROP TABLE staging_exam_student;


ALTER TABLE asmt
  CHANGE import_id update_import_id BIGINT NOT NULL,
  ADD INDEX idx__asmt__name (name);

ALTER TABLE student
  ADD COLUMN inferred_school_id int,
  CHANGE import_id update_import_id BIGINT NOT NULL,
  ADD INDEX idx__student__inferred_school (inferred_school_id),
  ADD CONSTRAINT fk__student__inferred_school_id FOREIGN KEY (inferred_school_id) REFERENCES school(id);

ALTER TABLE student_group
  CHANGE import_id update_import_id BIGINT NOT NULL;

ALTER TABLE staging_student
  ADD COLUMN inferred_school_id int,
  CHANGE import_id update_import_id BIGINT NOT NULL;

ALTER TABLE staging_student_group
  CHANGE import_id update_import_id BIGINT NOT NULL;

ALTER TABLE staging_asmt
  CHANGE import_id update_import_id BIGINT NOT NULL;


ALTER TABLE translation
  ADD PRIMARY KEY (namespace, label_code, language_code),
  DROP INDEX idx__translation__namespace_label_code_language_code;


ALTER TABLE item
  ADD COLUMN field_test tinyint,
  ADD COLUMN active tinyint,
  ADD COLUMN type varchar(40),
  ADD COLUMN options_count tinyint,
  ADD COLUMN answer_key varchar(50);

ALTER TABLE staging_item
  ADD COLUMN field_test tinyint,
  ADD COLUMN active tinyint,
  ADD COLUMN type varchar(40),
  ADD COLUMN options_count tinyint,
  ADD COLUMN answer_key varchar(50);


ALTER TABLE instructional_resource
  DROP PRIMARY KEY,
  CHANGE name asmt_name VARCHAR(250) NOT NULL,
  ADD COLUMN org_level VARCHAR(15) NOT NULL DEFAULT 'System',
  ADD COLUMN performance_level TINYINT DEFAULT 0,
  ADD COLUMN org_id INT,
  ADD UNIQUE INDEX idx__instructional_resource (asmt_name, org_level, performance_level, org_id);

