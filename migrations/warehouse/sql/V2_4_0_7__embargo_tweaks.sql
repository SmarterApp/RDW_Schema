-- v2.4.0_7 flyway script
--
-- embargo / test-results-availability refinements

use ${schemaName};

-- reference table
CREATE TABLE embargo_status (
  id tinyint NOT NULL PRIMARY KEY,
  name varchar(20) NOT NULL UNIQUE
);

INSERT INTO embargo_status (id, name) VALUES
  (0, 'Loading'),
  (1, 'Reviewing'),
  (2, 'Released');

ALTER TABLE district_embargo
    ADD CONSTRAINT fk__district_embargo__individual_status FOREIGN KEY (individual) REFERENCES embargo_status(id),
    ADD CONSTRAINT fk__district_embargo__aggregate_status FOREIGN KEY (aggregate) REFERENCES embargo_status(id);

-- The original script (V2_4_0_4__test_results_availability.sql) copied existing entries,
-- crossing with the subject and school year. However, the sense of the embargo flags has
-- flipped so the entries are not correct. Originally, the flags were 0 for released and
-- 1 for embargoed. The new values are 0 (Loading), 1 (Reviewing), 2 (Released).
-- Based on requirements for Phase 6, exams for all districts for all subjects for
-- all previous school years should be set to RELEASED (2). For the current school
-- year, there should be no entries, for which the system will default to LOADING.
UPDATE district_embargo SET individual = 2 WHERE school_year NOT IN (SELECT max(year) FROM school_year);
DELETE FROM district_embargo WHERE school_year IN (SELECT max(year) FROM school_year);
