-- Refactor instructional_resource table to reference asmt by name
-- rather than natural_id.

use ${schemaName};

ALTER TABLE instructional_resource
  DROP INDEX idx__instructional_resource,
  CHANGE asmt_natural_id asmt_name VARCHAR(250) NOT NULL,
  ADD UNIQUE INDEX idx__instructional_resource (asmt_name, org_level, performance_level, org_id);

ALTER TABLE asmt
  ADD INDEX idx__asmt__name (name);