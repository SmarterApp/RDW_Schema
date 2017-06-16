USE ${schemaName};

/****
**
**  Remove accommodation_translation table in favor of a more generic translation table
**  for UI items as well as full page reports
*****/

ALTER TABLE staging_accommodation_translation RENAME TO staging_translations;

ALTER TABLE staging_translations ADD COLUMN namespace varchar(10) NOT NULL;
ALTER TABLE staging_translations ADD COLUMN language_code varchar(3) NOT NULL;
ALTER TABLE staging_translations ADD COLUMN content_code varchar(30) NOT NULL;

ALTER TABLE staging_translations DROP COLUMN accommodation_id;
ALTER TABLE staging_translations DROP COLUMN language_id;

DROP TABLE staging_language;