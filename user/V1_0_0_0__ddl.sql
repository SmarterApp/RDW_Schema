/*
Initial script for the SBAC RDW Reporting Datamart 1.0.0 schema

NOTES
This schema assumes the following:
   1. one state (aka tenant) per data warehouse
   2. not all data elements from TRT are included, only those that are required for the current reporting
   3. MySQL treats FK this way:
         In the referencing table, there must be an index where the foreign key columns are listed as the first columns in the same order.
         Such an index is created on the referencing table automatically if it does not exist.
         This index is silently dropped later, if you create another index that can be used to enforce the foreign key constraint.
         When restoring a DB from a back up, MySQL does not see an automatically created FK index as such and treats it as a user defined.
         So when running this on the restored DB, you will end up with duplicate indexes.
    To avoid this problem we explicitly create all the indexes.
*/

ALTER DATABASE ${schemaName} CHARACTER SET utf8 COLLATE utf8_unicode_ci;

USE ${schemaName};

CREATE TABLE IF NOT EXISTS teacher_student_group (
  id int NOT NULL PRIMARY KEY,
  name varchar(255) NOT NULL,
  school_id int NOT NULL,
  school_year smallint NOT NULL,
  user_login varchar(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS teacher_student_group_membership (
  teacher_student_group_id int NOT NULL,
  student_id int NOT NULL
);

CREATE TABLE IF NOT EXISTS teacher_student_group_subject (
  teacher_student_group_id int NOT NULL,
  subject_id int NOT NULL
);
