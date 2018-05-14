/*
Initial data load for SBAC OLAP Reporting Data Warehouse 1.0.0
*/

SET SEARCH_PATH to ${schemaName};

INSERT INTO strict_boolean (id, code) VALUES
  (0, 'no'),
  (1, 'yes');

INSERT INTO boolean (id, code) VALUES
  (0, 'no'),
  (1, 'yes'),
  (2, 'undefined');

INSERT INTO asmt_type (id, code) VALUES
  (1, 'ica'),
  (2, 'iab'),
  (3, 'sum');

INSERT INTO subject (id, code) VALUES
  (1, 'Math'),
  (2, 'ELA');

INSERT INTO subject_claim_score (id, subject_id, asmt_type_id, code) VALUES
  (1,  1, 1, '1'),
  (2,  1, 1, 'SOCK_2'),
  (3,  1, 1, '3'),
  (4,  2, 1, 'SOCK_R'),
  (5,  2, 1, 'SOCK_LS'),
  (6,  2, 1, '2-W'),
  (7,  2, 1, '4-CR'),
  (8,  1, 3, '1'),
  (9,  1, 3, 'SOCK_2'),
  (10, 1, 3, '3'),
  (11, 2, 3, 'SOCK_R'),
  (12, 2, 3, 'SOCK_LS'),
  (13, 2, 3, '2-W'),
  (14, 2, 3, '4-CR');

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