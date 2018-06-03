-- Add audit table/triggers for exam target score

USE ${schemaName};

/*
  exam_target_score audit table and triggers
  exam_target_score can be updated
*/

CREATE TABLE IF NOT EXISTS audit_exam_target_score (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  action VARCHAR(8) NOT NULL,
  audited TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL,
  database_user VARCHAR(255) NOT NULL,
  exam_target_score_id BIGINT NOT NULL,
  exam_id BIGINT NOT NULL,
  target_id SMALLINT NOT NULL,
  student_relative_residual_score FLOAT,
  student_relative_residual_score_std_err FLOAT,
  standard_met_relative_residual_score FLOAT,
  standard_met_relative_residual_score_std_err FLOAT
);

CREATE TRIGGER trg__exam_target_score__update
  BEFORE UPDATE ON exam_target_score
  FOR EACH ROW
  INSERT INTO audit_exam_target_score (action, database_user, exam_target_score_id, exam_id, target_id,
                                       student_relative_residual_score, student_relative_residual_score_std_err,
                                       standard_met_relative_residual_score, standard_met_relative_residual_score_std_err)
    SELECT 'update', USER(), OLD.id, OLD.exam_id, OLD.target_id,
      OLD.student_relative_residual_score, OLD.student_relative_residual_score_std_err,
      OLD.standard_met_relative_residual_score, OLD.standard_met_relative_residual_score_std_err
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

CREATE TRIGGER trg__exam_target_score__delete
  BEFORE DELETE ON exam_target_score
  FOR EACH ROW
  INSERT INTO audit_exam_target_score (action, database_user, exam_target_score_id, exam_id, target_id,
                                       student_relative_residual_score, student_relative_residual_score_std_err,
                                       standard_met_relative_residual_score, standard_met_relative_residual_score_std_err)
    SELECT 'delete', USER(), OLD.id, OLD.exam_id, OLD.target_id,
      OLD.student_relative_residual_score, OLD.student_relative_residual_score_std_err,
      OLD.standard_met_relative_residual_score, OLD.standard_met_relative_residual_score_std_err
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

