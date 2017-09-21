-- add district and school groups

USE ${schemaName};

CREATE TABLE IF NOT EXISTS staging_district_group (
  id int NOT NULL PRIMARY KEY,
  natural_id varchar(40) NOT NULL,
  name varchar(100) NOT NULL,
  external_id varchar(40),
  migrate_id bigint NOT NULL
);

CREATE TABLE IF NOT EXISTS staging_school_group (
  id int NOT NULL PRIMARY KEY,
  natural_id varchar(40) NOT NULL,
  name varchar(100) NOT NULL,
  external_id varchar(40),
  migrate_id bigint NOT NULL
);

ALTER TABLE staging_district
  ADD COLUMN external_id varchar(40);

ALTER TABLE staging_school
  ADD COLUMN district_group_id int,
  ADD COLUMN school_group_id int,
  ADD COLUMN external_id varchar(40);


CREATE TABLE IF NOT EXISTS district_group (
  id int NOT NULL PRIMARY KEY,
  natural_id varchar(40) NOT NULL,
  name varchar(100) NOT NULL,
  external_id varchar(40),
  UNIQUE INDEX idx__district_group__natural_id (natural_id)
);

CREATE TABLE IF NOT EXISTS school_group (
  id int NOT NULL PRIMARY KEY,
  natural_id varchar(40) NOT NULL,
  name varchar(100) NOT NULL,
  external_id varchar(40),
  UNIQUE INDEX idx__school_group__natural_id (natural_id)
);

ALTER TABLE district
  ADD COLUMN external_id varchar(40);

ALTER TABLE school
  ADD COLUMN district_group_id int,
  ADD COLUMN school_group_id int,
  ADD COLUMN external_id varchar(40),
  ADD INDEX idx__school__district_group (district_group_id),
  ADD INDEX idx__school__school_group (school_group_id),
  ADD CONSTRAINT fk__school__district_group FOREIGN KEY (district_group_id) REFERENCES district_group(id),
  ADD CONSTRAINT fk__school__school_group FOREIGN KEY (school_group_id) REFERENCES school_group(id);
