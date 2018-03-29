-- Add a reporting.user_report.report_type column identifying the type of user report

USE ${schemaName};

ALTER TABLE user_report
  ADD COLUMN report_type VARCHAR(100);
