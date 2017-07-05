# fix the item position column types

USE ${schemaName};

ALTER TABLE staging_item MODIFY position smallint;

ALTER TABLE staging_exam_item MODIFY position smallint NOT NULL;
