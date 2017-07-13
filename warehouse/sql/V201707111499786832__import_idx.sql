# add index to import for created

USE ${schemaName};

ALTER TABLE import ADD INDEX idx__import__created (created);
