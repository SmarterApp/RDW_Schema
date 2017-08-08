-- remove the replay_id as it is no longer needed
--
-- delete any import records with replay_id set, since they are represented by another record

USE ${schemaName};

DELETE FROM import WHERE replay_id IS NOT NULL;
ALTER TABLE import DROP COLUMN replay_id;