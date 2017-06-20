/**
* MySQL treats FK this way:
* In the referencing table, there must be an index where the foreign key columns are listed as the first columns in the same order.
* Such an index is created on the referencing table automatically if it does not exist.
* This index is silently dropped later, if you create another index that can be used to enforce the foreign key constraint.
*
* When restoring a DB from a back up, MySQL does not see an automatically created FK index as such and treats it as a user defined.
* So when running this on the restored DB, you will end up with duplicate indexes.
**/

ALTER TABLE exam DROP FOREIGN KEY fk__exam__school;

CREATE INDEX idx__exam__school ON exam (school_id);
ALTER TABLE exam ADD CONSTRAINT idx__exam__school FOREIGN KEY (school_id) REFERENCES school(id);
