-- Use this script (carefully) to map ETS's one-way hash values into more familiar values

CREATE SCHEMA IF NOT EXISTS datagen;
USE datagen;

-- execute these scripts to create names tables:
--   boy_names.sql
--   girl_names.sql
--   last_names.sql
--   animal_names.sql

CREATE TABLE IF NOT EXISTS datagen.first_name_mapping (
  hash_name VARCHAR(60),
  gender_id TINYINT,
  name      VARCHAR(60),
  INDEX idx__first_name_mapping__hash_name(hash_name)
);
CREATE TABLE IF NOT EXISTS datagen.last_name_mapping (
  hash_name VARCHAR(60),
  name      VARCHAR(60),
  INDEX idx__last_name_mapping__hash_name(hash_name)
);
CREATE TABLE IF NOT EXISTS datagen.ssid_mapping (
  hash_ssid VARCHAR(65),
  ssid VARCHAR(10)
);

-- collect first "names" that we want to map
INSERT INTO datagen.first_name_mapping (hash_name, gender_id)
  SELECT DISTINCT hash_name, gender_id
  FROM (SELECT first_name as hash_name, gender_id FROM warehouse.student WHERE LENGTH(first_name) = 40
        UNION ALL
        SELECT middle_name as hash_name, gender_id FROM warehouse.student WHERE LENGTH(middle_name) = 40) u;
-- map random nice names to those first "names"; special handling of null mapping
UPDATE datagen.first_name_mapping SET name = (SELECT name FROM datagen.boy_names ORDER BY RAND() limit 1)
WHERE gender_id = 1 and name IS NULL;
UPDATE datagen.first_name_mapping SET name = (SELECT name FROM datagen.girl_names ORDER BY RAND() limit 1)
WHERE gender_id = 2 and name IS NULL;
INSERT INTO datagen.first_name_mapping (hash_name, gender_id, name) VALUES (null, 1, null), (null, 2, null);

-- collect last "names" that we want to map
INSERT INTO datagen.last_name_mapping (hash_name)
  SELECT DISTINCT last_or_surname FROM warehouse.student WHERE LENGTH(last_or_surname) = 40;
-- map random nice names to those last "names"
UPDATE datagen.last_name_mapping SET name = (SELECT name FROM datagen.last_names ORDER BY RAND() limit 1) WHERE name IS NULL;

-- collect "ssids" that we want to map
-- for ssid's we have to be careful about truncating them in case there is duplication
SELECT COUNT(DISTINCT(ssid)), COUNT(DISTINCT(substring(ssid, 1, 10))) FROM warehouse.student WHERE LENGTH(ssid) = 40;
INSERT INTO datagen.ssid_mapping (hash_ssid, ssid)
  SELECT ssid, substring(ssid, 1, 10) FROM warehouse.student WHERE LENGTH(ssid) = 40;

-- make an import record for these changes
INSERT INTO warehouse.import (status, content, contentType, digest, batch)
  VALUES (0, 5, 'text/plan', 'MANUAL', 'mlaffoon cleaning student data');
SELECT LAST_INSERT_ID() INTO @importid;

-- make the mapping changes; indexes drastically improve update performance
ALTER TABLE warehouse.student
  ADD INDEX idx__student__first_name(first_name),
  ADD INDEX idx__student__middle_name(middle_name),
  ADD INDEX idx__student__last_name(last_or_surname);

UPDATE warehouse.student ws
  JOIN datagen.ssid_mapping sm ON sm.hash_ssid = ws.ssid
SET ws.ssid = sm.ssid, update_import_id = @importid
WHERE LENGTH(ws.ssid) = 40;

UPDATE warehouse.student ws
  JOIN datagen.first_name_mapping fm ON fm.hash_name = ws.first_name AND fm.gender_id = ws.gender_id
SET ws.first_name = fm.name, update_import_id = @importid
WHERE LENGTH(ws.first_name) = 40;

UPDATE warehouse.student ws
  JOIN datagen.first_name_mapping mm ON mm.hash_name = ws.middle_name AND mm.gender_id = ws.gender_id
SET ws.middle_name = mm.name, update_import_id = @importid
WHERE LENGTH(ws.middle_name) = 40;

UPDATE warehouse.student ws
  JOIN datagen.last_name_mapping lm ON lm.hash_name = ws.last_or_surname
SET ws.last_or_surname = lm.name, update_import_id = @importid
WHERE LENGTH(ws.last_or_surname) = 40;

ALTER TABLE warehouse.student
  DROP INDEX idx__student__first_name,
  DROP INDEX idx__student__middle_name,
  DROP INDEX idx__student__last_name;

-- trigger migration
UPDATE warehouse.import SET status = 1 WHERE id = @importid;


-- Schools and Districts
-- Here we are just overwriting the names for real orgs, indicated by a natural_id of length 14.
-- We are keeping around the original real names in case we want to undo this.

CREATE TABLE IF NOT EXISTS datagen.school_name_mapping (
  natural_id VARCHAR(20),
  real_name VARCHAR(100),
  name VARCHAR(60)
);
CREATE TABLE IF NOT EXISTS datagen.district_name_mapping (
  natural_id VARCHAR(20),
  real_name VARCHAR(100),
  name VARCHAR(60)
);
-- collect schools that we want to map
INSERT INTO datagen.school_name_mapping (natural_id, real_name)
  SELECT natural_id, name FROM warehouse.school WHERE LENGTH(natural_id) = 14;
-- map random animal names
UPDATE datagen.school_name_mapping SET name =
  CONCAT_WS(' ',
            (SELECT name FROM datagen.animal_names ORDER BY RAND() limit 1),
            (SELECT name FROM datagen.animal_names ORDER BY RAND() limit 1),
            'School')
  WHERE name IS NULL;

-- collect districts that we want to map
INSERT INTO datagen.district_name_mapping (natural_id, real_name)
  SELECT natural_id, name FROM warehouse.district WHERE LENGTH(natural_id) = 14;
-- map random animal names
UPDATE datagen.district_name_mapping SET name =
  CONCAT_WS(' ',
            (SELECT name FROM datagen.animal_names ORDER BY RAND() limit 1),
            (SELECT name FROM datagen.animal_names ORDER BY RAND() limit 1),
            'District')
  WHERE name IS NULL;

-- make an import record for these changes
INSERT INTO warehouse.import (status, content, contentType, digest, batch)
VALUES (0, 4, 'text/plan', 'MANUAL', 'mlaffoon cleaning organization data');
SELECT LAST_INSERT_ID() INTO @importid;

UPDATE warehouse.school ws
  JOIN datagen.school_name_mapping sm ON sm.natural_id = ws.natural_id
SET ws.name = sm.name, update_import_id = @importid
WHERE LENGTH(ws.natural_id) = 14;

UPDATE warehouse.district wd
  JOIN datagen.district_name_mapping dm ON dm.natural_id = wd.natural_id
SET wd.name = dm.name
WHERE LENGTH(wd.natural_id) = 14;

-- trigger migration
UPDATE warehouse.import SET status = 1 WHERE id = @importid;

