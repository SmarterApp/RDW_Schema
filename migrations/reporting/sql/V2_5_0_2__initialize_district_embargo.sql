-- Populate district_embargo from current school table, subjects, school years.
-- Based on requirements for Phase 6, exams for all districts for all subjects for
-- all previous school years should be set to RELEASED (2). For the current school
-- year, there should be no entries, for which the system will default to LOADING.
-- So, the current embargo settings just don't matter.
-- All previous years should be set to Released.
INSERT IGNORE INTO district_embargo (school_year, district_id, subject_id, individual)
SELECT  y.year, d.id, s.id, 2
FROM school_year y
         JOIN district d
         JOIN subject s
WHERE y.year NOT IN (SELECT max(year) FROM school_year);
