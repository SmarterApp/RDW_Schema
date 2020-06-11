-- v2.4.0 flyway script
--
-- adds support for exam trait scores

use ${schemaName};

-- store trait report flag by subject/assessment
-- default to false except for ELA Summative
ALTER TABLE subject_asmt_type ADD COLUMN trait_report tinyint;
UPDATE subject_asmt_type SET trait_report = IF(asmt_type_id = 3 AND subject_id = 2, 1, 0);
ALTER TABLE subject_asmt_type MODIFY COLUMN trait_report tinyint NOT NULL;

-- table to store trait codes by subject
CREATE TABLE subject_trait (
    id smallint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    subject_id smallint NOT NULL,
    code varchar(20) NOT NULL,
    purpose varchar(10) NOT NULL,
    category varchar(10) NOT NULL,
    INDEX idx__trait__subject (subject_id),
    CONSTRAINT fk__trait__subject FOREIGN KEY (subject_id) REFERENCES subject(id),
    UNIQUE INDEX idx__subject_trait__subject_code(subject_id, code)
);

-- enter known ELA WER traits
-- (include id for consistency with reporting database update)
INSERT INTO subject_trait (id, subject_id, code, purpose, category) VALUES
(01, 2, 'SOCK_ARGU_ORG', 'ARGU', 'ORG'),
(02, 2, 'SOCK_ARGU_CON', 'ARGU', 'CON'),
(03, 2, 'SOCK_ARGU_EVI', 'ARGU', 'EVI'),
(04, 2, 'SOCK_EXPL_ORG', 'EXPL', 'ORG'),
(05, 2, 'SOCK_EXPL_CON', 'EXPL', 'CON'),
(06, 2, 'SOCK_EXPL_EVI', 'EXPL', 'EVI'),
(07, 2, 'SOCK_INFO_ORG', 'INFO', 'ORG'),
(08, 2, 'SOCK_INFO_CON', 'INFO', 'CON'),
(09, 2, 'SOCK_INFO_EVI', 'INFO', 'EVI'),
(10, 2, 'SOCK_NARR_ORG', 'NARR', 'ORG'),
(11, 2, 'SOCK_NARR_CON', 'NARR', 'CON'),
(12, 2, 'SOCK_NARR_EVI', 'NARR', 'EVI'),
(13, 2, 'SOCK_OPIN_ORG', 'OPIN', 'ORG'),
(14, 2, 'SOCK_OPIN_CON', 'OPIN', 'CON'),
(15, 2, 'SOCK_OPIN_EVI', 'OPIN', 'EVI');

-- table to store exam-level trait scores
CREATE TABLE exam_trait_score (
    id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    exam_id bigint NOT NULL,
    trait_id smallint NOT NULL,
    score float,
    stderr float,
    condition_code varchar(10),
    INDEX idx__exam_trait_score__exam (exam_id),
    CONSTRAINT fk__exam_trait_score__exam FOREIGN KEY (exam_id) REFERENCES exam(id)
);

-- audit table and triggers for exam trait score entries
CREATE TABLE IF NOT EXISTS audit_exam_trait_score (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    action VARCHAR(8) NOT NULL,
    audited TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL,
    database_user VARCHAR(255) NOT NULL,
    exam_trait_score_id bigint NOT NULL,
    exam_id bigint NOT NULL,
    trait_id smallint NOT NULL,
    score float,
    stderr float,
    condition_code varchar(10)
);

CREATE TRIGGER trg__exam_trait_score__update
    BEFORE UPDATE ON exam_trait_score
    FOR EACH ROW
    INSERT INTO audit_exam_trait_score (action, database_user, exam_trait_score_id, exam_id, trait_id, score, stderr, condition_code)
    SELECT 'update', USER(), OLD.id, OLD.exam_id, OLD.trait_id, OLD.score, OLD.stderr, OLD.condition_code
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

CREATE TRIGGER trg__exam_trait_score__delete
    BEFORE DELETE ON exam_trait_score
    FOR EACH ROW
    INSERT INTO audit_exam_trait_score (action, database_user, exam_trait_score_id, exam_id, trait_id, score, stderr, condition_code)
    SELECT 'delete', USER(), OLD.id, OLD.exam_id, OLD.trait_id, OLD.score, OLD.stderr, OLD.condition_code
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';
