-- Add audit tables for student and add a primary key for setting table
-- 1: Primary key change for setting table
-- 2: timestamp added to student_ethnicity
-- 3: student and student_ethnicity audit tables and triggers

USE ${schemaName};

/*
 Modify the setting table.  Each setting name should be unique.
*/
ALTER TABLE setting ADD PRIMARY KEY (name);

/*
  Add created timestamp to child tables of parent being audited.
  Audit records are created for update and delete.
  Timestamp is required for student updates that include creating a new child record.
  Child records do not have the import id.
*/
ALTER TABLE student_ethnicity
  ADD COLUMN created TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL;

/*
  student triggers
*/

-- audit table
CREATE TABLE audit_student (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  action VARCHAR(8) NOT NULL,
  audited TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL,
  database_user VARCHAR(255) NOT NULL,
  student_id INT NOT NULL,
  ssid VARCHAR(65) NOT NULL,
  last_or_surname VARCHAR(60) NULL,
  first_name VARCHAR(60) NULL,
  middle_name VARCHAR(60) NULL,
  gender_id TINYINT NULL,
  first_entry_into_us_school_at DATE NULL,
  lep_entry_at DATE NULL,
  lep_exit_at DATE NULL,
  birthday DATE NULL,
  import_id BIGINT NOT NULL,
  update_import_id BIGINT NOT NULL,
  deleted TINYINT NOT NULL,
  created TIMESTAMP(6) NOT NULL,
  updated TIMESTAMP(6) NOT NULL
);

-- update trigger
CREATE TRIGGER trg__student__update
BEFORE UPDATE ON student
FOR EACH ROW
  INSERT INTO audit_student (action, database_user, student_id, ssid, last_or_surname, first_name, middle_name,
                             gender_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, birthday, import_id,
                             update_import_id, deleted, created, updated)
    SELECT
      'update',
      USER(),
      OLD.id,
      OLD.ssid,
      OLD.last_or_surname,
      OLD.first_name,
      OLD.middle_name,
      OLD.gender_id,
      OLD.first_entry_into_us_school_at,
      OLD.lep_entry_at,
      OLD.lep_exit_at,
      OLD.birthday,
      OLD.import_id,
      OLD.update_import_id,
      OLD.deleted,
      OLD.created,
      OLD.updated
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

-- delete trigger
CREATE TRIGGER trg__student__delete
BEFORE DELETE ON student
FOR EACH ROW
  INSERT INTO audit_student (action, database_user, student_id, ssid, last_or_surname, first_name, middle_name,
                             gender_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, birthday, import_id,
                             update_import_id, deleted, created, updated)
    SELECT
      'delete',
      USER(),
      OLD.id,
      OLD.ssid,
      OLD.last_or_surname,
      OLD.first_name,
      OLD.middle_name,
      OLD.gender_id,
      OLD.first_entry_into_us_school_at,
      OLD.lep_entry_at,
      OLD.lep_exit_at,
      OLD.birthday,
      OLD.import_id,
      OLD.update_import_id,
      OLD.deleted,
      OLD.created,
      OLD.updated
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

/*
  student_ethnicity triggers
*/

CREATE TABLE audit_student_ethnicity (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  action VARCHAR(8) NOT NULL,
  audited TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL,
  database_user VARCHAR(255) NOT NULL,
  ethnicity_id TINYINT NOT NULL,
  student_id INT NOT NULL,
  created TIMESTAMP(6) NOT NULL
);

-- update trigger
CREATE TRIGGER trg__student_ethnicity__update
BEFORE UPDATE ON student_ethnicity
FOR EACH ROW
  INSERT INTO audit_student_ethnicity (action, database_user, ethnicity_id, student_id, created)
    SELECT
      'update',
      USER(),
      OLD.ethnicity_id,
      OLD.student_id,
      OLD.created
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';


-- delete trigger
CREATE TRIGGER trg__student_ethnicity__delete
BEFORE DELETE ON student_ethnicity
FOR EACH ROW
  INSERT INTO audit_student_ethnicity (action, database_user, ethnicity_id, student_id, created)
    SELECT
      'delete',
      USER(),
      OLD.ethnicity_id,
      OLD.student_id,
      OLD.created
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';
