# change section504 to be nullable, indicating "unknown"

USE ${schemaName};

ALTER TABLE exam MODIFY section504 tinyint;
