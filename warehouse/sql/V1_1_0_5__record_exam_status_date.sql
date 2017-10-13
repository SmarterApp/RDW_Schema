-- Update exam table to record Opportunity statusDate attribute
-- Modify unique index to only include assessment id and opportunity id

USE ${schemaName};

ALTER TABLE exam
  ADD COLUMN status_date TIMESTAMP(6) DEFAULT NULL,
  DROP INDEX idx__exam__student_asmt_oppId,
  ADD UNIQUE INDEX idx__exam__oppId_asmt (oppId, asmt_id);

-- Update audit table and triggers
ALTER TABLE audit_exam
  ADD COLUMN status_date TIMESTAMP(6) DEFAULT NULL;

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
  VALUES
    (
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
      OLD.status_date);

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
  VALUES
    (
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
      OLD.status_date);
