
/**
** 	Initial data load
**/

USE ${schemaName};

INSERT INTO migrate_status (id, name) VALUES
  (-20, 'FAILED'),
  (-10, 'ABANDONED'),
  (10, 'STARTED'),
  (20, 'COMPLETED');

INSERT INTO subject (id, code) VALUES
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

INSERT INTO instructional_resource (name, resource) VALUES
  ('SBAC-IAB-FIXED-G3M-NBT-MATH-3', 'https://portal.smarterbalanced.org/library/en/v1.0/digital-library-connections-grade-3-number-and-operations-in-base-ten.docx'),
  ('SBAC-IAB-FIXED-G4E-Revision-ELA-4', 'https://portal.smarterbalanced.org/library/en/digital-library-connections-grade-4-revision.docx'),
  ('SBAC-IAB-FIXED-G4E-BriefWrites-ELA-4', 'https://portal.smarterbalanced.org/library/en/v1.0/digital-library-connections-grade-4-brief-writes.docx'),
  ('SBAC-IAB-FIXED-G5M-NF-MATH-5', 'https://portal.smarterbalanced.org/library/en/digital-library-connections-grade-5-fractions.docx'),
  ('SBAC-IAB-FIXED-G6M-G-Calc-MATH-6', 'https://portal.smarterbalanced.org/library/en/digital-library-connections-grade-6-geometry.docx'),
  ('SBAC-IAB-FIXED-G7E-ReadLit-ELA-7', 'https://portal.smarterbalanced.org/library/en/digital-library-connections-grade-7-read-literary-texts.docx'),
  ('SBAC-IAB-FIXED-G7M-RP-Calc-MATH-7', 'https://portal.smarterbalanced.org/library/en/digital-library-connections-grade-7-ratio-and-proportional-relationships.docx'),
  ('SBAC-IAB-FIXED-G8E-Research-ELA-8', 'https://portal.smarterbalanced.org/library/en/digital-library-connections-grade-8-research.docx'),
  ('SBAC-IAB-FIXED-G11E-BriefWrites-ELA-11','https://portal.smarterbalanced.org/library/en/digital-library-connections-high-school-brief-writes.docx'),
  ('SBAC-IAB-FIXED-G11E-Revision-ELA-11', 'https://portal.smarterbalanced.org/library/en/digital-library-connections-high-school-revision.docx'),
  ('SBAC-IAB-FIXED-G11M-SP-Calc-MATH-11', 'https://portal.smarterbalanced.org/library/en/digital-library-connections-high-school-statistics-and-probability.docx');

-- THE REST OF THE DATA IS LOADED VIA MIGRATE PROCESS