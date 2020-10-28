-- v2.4.0_7 flyway script
--
-- widens exam_trait_score.condition_code to varchar(20)
--
use ${schemaName};

ALTER TABLE exam_trait_score MODIFY COLUMN condition_code VARCHAR(20);
