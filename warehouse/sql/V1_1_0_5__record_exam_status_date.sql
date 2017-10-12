-- Update exam table to record Opportunity statusDate attribute
-- Modify unique index to only include assessment id and opportunity id

USE ${schemaName};

ALTER TABLE exam
  ADD COLUMN status_date TIMESTAMP(6) DEFAULT NULL,
  DROP INDEX idx__exam__student_asmt_oppId,
  ADD UNIQUE INDEX idx__exam__asmt_oppId (asmt_id, oppId);
