-- v2.4.0.2 flyway script
--
-- remove trait code from reporting (it is used only during warehouse ingest)

use ${schemaName};

ALTER TABLE subject_trait
    DROP INDEX idx__subject_trait__subject_code,
    DROP COLUMN code;

ALTER TABLE staging_subject_trait
    DROP COLUMN code;
