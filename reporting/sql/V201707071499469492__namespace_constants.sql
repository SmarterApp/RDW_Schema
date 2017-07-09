# add namespace column value constants for use in translation table.

USE ${schemaName};


# This creates a table that should have only 1 row.
CREATE TABLE IF NOT EXISTS namespace_constants (
  id enum('1') NOT NULL,
  backend varchar(7) NOT NULL,
  frontend varchar(8) NOT NULL,
  PRIMARY KEY (`id`)
) COMMENT='The ENUM(''1'') construct as primary key is used to prevent that more than one row can be entered to the table';

INSERT INTO namespace_constants VALUES ('1', 'backend', 'frontend');