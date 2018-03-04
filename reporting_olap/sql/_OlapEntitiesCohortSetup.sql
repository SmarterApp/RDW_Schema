INSERT INTO grade (id, code) VALUES (-3,'-3'),(-4 ,'-4'),(-5, '-5'),(-6, '-6');
INSERT INTO completeness (id, code) VALUES (-9, 'Complete'), (-8, 'Partial');
INSERT INTO administration_condition VALUES (-99,'IN'),(-98,'SD'),(-97,'NS'),(-96,'Valid');
INSERT INTO ethnicity VALUES (-29,'ethnicity-29'),(-28,'ethnicity-28'),(-27, 'ethnicity-27'), (-26, 'ethnicity-26');
INSERT INTO gender VALUES (-19,'gender-19'),(-18,'gender-18');
INSERT INTO school_year VALUES (1997),(1999),(2000),(2001);

-- ------------------------------------------ School/Districts --------------------------------------------------------------------------------------------------
INSERT INTO district (id, name, natural_id, external_id, migrate_id) VALUES
--  (-17, 'District-7', 'id-7', 'externalId-7', -1),
  (-18, 'District-8', 'id-8', 'externalId-8', -1),
  (-19, 'District-9', 'id-9', 'externalId-9', -1);

INSERT INTO school (id, district_group_id, district_id, school_group_id, name, natural_id, external_id, embargo_enabled, updated, update_import_id, migrate_id) VALUES
  (-7,  -1, -18, -1, 'School-7', 'id-7', 'externalId-7', 1, '2016-08-14 19:05:33.000000', -1, -1),
  (-8,  -1, -19, -1, 'School-8', 'id-8', 'externalId-8', 1, '2016-08-14 19:05:33.000000', -1, -1),
  (-9,  -1, -19, -1, 'School-9', 'id-9', 'externalId-9', 1, '2016-08-14 19:05:33.000000', -1, -1);

-- ------------------------------------------ Asmt ---------------------------------------------------------------------------------------------------------
INSERT INTO asmt (id, grade_id, subject_id, type_id, school_year, name, label, updated, update_import_id, migrate_id) VALUES
  (-3,  -3, 1, 1, 1997, 'asmt-3', 'asmt-3', '2016-08-14 19:05:33.000000', -1, -1),
  (-4,  -4, 1, 1, 1998, 'asmt-4', 'asmt-4', '2016-08-14 19:05:33.000000', -1, -1),
  (-5,  -5, 1, 1, 1999, 'asmt-5','asmt-5', '2016-08-14 19:05:33.000000', -1, -1),
  (-6,  -6, 1, 1, 2000, 'asmt-6','asmt-6', '2016-08-14 19:05:33.000000', -1, -1);

INSERT INTO asmt_active_year(asmt_id, school_year) VALUES
   (-3, 1997),
   (-4, 1998),
   (-5, 1999),
   (-6, 2000);

-- ------------------------------------------ Student and Groups  ------------------------------------------------------------------------------------------------
INSERT INTO student (id, gender_id, updated, update_import_id, migrate_id) VALUES
  (-100, -18, '2016-08-14 19:05:33.000000', -1, -1),
  (-101, -18, '2016-08-14 19:05:33.000000', -1, -1),
  (-102, -18, '2016-08-14 19:05:33.000000', -1, -1),
  (-103, -19, '2016-08-14 19:05:33.000000', -1, -1),
  (-104, -19, '2016-08-14 19:05:33.000000', -1, -1),
  (-105, -19, '2016-08-14 19:05:33.000000', -1, -1),
  (-150, -19, '2016-08-14 19:05:33.000000', -1, -1),
  (-200, -19, '2016-08-14 19:05:33.000000', -1, -1);

-- ------------------------------------------ Exams ---------------------------------------------------------------------------------------------
INSERT INTO  fact_student_exam (id, school_year, asmt_id, grade_id, student_id, school_id,
                                    completeness_id, administration_condition_id, performance_level,
                                    scale_score, scale_score_std_err,
                                    iep, lep, section504, economic_disadvantage, migrant_status,
                                    claim1_scale_score, claim1_scale_score_std_err,claim1_category,
                                    claim2_scale_score, claim2_scale_score_std_err,claim2_category,
                                    claim3_scale_score, claim3_scale_score_std_err,claim3_category,
                                    claim4_scale_score, claim4_scale_score_std_err,claim4_category,
                                    completed_at, updated, update_import_id, migrate_id) VALUES
-- school -9 over years
-- id represents - the last digit of year, school id (one digit) + student id
  (-79100,  1997, -3, -3, -100, -9,  -8, -98, 1, 2500, 25,  1, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),
  (-79102,  1997, -3, -4, -102, -9,  -9, -98, 2, 2400, 24,  0, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),
  (-79103,  1997, -3, -5, -103, -9,  -9, -99, 3, 2300, 23,  1, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),
  (-79104,  1997, -3, -4, -104, -9,  -9, -99, 4, 2100, 21,  0, 1, 2, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),
  (-79105,  1997, -3, -5, -105, -9,  -9, -99, 1, 2000, 20,  1, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),
  (-79106,  1997, -4, -4, -150, -9,  -9, -99, 1, 2000, 20,  1, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),

  (-89100,  1998, -4, -4, -100, -9,  -8, -98, 1, 2500, 25,  1, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),
--  (-89102,  1998, -4, -5, -102, -9,  -9, -98, 2, 2400, 24,  0, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),
  (-89103,  1998, -4, -6, -103, -9,  -9, -99, 3, 2300, 23,  1, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),
  (-89104,  1998, -4, -5, -104, -9,  -9, -99, 4, 2100, 21,  0, 1, 2, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),
  (-89105,  1998, -4, -6, -105, -9,  -9, -99, 1, 2000, 20,  1, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),
  (-99106,  1998, -5, -5, -150, -9,  -9, -99, 1, 2000, 20,  1, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),


  (-99100,  1999, -5, -5, -100, -9,  -8, -98, 1, 2500, 25,  1, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),
  (-99102,  1999, -5, -6, -102, -9,  -9, -98, 2, 2400, 24,  0, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),
--  (-99103,  1999, -5, -7, -103, -9,  -9, -99, 3, 2300, 23,  1, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),
  (-99104,  1999, -5, -6, -104, -9,  -9, -99, 4, 2100, 21,  0, 1, 2, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),
  (-99105,  1999, -5, -7, -105, -9,  -9, -99, 1, 2000, 20,  1, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),
  (-99150,  1999, -6, -6, -150, -9,  -9, -99, 1, 2000, 20,  1, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),

-- school -8 over years
 (-88102,  1998, -4, -4, -102, -8,  -8, -98, 1, 2500, 25,  1, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),

-- school -7, different district
 (-77200,  1997, -3, -3, -200, -7,  -9, -98, 1, 2500, 25,  1, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),
 (-77101,  1997, -3, -3, -101, -7,  -9, -98, 1, 2500, 25,  1, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),

 (-87200,  1998, -4, -4, -200, -7,  -9, -98, 1, 2500, 25,  1, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),

 (-97200,  1999, -5, -4, -200, -7,  -9, -98, 1, 2500, 25,  1, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1),
 (-97103,  1999, -5, -4, -103, -7,  -9, -98, 1, 2500, 25,  1, 1, 0, 0, 1,  2000, 0.11, 1, 2100, 0.12, 2, 2500, 0.13, 3, 3500, .15, 4, '2016-08-14 19:05:33.000000', '2016-09-14 19:05:33.000000', -1, -1);
