/**
** Address some known issues in the original script.
**/

USE ${schemaName};

ALTER TABLE asmt MODIFY label varchar(255) NOT NULL;
ALTER TABLE asmt MODIFY name varchar(250) NOT NULL;

ALTER TABLE iab_exam MODIFY session_id varchar(128) NOT NULL;
ALTER TABLE iab_exam DROP COLUMN status;

ALTER TABLE exam MODIFY session_id varchar(128) NOT NULL;
ALTER TABLE exam DROP COLUMN status;

ALTER TABLE student_ethnicity DROP COLUMN id;
