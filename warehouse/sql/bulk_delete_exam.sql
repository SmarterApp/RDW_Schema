-- ------------------------------------------------------------------------------------------------------------
-- IMPORTANT NOTE
-- ------------------------------------------------------------------------------------------------------------
-- This may create a large volume of data to process. It is highly advisable to run this during the maintenance
-- window and while the Exam Processor is stopped.
--
-- Validation script should be executed before and after this scrip to check data quality:
-- https://github.com/SmarterApp/RDW_Schema/validation-scripts
-- ------------------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------------------------
-- STEP 1: replace a placeholder below
SET @select_exam_ids = '{placeholder for query that identifies exams to be deleted}';
-- ------------------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------------------------
-- STEP 2 (optional): turn off auditing
-- ------------------------------------------------------------------------------------------------------------
SELECT value INTO @audit_setting FROM setting WHERE name = 'AUDIT_TRIGGER_ENABLE';
UPDATE setting SET value = 'FALSE' WHERE name = 'AUDIT_TRIGGER_ENABLE' AND value != 'FALSE';

-- ------------------------------------------------------------------------------------------------------------
-- STEP 3: initialization
-- ------------------------------------------------------------------------------------------------------------
-- define partition size
SET @partition_size = 1000000;

-- create a unique digest fo the bulk run
SELECT concat('bulk run ' COLLATE utf8_unicode_ci, now()) into @digest;

-- create a table to store the partition ids of the exams to be deleted
CREATE TABLE exam_delete_partition (
  exam_id BIGINT NOT NULL PRIMARY KEY,
  partition_id INT
);

-- create helper procedure to run partitions in a loop
DELIMITER //
CREATE PROCEDURE loop_by_partition(IN p_sql VARCHAR(1000), IN p_last INTEGER)
  BEGIN
    DECLARE iteration INTEGER;
    SET iteration = 0;

    partition_loop: LOOP
      SET @stmt = concat(p_sql, ' partition_id =', iteration);
      PREPARE stmt FROM @stmt;
      EXECUTE stmt;
      DEALLOCATE PREPARE stmt;
      SELECT concat('executed partition:', iteration);

      SET iteration = iteration + 1;
      IF iteration > p_last
        THEN LEAVE partition_loop;
      END IF;
    END LOOP partition_loop;

  END;
//
DELIMITER ;

-- ------------------------------------------------------------------------------------------------------------
-- STEP 4: load exams to be deleted
-- ------------------------------------------------------------------------------------------------------------
SET @load_exam_delete_partion = concat('INSERT IGNORE INTO exam_delete_partition (exam_id) ', @select_exam_ids);
PREPARE stmt FROM @load_exam_delete_partion;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ------------------------------------------------------------------------------------------------------------
-- STEP 5: partition exams to be process in chunks
-- ------------------------------------------------------------------------------------------------------------
SELECT ceil(count(*)/@partition_size) INTO @exam_partition_end FROM exam_delete_partition;
UPDATE exam_delete_partition SET partition_id = MOD(exam_id, @exam_partition_end);

-- ------------------------------------------------------------------------------------------------------------
-- STEP 6: create imports - one per exam
-- ------------------------------------------------------------------------------------------------------------
INSERT INTO import (status, content, contentType, digest, batch)
  SELECT 0, 1, 'bulk delete exams by ...', @digest, exam_id FROM exam_delete_partition;

-- ------------------------------------------------------------------------------------------------------------
-- STEP 7: soft-delete exams by partition
-- ------------------------------------------------------------------------------------------------------------
CALL loop_by_partition(
    'UPDATE exam e
      JOIN (SELECT id, cast(batch AS UNSIGNED) exam_id FROM import where digest = @digest AND status = 0) i ON e.id = i.exam_id
      JOIN exam_delete_partition p on p.exam_id = e.id
    SET
      e.deleted = 1,
      e.update_import_id = i.id
    WHERE ',
    @exam_partition_end);

-- ------------------------------------------------------------------------------------------------------------
-- STEP 8: prepare for migrate to pick it up
-- ------------------------------------------------------------------------------------------------------------
-- all exams in one partition have the same timestamp; this will overflow the reporting migrate
-- to address this we need to distribute the timestamps for the updated exams
SELECT max(id) INTO @maxImportId FROM import WHERE digest = @digest;

-- distribute imports timestamps for migrate to have smaller chunks
UPDATE import
SET
  created = DATE_ADD(created, INTERVAL (@maxImportId -id)  MICROSECOND),
  updated = DATE_ADD(updated, INTERVAL (@maxImportId -id)  MICROSECOND)
WHERE status = 0
      AND content = 1
      AND digest =  @digest;

-- update exams to match imports
UPDATE exam e
  JOIN import i ON i.id = e.update_import_id
SET
  e.updated = i.updated
WHERE i.status = 0
      AND content = 1
      AND digest = @digest;

-- update import status to release it for the migrate
UPDATE import
SET
  status = 1,
  updated = updated -- make sure to not reset the timestamp
WHERE status = 0
  AND content = 1
  AND digest = @digest;

-- ------------------------------------------------------------------------------------------------------------
-- STEP 9: clean up
-- ------------------------------------------------------------------------------------------------------------
DROP TABLE exam_delete_partition;
DROP PROCEDURE loop_by_partition;

-- ------------------------------------------------------------------------------------------------------------
-- STEP 10 (optional): turn auditing back on (if needed)
-- ------------------------------------------------------------------------------------------------------------
UPDATE setting SET value = @audit_setting WHERE name = 'AUDIT_TRIGGER_ENABLE' AND value != @audit_setting;
