/** Add accommodation translation tables to the database **/

USE ${schemaName};

CREATE TABLE IF NOT EXISTS language (
  id tinyint NOT NULL PRIMARY KEY,
  code varchar(3) NOT NULL UNIQUE
);

/** Accommodation Translations **/

CREATE TABLE IF NOT EXISTS accommodation_translation (
  accommodation_id smallint NOT NULL,
  language_id tinyint NOT NULL,
  label varchar(40) NOT NULL,
  CONSTRAINT uk__accommodation_id__language_id UNIQUE KEY (accommodation_id, language_id),
  CONSTRAINT fk__accommodation_translation__accommodation FOREIGN KEY (accommodation_id) REFERENCES accommodation(id),
  CONSTRAINT fk__accommodation_translation__language FOREIGN KEY (language_id) REFERENCES language(id)
);