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

DROP TRIGGER trg__district_embargo__insert;
DROP TRIGGER trg__district_embargo__update;
DROP TRIGGER trg__district_embargo__delete;

-- add subject id to district_embargo
ALTER TABLE district_embargo
    ADD COLUMN subject_id smallint,
    DROP PRIMARY KEY;

-- create reference table
CREATE TABLE embargo_status (
    id tinyint NOT NULL PRIMARY KEY,
    name varchar(20) NOT NULL UNIQUE
);

INSERT INTO embargo_status (id, name) VALUES
(0, 'Loading'),
(1, 'Reviewing'),
(2, 'Released');

-- Add foreign key constraints to subject_id and embargo status, and primary key to include
-- school_year, district_id, and subject_id
ALTER TABLE district_embargo
    ADD CONSTRAINT fk__district_embargo__subject FOREIGN KEY (subject_id) REFERENCES subject(id) ON DELETE CASCADE,
    ADD INDEX idx__district_embargo__subject (subject_id),
    ADD PRIMARY KEY(school_year, district_id, subject_id),
    ADD CONSTRAINT fk__district_embargo__individual_status FOREIGN KEY (individual) REFERENCES embargo_status(id),
    ADD CONSTRAINT fk__district_embargo__aggregate_status FOREIGN KEY (aggregate) REFERENCES embargo_status(id);

-- Backup old audit history and clear out current.
CREATE TABLE legacy_audit_district_embargo SELECT * FROM audit_district_embargo;

-- Empty out old tables
DELETE FROM district_embargo WHERE 1=1;
DELETE FROM audit_district_embargo WHERE 1=1;

-- Update triggers to handle new auditing logic
CREATE TRIGGER trg__district_embargo__insert
    AFTER INSERT ON district_embargo
    FOR EACH ROW
INSERT INTO audit_district_embargo (action, database_user, district_id, subject_id, school_year, individual, aggregate, updated, updated_by)
SELECT
    'insert',
    USER(),
    NEW.district_id,
    NEW.subject_id,
    NEW.school_year,
    NEW.individual,
    NEW.aggregate,
    NEW.updated,
    NEW.updated_by;

CREATE TRIGGER trg__district_embargo__update
    AFTER UPDATE ON district_embargo
    FOR EACH ROW
INSERT INTO audit_district_embargo (action, database_user, district_id, subject_id, school_year, individual, previous_individual, aggregate, previous_aggregate, updated, updated_by)
SELECT
    'update',
    USER(),
    NEW.district_id,
    NEW.subject_id,
    NEW.school_year,
    NEW.individual,
    OLD.individual,
    NEW.aggregate,
    OLD.aggregate,
    NEW.updated,
    NEW.updated_by;

CREATE TRIGGER trg__district_embargo__delete
    AFTER DELETE ON district_embargo
    FOR EACH ROW
INSERT INTO audit_district_embargo (action, database_user, district_id, subject_id, school_year, previous_individual, previous_aggregate, updated, updated_by)
SELECT
    'delete',
    USER(),
    OLD.district_id,
    OLD.subject_id,
    OLD.school_year,
    OLD.individual,
    OLD.aggregate,
    OLD.updated,
    OLD.updated_by;

