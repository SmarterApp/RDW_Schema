/*
Initial data load for SBAC OLAP Reporting Data Warehouse 1.0.0
*/

SET SEARCH_PATH to ${schemaName};

INSERT INTO asmt_type (id, code, name) VALUES
  (1, 'ica', 'Interim Comprehensive'),
  (2, 'iab', 'Interim Assessment Block'),
  (3, 'sum', 'Summative');

INSERT INTO subject (id, code) VALUES
  (1, 'Math'),
  (2, 'ELA');

INSERT INTO exam_claim_score_mapping (subject_claim_score_id, num) VALUES
  (1, 1),
  (2, 2),
  (3, 3),
  (4, 1),
  (5, 2),
  (6, 3),
  (7, 4),
  (8, 1),
  (9, 2),
  (10, 3),
  (11, 1),
  (12, 2),
  (13, 3),
  (14, 4);

INSERT INTO status_indicator (id) VALUES
  (1);