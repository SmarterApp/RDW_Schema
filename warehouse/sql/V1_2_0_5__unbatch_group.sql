-- Student group import processing has been significantly changed.
--
-- BEFORE:
-- A record is created in upload_student_group_batch. This table is the record of upload events.
-- The raw CSV is loaded into upload_student_group. The upload_student_group_batch_progress and
-- upload_student_group_import tables are used for interim results and data manipulation. Also
-- during the process, import records are created to trigger migration.
--
-- AFTER:
-- A record is created in the import table. As for other data, this table is the record of import events.
-- The raw CSV is loaded into upload_student_group. All data manipulation happens directly in this table.
-- No additional import records are created (timestamps are used to distribute migration work).

USE ${schemaName};

-- copy successful batch upload records into the import table
-- this will allow users to see their old uploads
INSERT INTO import (status, content, contentType, digest, batch, creator, created, updated, message)
  SELECT status, 5, 'text/csv', digest, filename, creator, created, updated, message
  FROM upload_student_group_batch
  WHERE status = 1;

ALTER TABLE upload_student_group DROP COLUMN batch_id;

DROP TABLE upload_student_group_import;
DROP TABLE upload_student_group_import_ref_type;
DROP TABLE upload_student_group_batch_progress;
DROP TABLE upload_student_group_batch;

ALTER TABLE import
  ADD INDEX idx__import__content_creator_contentType (creator, content, contentType);