-- Refactor instructional_resource table to allow organization-level and performance-level
-- instructional resources.

USE ${schemaName};

ALTER TABLE instructional_resource
  DROP PRIMARY KEY,
  CHANGE name asmt_natural_id VARCHAR(250) NOT NULL,
  ADD COLUMN performance_level TINYINT DEFAULT NULL,
  ADD COLUMN org_level VARCHAR(15) NOT NULL, -- 'System' | 'State' | 'DistrictGroup' | 'District' | 'SchoolGroup'
  ADD COLUMN org_natural_id VARCHAR(250) DEFAULT NULL,
  ADD PRIMARY KEY (asmt_natural_id, org_level, performance_level);

UPDATE instructional_resource
  SET org_level = 'System';