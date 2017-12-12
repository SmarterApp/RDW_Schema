-- Modify embargo tables to be flat: columns instead of rows for different embargo scopes.

USE ${schemaName};

-- this assumes there is no real embargo data out there yet so just clear tables
DELETE FROM district_embargo;
DELETE FROM state_embargo;


ALTER TABLE district_embargo
  DROP PRIMARY KEY,
  DROP FOREIGN KEY fk__district_embargo__embargo_scope,
  DROP INDEX idx__district_embargo__embargo_scope,
  DROP COLUMN embargo_scope_id,
  DROP COLUMN enabled,
  ADD PRIMARY KEY (district_id, school_year),
  ADD COLUMN individual tinyint,
  ADD COLUMN aggregate tinyint
;

ALTER TABLE state_embargo
  DROP PRIMARY KEY,
  DROP FOREIGN KEY fk__state_embargo__embargo_scope,
  DROP INDEX idx__state_embargo__embargo_scope,
  DROP COLUMN embargo_scope_id,
  DROP COLUMN enabled,
  ADD PRIMARY KEY (school_year),
  ADD COLUMN individual tinyint,
  ADD COLUMN aggregate tinyint
;

DROP TABLE embargo_scope;
