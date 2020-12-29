-- v2.5.0_3 flyway script
-- Creates a staging_exam_count used to temporarily hold exam count data computed in Redshift and export
-- until it can be copied into the proper exam_count table.
CREATE TABLE staging_exam_count
(
    school_year SMALLINT,
    district_id INT,
    subject_id SMALLINT,
    count INT DEFAULT 0 NOT NULL
);
