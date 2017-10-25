-- Replace the UNIQUE INDEX on the translation table with a primary key

USE ${schemaName};

CREATE TABLE translation_temp (
  namespace varchar(10) NOT NULL,
  label_code varchar(128) NOT NULL,
  language_code varchar(3) NOT NULL,
  label text,
  PRIMARY KEY (namespace, label_code, language_code)
);

INSERT INTO translation_temp (namespace, label_code, language_code, label)
  SELECT namespace, label_code, language_code, label
  FROM translation;

DROP TABLE translation;

RENAME TABLE translation_temp TO translation;