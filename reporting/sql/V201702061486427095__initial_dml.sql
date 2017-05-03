
/**
** 	Initial data load
**/

USE `${schemaName}`;

INSERT INTO application_schema_version (major_version) VALUES (0);

INSERT INTO migrate_status (id, name) VALUES
  (-20, 'FAILED'),
  (-10, 'ABANDONED'),
  (10, 'STARTED'),
  (20, 'COMPLETED');

INSERT INTO subject (id, name) VALUES
  (1, 'Math'),
  (2, 'ELA');

INSERT INTO grade (id, code, name) VALUES
  (16, 'IT', 'Infant/toddler'),
  (17, 'PR', 'Preschool'),
  (18, 'PK', 'Prekindergarten'),
  (19, 'TK', 'Transitional Kindergarten'),
  (0,  'KG', 'Kindergarten'),
  (1,  '01', 'First grade'),
  (2,  '02', 'Second grade'),
  (3,  '03', 'Third grade'),
  (4,  '04', 'Fourth grade'),
  (5,  '05', 'Fifth grade'),
  (6,  '06', 'Sixth grade'),
  (7,  '07', 'Seventh grade'),
  (8,  '08', 'Eighth grade'),
  (9,  '09', 'Ninth grade'),
  (10, '10', 'Tenth grade'),
  (11, '11', 'Eleventh grade'),
  (12, '12', 'Twelfth grade'),
  (13, '13', 'Grade 13'),
  (14, 'PS', 'Postsecondary'),
  (15, 'UG', 'Ungraded');

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

INSERT INTO completeness (id, name) VALUES
  (1, 'Partial'),
  (2, 'Complete');

INSERT INTO administration_condition (id, name) VALUES
  (1, 'Valid'),
  (2, 'SD'),
  (3, 'NS'),
  (4, 'IN');

INSERT INTO ethnicity (id, name) VALUES
  (1, 'HispanicOrLatinoEthnicity'),
  (2, 'AmericanIndianOrAlaskaNative'),
  (3, 'Asian'),
  (4, 'BlackOrAfricanAmerican'),
  (5, 'White'),
  (6, 'NativeHawaiianOrOtherPacificIslander'),
  (7, 'DemographicRaceTwoOrMoreRaces'),
  (8, 'Filipino');

INSERT INTO gender (id, name) VALUES
  (1, 'Male'),
  (2, 'Female');

INSERT INTO item_difficulty_cuts (id, asmt_type_id, subject_id, grade_id, moderate_low_end, difficult_low_end) VALUES
  (1, 1, 2, 3, -1.93882, -0.43906),
  (2, 1, 2, 4, -1.51022, 0.14288),
  (3, 1, 2, 5, -1.07082, 0.55842),
  (4, 1, 2, 6, -0.88783, 0.88783),
  (5, 1, 2, 7, -0.72150, 1.06739),
  (6, 1, 2, 8, -0.47018, 1.34599),
  (7, 1, 2, 11, -0.38186, 1.54790),

  (8, 1, 1, 3, -1.86632, -0.61482),
  (9, 1, 1, 4, -1.33005, -0.00367),
  (10, 1, 1, 5, -0.98177, 0.42321),
  (11, 1, 1, 6, -0.74333, 0.74333),
  (12, 1, 1, 7, -0.61866, 0.91307),
  (13, 1, 1, 8, -0.50969, 1.19076),
  (14, 1, 1, 11, -0.34891, 1.60976),

  (15, 2, 2, 3, -1.93882, -0.43906),
  (16, 2, 2, 4, -1.51022, 0.14288),
  (17, 2, 2, 5, -1.07082, 0.55842),
  (18, 2, 2, 6, -0.88783, 0.88783),
  (19, 2, 2, 7, -0.72150, 1.06739),
  (20, 2, 2, 8, -0.47018, 1.34599),
  (21, 2, 2, 11, -0.38186, 1.54790),

  (22, 2, 1, 3, -1.86632, -0.61482),
  (23, 2, 1, 4, -1.33005, -0.00367),
  (24, 2, 1, 5, -0.98177, 0.42321),
  (25, 2, 1, 6, -0.74333, 0.74333),
  (26, 2, 1, 7, -0.61866, 0.91307),
  (27, 2, 1, 8, -0.50969, 1.19076),
  (28, 2, 1, 11, -0.34891, 1.60976);

INSERT INTO depth_of_knowledge (id, level, subject_id, description, reference) VALUES
  (1, 1, 1, 'Recall and Reproduction', 'https://portal.smarterbalanced.org/library/en/mathematics-content-specifications.pdf#page=72'),
  (2, 2, 1, 'Basic Skills and Concepts', 'https://portal.smarterbalanced.org/library/en/mathematics-content-specifications.pdf#page=72'),
  (3, 3, 1, 'Strategic Thinking and Reasoning', 'https://portal.smarterbalanced.org/library/en/mathematics-content-specifications.pdf#page=72'),
  (4, 4, 1, 'Extended Thinking', 'https://portal.smarterbalanced.org/library/en/mathematics-content-specifications.pdf#page=72'),
  (5, 1, 2, 'Recall and Reproduction', 'https://portal.smarterbalanced.org/library/en/english-language-artsliteracy-content-specifications.pdf#page=54'),
  (6, 2, 2, 'Basic Skills and Concepts', 'https://portal.smarterbalanced.org/library/en/english-language-artsliteracy-content-specifications.pdf#page=54'),
  (7, 3, 2, 'Strategic Thinking and Reasoning', 'https://portal.smarterbalanced.org/library/en/english-language-artsliteracy-content-specifications.pdf#page=54'),
  (8, 4, 2, 'Extended Thinking', 'https://portal.smarterbalanced.org/library/en/english-language-artsliteracy-content-specifications.pdf#page=54');

INSERT INTO math_practice (practice, description) VALUES
  (1, 'Make sense of problems and persevere in solving them'),
  (2, 'Reason abstractly and quantitatively'),
  (3, 'Construct viable arguments and critique the reasoning of others'),
  (4, 'Model with mathematics'),
  (5, 'Use appropriate tools strategically'),
  (6, 'Attend to precision'),
  (7, 'Look for and make use of structure'),
  (8, 'Look for and express regularity in repeated reasoning');

-- below data is loaded from https://github.com/SmarterApp/SS_CoreStandards/tree/master/Documents/Imports

INSERT INTO claim (id, subject_id, code, name, description) VALUES
  (1, 2, '1-IT', 'Read Analytically: Informational Text', 'Read Analytically: Informational Text - Students can read closely and analytically to comprehend a range of increasingly complex literary and informational texts.'),
  (2, 2, '1-LT', 'Read Analytically: Literary Text', 'Read Analytically: Literary Text - Students can read closely and analytically to comprehend a range of increasingly complex literary and informational texts.'),
  (3, 2, '2-W', 'Write Effectively', 'Write Effectively - Students can produce effective and well-grounded writing for a range of purposes and audiences.'),
  (4, 2, '3-L', 'Listen Purposefully', 'Speak and Listen purposefully - Students can employ effective speaking and listening skills for a range of purposes and audiences.'),
  (5, 2, '3-S', 'Speak Purposefully', 'Speak and Listen purposefully - Students can employ effective speaking and listening skills for a range of purposes and audiences.'),
  (6, 2, '4-CR', 'Conduct Research', 'Conduct Research - Students can engage in research/ inquiry to investigate topics and to analyze, integrate, and present information.'),
  (7, 2, 'NA', 'NA', 'NA'),
  (8, 1, '1', 'Concepts and Procedures', 'Concepts and Procedures - Students can explain and apply mathematical concepts and interpret and carry out mathematical procedures with precision and fluency.'),
  (9, 1, '2', 'Problem Solving', 'Problem Solving - Students can solve a range of complex well-posed problems in pure and applied mathematics, making productive use of knowledge and problem solving strategies.'),
  (10, 1, '3', 'Communicating Reasoning', 'Communicating Reasoning - Students can clearly and precisely construct viable arguments to support their own reasoning and to critique the reasoning of others.'),
  (11, 1, '4', 'Modeling and Data Analysis', 'Modeling and Data Analysis - Students can analyze complex, real-world scenarios and can construct and use mathematical models to interpret and solve problems.');

-- TODO: missing target and claims data