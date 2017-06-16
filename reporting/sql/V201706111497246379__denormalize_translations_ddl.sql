USE ${schemaName};

/****
**
**  Remove accommodation_translation table in favor of a more generic translation table
**  for UI items as well as full page reports
*****/

ALTER TABLE accommodation_translation RENAME TO translations;

ALTER TABLE translations ADD COLUMN namespace varchar(10);
ALTER TABLE translations ADD COLUMN language_code varchar(3);
ALTER TABLE translations ADD COLUMN content_code varchar(30);

UPDATE translations t
  JOIN (accommodation AS a, language AS l) ON t.accommodation_id = a.id AND t.language_id=l.id
 SET t.namespace = "backend", t.content_code = a.code, t.language_code = l.code;


ALTER TABLE translations DROP FOREIGN KEY fk__accommodation_translation__accommodation;
ALTER TABLE translations DROP FOREIGN KEY fk__accommodation_translation__language;
ALTER TABLE translations DROP KEY uk__accommodation_id__language_id;

ALTER TABLE translations DROP COLUMN accommodation_id;
ALTER TABLE translations DROP COLUMN language_id;

ALTER TABLE translations ADD CONSTRAINT uk__content_code__language_code UNIQUE KEY (namespace, content_code, language_code);

ALTER TABLE translations MODIFY COLUMN namespace varchar(10) NOT NULL;
ALTER TABLE translations MODIFY COLUMN language_code varchar(3) NOT NULL;
ALTER TABLE translations MODIFY COLUMN content_code varchar(30) NOT NULL;

DROP TABLE language;