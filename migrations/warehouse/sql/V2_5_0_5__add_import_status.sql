-- v2.5.0_5 flyway script
-- Add NO_UPDATE status to import_status table
use ${schemaName};

INSERT INTO import_status (id, name) VALUES (2, 'NO_UPDATE');
