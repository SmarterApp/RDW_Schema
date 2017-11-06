-- Change completed_at to have the same precision as other timestamps.

USE ${schemaName};

ALTER TABLE exam
  MODIFY COLUMN completed_at TIMESTAMP(6) NOT NULL;

ALTER TABLE staging_exam
  MODIFY COLUMN completed_at TIMESTAMP(6) NOT NULL;

