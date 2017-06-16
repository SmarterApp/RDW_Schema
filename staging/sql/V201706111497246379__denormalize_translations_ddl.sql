USE ${schemaName};

/****
**
**  Remove accommodation_translation table in favor of a more generic translation table
**  for UI items as well as full page reports
*****/

ALTER TABLE staging_accommodation_translation RENAME TO staging_translation;

ALTER TABLE staging_translation ADD COLUMN namespace varchar(10) NOT NULL;
ALTER TABLE staging_translation ADD COLUMN language_code varchar(3) NOT NULL;
ALTER TABLE staging_translation ADD COLUMN label_code varchar(128) NOT NULL;

ALTER TABLE staging_translation DROP COLUMN accommodation_id;
ALTER TABLE staging_translation DROP COLUMN language_id;

DROP TABLE staging_language;