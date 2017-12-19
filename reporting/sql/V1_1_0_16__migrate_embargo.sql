-- Changes to embargo tables to support migrate

USE ${schemaName};

ALTER TABLE migrate
  ADD COLUMN migrate_embargo tinyint
;

-- this column should really be called
-- individual_embargo_enabled_for_summative_test_results_for_current_school_year
ALTER TABLE school
  CHANGE district_embargo_enabled embargo_enabled tinyint NOT NULL
;

ALTER TABLE district
  DROP COLUMN embargo_enabled
;

CREATE TABLE IF NOT EXISTS staging_district_embargo (
  district_id int NOT NULL,
  individual tinyint,
  aggregate tinyint,
  migrate_id bigint NOT NULL
);