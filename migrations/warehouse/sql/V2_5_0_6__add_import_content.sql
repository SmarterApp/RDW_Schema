-- v2.5.0_6 flyway script
-- Add STUDENTS content to import_content table
use ${schemaName};

INSERT INTO import_content (id, name) VALUES (9, 'STUDENTS');
