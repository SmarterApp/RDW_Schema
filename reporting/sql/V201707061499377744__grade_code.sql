# denormalize grade_code in asmt and exam tables

USE ${schemaName};

ALTER TABLE asmt ADD COLUMN grade_code varchar(2);
UPDATE asmt a JOIN grade g ON g.id = a.grade_id SET a.grade_code = g.code;
ALTER TABLE asmt MODIFY grade_code varchar(2) NOT NULL;

ALTER TABLE exam ADD COLUMN grade_code varchar(2);
UPDATE exam e JOIN grade g ON g.id = e.grade_id SET e.grade_code = g.code;
ALTER TABLE exam MODIFY grade_code varchar(2) NOT NULL;