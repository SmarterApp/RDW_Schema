-- Migrate chunk counts for user reports from properties to metadata

USE ${schemaName};

INSERT INTO user_report_metadata (report_id, name, value)
  SELECT
    r.id,
    'total_chunk_count',
    CAST(r.total_chunk_count AS CHAR)
  FROM user_report r
  WHERE
    r.total_chunk_count > 0;

INSERT INTO user_report_metadata (report_id, name, value)
  SELECT
    r.id,
    'completed_chunk_count',
    CAST(r.complete_chunk_count AS CHAR)
  FROM user_report r
  WHERE
    r.total_chunk_count > 0;

ALTER TABLE user_report
  DROP COLUMN total_chunk_count,
  DROP COLUMN complete_chunk_count;


