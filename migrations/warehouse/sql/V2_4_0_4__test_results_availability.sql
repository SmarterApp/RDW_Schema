-- v2.4.0_4 flyway script
--
-- NOTE: this script was modified after initial creation which will mess up
-- things if the older version was run successfully. The original version had
-- a checksum of -385633165. However, if it was run successfully, the embargo
-- table must've been empty which means you don't need to rerun this script.
-- Update the schema_version and set the checksum to the correct value for
-- this version of the script (which can't be shown here because documenting
-- it will change it ... sigh).
--
-- adds support for finer-grained embargo control

use ${schemaName};

ALTER TABLE district_embargo
  ADD COLUMN subject_id smallint,
  DROP PRIMARY KEY;

-- replace any existing entries with multiple new entries by crossing with the subject table
INSERT INTO district_embargo (district_id, subject_id, school_year, individual, aggregate, updated, updated_by)
  SELECT district_id, s.id, school_year, individual, aggregate, de.updated, de.updated_by
    FROM district_embargo de JOIN subject s;
DELETE FROM district_embargo WHERE subject_id IS NULL;

ALTER TABLE district_embargo
  ADD CONSTRAINT fk__district_embargo__subject FOREIGN KEY (subject_id) REFERENCES subject(id),
  ADD INDEX idx__district_embargo__subject (subject_id),
  ADD PRIMARY KEY(school_year, district_id, subject_id);


CREATE TABLE embargo_report_type (
  name VARCHAR(20) PRIMARY KEY
);

INSERT INTO embargo_report_type VALUES ('Aggregate'), ('Individual');
