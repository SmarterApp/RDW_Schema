-- Add the ability to enable and disable audit triggers
-- 1: create table to hold a trigger on/off switch
-- 2: sample turn on and off
-- 2: modify audit triggers to respect the on/off switch

USE ${schemaName};

/*
 Create the setting table that holds setting name and value pairs.
*/
CREATE TABLE setting (
  name VARCHAR(20),
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
  exam triggers
*/

-- UPDATE
DROP TRIGGER trg__exam__update;

CREATE TRIGGER trg__exam__update
BEFORE UPDATE ON exam
FOR EACH ROW
  INSERT INTO audit_exam (action, database_user, exam_id, type_id, school_year, asmt_id, asmt_version,
                          opportunity, oppId, completeness_id, administration_condition_id, session_id, scale_score,
                          scale_score_std_err, performance_level, completed_at, import_id, update_import_id, deleted,
                          created, updated, grade_id, student_id, school_id, iep, lep, section504,
                          economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type, language_code,
                          prim_disability_type, status_date)
  SELECT
      'update',
      USER(),
      OLD.id,
      OLD.type_id,
      OLD.school_year,
      OLD.asmt_id,
      OLD.asmt_version,
      OLD.opportunity,
      OLD.oppId,
      OLD.completeness_id,
      OLD.administration_condition_id,
      OLD.session_id,
      OLD.scale_score,
      OLD.scale_score_std_err,
      OLD.performance_level,
      OLD.completed_at,
      OLD.import_id,
      OLD.update_import_id,
      OLD.deleted,
      OLD.created,
      OLD.updated,
      OLD.grade_id,
      OLD.student_id,
      OLD.school_id,
      OLD.iep,
      OLD.lep,
      OLD.section504,
      OLD.economic_disadvantage,
      OLD.migrant_status,
      OLD.eng_prof_lvl,
      OLD.t3_program_type,
      OLD.language_code,
      OLD.prim_disability_type,
      OLD.status_date
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

-- DELETE
DROP TRIGGER trg__exam__delete;

CREATE TRIGGER trg__exam__delete
BEFORE DELETE ON exam
FOR EACH ROW
  INSERT INTO audit_exam (action, database_user, exam_id, type_id, school_year, asmt_id, asmt_version,
                          opportunity, oppId, completeness_id, administration_condition_id, session_id, scale_score,
                          scale_score_std_err, performance_level, completed_at, import_id, update_import_id, deleted,
                          created, updated, grade_id, student_id, school_id, iep, lep, section504,
                          economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type, language_code,
                          prim_disability_type, status_date)
  SELECT
      'delete',
      USER(),
      OLD.id,
      OLD.type_id,
      OLD.school_year,
      OLD.asmt_id,
      OLD.asmt_version,
      OLD.opportunity,
      OLD.oppId,
      OLD.completeness_id,
      OLD.administration_condition_id,
      OLD.session_id,
      OLD.scale_score,
      OLD.scale_score_std_err,
      OLD.performance_level,
      OLD.completed_at,
      OLD.import_id,
      OLD.update_import_id,
      OLD.deleted,
      OLD.created,
      OLD.updated,
      OLD.grade_id,
      OLD.student_id,
      OLD.school_id,
      OLD.iep,
      OLD.lep,
      OLD.section504,
      OLD.economic_disadvantage,
      OLD.migrant_status,
      OLD.eng_prof_lvl,
      OLD.t3_program_type,
      OLD.language_code,
      OLD.prim_disability_type,
      OLD.status_date
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

/*
  exam_claim_score audit triggers
*/

-- UPDATE
DROP TRIGGER trg__exam_claim_score__update;

CREATE TRIGGER trg__exam_claim_score__update
BEFORE UPDATE ON exam_claim_score
FOR EACH ROW
  INSERT INTO audit_exam_claim_score (
    action, database_user, exam_claim_score_id, exam_id, subject_claim_score_id, scale_score, scale_score_std_err, category
  )
  SELECT
      'update',
      USER(),
      OLD.id,
      OLD.exam_id,
      OLD.subject_claim_score_id,
      OLD.scale_score,
      OLD.scale_score_std_err,
      OLD.category
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

-- DELETE
DROP TRIGGER trg__exam_claim_score__delete;

CREATE TRIGGER trg__exam_claim_score__delete
BEFORE DELETE ON exam_claim_score
FOR EACH ROW
  INSERT INTO audit_exam_claim_score (
    action, database_user, exam_claim_score_id, exam_id, subject_claim_score_id, scale_score, scale_score_std_err, category
  )
  SELECT
      'delete',
      USER(),
      OLD.id,
      OLD.exam_id,
      OLD.subject_claim_score_id,
      OLD.scale_score,
      OLD.scale_score_std_err,
      OLD.category
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

/*
  exam_available_accommodation audit triggers
*/

-- UPDATE
DROP TRIGGER trg__exam_available_accommodation__update;

CREATE TRIGGER trg__exam_available_accommodation__update
BEFORE UPDATE ON exam_available_accommodation
FOR EACH ROW
  INSERT INTO audit_exam_available_accommodation (
    action, database_user, exam_id, accommodation_id
  )
  SELECT
      'update',
      USER(),
      OLD.exam_id,
      OLD.accommodation_id
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

-- DELETE
DROP TRIGGER trg__exam_available_accommodation__delete;

CREATE TRIGGER trg__exam_available_accommodation__delete
BEFORE DELETE ON exam_available_accommodation
FOR EACH ROW
  INSERT INTO audit_exam_available_accommodation (
    action, database_user, exam_id, accommodation_id
  )
  SELECT
      'delete',
      USER(),
      OLD.exam_id,
      OLD.accommodation_id
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

/*
  exam_item audit triggers
*/

-- UPDATE
DROP TRIGGER trg__exam_item__update;

CREATE TRIGGER trg__exam_item__update
BEFORE UPDATE ON exam_item
FOR EACH ROW
  INSERT INTO audit_exam_item (
    action, database_user, exam_item_id, exam_id, item_id, score,
    score_status, position, response, trait_evidence_elaboration_score,
    trait_evidence_elaboration_score_status, trait_organization_purpose_score,
    trait_organization_purpose_score_status, trait_conventions_score, trait_conventions_score_status
  )
  SELECT
      'update',
      USER(),
      OLD.id,
      OLD.exam_id,
      OLD.item_id,
      OLD.score,
      OLD.score_status,
      OLD.position,
      OLD.response,
      OLD.trait_evidence_elaboration_score,
      OLD.trait_evidence_elaboration_score_status,
      OLD.trait_organization_purpose_score,
      OLD.trait_organization_purpose_score_status,
      OLD.trait_conventions_score,
      OLD.trait_conventions_score_status
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

-- DELETE
DROP TRIGGER trg__exam_item__delete;

CREATE TRIGGER trg__exam_item__delete
BEFORE DELETE ON exam_item
FOR EACH ROW
  INSERT INTO audit_exam_item (
    action, database_user, exam_item_id, exam_id, item_id, score,
    score_status, position, response, trait_evidence_elaboration_score,
    trait_evidence_elaboration_score_status, trait_organization_purpose_score,
    trait_organization_purpose_score_status, trait_conventions_score, trait_conventions_score_status
  )
  SELECT
      'delete',
      USER(),
      OLD.id,
      OLD.exam_id,
      OLD.item_id,
      OLD.score,
      OLD.score_status,
      OLD.position,
      OLD.response,
      OLD.trait_evidence_elaboration_score,
      OLD.trait_evidence_elaboration_score_status,
      OLD.trait_organization_purpose_score,
      OLD.trait_organization_purpose_score_status,
      OLD.trait_conventions_score,
      OLD.trait_conventions_score_status
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';



