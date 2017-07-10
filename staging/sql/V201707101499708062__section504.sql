# change section504 to be nullable, indicating "unknown"

USE ${schemaName};

ALTER TABLE staging_exam_student MODIFY section504 tinyint;
