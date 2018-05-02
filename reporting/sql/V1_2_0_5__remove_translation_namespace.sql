-- Remove the `namespace` column from the translation table since we no longer
-- require or respect it in the reporting application.

use ${schemaName};

ALTER TABLE translation
  DROP PRIMARY KEY,
  ADD PRIMARY KEY(language_code, label_code),
  DROP COLUMN namespace;

-- Remove the `namespace` column from the translation staging table.
ALTER TABLE staging_translation
  DROP COLUMN namespace;