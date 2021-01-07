-- v2.5.0_1 flyway script
--
-- adds support for finer-grained embargo control

SET SEARCH_PATH to ${schemaName};

SET client_encoding = 'UTF8';

-- reference table
CREATE TABLE embargo_status (
  id smallint NOT NULL PRIMARY KEY SORTKEY,
  name varchar(20) NOT NULL UNIQUE
) DISTSTYLE ALL;

INSERT INTO embargo_status (id, name) VALUES
  (0, 'Loading'),
  (1, 'Reviewing'),
  (2, 'Released');

-- Previously, there was a single embargo flag so it was denormalized into the school table.
-- This eliminated a join or two, improving performance. However, now that there are multiple
-- embargo levels (LOADING, REVIEWING, RELEASED), applied by school year and subject, a child
-- table is needed to handle the one-to-many. Since these settings are at the district level,
-- there is no longer a benefit of pushing the data down to the school level (there would be
-- a multiplicative effect on the size of the child table).
CREATE TABLE district_embargo (
    district_id integer NOT NULL,
    school_year smallint NOT NULL,
    subject_id smallint NOT NULL,
    aggregate smallint,
    migrate_id bigint,
    UNIQUE (district_id, school_year, subject_id),
    CONSTRAINT fk__district_embargo__district FOREIGN KEY (district_id) REFERENCES district (id),
    CONSTRAINT fk__district_embargo__school_year FOREIGN KEY (school_year) REFERENCES school_year (year),
    CONSTRAINT fk__district_embargo__subject FOREIGN KEY (subject_id) REFERENCES subject (id),
    CONSTRAINT fk__district_embargo__status FOREIGN KEY(aggregate) REFERENCES embargo_status(id)
) DISTSTYLE ALL;

-- drop obsolete column in school table
ALTER TABLE school
  DROP COLUMN embargo_enabled;

-- recreate staging table
DROP TABLE staging_district_embargo;
CREATE TABLE staging_district_embargo (
  district_id integer NOT NULL,
  school_year smallint NOT NULL,
  subject_id smallint NOT NULL,
  aggregate smallint,
  migrate_id bigint NOT NULL,
  UNIQUE (district_id, school_year, subject_id)
);
