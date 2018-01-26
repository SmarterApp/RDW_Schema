-- Add user report metadata to contain report-type-specific information

CREATE TABLE user_report_metadata (
  report_id BIGINT NOT NULL,
  name VARCHAR(50) NOT NULL,
  value VARCHAR(255) NOT NULL,
  PRIMARY KEY (report_id, name),
  CONSTRAINT fk__user_report__report_id FOREIGN KEY (report_id) REFERENCES user_report (id) ON DELETE CASCADE
);