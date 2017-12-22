-- Consolidated script for v1.0 -> v1.1 audit tables.
--
-- These are all new tables.

USE ${schemaName};

/*
 Create the setting table that holds setting name and value pairs.
*/
CREATE TABLE setting (
  name VARCHAR(20) NOT NULL PRIMARY KEY,
  value VARCHAR(100),
  updated timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6)
);


/*
 Insert the setting row for AUDIT_TRIGGER_ENABLE with the initial value to enable audit triggers.
 When enabled, audit triggers will insert to audit tables.
 When not enabled audit triggers will not insert to audit tables.
 Disable audit triggers with: UPDATE setting s SET s.value = 'FALSE' WHERE s.name = 'AUDIT_TRIGGER_ENABLE';
 Enable audit triggers with:  UPDATE setting s SET s.value = 'TRUE' WHERE s.name = 'AUDIT_TRIGGER_ENABLE';
*/
INSERT INTO setting (name, value) VALUES ('AUDIT_TRIGGER_ENABLE', 'TRUE');

/*
  exam audit table and triggers
  exam can be updated
*/

CREATE TABLE IF NOT EXISTS audit_exam (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  action VARCHAR(8) NOT NULL,
  audited TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL,
  database_user VARCHAR(255) NOT NULL,
  exam_id BIGINT NOT NULL,
  type_id TINYINT NOT NULL,
  school_year SMALLINT(6) NOT NULL,
  asmt_id INT NOT NULL,
  asmt_version VARCHAR(30) NULL,
  opportunity INT NULL,
  oppId VARCHAR(60) NULL,
  completeness_id TINYINT NOT NULL,
  administration_condition_id TINYINT NOT NULL,
  session_id VARCHAR(128) NOT NULL,
  scale_score FLOAT NULL,
  scale_score_std_err FLOAT NULL,
  performance_level TINYINT NULL,
  completed_at TIMESTAMP NOT NULL,
  import_id BIGINT NOT NULL,
  update_import_id BIGINT NOT NULL,
  deleted TINYINT NOT NULL,
  created TIMESTAMP(6) NOT NULL,
  updated TIMESTAMP(6) NOT NULL,
  grade_id TINYINT NOT NULL,
  student_id INT NOT NULL,
  school_id INT NOT NULL,
  iep TINYINT NOT NULL,
  lep TINYINT NOT NULL,
  section504 TINYINT NULL,
  economic_disadvantage TINYINT NOT NULL,
  migrant_status TINYINT NULL,
  eng_prof_lvl VARCHAR(20) NULL,
  t3_program_type VARCHAR(30) NULL,
  language_code VARCHAR(3) NULL,
  prim_disability_type VARCHAR(3) NULL,
  status_date TIMESTAMP(6),
  examinee_id bigint,
  deliver_mode varchar(10),
  hand_score_project int,
  contract varchar(100),
  test_reason varchar(255),
  assessment_admin_started_at date,
  started_at timestamp(6),
  force_submitted_at timestamp(6),
  status varchar(50),
  item_count smallint,
  field_test_count smallint,
  pause_count  smallint, --
  grace_period_restarts smallint,
  abnormal_starts smallint,
  test_window_id varchar(50),
  test_administrator_id varchar(128),
  responsible_organization_name varchar(60),
  test_administrator_name varchar(128),
  session_platform_user_agent varchar(512),
  test_delivery_server varchar(128),
  test_delivery_db varchar(128),
  window_opportunity_count varchar(8),
  theta_score float,
  theta_score_std_err float
);

CREATE TRIGGER trg__exam__update
BEFORE UPDATE ON exam
FOR EACH ROW
  INSERT INTO audit_exam (action, database_user, exam_id, type_id, school_year, asmt_id, asmt_version,
                          opportunity, oppId, completeness_id, administration_condition_id, session_id, scale_score,
                          scale_score_std_err, performance_level, completed_at, import_id, update_import_id, deleted,
                          created, updated, grade_id, student_id, school_id, iep, lep, section504,
                          economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type, language_code,
                          prim_disability_type, status_date,
                          examinee_id, deliver_mode, hand_score_project, contract, test_reason,
                          assessment_admin_started_at, started_at, force_submitted_at, status,
                          item_count, field_test_count, pause_count, grace_period_restarts, abnormal_starts,
                          test_window_id, test_administrator_id, responsible_organization_name, test_administrator_name,
                          session_platform_user_agent, test_delivery_server, test_delivery_db, window_opportunity_count,
                          theta_score, theta_score_std_err)
    SELECT 'update', USER(), OLD.id, OLD.type_id, OLD.school_year, OLD.asmt_id, OLD.asmt_version,
      OLD.opportunity, OLD.oppId, OLD.completeness_id, OLD.administration_condition_id, OLD.session_id, OLD.scale_score,
      OLD.scale_score_std_err, OLD.performance_level, OLD.completed_at, OLD.import_id, OLD.update_import_id, OLD.deleted,
      OLD.created, OLD.updated, OLD.grade_id, OLD.student_id, OLD.school_id, OLD.iep, OLD.lep, OLD.section504,
      OLD.economic_disadvantage, OLD.migrant_status, OLD.eng_prof_lvl, OLD.t3_program_type, OLD.language_code,
      OLD.prim_disability_type, OLD.status_date,
      OLD.examinee_id, OLD.deliver_mode, OLD.hand_score_project, OLD.contract, OLD.test_reason,
      OLD.assessment_admin_started_at, OLD.started_at, OLD.force_submitted_at, OLD.status,
      OLD.item_count, OLD.field_test_count, OLD.pause_count, OLD.grace_period_restarts, OLD.abnormal_starts,
      OLD.test_window_id, OLD.test_administrator_id, OLD.responsible_organization_name, OLD.test_administrator_name,
      OLD.session_platform_user_agent, OLD.test_delivery_server, OLD.test_delivery_db, OLD.window_opportunity_count,
      OLD.theta_score, OLD.theta_score_std_err
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

CREATE TRIGGER trg__exam__delete
BEFORE DELETE ON exam
FOR EACH ROW
  INSERT INTO audit_exam (action, database_user, exam_id, type_id, school_year, asmt_id, asmt_version,
                          opportunity, oppId, completeness_id, administration_condition_id, session_id, scale_score,
                          scale_score_std_err, performance_level, completed_at, import_id, update_import_id, deleted,
                          created, updated, grade_id, student_id, school_id, iep, lep, section504,
                          economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type, language_code,
                          prim_disability_type, status_date,
                          examinee_id, deliver_mode, hand_score_project, contract, test_reason,
                          assessment_admin_started_at, started_at, force_submitted_at, status,
                          item_count, field_test_count, pause_count, grace_period_restarts, abnormal_starts,
                          test_window_id, test_administrator_id, responsible_organization_name, test_administrator_name,
                          session_platform_user_agent, test_delivery_server, test_delivery_db, window_opportunity_count,
                          theta_score, theta_score_std_err)
    SELECT 'delete', USER(), OLD.id, OLD.type_id, OLD.school_year, OLD.asmt_id, OLD.asmt_version,
      OLD.opportunity, OLD.oppId, OLD.completeness_id, OLD.administration_condition_id, OLD.session_id, OLD.scale_score,
      OLD.scale_score_std_err, OLD.performance_level, OLD.completed_at, OLD.import_id, OLD.update_import_id, OLD.deleted,
      OLD.created, OLD.updated, OLD.grade_id, OLD.student_id, OLD.school_id, OLD.iep, OLD.lep, OLD.section504,
      OLD.economic_disadvantage, OLD.migrant_status, OLD.eng_prof_lvl, OLD.t3_program_type, OLD.language_code,
      OLD.prim_disability_type, OLD.status_date,
      OLD.examinee_id, OLD.deliver_mode, OLD.hand_score_project, OLD.contract, OLD.test_reason,
      OLD.assessment_admin_started_at, OLD.started_at, OLD.force_submitted_at, OLD.status,
      OLD.item_count, OLD.field_test_count, OLD.pause_count, OLD.grace_period_restarts, OLD.abnormal_starts,
      OLD.test_window_id, OLD.test_administrator_id, OLD.responsible_organization_name, OLD.test_administrator_name,
      OLD.session_platform_user_agent, OLD.test_delivery_server, OLD.test_delivery_db, OLD.window_opportunity_count,
      OLD.theta_score, OLD.theta_score_std_err
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

/*
  exam_claim_score audit table and triggers
  exam_claim_score can be updated
*/

CREATE TABLE IF NOT EXISTS audit_exam_claim_score (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  action VARCHAR(8) NOT NULL,
  audited TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL,
  database_user VARCHAR(255) NOT NULL,
  exam_claim_score_id BIGINT NOT NULL,
  exam_id BIGINT NOT NULL,
  subject_claim_score_id SMALLINT(6) NOT NULL,
  scale_score FLOAT NULL,
  scale_score_std_err FLOAT NULL,
  category TINYINT NULL,
  theta_score float,
  theta_score_std_err float,
  created TIMESTAMP(6) NOT NULL
);

CREATE TRIGGER trg__exam_claim_score__update
BEFORE UPDATE ON exam_claim_score
FOR EACH ROW
  INSERT INTO audit_exam_claim_score (action, database_user, exam_claim_score_id, exam_id, subject_claim_score_id,
                                      scale_score, scale_score_std_err, category, theta_score, theta_score_std_err, created)
    SELECT 'update', USER(), OLD.id, OLD.exam_id, OLD.subject_claim_score_id,
      OLD.scale_score, OLD.scale_score_std_err, OLD.category, OLD.theta_score, OLD.theta_score_std_err, OLD.created
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

CREATE TRIGGER trg__exam_claim_score__delete
BEFORE DELETE ON exam_claim_score
FOR EACH ROW
  INSERT INTO audit_exam_claim_score (action, database_user, exam_claim_score_id, exam_id, subject_claim_score_id,
                                      scale_score, scale_score_std_err, category, theta_score, theta_score_std_err, created)
    SELECT 'delete', USER(), OLD.id, OLD.exam_id, OLD.subject_claim_score_id,
      OLD.scale_score, OLD.scale_score_std_err, OLD.category, OLD.theta_score, OLD.theta_score_std_err, OLD.created
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

/*
  exam_available_accommodation audit table and triggers
  exam_available_accommodation can be deleted
*/

CREATE TABLE IF NOT EXISTS audit_exam_available_accommodation (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  action VARCHAR(8) NOT NULL,
  audited TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL,
  database_user VARCHAR(255) NOT NULL,
  exam_id BIGINT NOT NULL,
  accommodation_id SMALLINT(6) NOT NULL,
  created TIMESTAMP(6) NOT NULL
);

CREATE TRIGGER trg__exam_available_accommodation__update
BEFORE UPDATE ON exam_available_accommodation
FOR EACH ROW
  INSERT INTO audit_exam_available_accommodation (action, database_user, exam_id, accommodation_id, created)
    SELECT 'update', USER(), OLD.exam_id, OLD.accommodation_id, OLD.created
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

CREATE TRIGGER trg__exam_available_accommodation__delete
BEFORE DELETE ON exam_available_accommodation
FOR EACH ROW
  INSERT INTO audit_exam_available_accommodation (action, database_user, exam_id, accommodation_id, created)
    SELECT 'delete', USER(), OLD.exam_id, OLD.accommodation_id, OLD.created
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

/*
  exam_item audit table and triggers
  exam_item can be updated and deleted
*/

CREATE TABLE IF NOT EXISTS audit_exam_item (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  action VARCHAR(8) NOT NULL,
  audited TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL,
  database_user VARCHAR(255) NOT NULL,
  exam_item_id BIGINT NOT NULL,
  exam_id BIGINT NOT NULL,
  item_id INT NOT NULL,
  score FLOAT NOT NULL,
  score_status VARCHAR(50) NULL,
  position SMALLINT(6) NOT NULL,
  response TEXT NULL,
  trait_evidence_elaboration_score FLOAT NULL,
  trait_evidence_elaboration_score_status VARCHAR(50) NULL,
  trait_organization_purpose_score FLOAT NULL,
  trait_organization_purpose_score_status VARCHAR(50) NULL,
  trait_conventions_score FLOAT NULL,
  trait_conventions_score_status VARCHAR(50) NULL,
  administered_at timestamp(6),
  submitted tinyint,
  submitted_at timestamp(6),
  number_of_visits smallint,
  response_duration float,
  response_content_type varchar(50),
  page_number smallint,
  page_visits smallint,
  page_time int,
  response_type_id tinyint,
  created TIMESTAMP(6) NOT NULL
);

CREATE TRIGGER trg__exam_item__update
BEFORE UPDATE ON exam_item
FOR EACH ROW
  INSERT INTO audit_exam_item (action, database_user, exam_item_id, exam_id, item_id, score, score_status, position,
                               response, trait_evidence_elaboration_score, trait_evidence_elaboration_score_status,
                               trait_organization_purpose_score, trait_organization_purpose_score_status,
                               trait_conventions_score, trait_conventions_score_status,
                               administered_at, submitted, submitted_at, number_of_visits, response_duration,
                               response_content_type, page_number, page_visits, page_time, response_type_id, created)
    SELECT 'update', USER(), OLD.id, OLD.exam_id, OLD.item_id, OLD.score, OLD.score_status, OLD.position,
      OLD.response, OLD.trait_evidence_elaboration_score, OLD.trait_evidence_elaboration_score_status,
      OLD.trait_organization_purpose_score, OLD.trait_organization_purpose_score_status,
      OLD.trait_conventions_score, OLD.trait_conventions_score_status,
      OLD.administered_at, OLD.submitted, OLD.submitted_at, OLD.number_of_visits, OLD.response_duration,
      OLD.response_content_type, OLD.page_number, OLD.page_visits, OLD.page_time, OLD.response_type_id, OLD.created
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

CREATE TRIGGER trg__exam_item__delete
BEFORE DELETE ON exam_item
FOR EACH ROW
  INSERT INTO audit_exam_item (action, database_user, exam_item_id, exam_id, item_id, score, score_status, position,
                               response, trait_evidence_elaboration_score, trait_evidence_elaboration_score_status,
                               trait_organization_purpose_score, trait_organization_purpose_score_status,
                               trait_conventions_score, trait_conventions_score_status,
                               administered_at, submitted, submitted_at, number_of_visits, response_duration,
                               response_content_type, page_number, page_visits, page_time, response_type_id, created)
    SELECT 'delete', USER(), OLD.id, OLD.exam_id, OLD.item_id, OLD.score, OLD.score_status, OLD.position,
      OLD.response, OLD.trait_evidence_elaboration_score, OLD.trait_evidence_elaboration_score_status,
      OLD.trait_organization_purpose_score, OLD.trait_organization_purpose_score_status,
      OLD.trait_conventions_score, OLD.trait_conventions_score_status,
      OLD.administered_at, OLD.submitted, OLD.submitted_at, OLD.number_of_visits, OLD.response_duration,
      OLD.response_content_type, OLD.page_number, OLD.page_visits, OLD.page_time, OLD.response_type_id, OLD.created
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';


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
  inferred_school_id INT,
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
                             gender_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, birthday,
                             inferred_school_id, import_id, update_import_id, deleted, created, updated)
    SELECT 'update', USER(), OLD.id, OLD.ssid, OLD.last_or_surname, OLD.first_name, OLD.middle_name,
      OLD.gender_id, OLD.first_entry_into_us_school_at, OLD.lep_entry_at, OLD.lep_exit_at, OLD.birthday,
      OLD.inferred_school_id,OLD.import_id, OLD.update_import_id, OLD.deleted, OLD.created, OLD.updated
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

-- delete trigger
CREATE TRIGGER trg__student__delete
BEFORE DELETE ON student
FOR EACH ROW
  INSERT INTO audit_student (action, database_user, student_id, ssid, last_or_surname, first_name, middle_name,
                             gender_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, birthday,
                             inferred_school_id, import_id, update_import_id, deleted, created, updated)
    SELECT 'delete', USER(), OLD.id, OLD.ssid, OLD.last_or_surname, OLD.first_name, OLD.middle_name,
      OLD.gender_id, OLD.first_entry_into_us_school_at, OLD.lep_entry_at, OLD.lep_exit_at, OLD.birthday,
      OLD.import_id, OLD.update_import_id, OLD.deleted, OLD.created, OLD.updated
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

CREATE TRIGGER trg__student_ethnicity__update
BEFORE UPDATE ON student_ethnicity
FOR EACH ROW
  INSERT INTO audit_student_ethnicity (action, database_user, ethnicity_id, student_id, created)
    SELECT 'update', USER(), OLD.ethnicity_id, OLD.student_id, OLD.created
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

CREATE TRIGGER trg__student_ethnicity__delete
BEFORE DELETE ON student_ethnicity
FOR EACH ROW
  INSERT INTO audit_student_ethnicity (action, database_user, ethnicity_id, student_id, created)
    SELECT 'delete', USER(), OLD.ethnicity_id, OLD.student_id, OLD.created
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';


CREATE TABLE audit_student_group (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  action VARCHAR(8) NOT NULL,
  audited TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL,
  database_user VARCHAR(255) NOT NULL,
  student_group_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  school_id INT NOT NULL,
  school_year SMALLINT(6) NOT NULL,
  subject_id TINYINT NULL,
  active TINYINT NOT NULL,
  creator VARCHAR(250) NULL,
  import_id BIGINT NOT NULL,
  update_import_id BIGINT NOT NULL,
  deleted TINYINT NOT NULL,
  created TIMESTAMP(6) NOT NULL,
  updated TIMESTAMP(6) NOT NULL
);

CREATE TRIGGER trg__student_group__update
BEFORE UPDATE ON student_group
FOR EACH ROW
  INSERT INTO audit_student_group (action, database_user, student_group_id, name, school_id, school_year, subject_id,
                                   active, creator, import_id, update_import_id, deleted, created, updated)
    SELECT 'update', USER(), OLD.id, OLD.name, OLD.school_id, OLD.school_year, OLD.subject_id,
      OLD.active, OLD.creator, OLD.import_id, OLD.update_import_id, OLD.deleted, OLD.created, OLD.updated
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

CREATE TRIGGER trg__student_group__delete
BEFORE DELETE ON student_group
FOR EACH ROW
  INSERT INTO audit_student_group (action, database_user, student_group_id, name, school_id, school_year, subject_id,
                                   active, creator, import_id, update_import_id, deleted, created, updated)
    SELECT 'delete', USER(), OLD.id, OLD.name, OLD.school_id, OLD.school_year, OLD.subject_id,
      OLD.active, OLD.creator, OLD.import_id, OLD.update_import_id, OLD.deleted, OLD.created, OLD.updated
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';


CREATE TABLE audit_student_group_membership (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  action VARCHAR(8) NOT NULL,
  audited TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL,
  database_user VARCHAR(255) NOT NULL,
  student_group_id INT NOT NULL,
  student_id INT NOT NULL,
  created TIMESTAMP(6) NOT NULL
);

CREATE TRIGGER trg__student_group_membership__update
BEFORE UPDATE ON student_group_membership
FOR EACH ROW
  INSERT INTO audit_student_group_membership (action, database_user, student_group_id, student_id, created)
    SELECT 'update', USER(), OLD.student_group_id, OLD.student_id, OLD.created
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

CREATE TRIGGER trg__student_group_membership__delete
BEFORE DELETE ON student_group_membership
FOR EACH ROW
  INSERT INTO audit_student_group_membership (action, database_user, student_group_id, student_id, created)
    SELECT 'delete', USER(), OLD.student_group_id, OLD.student_id, OLD.created
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';


CREATE TABLE audit_user_student_group (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  action VARCHAR(8) NOT NULL,
  audited TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL,
  database_user VARCHAR(255) NOT NULL,
  student_group_id INT NOT NULL,
  user_login VARCHAR(255) NOT NULL,
  created TIMESTAMP(6) NOT NULL
);

CREATE TRIGGER trg__user_student_group__update
BEFORE UPDATE ON user_student_group
FOR EACH ROW
  INSERT INTO audit_user_student_group (action, database_user, student_group_id, user_login, created)
    SELECT 'update', USER(), OLD.student_group_id, OLD.user_login, OLD.created
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

CREATE TRIGGER trg__user_student_group__delete
BEFORE DELETE ON user_student_group
FOR EACH ROW
  INSERT INTO audit_user_student_group (action, database_user, student_group_id, user_login, created)
    SELECT 'delete', USER(), OLD.student_group_id, OLD.user_login, OLD.created
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';