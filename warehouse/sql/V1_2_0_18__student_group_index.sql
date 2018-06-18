-- add indexes to support student group processing
use ${schemaName};

ALTER TABLE student ADD INDEX idx__student__deleted(deleted);

ALTER TABLE upload_student_group  ADD INDEX idx__upload_student_group__import_group_student(import_id, group_id, student_id);

-- Please remove (from awsdev) the following indices (MySQL 5.6 doesn't support IF EXISTS for this):
-- DROP INDEX idx_student_alla ON student;
-- DROP INDEX idx_test_alla ON upload_student_group;


-- Please note that the V1_2_0_15 change to audit/exam_item making score and position nullable
-- should NOT be included in the consolidated script. But i'm not putting the reversal in here.