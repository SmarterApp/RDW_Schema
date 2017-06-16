/**
* DWR-413 Reporting datamart: denormalize code fields for student and student_ethnicity
**/

USE ${schemaName};

-- add gender_code
ALTER TABLE student ADD COLUMN gender_code varchar(255);
update student s
  join gender g on s.gender_id = g.id
 set s.gender_code = g.code

ALTER TABLE student_ethnicity ADD COLUMN ethnicity_code varchar(255);

-- add ethnicity code
update student_ethnicity se
   join ethnicity e on e.id = se.ethnicity_id
  set se.ethnicity_code = e.code;

ALTER TABLE student MODIFY COLUMN gender_code varchar(255) NOT NULL;
ALTER TABLE student_ethnicity MODIFY COLUMN ethnicity_code varchar(255) NOT NULL;