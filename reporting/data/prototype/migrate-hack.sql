INSERT INTO reporting.district(id, name, natural_id)
  SELECT id, name, natural_id FROM warehouse.district;

INSERT INTO reporting.school(id, district_id, name, natural_id)
  SELECT id, district_id, name, natural_id FROM warehouse.school;

INSERT INTO reporting.student (id, ssid, last_or_surname, first_name, middle_name, gender_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, birthday)
  SELECT id, ssid, last_or_surname, first_name, middle_name, gender_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, birthday FROM warehouse.student;

INSERT INTO reporting.asmt (id, natural_id, grade_id,type_id, subject_id, school_year, name, label, version)
  SELECT id, natural_id, grade_id,type_id, subject_id, school_year, name, label, version from warehouse.asmt;

INSERT INTO reporting.item (id, claim_id, target_id, natural_id, asmt_id, dok_id, difficulty, max_points, math_practice, allow_calc)
  SELECT id, claim_id, target_id, natural_id, asmt_id, dok_id, difficulty, max_points, math_practice, allow_calc FROM warehouse.item;

INSERT INTO reporting.iab_exam (id, school_year, asmt_id, asmt_version, opportunity, status, completeness_id, administration_condition_id, session_id, scale_score, scale_score_std_err, category, completed_at,
                                grade_id, student_id, school_id, iep, lep, section504, economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type, language_code, prim_disability_type,
                                is_category1, is_category2, is_category3)
  SELECT e.id, school_year, asmt_id, asmt_version, opportunity, status, completeness_id, administration_condition_id, session_id, round(scale_score), scale_score_std_err, category, completed_at,
    grade_id, student_id, school_id, iep, lep, section504, economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type, language_code, prim_disability_type,
    CASE category WHEN 1 THEN 1  ELSE 0  END AS is_category1,
    CASE category WHEN 2 THEN 1  ELSE 0  END AS is_category2,
    CASE category WHEN 3 THEN 1  ELSE 0  END AS is_category3
  FROM warehouse.iab_exam e JOIN warehouse.iab_exam_student s on e.iab_exam_student_id = s.id;

INSERT INTO reporting.iab_exam_item (id, iab_exam_id, item_natural_id, score, score_status, response, position)
  SELECT id, iab_exam_id, item_natural_id, round(score), score_status, response, position FROM warehouse.iab_exam_item;

INSERT INTO reporting.exam (id, school_year,  asmt_id, asmt_version, opportunity, status, completeness_id, administration_condition_id, session_id, scale_score, scale_score_std_err, achievement_level, completed_at,
                            grade_id, student_id, school_id, iep, lep, section504, economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type, language_code, prim_disability_type,
                            claim1_scale_score, claim1_scale_score_std_err, claim1_category,
                            claim2_scale_score, claim2_scale_score_std_err, claim2_category,
                            claim3_scale_score, claim3_scale_score_std_err, claim3_category,
                            claim4_scale_score, claim4_scale_score_std_err, claim4_category
)
  SELECT  e.id, e.school_year,  e.asmt_id, e.asmt_version, opportunity, status, completeness_id, administration_condition_id, session_id, round(e.scale_score), e.scale_score_std_err, achievement_level, completed_at,
    s.grade_id, student_id, school_id, iep, lep, section504, economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type, language_code, prim_disability_type,
    round(claim1.scale_score) as claim1_scale_score, claim1.scale_score_std_err as claim1_scale_score_std_err, claim1.category as claim1_category,
    round(claim2.scale_score) as claim2_scale_score, claim2.scale_score_std_err as claim2_scale_score_std_err, claim2.category as claim2_category,
    round(claim3.scale_score) as claim3_scale_score, claim3.scale_score_std_err as claim3_scale_score_std_err, claim3.category as claim3_category,
    round(claim4.scale_score) as claim4_scale_score, claim4.scale_score_std_err as claim4_scale_score_std_err, claim4.category as claim4_category
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


INSERT INTO reporting.exam_item (id, exam_id, item_natural_id, score, score_status, response, position)
   SELECT id, exam_id, item_natural_id, round(score), score_status, response, position FROM warehouse.exam_item;


DROP PROCEDURE IF EXISTS reporting.create_student_groups;

DELIMITER //

CREATE PROCEDURE reporting.create_student_groups()
  BEGIN
    DECLARE x INT;
    DECLARE idVal INT;
    SET x = 2000;

    REPEAT
      SELECT max(id) +1 INTO idVal FROM student_group;
      IF (idval is null) THEN SET idVal = 1; END IF;
      INSERT INTO student_group (id, created_by, school_id, school_year, name, subject_id) VALUES
        (idVal , 'dwtest@example.com', (SELECT id FROM school ORDER BY RAND() LIMIT 1), 2017, CONCAT('Test Student Group ', idVal), null);

      INSERT INTO user_student_group (student_group_id, user_login) VALUES
        (idVal, CONCAT('user', FLOOR(RAND()*10)));

      INSERT INTO student_group_membership (student_group_id, student_id)
        SELECT idVal, s.id FROM student s ORDER BY RAND() LIMIT 200;

      SET x = x - 1;
    UNTIL x <= 0
    END REPEAT;

  END; //

DELIMITER ;

call create_student_groups();

