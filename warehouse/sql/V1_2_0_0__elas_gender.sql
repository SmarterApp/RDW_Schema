-- Flyway script to add ELAS (English Language Acquisition Status) and unknown gender

USE ${schemaName};

INSERT INTO gender (id, code) VALUES
  (3, 'NonBinary');

CREATE TABLE IF NOT EXISTS elas (
  id tinyint NOT NULL PRIMARY KEY,
  code varchar(20) NOT NULL UNIQUE
);

INSERT INTO elas (id, code) VALUES
  (1, 'EO'),
  (2, 'EL'),
  (3, 'IFEP'),
  (4, 'RFEP'),
  (5, 'TBD');

ALTER TABLE exam
  MODIFY COLUMN lep TINYINT NULL,
  ADD COLUMN elas_id TINYINT NULL,
  -- ??? i don't see FKs for completeness_id or administration_condition_id, do we want these?
  ADD CONSTRAINT fk__exam__elas FOREIGN KEY (elas_id) REFERENCES elas(id);

#
# -- trigger a CODES migration
# -- NOTE: this just catches the
# INSERT INTO import(status, content, contentType, digest) VALUES
#   (1, 3, 'v1.2 update', 'v1.2 update');
