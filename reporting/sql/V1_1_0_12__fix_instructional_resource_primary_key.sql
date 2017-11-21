-- Update instructional_resource primary key to allow a single value per institution

USE ${schemaName};

ALTER TABLE instructional_resource
  DROP PRIMARY KEY,
  ADD UNIQUE INDEX idx__instructional_resource (asmt_natural_id, org_level, performance_level, org_natural_id);