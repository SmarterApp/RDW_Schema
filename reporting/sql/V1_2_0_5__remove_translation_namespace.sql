-- Remove the `namespace` column from the translation table since we no longer
-- require or respect it in the reporting application.

use ${schemaName};

-- Create the new translation table
CREATE TABLE new_translation (
  label_code VARCHAR(128),
  language_code VARCHAR(3),
  label text,
  PRIMARY KEY (language_code, label_code)
);

-- Migrate existing translations into new table
INSERT INTO new_translation (label_code, language_code, label)
  SELECT
    label_code,
    language_code,
    label
  FROM translation;

DROP TABLE translation;
RENAME TABLE new_translation TO translation;

-- Remove the `namespace` column from the translation staging table.
ALTER TABLE staging_translation
  DROP COLUMN namespace;