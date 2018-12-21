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

-- NOTE: this is done for the historical reason in order to load records ingested BEFORE configurable subjects
-- It will be updated during the migrate
INSERT INTO subject (id, code, updated, update_import_id, migrate_id) VALUES
  (1, 'Math', now(), -1, -1),
  (2, 'ELA',  now(), -1, -1);

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

INSERT INTO subject_asmt_type (asmt_type_id, subject_id, performance_level_count, performance_level_standard_cutoff, claim_score_performance_level_count, target_report) VALUES
  (1,  1,  4, 3,    3,    false),
  (1,  2,  4, 3,    3,    false),
  (2,  1,  3, null, null, false),
  (2,  2,  3, null, null, false),
  (3,  1,  4, 3,    3,    true),
  (3,  2,  4, 3,    3,    true);

INSERT INTO status_indicator (id) VALUES
  (1);
