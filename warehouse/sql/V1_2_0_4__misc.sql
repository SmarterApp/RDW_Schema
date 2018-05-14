-- Two miscellaneous changes ...

USE ${schemaName};

-- this isn't used anywhere
DROP TABLE upload_student_group_status;

-- need difficulty-cuts to calculate difficulty for summative items
INSERT INTO item_difficulty_cuts (id, asmt_type_id, subject_id, grade_id, moderate_low_end, difficult_low_end) VALUES
  (29, 3, 2, 3, -1.93882, -0.43906),
  (30, 3, 2, 4, -1.51022, 0.14288),
  (31, 3, 2, 5, -1.07082, 0.55842),
  (32, 3, 2, 6, -0.88783, 0.88783),
  (33, 3, 2, 7, -0.72150, 1.06739),
  (34, 3, 2, 8, -0.47018, 1.34599),
  (35, 3, 2, 11, -0.38186, 1.54790),

  (36, 3, 1, 3, -1.86632, -0.61482),
  (37, 3, 1, 4, -1.33005, -0.00367),
  (38, 3, 1, 5, -0.98177, 0.42321),
  (39, 3, 1, 6, -0.74333, 0.74333),
  (40, 3, 1, 7, -0.61866, 0.91307),
  (41, 3, 1, 8, -0.50969, 1.19076),
  (42, 3, 1, 11, -0.34891, 1.60976);
