use staging;
-- ----------------------------------------------------------------------
-- School / District migration
-- ----------------------------------------------------------------------
-- TODO: this is a temp hack/simulation that I needed to test
TRUNCATE TABLE reporting.migrate;
-- In the real life this will be done at the beginning of the migration
INSERT INTO reporting.migrate (id, status, first_import_id, last_import_id)
VALUES (11, 10, 100, 1100);

-- ----------------------------------------------------------------------
-- clean up
-- ----------------------------------------------------------------------
TRUNCATE TABLE staging_school;
TRUNCATE TABLE staging_district;

-- ----------------------------------------------------------------------
-- load data into staging table
-- ----------------------------------------------------------------------
INSERT INTO staging_district (id, natural_id, name, migrate_id)
  SELECT
    wd.id,
    wd.natural_id,
    wd.name,
    11 -- TODO: this id will be passed in from the previous migrate task
  FROM warehouse.district wd
  WHERE EXISTS(
      SELECT id from warehouse.school ws
      WHERE district_id = wd.id
            AND ws.deleted = 0 -- delete will be taken care on the 'master' level
            -- TODO: this ids will be passed in from the previous migrate task
            AND import_id  IN ( SELECT id FROM warehouse.import WHERE id >= -1));

INSERT INTO staging_school (id, natural_id, name, import_id, deleted, district_id, migrate_id)
  SELECT
    ws.id,
    ws.natural_id,
    ws.name,
    ws.import_id,
    ws.deleted,
    ws.district_id,
    11 -- TODO: this id will be passed in from the previous migrate task
  FROM warehouse.school ws
    JOIN warehouse.district wd ON wd.id = ws.district_id
  WHERE
    -- TODO: this ids will be passed in from the previous migrate task
    ws.import_id IN (SELECT id FROM warehouse.import WHERE id >= -1);

-- -----------------------------------------------------------------------------------------
-- handle delete first
-- -----------------------------------------------------------------------------------------
-- student groups and exams depend on the school.
-- Assume that all the dependent deletes were processed first
-- TODO: how to handle errors in this case?
DELETE FROM reporting.school WHERE id IN (SELECT id FROM staging_school WHERE deleted = 1);

-- remove districts if it is not associated with a school
DELETE FROM reporting.district
WHERE id in (SELECT district_id from staging_school WHERE deleted = 1)
      AND NOT EXISTS(SELECT id from reporting.school WHERE district_id = id);

-- -----------------------------------------------------------------------------------------
-- Update/insert districts. This covers a use case when a school gets re-assigned to a new district
-- Note that updates comes before insert to avoid updating newly inserted records
-- -----------------------------------------------------------------------------------------
UPDATE reporting.district d
  JOIN (SELECT id, name FROM staging_district) sd ON sd.id = d.id
SET d.name = sd.name;

INSERT INTO reporting.district(id, natural_id,name)
  SELECT
    sd.id,
    sd.natural_id,
    sd.name
  FROM staging_district sd
    LEFT JOIN reporting.district rd ON rd.id = sd.id
  WHERE rd.id IS NULL;

-- -----------------------------------------------------------------------------------------
-- Update/insert schools.
-- -----------------------------------------------------------------------------------------
UPDATE reporting.school rs
  JOIN staging_school ss ON ss.id = rs.id
SET rs.name = ss.name,
  rs.district_id = ss.district_id,
  rs.import_id = ss.import_id
WHERE ss.deleted = 0;

INSERT INTO reporting.school (id, natural_id, name, district_id, import_id)
  SELECT
    ss.id,
    ss.natural_id,
    ss.name,
    ss.district_id,
    ss.import_id
  FROM staging_school ss
    LEFT JOIN reporting.school rs ON rs.id = ss.id
  WHERE rs.id IS NULL and ss.deleted = 0;