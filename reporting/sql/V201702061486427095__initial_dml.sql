
/**
** 	Initial data load
**/

USE ${schemaName};

INSERT INTO application_schema_version (major_version) VALUES (0);

INSERT INTO migrate_status (id, name) VALUES
  (-20, 'FAILED'),
  (-10, 'ABANDONED'),
  (10, 'STARTED'),
  (20, 'COMPLETED');

INSERT INTO subject (id, name) VALUES
  (1, 'Math'),
  (2, 'ELA');

INSERT INTO asmt_type (id, code, name) VALUES
  (1, 'ica', 'Interim Comprehensive'),
  (2, 'iab', 'Interim Assessment Block'),
  (3, 'sum', 'Summative');

INSERT INTO subject_claim_score (id, subject_id, asmt_type_id, code, name) VALUES
  (1,  1, 1, '1', 'Concepts' ),
  (2,  1, 1, 'SOCK_2', 'PSMDA (Problem Solving and Modeling & Data Analysis)'),
  (3,  1, 1, '3', 'Reasoning'),
  (4,  2, 1, 'SOCK_R' , 'Reading'),
  (5,  2, 1, 'SOCK_LS', 'Listening'),
  (6,  2, 1, '2-W', 'Writing'),
  (7,  2, 1, '4-CR', 'Research'),
  (8,  1, 3, '1', 'Concepts' ),
  (9,  1, 3, 'SOCK_2', 'PSMDA (Problem Solving and Modeling & Data Analysis)'),
  (10, 1, 3, '3', 'Reasoning'),
  (11, 2, 3, 'SOCK_R' , 'Reading'),
  (12, 2, 3, 'SOCK_LS', 'Listening'),
  (13, 2, 3, '2-W', 'Writing'),
  (14, 2, 3, '4-CR', 'Research');

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

-- THE REST OF THE DATA IS LOADED VIA MIGRATE PROCESS