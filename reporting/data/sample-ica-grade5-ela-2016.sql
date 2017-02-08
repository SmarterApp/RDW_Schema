/**
 **  Sample data parsed from ETS provided TRT-like XML
 */
INSERT INTO asmt (id, natural_id, grade_id,type_id, subject_id, academic_year, name, label, version) VALUES
  (1, 'SBAC)SBAC-ICA-FIXED-G5E-COMBINED-2017-Winter-2016-2017', 5, 1, 2, 2016, 'SBAC-ICA-FIXED-G5E-COMBINED-2017', 'Grade 5 ELA', '9831');

INSERT INTO asmt_score (asmt_id, cut_point_1, cut_point_2, cut_point_3, min_score, max_score) VALUES
  (1, 2442, 2502, 2582, 2201, 2701);

-- TODO: where to find min/max score. Also ETS TRT has codes without SBAC?
INSERT INTO claim (id, asmt_id, min_score, max_score, code) VALUES
  (1, 1, null, null, 'SBAC-2-W'),
  (2, 1, null, null, 'SBAC-4-CR'),
  (3, 1, null, null, 'SOCK_LS'),
  (4, 1, null, null, 'SOCK_R');

-- TODO: currently item to claim assignment is random
INSERT INTO item (id, claim_id, target_id, item_key, bank_key) VALUES
  (60347, 1, null, 60347, '200'),
  (51719, 1, null, 51719, '200'),
  (59217, 1, null, 59217, '200'),
  (59208, 1, null, 59208, '200'),
  (30901, 1, null, 30901, '200'),
  (30899, 1, null, 30899, '200'),
  (30891, 1, null, 30891, '200'),
  (32604, 1, null, 32604, '200'),
  (58465, 1, null, 58465, '200'),
  (43427, 1, null, 43427, '200'),
  (43440, 1, null, 43440, '200'),
  (54097, 1, null, 54097, '200'),
  (58401, 2, null, 58401, '200'),
  (43423, 2, null, 43423, '200'),
  (41656, 2, null, 41656, '200'),
  (35901, 2, null, 35901, '200'),
  (35903, 2, null, 35903, '200'),
  (35905, 2, null, 35905, '200'),
  (63424, 2, null, 63424, '200'),
  (30153, 2, null, 30153, '200'),
  (26487, 2, null, 26487, '200'),
  (27817, 3, null, 27817, '200'),
  (26485, 3, null, 26485, '200'),
  (26475, 3, null, 26475, '200'),
  (27823, 3, null, 27823, '200'),
  (26483, 3, null, 26483, '200'),
  (26465, 3, null, 26465, '200'),
  (33850, 3, null, 33850, '200'),
  (33848, 3, null, 33848, '200'),
  (33846, 3, null, 33846, '200'),
  (32360, 3, null, 32360, '200'),
  (31902, 3, null, 31902, '200'),
  (28209, 3, null, 28209, '200'),
  (28203, 3, null, 28203, '200'),
  (28215, 4, null, 28215, '200'),
  (28205, 4, null, 28205, '200'),
  (30149, 4, null, 30149, '200'),
  (32372, 4, null, 32372, '200'),
  (41676, 4, null, 41676, '200'),
  (54456, 4, null, 54456, '200'),
  (54466, 4, null, 54466, '200'),
  (54458, 4, null, 54458, '200'),
  (54452, 4, null, 54452, '200'),
  (54141, 4, null, 54141, '200'),
  (61136, 4, null, 61136, '200'),
  (61138, 4, null, 61138, '200'),
  (54683, 4, null, 54683, '200');

-- NOTE: ETS samples with anonymized data do not have names for school and district
INSERT IGNORE INTO district (id, name, natural_id) VALUES
  (1, 'Sample District 1', '01247430000000');

INSERT IGNORE INTO school (id, district_id, name, natural_id) VALUES
  (1, 1, 'Sample School 1', '30664640124743');

INSERT IGNORE INTO state (code) VALUES
  ('SM');

INSERT INTO student (id, ssid, last_or_surname, first_name, middle_name, gender_id, ethnicity_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, is_demo, birthday) VALUES
  (1, '6666666666', 'LastName6', 'FirstName6', 'MiddleName6', 1, 4, '2015-09-01', null, null, false, '2006-01-01');

INSERT INTO roster (id, created_by, school_id, name, exam_from, exam_to, subject_id) VALUES
  (1, 'dwtest@example.com', 1, 'Test Student Group', null, '2017-08-01', 2);

INSERT INTO roster_membership (roster_id, student_id) VALUES
  (1, 1);

INSERT INTO user_roster (roster_id, user_login) VALUES
  (1, 'dwtest@example.com');

INSERT INTO exam_student (id, grade_id, student_id, school_id, iep, lep, section504, economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type, language_code, prim_disability_type) VALUES
  (1, 5, 1, 1, null, null, null, null, null, 'EO', null,'ENG', null);

INSERT INTO exam (id, exam_student_id, asmt_id, asmt_version, opportunity, status, validity, completeness, administration_condition_id, session_id, scale_score, scale_score_std_err, achievement_level, asmt_session_location_id) VALUES
  (1, 1, 1, null, 0, 'completed', 1, 1, 1, 'CA-3ACF-69', 2642.54836495757, 27.6925766459382, 4, null);

-- TODO: this needs more research. There are some mismatched codes and it is not clear what is available and what needs to be stored
-- INSERT INTO exam_available_accommodation (exam_id, accommodation_id) VALUES ...

INSERT INTO exam_claim_score (id, exam_id, claim_id, scale_score, scale_score_std_err, level) VALUES
  (1, 1, 1, 2577.80680893986, 46.7512956510613, 3),
  (2, 1, 2, 2668.81750838064, 67.885043404398, 3),
  (3, 1, 3, 2701.23284, 101.838594705009, 3),
  (4, 1, 4, 2657.87221487352, 42.9833504368907, 3);

INSERT INTO exam_item (exam_id, item_id, score, score_status, response) VALUES
  (1, 60347, 1, 'SCORED', 'D'),
  (1, 51719, 1, 'SCORED', 'B'),
  (1, 59217, 1, 'SCORED', 'D'),
  (1, 30901, 1, 'SCORED', 'C'),
  (1, 30899, 1, 'SCORED', 'B'),
  (1, 30891, 1, 'SCORED', '<itemResponse><response id="EBSR1"><value>A</value></response><response id="EBSR2"><value>D</value></response></itemResponse>'),
  (1, 32604, 1, 'SCORED', 'C'),
  (1, 58465, 1, 'SCORED', 'C,E'),
  (1, 43427, 1, 'SCORED', 'A'),
  (1, 43440, 1, 'SCORED', 'A'),
  (1, 54097, 1, 'SCORED', '<itemResponse><response id="1"><value>3</value><value>5</value></response></itemResponse>'),
  (1, 58401, 1, 'SCORED', '<itemResponse><response id="EBSR1"><value>C</value></response><response id="EBSR2"><value>A</value></response></itemResponse>'),
  (1, 43423, 1, 'SCORED', 'E, F'),
  (1, 41656, 1, 'SCORED', 'C'),
  (1, 35901, 1, 'SCORED', '<itemResponse><response id="EBSR1"><value>B</value></response><response id="EBSR2"><value>A</value></response></itemResponse>'),
  (1, 35903, 1, 'SCORED', 'C'),
  (1, 35905, 1, 'SCORED', '<itemResponse><response id="RESPONSE"><value>1 a</value><value>2 b</value><value>3 b</value><value>4 b</value><value>5 a</value><value>6 a</value></response></itemResponse>'),
  (1, 63424, 1, 'SCORED', 'B'),
  (1, 30153, 1, 'SCORED', 'B'),
  (1, 26487, 0, 'SCORED', 'D'),
  (1, 27817, 0, 'SCORED', '<itemResponse><response id="1"><value>3</value></response></itemResponse>'),
  (1, 26485, 1, 'SCORED', '<itemResponse><response id="EBSR1"><value>C</value></response><response id="EBSR2"><value>C</value></response></itemResponse>'),
  (1, 26475, 1, 'SCORED', '<itemResponse><response id="1"><value>1</value><value>2</value></response></itemResponse>'),
  (1, 26475, 1, 'SCORED', 'A,E'),
  (1, 26483, 1, 'SCORED', 'That the water-scorpion inhales air in an odd way. The source says,"You may catch him too when he comes up to get air. This he does in a very funny way."'),
  (1, 26465, 1, 'SCORED', 'A'),
  (1, 33850, 1, 'SCORED', '<itemResponse><response id="RESPONSE"><value>1 a</value><value>2 b</value><value>3 a</value><value>4 a</value></response></itemResponse>'),
  (1, 33848, 1, 'SCORED', 'D'),
  (1, 33846, 1, 'SCORED', '<itemResponse><response id="EBSR1"><value>A</value></response><response id="EBSR2"><value>D</value></response></itemResponse>'),
  (1, 32360, 1, 'SCORED', 'I think that the person named Tiffany is right. It is not the older kids fault for the younger kids that get hurt. The parents who are mad should be mad at themselves because they are the ones who let their kids skateboard. I don''t know howyoung these kids are skateboarding but 8, 9, or 10 sounds like a good age. I think too that the older kids 8 up should still have their rights as skateboarders. These examples clearly state what and why I think about this topic.'),
  (1, 28209, 1, 'SCORED', '<itemResponse><response id="EBSR1"><value>D</value></response><response id="EBSR2"><value>D</value></response></itemResponse>'),
  (1, 28203, 0, 'SCORED', '<itemResponse><response id="1"><value>2</value><value>3</value></response></itemResponse>'),
  (1, 28215, 0, 'SCORED', 'C'),
  (1, 28205, 0, 'SCORED', '<itemResponse><response id="EBSR1"><value>D</value></response><response id="EBSR2"><value>D</value></response></itemResponse>'),
  (1, 30149, 1, 'SCORED', '<itemResponse><response id="1"><value>1</value><value>4</value></response></itemResponse>'),
  (1, 32372, 0, 'SCORED', 'C,F'),
  (1, 41676, 1, 'SCORED', 'C'),
  (1, 54456, 1, 'SCORED', 'A'),
  (1, 54466, 1, 'SCORED', 'C'),
  (1, 54458, 0, 'SCORED', 'B'),
  (1, 54452, 2, 'SCORED', 'The theme of the text is to always help someone who is in need of help. In the text it says,"She thought quickly, then decided it wouldn''t take her long to search for the lamb."'),
  (1, 54141, 2, 'SCORED', 'Whales work together in many ways. In Source #2 it said," Sometimes the pod might even help an injured whale come up to the surface for air." Another example is in source #3,"Dr. Fred Sharpe had an idea, mabey the whales were working together...the Humpback whales would help each other catch food...the whales were working together!" That is how the different types of whales work together, or help each other"'),
  (1, 61136, 2, 'SCORED', 'Whales use different sounds to o different things together. In Source #2 it says,"The whales use many calls to stay in touch as they hunt." One more example on how whales use their different sounds comes from Source #3,"The whales made magnificent trumpet-like sounds as they swept up and ate the fish." These exaples clearly state why whales use different types of sounds.'),
  (1, 61138, 1, 'SCORED', 'B,F'),
  (1, 54683, 3, 'SCORED', '<p>&nbsp; &nbsp; Jacob woke up and was very disappointed. He had another Monday at school, wait he forgot! The 5th grader Jacob and his family were going to Monterey, CA. The family was getting ready and packing into the car. They lived in Mammoth. It was a long drive there. They had to take the 203 to the 395 to the 14 to the 58 to the 99. Then to the 46 to the 101 to the 67 to their boat. When they got there. They planned to take a boat ride. The started their trip on the 203, after a while Jacob woke up on the 14. He played some games and when he looked up they were on the 99. He did one last nap and woke up on the 101 and then stayed awake the rest of the time and had lunch and played more games. They got there and checked in to the hotel, Best Western Hotel. At 2:00 pm they went on their 3 1/2 voyage. Around the 1st hour Jacob got seasick. As they were heading back to the docks in the boat they saw a Humpback whale leap out of the water, gracefully not slopy.&nbsp;&nbsp;</p>');
