-- v2.5.0_1 flyway script
-- adds support for finer-grained embargo control

use ${schemaName};

DROP TRIGGER IF EXISTS trg__district_embargo__insert;
DROP TRIGGER IF EXISTS trg__district_embargo__update;
DROP TRIGGER IF EXISTS trg__district_embargo__delete;

DROP TABLE IF EXISTS district_embargo;
DROP TABLE IF EXISTS legacy_audit_district_embargo;
RENAME TABLE audit_district_embargo TO legacy_audit_district_embargo;

-- create reference table
DROP TABLE IF EXISTS embargo_status;
CREATE TABLE embargo_status (
    id tinyint NOT NULL PRIMARY KEY,
    name varchar(20) NOT NULL UNIQUE
);

INSERT INTO embargo_status (id, name) VALUES
(0, 'Loading'),
(1, 'Reviewing'),
(2, 'Released');


-- Crete new district embargo table
CREATE TABLE district_embargo (
     school_year smallint NOT NULL,
    district_id int NOT NULL,
    subject_id smallint default 0 NOT NULL,
    individual tinyint NOT NULl,
    aggregate tinyint NOT NULL,
    updated timestamp(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL ON update CURRENT_TIMESTAMP(6),
    updated_by varchar(255) null,
    primary key (school_year, district_id, subject_id),
    constraint fk__district_embargo__district
        foreign key (district_id) references district (id)
            on delete cascade,
    constraint fk__district_embargo__individual_status
        foreign key (individual) references embargo_status (id),
     constraint fk__district_embargo__aggregate_status
         foreign key (aggregate) references embargo_status (id),
    constraint fk__district_embargo__subject
        foreign key (subject_id) references subject (id)
            on delete cascade
);

create index idx__district_embargo__district on district_embargo (district_id);

create index idx__district_embargo__subject on district_embargo (subject_id);

-- Create new audit_district_embargo
create table if not exists audit_district_embargo
(
    id bigint auto_increment
        primary key,
    action varchar(8) not null,
    audited timestamp(6) default CURRENT_TIMESTAMP(6) not null,
    database_user varchar(255) not null,
    district_id int not null,
    school_year smallint not null,
    individual tinyint null,
    aggregate tinyint null,
    updated timestamp(6) not null,
    updated_by varchar(255) null,
    previous_individual tinyint null,
    previous_aggregate tinyint null,
    subject_id smallint null
);

create index idx__audit_district_embargo__district on audit_district_embargo (district_id);
create index idx__audit_district_embargo__subject on audit_district_embargo (subject_id);

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

