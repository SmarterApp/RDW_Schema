-- Drop std_err columns from target score table, they will never be populated

USE ${schemaName};

ALTER TABLE exam_target_score
    DROP COLUMN student_relative_residual_score_std_err,
    DROP COLUMN standard_met_relative_residual_score_std_err;

ALTER TABLE audit_exam_target_score
    DROP COLUMN student_relative_residual_score_std_err,
    DROP COLUMN standard_met_relative_residual_score_std_err;

DROP TRIGGER trg__exam_target_score__update;
CREATE TRIGGER trg__exam_target_score__update
    BEFORE UPDATE ON exam_target_score
    FOR EACH ROW
    INSERT INTO audit_exam_target_score (action, database_user, exam_target_score_id, exam_id, target_id,
                                         student_relative_residual_score, standard_met_relative_residual_score)
        SELECT 'update', USER(), OLD.id, OLD.exam_id, OLD.target_id,
            OLD.student_relative_residual_score, OLD.standard_met_relative_residual_score
        FROM setting s
        WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

DROP TRIGGER trg__exam_target_score__delete;
CREATE TRIGGER trg__exam_target_score__delete
    BEFORE DELETE ON exam_target_score
    FOR EACH ROW
    INSERT INTO audit_exam_target_score (action, database_user, exam_target_score_id, exam_id, target_id,
                                         student_relative_residual_score, standard_met_relative_residual_score)
        SELECT 'delete', USER(), OLD.id, OLD.exam_id, OLD.target_id,
            OLD.student_relative_residual_score, OLD.standard_met_relative_residual_score
        FROM setting s
        WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';
