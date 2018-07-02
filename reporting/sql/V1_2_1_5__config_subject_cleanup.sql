-- Remove unused columns
use ${schemaName};

ALTER TABLE depth_of_knowledge
    DROP COLUMN description;

ALTER TABLE claim
    DROP COLUMN name,
    DROP COLUMN description;

ALTER TABLE common_core_standard
    DROP COLUMN description;

ALTER TABLE subject_claim_score
    DROP COLUMN name;

ALTER TABLE target
   DROP COLUMN code,
   DROP COLUMN description,
   MODIFY COLUMN natural_id varchar(20) not null;

ALTER TABLE grade
   DROP COLUMN name;

ALTER TABLE asmt_type
   DROP COLUMN name;

ALTER TABLE item
   DROP COLUMN target_code,
   DROP COLUMN dok_level_subject_id;

-- Modify corresponding staging tables
ALTER TABLE staging_depth_of_knowledge
    DROP COLUMN description;

ALTER TABLE staging_claim
    DROP COLUMN name,
    DROP COLUMN description;

ALTER TABLE staging_common_core_standard
    DROP COLUMN description;

ALTER TABLE staging_subject_claim_score
    DROP COLUMN name;

ALTER TABLE staging_target
    DROP COLUMN code,
    DROP COLUMN description,
    MODIFY COLUMN natural_id varchar(20) not null;

ALTER TABLE staging_grade
    DROP COLUMN name;