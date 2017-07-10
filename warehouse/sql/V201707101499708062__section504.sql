# change section504 to be nullable, indicating "unknown"

USE ${schemaName};

ALTER TABLE exam_student MODIFY section504 tinyint;
