-- Remove the `namespace` column from the translation table since we no longer
-- require or respect it in the reporting application.
-- Rename the existing reporting translation table to accommodation_translation
-- to denote that it only contains accommodation translation labels

use ${schemaName};

ALTER TABLE translation
  DROP PRIMARY KEY,
  ADD PRIMARY KEY(language_code, label_code),
  DROP COLUMN namespace;

-- Rename translation table to accommodation_translation
RENAME TABLE translation TO accommodation_translation;

-- Remove the `namespace` column from the translation staging table.
ALTER TABLE staging_translation
  DROP COLUMN namespace;

RENAME TABLE staging_translation TO staging_accommodation_translation;