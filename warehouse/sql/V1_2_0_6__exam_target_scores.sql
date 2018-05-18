-- Add exam target scores
USE ${schemaName};

CREATE TABLE exam_target_score (
  id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  exam_id bigint NOT NULL,
  target_id smallint NOT NULL,
  student_relative_residual_score float,
  student_relative_residual_score_std_err float,
  standard_met_relative_residual_score float,
  standard_met_relative_residual_score_std_err float,
  performance_level tinyint,
  INDEX idx__exam_claim_score__exam (exam_id),
  UNIQUE INDEX idx__exam_target_score_exam_target (exam_id, target_id),
  CONSTRAINT fk__exam_target_score__exam FOREIGN KEY (exam_id) REFERENCES exam(id),
  CONSTRAINT fk__exam_target_score__target FOREIGN KEY (target_id) REFERENCES target(id)
);