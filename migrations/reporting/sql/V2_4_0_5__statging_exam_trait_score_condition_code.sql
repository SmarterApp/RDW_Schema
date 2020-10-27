-- v2.4.0_5 flyway script
--
-- widens exam_trait_score.condition_code to varchar(20)
-- previous script missed the staging_exam_trait_score table
--
use ${schemaName};

ALTER TABLE staging_exam_trait_score MODIFY COLUMN condition_code VARCHAR(20);
