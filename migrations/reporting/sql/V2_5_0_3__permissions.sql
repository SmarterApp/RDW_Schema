-- v2.5.0_3 flyway script
-- Move role and permissions tables from Perms service to be local to RDW.
use ${schemaName};

drop table if exists auth_permission_role;
drop table if exists auth_role;
drop table if exists auth_permission;

create table auth_role
(
    id int auto_increment
        primary key,
    name varchar(50) not null
);

create table auth_permission
(
    id int auto_increment
        primary key,
    name varchar(50) not null
);

create table auth_permission_role
(
    id int auto_increment
        primary key,
    role_id int null,
    permission_id int not null,
    constraint fk__auth_permission_role__auth_permission
        foreign key (permission_id) references auth_permission (id),
    constraint fk__auth_permission_role__auth_role
        foreign key (role_id) references auth_role (id)
);

create index idx__auth_permisssion_role__role
    on auth_permission_role (role_id);

create index idx__auth_permisssion_role__permission
    on auth_permission_role (permission_id);

--
--  IMPORTANT!!! All roles and permissions must be added to both warehouse and reporting schemas.
--  Webapp uses reporting and services use warehouse, and there is no migration process related to permissions.
--

-- Insert initial roles
INSERT INTO auth_role(name) VALUES ('ALLSTATES');
INSERT INTO auth_role(name) VALUES ('ASMTDATALOAD');
INSERT INTO auth_role(name) VALUES ('AUDITXML');
INSERT INTO auth_role(name) VALUES ('CUSTOM_AGGREGATE_REPORTER');
INSERT INTO auth_role(name) VALUES ('DevOps');
INSERT INTO auth_role(name) VALUES ('EMBARGO_ADMIN');
INSERT INTO auth_role(name) VALUES ('EMBARGO_ADMIN_RELEASE');
INSERT INTO auth_role(name) VALUES ('GENERAL');
INSERT INTO auth_role(name) VALUES ('GROUP_ADMIN');
INSERT INTO auth_role(name) VALUES ('IIRDEXTRACTS');
INSERT INTO auth_role(name) VALUES ('ISR_TEMPLATE_ADMIN');
INSERT INTO auth_role(name) VALUES ('ISR_TEMPLATE_READONLY');
INSERT INTO auth_role(name) VALUES ('Instructional Resource Admin');
INSERT INTO auth_role(name) VALUES ('PII');
INSERT INTO auth_role(name) VALUES ('PII_GROUP');
INSERT INTO auth_role(name) VALUES ('PIPELINE_ADMIN');
INSERT INTO auth_role(name) VALUES ('SandboxDistrictAdmin');
INSERT INTO auth_role(name) VALUES ('SandboxSchoolAdmin');
INSERT INTO auth_role(name) VALUES ('SandboxTeacher');
INSERT INTO auth_role(name) VALUES ('TENANT_ADMIN');

-- Insert initial permissions
INSERT INTO auth_permission(name) VALUES ('ALL_STATES_READ');
INSERT INTO auth_permission(name) VALUES ('AUDIT_XML_READ');
INSERT INTO auth_permission(name) VALUES ('CUSTOM_AGGREGATE_READ');
INSERT INTO auth_permission(name) VALUES ('DATA_WRITE');
INSERT INTO auth_permission(name) VALUES ('GROUP_PII_READ');
INSERT INTO auth_permission(name) VALUES ('GROUP_READ');
INSERT INTO auth_permission(name) VALUES ('GROUP_WRITE');
INSERT INTO auth_permission(name) VALUES ('IIRD_EXTRACTS_READ');
INSERT INTO auth_permission(name) VALUES ('INDIVIDUAL_PII_READ');
INSERT INTO auth_permission(name) VALUES ('INSTRUCTIONAL_RESOURCE_WRITE');
INSERT INTO auth_permission(name) VALUES ('ISR_TEMPLATE_READ');
INSERT INTO auth_permission(name) VALUES ('ISR_TEMPLATE_WRITE');
INSERT INTO auth_permission(name) VALUES ('PIPELINE_READ');
INSERT INTO auth_permission(name) VALUES ('PIPELINE_WRITE');
INSERT INTO auth_permission(name) VALUES ('POPULATION_AGGREGATE_READ');
INSERT INTO auth_permission(name) VALUES ('TENANT_READ');
INSERT INTO auth_permission(name) VALUES ('TENANT_WRITE');
INSERT INTO auth_permission(name) VALUES ('TEST_DATA_LOADING_READ');
INSERT INTO auth_permission(name) VALUES ('TEST_DATA_LOADING_WRITE');
INSERT INTO auth_permission(name) VALUES ('TEST_DATA_REVIEWING_READ');
INSERT INTO auth_permission(name) VALUES ('TEST_DATA_REVIEWING_WRITE');

-- Insert initial role/permission relationships
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'ALLSTATES'),
        (SELECT id FROM auth_permission WHERE name = 'ALL_STATES_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'ASMTDATALOAD'),
        (SELECT id FROM auth_permission WHERE name = 'DATA_WRITE'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'AUDITXML'),
        (SELECT id FROM auth_permission WHERE name = 'AUDIT_XML_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'CUSTOM_AGGREGATE_REPORTER'),
        (SELECT id FROM auth_permission WHERE name = 'CUSTOM_AGGREGATE_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'DevOps'),
        (SELECT id FROM auth_permission WHERE name = 'ISR_TEMPLATE_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'DevOps'),
        (SELECT id FROM auth_permission WHERE name = 'ISR_TEMPLATE_WRITE'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'DevOps'),
        (SELECT id FROM auth_permission WHERE name = 'PIPELINE_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'DevOps'),
        (SELECT id FROM auth_permission WHERE name = 'PIPELINE_WRITE'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'DevOps'),
        (SELECT id FROM auth_permission WHERE name = 'TENANT_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'DevOps'),
        (SELECT id FROM auth_permission WHERE name = 'TENANT_WRITE'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'DevOps'),
        (SELECT id FROM auth_permission WHERE name = 'TEST_DATA_LOADING_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'DevOps'),
        (SELECT id FROM auth_permission WHERE name = 'TEST_DATA_LOADING_WRITE'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'DevOps'),
        (SELECT id FROM auth_permission WHERE name = 'TEST_DATA_REVIEWING_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'DevOps'),
        (SELECT id FROM auth_permission WHERE name = 'TEST_DATA_REVIEWING_WRITE'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'EMBARGO_ADMIN'),
        (SELECT id FROM auth_permission WHERE name = 'TEST_DATA_REVIEWING_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'EMBARGO_ADMIN_RELEASE'),
        (SELECT id FROM auth_permission WHERE name = 'TEST_DATA_REVIEWING_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'EMBARGO_ADMIN_RELEASE'),
        (SELECT id FROM auth_permission WHERE name = 'TEST_DATA_REVIEWING_WRITE'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'GENERAL'),
        (SELECT id FROM auth_permission WHERE name = 'POPULATION_AGGREGATE_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'GROUP_ADMIN'),
        (SELECT id FROM auth_permission WHERE name = 'GROUP_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'GROUP_ADMIN'),
        (SELECT id FROM auth_permission WHERE name = 'GROUP_WRITE'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'IIRDEXTRACTS'),
        (SELECT id FROM auth_permission WHERE name = 'IIRD_EXTRACTS_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'ISR_TEMPLATE_ADMIN'),
        (SELECT id FROM auth_permission WHERE name = 'ISR_TEMPLATE_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'ISR_TEMPLATE_ADMIN'),
        (SELECT id FROM auth_permission WHERE name = 'ISR_TEMPLATE_WRITE'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'ISR_TEMPLATE_READONLY'),
        (SELECT id FROM auth_permission WHERE name = 'ISR_TEMPLATE_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'Instructional Resource Admin'),
        (SELECT id FROM auth_permission WHERE name = 'INSTRUCTIONAL_RESOURCE_WRITE'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'PII'),
        (SELECT id FROM auth_permission WHERE name = 'CUSTOM_AGGREGATE_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'PII'),
        (SELECT id FROM auth_permission WHERE name = 'GROUP_PII_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'PII'),
        (SELECT id FROM auth_permission WHERE name = 'GROUP_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'PII'),
        (SELECT id FROM auth_permission WHERE name = 'INDIVIDUAL_PII_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'PII_GROUP'),
        (SELECT id FROM auth_permission WHERE name = 'GROUP_PII_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'PII_GROUP'),
        (SELECT id FROM auth_permission WHERE name = 'GROUP_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'PIPELINE_ADMIN'),
        (SELECT id FROM auth_permission WHERE name = 'PIPELINE_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'PIPELINE_ADMIN'),
        (SELECT id FROM auth_permission WHERE name = 'PIPELINE_WRITE'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'SandboxDistrictAdmin'),
        (SELECT id FROM auth_permission WHERE name = 'CUSTOM_AGGREGATE_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'SandboxDistrictAdmin'),
        (SELECT id FROM auth_permission WHERE name = 'GROUP_PII_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'SandboxDistrictAdmin'),
        (SELECT id FROM auth_permission WHERE name = 'GROUP_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'SandboxDistrictAdmin'),
        (SELECT id FROM auth_permission WHERE name = 'GROUP_WRITE'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'SandboxDistrictAdmin'),
        (SELECT id FROM auth_permission WHERE name = 'INDIVIDUAL_PII_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'SandboxDistrictAdmin'),
        (SELECT id FROM auth_permission WHERE name = 'INSTRUCTIONAL_RESOURCE_WRITE'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'SandboxDistrictAdmin'),
        (SELECT id FROM auth_permission WHERE name = 'ISR_TEMPLATE_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'SandboxDistrictAdmin'),
        (SELECT id FROM auth_permission WHERE name = 'TEST_DATA_REVIEWING_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'SandboxDistrictAdmin'),
        (SELECT id FROM auth_permission WHERE name = 'TEST_DATA_REVIEWING_WRITE'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'SandboxSchoolAdmin'),
        (SELECT id FROM auth_permission WHERE name = 'CUSTOM_AGGREGATE_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'SandboxSchoolAdmin'),
        (SELECT id FROM auth_permission WHERE name = 'GROUP_PII_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'SandboxSchoolAdmin'),
        (SELECT id FROM auth_permission WHERE name = 'GROUP_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'SandboxSchoolAdmin'),
        (SELECT id FROM auth_permission WHERE name = 'INDIVIDUAL_PII_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'SandboxTeacher'),
        (SELECT id FROM auth_permission WHERE name = 'GROUP_PII_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'SandboxTeacher'),
        (SELECT id FROM auth_permission WHERE name = 'GROUP_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'TENANT_ADMIN'),
        (SELECT id FROM auth_permission WHERE name = 'TENANT_READ'));
INSERT INTO auth_permission_role(role_id, permission_id)
VALUES ((SELECT id FROM auth_role WHERE name = 'TENANT_ADMIN'),
        (SELECT id FROM auth_permission WHERE name = 'TENANT_WRITE'));
