/**
 **  Sample data parsed from ETS provided TRT-like XML
 */
use reporting;

INSERT INTO asmt (id, natural_id, grade_id,type_id, subject_id, academic_year, name, label, version) VALUES
  (1, 'SBAC)SBAC-ICA-FIXED-G5E-COMBINED-2017-Winter-2016-2017', 5, 1, 2, 2016, 'SBAC-ICA-FIXED-G5E-COMBINED-2017', 'Grade 5 ELA', '9831');

INSERT INTO asmt_score (asmt_id, cut_point_1, cut_point_2, cut_point_3, min_score, max_score) VALUES
  (1, 2442, 2502, 2582, 2201, 2701);

-- TODO: currently item to claim assignment is random
INSERT INTO item (id, claim_id, target_id, natural_id, asmt_id, dok, difficulty, max_points, math_practice, allow_calc) VALUES
  (60347, 1, null, '200-60347', 1, 2, -0.32, 1, null, null),
  (51719, 1, null, '200-51719', 1, 2, -1.32, 1, null, null),
  (59217, 1, null, '200-59217', 1, 2, -2.32, 1, null, null),
  (59208, 1, null, '200-59208', 1, 2, -0.32, 1, null, null),
  (30901, 1, null, '200-30901', 1, 2, -0.32, 1, null, null),
  (30899, 1, null, '200-30899', 1, 2,  0.32, 1, null, null),
  (30891, 1, null, '200-30891', 1, 2, -0.32, 1, null, null),
  (32604, 1, null, '200-32604', 1, 2, -1.32, 1, null, null),
  (58465, 1, null, '200-58465', 1, 2, -2.32, 1, null, null),
  (43427, 1, null, '200-43427', 1, 2,  0.32, 1, null, null),
  (43440, 1, null, '200-43440', 1, 2,  1.32, 1, null, null),
  (54097, 1, null, '200-54097', 1, 2, -0.32, 1, null, null),
  (58401, 2, null, '200-58401', 1, 2, -0.32, 1, null, null),
  (43423, 2, null, '200-43423', 1, 2, -0.34, 1, null, null),
  (41656, 2, null, '200-41656', 1, 2, -0.34, 1, null, null),
  (35901, 2, null, '200-35901', 1, 2, -0.14, 1, null, null),
  (35903, 2, null, '200-35903', 1, 2, -0.14, 1, null, null),
  (35905, 2, null, '200-35905', 1, 2, -0.14, 1, null, null),
  (63424, 2, null, '200-63424', 1, 2, -0.34, 1, null, null),
  (30153, 2, null, '200-30153', 1, 2, -0.32, 1, null, null),
  (26487, 2, null, '200-26487', 1, 2, -0.32, 1, null, null),
  (27817, 3, null, '200-27817', 1, 2, -0.32, 1, null, null),
  (26485, 3, null, '200-26485', 1, 2, -0.32, 1, null, null),
  (26475, 3, null, '200-26475', 1, 2, -0.32, 1, null, null),
  (27823, 3, null, '200-27823', 1, 2, -0.27, 1, null, null),
  (26483, 3, null, '200-26483', 1, 2, -0.27, 1, null, null),
  (26465, 3, null, '200-26465', 1, 2,  0.27, 1, null, null),
  (33850, 3, null, '200-33850', 1, 2,  0.27, 1, null, null),
  (33848, 3, null, '200-33848', 1, 2,  0.27, 1, null, null),
  (33846, 3, null, '200-33846', 1, 2,  0.37, 1, null, null),
  (32360, 3, null, '200-32360', 1, 2, -0.37, 1, null, null),
  (31902, 3, null, '200-31902', 1, 2, -0.37, 1, null, null),
  (28209, 3, null, '200-28209', 1, 2, -0.32, 1, null, null),
  (28203, 3, null, '200-28203', 1, 2, -0.32, 1, null, null),
  (28215, 4, null, '200-28215', 1, 2, -0.32, 1, null, null),
  (28205, 4, null, '200-28205', 1, 2, -0.32, 1, null, null),
  (30149, 4, null, '200-30149', 1, 2, -0.32, 1, null, null),
  (32372, 4, null, '200-32372', 1, 2, -0.32, 1, null, null),
  (41676, 4, null, '200-41676', 1, 2, -0.32, 1, null, null),
  (54456, 4, null, '200-54456', 1, 2,  1.16, 1, null, null),
  (54466, 4, null, '200-54466', 1, 2,  1.16, 1, null, null),
  (54458, 4, null, '200-54458', 1, 2,  1.16, 1, null, null),
  (54452, 4, null, '200-54452', 1, 2,  1.16, 1, null, null),
  (54141, 4, null, '200-54141', 1, 2, -0.32, 1, null, null),
  (61136, 4, null, '200-61136', 1, 2, -0.32, 1, null, null),
  (61138, 4, null, '200-61138', 1, 2, -0.32, 1, null, null),
  (54683, 4, null, '200-54683', 1, 2, -0.32, 1, null, null);

-- NOTE: ETS samples with anonymized data do not have names for school and district
INSERT IGNORE INTO district (id, name, natural_id) VALUES
  (1, 'Sample District 1', '01247430000000');

INSERT IGNORE INTO school (id, district_id, name, natural_id) VALUES
  (1, 1, 'Sample School 1', '30664640124743');

INSERT IGNORE INTO state (code) VALUES
  ('SM');

INSERT INTO student (id, ssid, last_or_surname, first_name, middle_name, gender_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, birthday) VALUES
  (1, '6666666666', 'LastName6', 'FirstName6', 'MiddleName6', 1, '2015-09-01', null, null, '2006-01-01');

INSERT INTO student_group (id, created_by, school_id, name, exam_from, exam_to, subject_id) VALUES
  (1, 'dwtest@example.com', 1, 'Test Student Group', null, '2017-08-01', 2);

INSERT INTO student_group_membership (student_group_id, student_id) VALUES
  (1, 1);

INSERT INTO user_student_group (student_group_id, user_login) VALUES
  (1, 'dwtest@example.com');

INSERT INTO exam_student (id, grade_id, student_id, school_id, iep, lep, section504, economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type, language_code, prim_disability_type) VALUES
  (1, 5, 1, 1, 0, 0, 0, 0, null, 'EO', null,'ENG', null);

INSERT INTO exam (id, exam_student_id, asmt_id, asmt_version, opportunity, status, completeness_id, administration_condition_id, session_id, scale_score, scale_score_std_err, achievement_level, completed_at) VALUES
  (1, 1, 1, null, 0, 'completed', 1, 1, 'CA-3ACF-69', 2642.54836495757, 27.6925766459382, 4, '2016-08-14');

-- TODO: this needs more research. There are some mismatched codes and it is not clear what is available and what needs to be stored
-- INSERT INTO exam_available_accommodation (exam_id, accommodation_id) VALUES ...

INSERT INTO exam_claim_score (id, exam_id, subject_claim_score_id, scale_score, scale_score_std_err, category) VALUES
  (1, 1, 4, 2577.80680893986, 46.7512956510613, 3),
  (2, 1, 5, 2668.81750838064, 67.885043404398, 3),
  (3, 1, 6, 2701.23284, 101.838594705009, 3),
  (4, 1, 7, 2657.87221487352, 42.9833504368907, 3);

INSERT INTO exam_item (exam_id, item_natural_id, score, score_status, response, position, max_score) VALUES
  (1, '200-60347', 1, 'SCORED', 'D', 1, 2),
  (1, '200-51719', 1, 'SCORED', 'B', 2, 2),
  (1, '200-59217', 1, 'SCORED', 'D', 3, 2),
  (1, '200-30901', 1, 'SCORED', 'C', 4, 2),
  (1, '200-30899', 1, 'SCORED', 'B', 5, 2),
  (1, '200-30891', 1, 'SCORED', '<itemResponse><response id="EBSR1"><value>A</value></response><response id="EBSR2"><value>D</value></response></itemResponse>', 6, 2),
  (1, '200-32604', 1, 'SCORED', 'C', 7, 2),
  (1, '200-58465', 1, 'SCORED', 'C,E', 8, 2),
  (1, '200-43427', 1, 'SCORED', 'A', 9, 2),
  (1, '200-43440', 1, 'SCORED', 'A', 10, 2),
  (1, '200-54097', 1, 'SCORED', '<itemResponse><response id="1"><value>3</value><value>5</value></response></itemResponse>', 11, 2),
  (1, '200-58401', 1, 'SCORED', '<itemResponse><response id="EBSR1"><value>C</value></response><response id="EBSR2"><value>A</value></response></itemResponse>', 12, 2),
  (1, '200-43423', 1, 'SCORED', 'E, F', 13, 2),
  (1, '200-41656', 1, 'SCORED', 'C', 14, 2),
  (1, '200-35901', 1, 'SCORED', '<itemResponse><response id="EBSR1"><value>B</value></response><response id="EBSR2"><value>A</value></response></itemResponse>', 15, 2),
  (1, '200-35903', 1, 'SCORED', 'C', 16, 2),
  (1, '200-35905', 1, 'SCORED', '<itemResponse><response id="RESPONSE"><value>1 a</value><value>2 b</value><value>3 b</value><value>4 b</value><value>5 a</value><value>6 a</value></response></itemResponse>', 17, 2),
  (1, '200-63424', 1, 'SCORED', 'B', 18, 2),
  (1, '200-30153', 1, 'SCORED', 'B', 19, 2),
  (1, '200-26487', 0, 'SCORED', 'D', 20, 2),
  (1, '200-27817', 0, 'SCORED', '<itemResponse><response id="1"><value>3</value></response></itemResponse>', 21, 2),
  (1, '200-26485', 1, 'SCORED', '<itemResponse><response id="EBSR1"><value>C</value></response><response id="EBSR2"><value>C</value></response></itemResponse>', 22, 2),
  (1, '200-26475', 1, 'SCORED', '<itemResponse><response id="1"><value>1</value><value>2</value></response></itemResponse>', 23, 2),
  (1, '200-26475', 1, 'SCORED', 'A,E', 24, 2),
  (1, '200-26483', 1, 'SCORED', 'That the water-scorpion inhales air in an odd way. The source says,"You may catch him too when he comes up to get air. This he does in a very funny way."', 25, 2),
  (1, '200-26465', 1, 'SCORED', 'A', 26, 2),
  (1, '200-33850', 1, 'SCORED', '<itemResponse><response id="RESPONSE"><value>1 a</value><value>2 b</value><value>3 a</value><value>4 a</value></response></itemResponse>', 27, 2),
  (1, '200-33848', 1, 'SCORED', 'D', 28, 2),
  (1, '200-33846', 1, 'SCORED', '<itemResponse><response id="EBSR1"><value>A</value></response><response id="EBSR2"><value>D</value></response></itemResponse>', 29, 2),
  (1, '200-32360', 1, 'SCORED', 'I think that the person named Tiffany is right. It is not the older kids fault for the younger kids that get hurt. The parents who are mad should be mad at themselves because they are the ones who let their kids skateboard. I don''t know howyoung these kids are skateboarding but 8, 9, or 10 sounds like a good age. I think too that the older kids 8 up should still have their rights as skateboarders. These examples clearly state what and why I think about this topic.', 30, 2),
  (1, '200-28209', 1, 'SCORED', '<itemResponse><response id="EBSR1"><value>D</value></response><response id="EBSR2"><value>D</value></response></itemResponse>', 31, 2),
  (1, '200-28203', 0, 'SCORED', '<itemResponse><response id="1"><value>2</value><value>3</value></response></itemResponse>', 32, 2),
  (1, '200-28215', 0, 'SCORED', 'C', 33, 2),
  (1, '200-28205', 0, 'SCORED', '<itemResponse><response id="EBSR1"><value>D</value></response><response id="EBSR2"><value>D</value></response></itemResponse>', 34, 2),
  (1, '200-30149', 1, 'SCORED', '<itemResponse><response id="1"><value>1</value><value>4</value></response></itemResponse>', 35, 2),
  (1, '200-32372', 0, 'SCORED', 'C,F', 36, 2),
  (1, '200-41676', 1, 'SCORED', 'C', 37, 2),
  (1, '200-54456', 1, 'SCORED', 'A', 38, 2),
  (1, '200-54466', 1, 'SCORED', 'C', 39, 2),
  (1, '200-54458', 0, 'SCORED', 'B', 40, 2),
  (1, '200-54452', 2, 'SCORED', 'The theme of the text is to always help someone who is in need of help. In the text it says,"She thought quickly, then decided it wouldn''t take her long to search for the lamb."', 41, 2),
  (1, '200-54141', 2, 'SCORED', 'Whales work together in many ways. In Source #2 it said," Sometimes the pod might even help an injured whale come up to the surface for air." Another example is in source #3,"Dr. Fred Sharpe had an idea, mabey the whales were working together...the Humpback whales would help each other catch food...the whales were working together!" That is how the different types of whales work together, or help each other"', 42, 2),
  (1, '200-61136', 2, 'SCORED', 'Whales use different sounds to o different things together. In Source #2 it says,"The whales use many calls to stay in touch as they hunt." One more example on how whales use their different sounds comes from Source #3,"The whales made magnificent trumpet-like sounds as they swept up and ate the fish." These exaples clearly state why whales use different types of sounds.', 43, 2),
  (1, '200-61138', 1, 'SCORED', 'B,F', 44, 2),
  (1, '200-54683', 3, 'SCORED', '<p>&nbsp; &nbsp; Jacob woke up and was very disappointed. He had another Monday at school, wait he forgot! The 5th grader Jacob and his family were going to Monterey, CA. The family was getting ready and packing into the car. They lived in Mammoth. It was a long drive there. They had to take the 203 to the 395 to the 14 to the 58 to the 99. Then to the 46 to the 101 to the 67 to their boat. When they got there. They planned to take a boat ride. The started their trip on the 203, after a while Jacob woke up on the 14. He played some games and when he looked up they were on the 99. He did one last nap and woke up on the 101 and then stayed awake the rest of the time and had lunch and played more games. They got there and checked in to the hotel, Best Western Hotel. At 2:00 pm they went on their 3 1/2 voyage. Around the 1st hour Jacob got seasick. As they were heading back to the docks in the boat they saw a Humpback whale leap out of the water, gracefully not slopy.&nbsp;&nbsp;</p>', 45, 2);
