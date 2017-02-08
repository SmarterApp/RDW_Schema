/**
 **  Sample data parsed from ETS provided TRT-like XML
 */
INSERT INTO asmt (id, natural_id, grade_id,type_id, subject_id, academic_year, name, label, version) VALUES
  (2, '(SBAC)SBAC-IAB-FIXED-G4M-OA-MATH-4-Winter-2016-2017', 4, 2, 1, 2016, 'SBAC-IAB-FIXED-G4M-OA-MATH-4', 'MTH IAB G4 OperationsAlgebraicThinking', '9835');

-- TODO: How to find a claim? Does it even exist?
INSERT INTO claim (id, asmt_id, min_score, max_score, code) VALUES
  (5, 2, null, null, 'OA');

-- TODO: should min/max be taken from assmt packge?
INSERT INTO item (id, claim_id, target_id, item_key, bank_key) VALUES
  (2010,  5, null, 2010,  '200'),
  (18943, 5, null, 18943, '200'),
  (8906,  5, null, 8906,  '200'),
  (2014,  5, null, 2014,  '200'),
  (2024,  5, null, 2024,  '200'),
  (13980, 5, null, 13980, '200'),
  (29233, 5, null, 29233, '200'),
  (2018,  5, null, 2018,  '200'),
  (11443, 5, null, 11443, '200'),
  (30075, 5, null, 30075, '200'),
  (18804, 5, null, 18804, '200'),
  (45230, 5, null, 45230, '200'),
  (2002,  5, null, 2002, '200'),
  (18461, 5, null, 18461, '200'),
  (13468, 5, null, 13468, '200'),
  (14461, 5, null, 14461, '200');

INSERT IGNORE INTO district (id, name, natural_id) VALUES
  (1, 'Sample District 1', '01247430000000');

INSERT IGNORE INTO school (id, district_id, name, natural_id) VALUES
  (1, 1, 'Sample School 1', '30664640124743');

INSERT IGNORE INTO state (code) VALUES
  ('SM');

INSERT INTO student (id, ssid, last_or_surname, first_name, middle_name, gender_id, ethnicity_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, is_demo, birthday) VALUES
  (2, '2222222222', 'LastName2', 'FirstName2', 'MiddleName2', 1, 3, '2012-08-14', '2012-11-13', null, false, '2000-01-01');

INSERT INTO roster (id, created_by, school_id, name, exam_from, exam_to, subject_id) VALUES
  (2, 'dwtest@example.com', 1, 'Test Student Group 2', null, '2017-08-01', 1);

INSERT INTO roster_membership (roster_id, student_id) VALUES
  (2, 2);

INSERT INTO user_roster (roster_id, user_login) VALUES
  (2, 'dwtest@example.com');

INSERT INTO iab_exam_student (id, grade_id, student_id, school_id, iep, lep, section504, economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type, language_code, prim_disability_type) VALUES
  (2, 4, 2, 1, null, null, null, null, 0, 'EL', null,'VIE', null);

INSERT INTO iab_exam (id, iab_exam_student_id, asmt_id, asmt_version, opportunity, status, validity, completeness, administration_condition_id, session_id, claim_id, claim_scale_score, claim_scale_score_std_err, claim_level, asmt_session_location_id) VALUES
  (1, 2, 2, null, 0, 'completed', 1, 1, 1, 'CA-3ACF-69', 5, 2412.74552705744, 30.4087233385275, 1, null);

-- TODO: this needs more research.
-- INSERT INTO exam_available_accommodation (exam_id, accommodation_id) VALUES ...

INSERT INTO iab_exam_item (iab_exam_id, item_id, score, score_status, response) VALUES
  (1,  2010, 1, 'SCORED', '<response><math xmlns="http://www.w3.org/1998/Math/MathML" title="10"><mstyle><mn>10</mn></mstyle></math></response>'),
  (1,  18943,1, 'SCORED', 'D'),
  (1,  8906, 0, 'SCORED', 'C'),
  (1,  2014, 0, 'SCORED', '<response><math xmlns="http://www.w3.org/1998/Math/MathML" title="46"><mstyle><mn>46</mn></mstyle></math></response>'),
  (1,  2024, 0, 'SCORED', '<response><math xmlns="http://www.w3.org/1998/Math/MathML" title="68"><mstyle><mn>68</mn></mstyle></math></response>'),
  (1,  13980,0, 'SCORED', 'A'),
  (1,  29233,1, 'SCORED', '<itemResponse><response id="RESPONSE"><value>1 b</value><value>2 a</value><value>3 a</value><value>4 b</value></response></itemResponse>'),
  (1,  2018, 1, 'SCORED', '<response><math xmlns="http://www.w3.org/1998/Math/MathML" title="63"><mstyle><mn>63</mn></mstyle></math></response>'),
  (1,  11443,0, 'SCORED', '<itemResponse><response id="RESPONSE"><value>1 b</value><value>2 b</value><value>3 b</value></response></itemResponse>'),
  (1,  30075,1, 'SCORED', 'B'),
  (1,  18804,1, 'SCORED', 'A'),
  (1,  45230,0, 'SCORED', 'A'),
  (1,  2002, 0, 'SCORED', '<response><math xmlns="http://www.w3.org/1998/Math/MathML" title="23×5.75"><mstyle><mn>23</mn><mo>×</mo><mn>5.75</mn></mstyle></math></response>'),
  (1,  18461,0, 'SCORED', '<response><math xmlns="http://www.w3.org/1998/Math/MathML" title="13w"><mstyle><mn>13</mn><mi>w</mi></mstyle></math></response>'),
  -- TODO: not sure what score - 1 means, looks like it means no response
  (1,  13468, -1, 'SCORED', null),
  (1,  14461, -1, 'SCORED', null);
