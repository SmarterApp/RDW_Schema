-- v2.4.0_8 flyway script
--
-- Undoes most of 2.4.0_4 and 2.4.0_5 as we are temporarily restoring older embargo functionality.
--
use ${schemaName};

-- Drop audit district embargo's foreign keys.
ALTER TABLE audit_district_embargo
    DROP FOREIGN KEY fk__audit_district_embargo__district,
    DROP FOREIGN KEY fk__audit_district_embargo__subject;

-- Drop triggers that populate the audit table
DROP TRIGGER trg__district_embargo__insert;
DROP TRIGGER trg__district_embargo__update;
DROP TRIGGER trg__district_embargo__delete;

-- Drop district embargo's subject foreign key.
ALTER TABLE district_embargo
    DROP FOREIGN KEY fk__district_embargo__subject,
    DROP INDEX idx__district_embargo__subject;

-- Recombine multiple subject entries into a single entry.
INSERT IGNORE INTO district_embargo (district_id, school_year, subject_id, individual, aggregate, updated, updated_by)
    SELECT district_id, school_year, 0, individual, aggregate, updated, updated_by FROM district_embargo;
DELETE FROM district_embargo WHERE subject_id <> 0;

-- Restore primary key to original two fields and drop subject id
ALTER TABLE district_embargo
    DROP PRIMARY KEY,
    DROP COLUMN subject_id,
    ADD PRIMARY KEY(school_year, district_id);

-- Restore triggers to previous definitions.
CREATE TRIGGER trg__district_embargo__insert
    AFTER INSERT ON district_embargo
    FOR EACH ROW
    INSERT INTO audit_district_embargo (action, database_user, district_id, school_year, individual, aggregate, updated, updated_by)
    SELECT
        'insert',
        USER(),
        NEW.district_id,
        NEW.school_year,
        NEW.individual,
        NEW.aggregate,
        NEW.updated,
        NEW.updated_by;

CREATE TRIGGER trg__district_embargo__update
    AFTER UPDATE ON district_embargo
    FOR EACH ROW
    INSERT INTO audit_district_embargo (action, database_user, district_id, school_year, individual, aggregate, updated, updated_by)
    SELECT
        'update',
        USER(),
        NEW.district_id,
        NEW.school_year,
        NEW.individual,
        NEW.aggregate,
        NEW.updated,
        NEW.updated_by;

CREATE TRIGGER trg__district_embargo__delete
    AFTER DELETE ON district_embargo
    FOR EACH ROW
    INSERT INTO audit_district_embargo (action, database_user, district_id, school_year, individual, aggregate, updated, updated_by)
    SELECT
        'delete',
        USER(),
        OLD.district_id,
        OLD.school_year,
        OLD.individual,
        OLD.aggregate,
        OLD.updated,
        OLD.updated_by;
