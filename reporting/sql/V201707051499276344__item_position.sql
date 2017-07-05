# fix the item position column types

USE ${schemaName};

ALTER TABLE item MODIFY position smallint;

ALTER TABLE exam_item MODIFY position smallint NOT NULL;
