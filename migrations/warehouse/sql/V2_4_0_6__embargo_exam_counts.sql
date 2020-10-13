-- v2.4.0_6 flyway script
--
-- adds exam_count table, which will hold pre-calculated summative exam counts by school year, district, and subject
-- for display in the test results availability (embargo) UI.
--
use ${schemaName};

CREATE TABLE exam_count
(
    school_year SMALLINT NOT NULL,
    district_id INT NOT NULL,
    subject_id SMALLINT NOT NULL,
    count INT DEFAULT 0 NOT NULL,
    PRIMARY KEY (school_year, district_id, subject_id)
);

