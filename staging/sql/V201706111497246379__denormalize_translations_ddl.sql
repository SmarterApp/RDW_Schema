USE ${schemaName};

/****
**
**  Remove accommodation_translation table in favor of a more generic translation table
**  for UI items as well as full page reports
*****/

ALTER TABLE accommodation_translation RENAME TO translations;

ALTER TABLE translations ADD COLUMN namespace varchar(10) NOT NULL;
ALTER TABLE translations ADD COLUMN language_code varchar(3) NOT NULL;
ALTER TABLE translations ADD COLUMN content_code varchar(30) NOT NULL;

ALTER TABLE translations DROP COLUMN accommodation_id;
ALTER TABLE translations DROP COLUMN language_id;

/* remove unnecessary tables */

DROP TABLE accommodation;
DROP TABLE language;