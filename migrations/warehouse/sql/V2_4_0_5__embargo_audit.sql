-- v2.4.0_5 flyway script
--
-- adds support for subject in audit_district_embargo and updates district_embargo triggers to populate it
-- also adds previous status fields to audit_district_embargo
--
use ${schemaName};

ALTER TABLE audit_district_embargo
    ADD COLUMN previous_individual tinyint,
    ADD COLUMN previous_aggregate tinyint,
    ADD COLUMN subject_id smallint,
    ADD CONSTRAINT fk__audit_district_embargo__subject FOREIGN KEY (subject_id) REFERENCES subject(id),
    ADD INDEX idx__audit_district_embargo__subject (subject_id),
    ADD CONSTRAINT fk__audit_district_embargo__district FOREIGN KEY (district_id) REFERENCES district(id),
    ADD INDEX idx__audit_district_embargo__district (district_id);

DROP TRIGGER trg__district_embargo__insert;
DROP TRIGGER trg__district_embargo__update;
DROP TRIGGER trg__district_embargo__delete;

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

