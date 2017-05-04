/**
** 	Initial script for the SBAC Reporting Staging schema used during migration
**/

ALTER DATABASE `${schemaName}` CHARACTER SET utf8  COLLATE utf8_unicode_ci;

USE `${schemaName}`;

CREATE TABLE IF NOT EXISTS staging_district (
  id int NOT NULL PRIMARY KEY,
  natural_id varchar(40) NOT NULL,
  name varchar(100) NOT NULL,
  migrate_id bigint NOT NULL
);

CREATE TABLE IF NOT EXISTS staging_school (
  id int NOT NULL PRIMARY KEY,
  district_id int NOT NULL,
  natural_id varchar(40) NOT NULL,
  name varchar(100) NOT NULL,
  import_id bigint NOT NULL,
  deleted tinyint NOT NULL,
  migrate_id bigint NOT NULL
);
