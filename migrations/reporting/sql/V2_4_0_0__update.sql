-- v2.4.0 flyway script
--
-- adds support for exam trait scores

use ${schemaName};

-- store trait report flag by subject/assessment
-- default to false except for ELA Summative
ALTER TABLE subject_asmt_type ADD COLUMN trait_report tinyint;
UPDATE subject_asmt_type SET trait_report = IF(asmt_type_id = 3 AND subject_id = 2, 1, 0);
ALTER TABLE subject_asmt_type MODIFY COLUMN trait_report tinyint NOT NULL;

ALTER TABLE staging_subject_asmt_type ADD COLUMN trait_report tinyint NOT NULL;

-- table to store trait codes by subject
CREATE TABLE subject_trait (
    id smallint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    subject_id smallint NOT NULL,
    code varchar(20) NOT NULL,
    purpose varchar(10) NOT NULL,
    category varchar(10) NOT NULL,
    max_score smallint NOT NULL,
    INDEX idx__trait__subject (subject_id),
    CONSTRAINT fk__trait__subject FOREIGN KEY (subject_id) REFERENCES subject(id),
    UNIQUE INDEX idx__subject_trait__subject_code(subject_id, code)
);

-- enter known ELA WER traits
-- (include id for consistency with warehouse database update)
INSERT INTO subject_trait (id, subject_id, code, purpose, category, max_score) VALUES
(01, 2, 'SOCK_ARGU_ORG', 'ARGU', 'ORG', 4),
(02, 2, 'SOCK_ARGU_CON', 'ARGU', 'CON', 2),
(03, 2, 'SOCK_ARGU_EVI', 'ARGU', 'EVI', 4),
(04, 2, 'SOCK_EXPL_ORG', 'EXPL', 'ORG', 4),
(05, 2, 'SOCK_EXPL_CON', 'EXPL', 'CON', 2),
(06, 2, 'SOCK_EXPL_EVI', 'EXPL', 'EVI', 4),
(07, 2, 'SOCK_INFO_ORG', 'INFO', 'ORG', 4),
(08, 2, 'SOCK_INFO_CON', 'INFO', 'CON', 2),
(09, 2, 'SOCK_INFO_EVI', 'INFO', 'EVI', 4),
(10, 2, 'SOCK_NARR_ORG', 'NARR', 'ORG', 4),
(11, 2, 'SOCK_NARR_CON', 'NARR', 'CON', 2),
(12, 2, 'SOCK_NARR_EVI', 'NARR', 'EVI', 4),
(13, 2, 'SOCK_OPIN_ORG', 'OPIN', 'ORG', 4),
(14, 2, 'SOCK_OPIN_CON', 'OPIN', 'CON', 2),
(15, 2, 'SOCK_OPIN_EVI', 'OPIN', 'EVI', 4);

CREATE TABLE staging_subject_trait (
   id smallint NOT NULL AUTO_INCREMENT PRIMARY KEY,
   subject_id smallint NOT NULL,
   code varchar(20) NOT NULL,
   purpose varchar(10) NOT NULL,
   category varchar(10) NOT NULL,
   max_score smallint NOT NULL
);


-- table to store exam-level trait scores
CREATE TABLE exam_trait_score (
    id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    exam_id bigint NOT NULL,
    trait_id smallint NOT NULL,
    score smallint,
    condition_code varchar(10),
    INDEX idx__exam_trait_score__exam (exam_id),
    CONSTRAINT fk__exam_trait_score__exam FOREIGN KEY (exam_id) REFERENCES exam(id)
);

CREATE TABLE staging_exam_trait_score (
    id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    exam_id bigint NOT NULL,
    trait_id smallint NOT NULL,
    score smallint,
    condition_code varchar(10)
);
