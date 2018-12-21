-- Add target_report flag to subject assessment type

USE ${schemaName};

-- add without constraint, set default values, add constraint
ALTER TABLE subject_asmt_type ADD COLUMN target_report tinyint;
UPDATE subject_asmt_type SET target_report = IF(asmt_type_id = 3, 1, 0);
ALTER TABLE subject_asmt_type MODIFY COLUMN target_report tinyint NOT NULL;

ALTER TABLE staging_subject_asmt_type ADD COLUMN target_report tinyint NOT NULL;
