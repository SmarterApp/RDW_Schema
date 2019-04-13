-- Modify translation label to be TEXT, i.e. no length limit

use ${schemaName};

ALTER TABLE accommodation_translation
  MODIFY COLUMN label TEXT NOT NULL;
