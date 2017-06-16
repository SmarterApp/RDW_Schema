USE ${schemaName};

/****
**
**  Remove accommodation_translation table in favor of a more generic translation table
**  for UI items as well as full page reports
*****/

ALTER TABLE accommodation_translation RENAME TO translation;

ALTER TABLE translation ADD COLUMN namespace varchar(10);
ALTER TABLE translation ADD COLUMN language_code varchar(3);
ALTER TABLE translation ADD COLUMN label_code varchar(128);

UPDATE translation t
  JOIN (accommodation AS a, language AS l) ON t.accommodation_id = a.id AND t.language_id=l.id
 SET t.namespace = "backend", t.label_code = a.code, t.language_code = l.code;


ALTER TABLE translation DROP FOREIGN KEY fk__accommodation_translation__accommodation;
ALTER TABLE translation DROP FOREIGN KEY fk__accommodation_translation__language;
ALTER TABLE translation DROP KEY uk__accommodation_id__language_id;

ALTER TABLE translation DROP COLUMN accommodation_id;
ALTER TABLE translation DROP COLUMN language_id;

ALTER TABLE translation ADD CONSTRAINT uk__label_code__language_code UNIQUE KEY (namespace, label_code, language_code);

ALTER TABLE translation MODIFY COLUMN namespace varchar(10) NOT NULL;
ALTER TABLE translation MODIFY COLUMN language_code varchar(3) NOT NULL;
ALTER TABLE translation MODIFY COLUMN label_code varchar(128) NOT NULL;

DROP TABLE language;