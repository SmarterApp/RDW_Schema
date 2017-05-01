INSERT INTO reporting.district(id, name, natural_id)
  SELECT id, name, natural_id FROM warehouse.district;

INSERT INTO reporting.school(id, district_id, name, natural_id, import_id)
  SELECT id, district_id, name, natural_id, import_id FROM warehouse.school;

INSERT INTO reporting.student (id, ssid, last_or_surname, first_name, middle_name, gender_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, birthday, import_id)
  SELECT id, ssid, last_or_surname, first_name, middle_name, gender_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, birthday, import_id FROM warehouse.student;

INSERT INTO reporting.asmt (id, natural_id, grade_id,type_id, subject_id, school_year, name, label, version, import_id)
  SELECT id, natural_id, grade_id,type_id, subject_id, school_year, name, label, version, import_id from warehouse.asmt;

INSERT INTO reporting.item (id, claim_id, target_id, natural_id, asmt_id, dok_id, difficulty, max_points, math_practice, allow_calc)
  SELECT id, claim_id, target_id, natural_id, asmt_id, dok_id, difficulty, max_points, math_practice, allow_calc FROM warehouse.item;

INSERT INTO reporting.iab_exam (id, school_year, asmt_id, asmt_version, opportunity, status, completeness_id, administration_condition_id, session_id, scale_score, scale_score_std_err, category, completed_at,
                                grade_id, student_id, school_id, iep, lep, section504, economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type, language_code, prim_disability_type, import_id)
  SELECT e.id, school_year, asmt_id, asmt_version, opportunity, status, completeness_id, administration_condition_id, session_id, round(scale_score), scale_score_std_err, category, completed_at,
    grade_id, student_id, school_id, iep, lep, section504, economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type, language_code, prim_disability_type, import_id
  FROM warehouse.iab_exam e JOIN warehouse.iab_exam_student s on e.iab_exam_student_id = s.id AND e.scale_score is not null;

INSERT INTO reporting.iab_exam_item (id, iab_exam_id, item_id, score, score_status, response, position)
  SELECT i.id, iab_exam_id, item_id, round(score), score_status, response, position FROM warehouse.iab_exam_item i
    JOIN warehouse.iab_exam e on e.id = i.iab_exam_id  WHERE e.scale_score is not null;

INSERT INTO reporting.exam (id, school_year,  asmt_id, asmt_version, opportunity, status, completeness_id, administration_condition_id, session_id, scale_score, scale_score_std_err, achievement_level, completed_at,
                            grade_id, student_id, school_id, iep, lep, section504, economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type, language_code, prim_disability_type,
                            claim1_scale_score, claim1_scale_score_std_err, claim1_category,
                            claim2_scale_score, claim2_scale_score_std_err, claim2_category,
                            claim3_scale_score, claim3_scale_score_std_err, claim3_category,
                            claim4_scale_score, claim4_scale_score_std_err, claim4_category,
                            import_id
)
  SELECT  e.id, e.school_year,  e.asmt_id, e.asmt_version, opportunity, status, completeness_id, administration_condition_id, session_id, round(e.scale_score), e.scale_score_std_err, achievement_level, completed_at,
    s.grade_id, student_id, school_id, iep, lep, section504, economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type, language_code, prim_disability_type,
    round(claim1.scale_score) as claim1_scale_score, claim1.scale_score_std_err as claim1_scale_score_std_err, claim1.category as claim1_category,
    round(claim2.scale_score) as claim2_scale_score, claim2.scale_score_std_err as claim2_scale_score_std_err, claim2.category as claim2_category,
    round(claim3.scale_score) as claim3_scale_score, claim3.scale_score_std_err as claim3_scale_score_std_err, claim3.category as claim3_category,
    round(claim4.scale_score) as claim4_scale_score, claim4.scale_score_std_err as claim4_scale_score_std_err, claim4.category as claim4_category,
    import_id
  FROM warehouse.exam e
    INNER JOIN warehouse.exam_student s ON e.exam_student_id = s.id
    INNER JOIN (
      SELECT exam_id
        ,scale_score
        ,scale_score_std_err
        ,category
      FROM warehouse.exam_claim_score s
      INNER JOIN reporting.exam_claim_score_mapping m ON m.subject_claim_score_id = s.subject_claim_score_id
        AND m.num = 1
      ) AS claim1 ON claim1.exam_id = e.id
    INNER JOIN (
      SELECT exam_id
        ,scale_score
        ,scale_score_std_err
        ,category
      FROM warehouse.exam_claim_score s
      INNER JOIN reporting.exam_claim_score_mapping m ON m.subject_claim_score_id = s.subject_claim_score_id
        AND m.num = 2
      ) AS claim2 ON claim2.exam_id = e.id
    INNER JOIN (
      SELECT exam_id
        ,scale_score
        ,scale_score_std_err
        ,category
      FROM warehouse.exam_claim_score s
      INNER JOIN reporting.exam_claim_score_mapping m ON m.subject_claim_score_id = s.subject_claim_score_id
        AND m.num = 3
      ) AS claim3 ON claim3.exam_id = e.id
    LEFT JOIN (
      SELECT exam_id
        ,scale_score
        ,scale_score_std_err
        ,category
      FROM warehouse.exam_claim_score s
      INNER JOIN reporting.exam_claim_score_mapping m ON m.subject_claim_score_id = s.subject_claim_score_id
        AND m.num = 4
      ) AS claim4 ON claim4.exam_id = e.id;

INSERT INTO reporting.exam_item (id, exam_id, item_id, score, score_status, response, position)
  SELECT id, exam_id, item_id, round(score), score_status, response, position FROM warehouse.exam_item;

INSERT INTO reporting.student_group (id, school_id, school_year, name, subject_id, import_id)
  SELECT id, school_id, school_year, name, subject_id, import_id FROM warehouse.student_group;

INSERT INTO reporting.student_group_membership (student_group_id, student_id)
  SELECT student_group_id, student_id FROM warehouse.student_group_membership;

INSERT INTO user_student_group (student_group_id, user_login)
  SELECT id, CONCAT('user', FLOOR(RAND()*10)) from student_group ;

