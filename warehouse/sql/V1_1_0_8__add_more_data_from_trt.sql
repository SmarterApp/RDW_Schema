-- store more data elements from TRT

USE ${schemaName};

CREATE TABLE IF NOT EXISTS response_type (
  id tinyint NOT NULL PRIMARY KEY,
  code varchar(10) NOT NULL UNIQUE
);

INSERT INTO response_type (id, code) VALUES
  (1, 'value'),
  (2, 'reference');

ALTER TABLE item
    ADD COLUMN field_test tinyint,
    ADD COLUMN active tinyint,
    ADD COLUMN type varchar(40);

ALTER TABLE exam
    ADD COLUMN examinee_id bigint,
    ADD COLUMN deliver_mode varchar(10),
    ADD COLUMN hand_score_project int,
    ADD COLUMN contract varchar(100),
    ADD COLUMN test_reason varchar(255),
    ADD COLUMN assessment_admin_started_at date,
    ADD COLUMN started_at timestamp(0),
    ADD COLUMN force_submitted_at timestamp(0),
    MODIFY COLUMN status_date timestamp(0),
    ADD COLUMN status varchar(50),
    ADD COLUMN item_count smallint,
    ADD COLUMN field_test_count smallint,
    ADD COLUMN pause_count  smallint, --
    ADD COLUMN grace_period_restarts smallint,
    ADD COLUMN abnormal_starts smallint,
    ADD COLUMN test_window_id varchar(50),
    ADD COLUMN test_administrator_id varchar(128),
    ADD COLUMN responsible_organization_name varchar(60),
    ADD COLUMN test_administrator_name varchar(128),
    ADD COLUMN session_platform_user_agent varchar(512),
    ADD COLUMN test_delivery_server varchar(128),
    ADD COLUMN test_delivery_db varchar(128),
    ADD COLUMN window_opportunity_count varchar(8),
    ADD COLUMN theta_score float,
    ADD COLUMN theta_score_std_err float;

ALTER TABLE audit_exam
    ADD COLUMN examinee_id bigint,
    ADD COLUMN deliver_mode varchar(10),
    ADD COLUMN hand_score_project int,
    ADD COLUMN contract varchar(100),
    ADD COLUMN test_reason varchar(255),
    ADD COLUMN assessment_admin_started_at date,
    ADD COLUMN started_at timestamp(0),
    ADD COLUMN force_submitted_at timestamp(0),
    MODIFY COLUMN status_date timestamp(0),
    ADD COLUMN status varchar(50),
    ADD COLUMN item_count smallint,
    ADD COLUMN field_test_count smallint,
    ADD COLUMN pause_count  smallint, --
    ADD COLUMN grace_period_restarts smallint,
    ADD COLUMN abnormal_starts smallint,
    ADD COLUMN test_window_id varchar(50),
    ADD COLUMN test_administrator_id varchar(128),
    ADD COLUMN responsible_organization_name varchar(60),
    ADD COLUMN test_administrator_name varchar(128),
    ADD COLUMN session_platform_user_agent varchar(512),
    ADD COLUMN test_delivery_server varchar(128),
    ADD COLUMN test_delivery_db varchar(128),
    ADD COLUMN window_opportunity_count varchar(8),
    ADD COLUMN theta_score float,
    ADD COLUMN theta_score_std_err float;

ALTER TABLE exam_claim_score
    ADD COLUMN theta_score float,
    ADD COLUMN theta_score_std_err float;

ALTER TABLE audit_exam_claim_score
    ADD COLUMN theta_score float,
    ADD COLUMN theta_score_std_err float;

ALTER TABLE exam_item
    ADD COLUMN administered_at timestamp(0),
    ADD COLUMN submitted tinyint,
    ADD COLUMN submitted_at timestamp(0),
    ADD COLUMN number_of_visits smallint,
    ADD COLUMN response_duration float,
    ADD COLUMN response_content_type varchar(50),
    ADD COLUMN client_id varchar(80),
    ADD COLUMN page_number smallint,
    ADD COLUMN page_visits smallint,
    ADD COLUMN page_time int,
    ADD COLUMN response_type_id tinyint,
    ADD INDEX idx__exam_item__response_type (response_type_id),
    ADD CONSTRAINT fk__exam_item__response_type FOREIGN KEY (response_type_id) REFERENCES response_type(id);

ALTER TABLE audit_exam_item
    ADD COLUMN administered_at timestamp(0),
    ADD COLUMN submitted tinyint,
    ADD COLUMN submitted_at timestamp(0),
    ADD COLUMN number_of_visits smallint,
    ADD COLUMN response_duration float,
    ADD COLUMN response_content_type varchar(50),
    ADD COLUMN client_id varchar(80),
    ADD COLUMN page_number smallint,
    ADD COLUMN page_visits smallint,
    ADD COLUMN page_time int,
    ADD COLUMN response_type_id tinyint;