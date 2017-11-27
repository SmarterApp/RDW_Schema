-- Refactor instructional_resource table to track organizations by database id rather than
-- natural id.

USE ${schemaName};

ALTER TABLE instructional_resource
  DROP INDEX idx__instructional_resource,
  CHANGE org_natural_id org_id int,
  ADD UNIQUE INDEX idx__instructional_resource (asmt_natural_id, org_level, performance_level, org_id);