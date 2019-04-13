-- Modify translation label to be TEXT, i.e. no length limit

use ${schemaName};

ALTER TABLE staging_accommodation_translation
  MODIFY COLUMN label TEXT NOT NULL;
