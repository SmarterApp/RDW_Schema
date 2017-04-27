USE reporting;

-- TODO: staging tables should be in a different schema

DROP TABLE IF EXISTS stage_import;
CREATE TABLE IF NOT EXISTS stage_import (
  id      BIGINT  NOT NULL AUTO_INCREMENT PRIMARY KEY,
  status  TINYINT NOT NULL,
  content TINYINT NOT NULL,
  message TEXT
);

-- NOTE: stage tables support duplicate rows
DROP TABLE IF EXISTS stage_asmt;
CREATE TABLE IF NOT EXISTS stage_asmt (
  id          BIGINT       NOT NULL,
  natural_id  VARCHAR(250) NOT NULL,
  grade_id    TINYINT      NOT NULL,
  type_id     TINYINT      NOT NULL,
  subject_id  TINYINT      NOT NULL,
  school_year SMALLINT     NOT NULL,
  name        VARCHAR(250),
  label       VARCHAR(255),
  version     VARCHAR(30)
);

DROP TABLE IF EXISTS stage_item;
CREATE TABLE IF NOT EXISTS stage_item (
  id            INT               NOT NULL PRIMARY KEY,
  claim_id      SMALLINT,
  target_id     SMALLINT,
  natural_id    VARCHAR(40)       NOT NULL,
  asmt_id       BIGINT            NOT NULL,
  math_practice TINYINT,
  allow_calc    BOOLEAN,
  dok_id        TINYINT           NOT NULL,
  difficulty    FLOAT             NOT NULL,
  max_points    SMALLINT UNSIGNED NOT NULL
);

DROP TABLE IF EXISTS stage_district;
CREATE TABLE IF NOT EXISTS stage_district (
  id         MEDIUMINT    NOT NULL,
  name       VARCHAR(100) NOT NULL,
  natural_id VARCHAR(40)  NOT NULL
);

DROP TABLE IF EXISTS stage_school;
CREATE TABLE IF NOT EXISTS stage_school (
  id          MEDIUMINT    NOT NULL,
  district_id MEDIUMINT    NOT NULL,
  name        VARCHAR(100) NOT NULL,
  natural_id  VARCHAR(40)  NOT NULL
);

DROP TABLE IF EXISTS stage_student;
CREATE TABLE IF NOT EXISTS stage_student (
  id                            BIGINT      NOT NULL PRIMARY KEY,
  ssid                          VARCHAR(65) NOT NULL UNIQUE,
  last_or_surname               VARCHAR(60) NOT NULL,
  first_name                    VARCHAR(60) NOT NULL,
  middle_name                   VARCHAR(60),
  gender_id                     TINYINT     NOT NULL,
  first_entry_into_us_school_at DATE,
  lep_entry_at                  DATE,
  lep_exit_at                   DATE,
  is_demo                       TINYINT,
  birthday                      DATE        NOT NULL
);

-- ----------------------------------------------------------------------
-- get the imports to process
-- ----------------------------------------------------------------------

-- TODO: below is a dummy version, the real one cannot connect to both dbs
-- It will have to take the last processed id from reporting and ask for
-- X imports from the warehouse
INSERT INTO reporting.stage_import (id, STATUS, content)
  SELECT
    w.id,
    -100 AS status,
    w.content
  FROM warehouse.import w
    LEFT JOIN reporting.import r ON w.id = r.id
  WHERE r.id IS NULL;

-- ----------------------------------------------------------------------
-- Migrate assessment data
-- ----------------------------------------------------------------------
-- load assessments into staging - note that there will be duplicates

-- Since we cannot connect to both DBs at once, the flow will be
-- 1. reporting: select ids from the stage_import
-- 2. warehouse: SELECT ... FROM warehouse.import i .. WHERE i.id IN ({ids from step 1})
-- 3. reporting: INSERT INTO reporting.stage_asmt
INSERT INTO reporting.stage_asmt (id, natural_id, grade_id, type_id, subject_id, school_year, NAME, label, version)
  SELECT
    a.id,
    natural_id,
    grade_id,
    type_id,
    subject_id,
    a.school_year,
    name,
    label,
    version
  FROM warehouse.import i
    JOIN warehouse.exam e ON e.import_id = i.id
    JOIN warehouse.asmt a ON e.asmt_id = a.id
  WHERE i.id IN (SELECT id
                 FROM reporting.stage_import);

INSERT INTO reporting.stage_asmt (id, natural_id, grade_id, type_id, subject_id, school_year, name, label, version)
  SELECT
    a.id,
    natural_id,
    grade_id,
    type_id,
    subject_id,
    a.school_year,
    name,
    label,
    version
  FROM warehouse.import i
    JOIN warehouse.iab_exam e ON e.import_id = i.id
    JOIN warehouse.asmt a ON e.asmt_id = a.id
  WHERE i.id IN (SELECT id
                 FROM reporting.stage_import);

-- insert/update asmts
-- TODO: needs to be wrapped into transaction?
UPDATE reporting.asmt a
  JOIN (SELECT DISTINCT
          sa.id,
          sa.natural_id,
          sa.grade_id,
          sa.type_id,
          sa.subject_id,
          sa.school_year,
          sa.name,
          sa.label,
          sa.version
        FROM reporting.stage_asmt sa) sa ON sa.id = a.id
SET
  a.natural_id  = sa.natural_id,
  a.grade_id    = sa.grade_id,
  a.type_id     = sa.type_id,
  a.subject_id  = sa.subject_id,
  a.school_year = sa.school_year,
  a.name        = sa.name,
  a.label       = sa.label,
  a.version     = sa.version;

INSERT INTO reporting.asmt (id, natural_id, grade_id, type_id, subject_id, school_year, name, label, version)
  SELECT DISTINCT
    sa.id,
    sa.natural_id,
    sa.grade_id,
    sa.type_id,
    sa.subject_id,
    sa.school_year,
    sa.name,
    sa.label,
    sa.version
  FROM stage_asmt sa
    LEFT JOIN reporting.asmt a ON sa.id = a.id
  WHERE a.id IS NULL;-- ----------------------------------------------------------------------
-- Migrate school/district
-- ---------------------------------------------------------------------

-- TODO: handle asmt delete

-- load items data into staging
INSERT INTO reporting.stage_item (id, claim_id, target_id, natural_id, asmt_id, dok_id, difficulty, max_points, math_practice, allow_calc)
  SELECT
    i.id,
    claim_id,
    target_id,
    i.natural_id,
    asmt_id,
    dok_id,
    difficulty,
    max_points,
    math_practice,
    allow_calc
  FROM warehouse.asmt a
    JOIN warehouse.item i ON i.asmt_id = a.id
  WHERE a.id IN (SELECT DISTINCT id
                 FROM reporting.stage_asmt);

-- update item data
UPDATE reporting.item i
  JOIN reporting.stage_item si ON i.id = si.id
SET
  i.id            = si.id,
  i.claim_id      = si.claim_id,
  i.target_id     = si.target_id,
  i.natural_id    = si.natural_id,
  i.asmt_id       = si.asmt_id,
  i.dok_id        = si.dok_id,
  i.difficulty    = si.difficulty,
  i.max_points    = si.max_points,
  i.math_practice = si.math_practice,
  i.allow_calc    = si.allow_calc;

-- insert item data
INSERT INTO reporting.item (id, claim_id, target_id, natural_id, asmt_id, dok_id, difficulty, max_points, math_practice, allow_calc)
  SELECT
    si.id,
    si.claim_id,
    si.target_id,
    si.natural_id,
    si.asmt_id,
    si.dok_id,
    si.difficulty,
    si.max_points,
    si.math_practice,
    si.allow_calc
  FROM stage_item si
    LEFT JOIN reporting.item i ON si.id = i.id
  WHERE i.id IS NULL;


-- TODO: delete item data

INSERT INTO reporting.import (id, STATUS, content)
  SELECT id, 100, content from reporting.stage_import;
--------------------------------------------------------------------------------------

INSERT INTO reporting.district(id, name, natural_id)
SELECT id, name, natural_id FROM warehouse.district;

INSERT INTO reporting.school(id, district_id, name, natural_id)
  SELECT id, district_id, name, natural_id FROM warehouse.school;

INSERT INTO reporting.student (id, ssid, last_or_surname, first_name, middle_name, gender_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, birthday, import_id)
  SELECT id, ssid, last_or_surname, first_name, middle_name, gender_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, birthday, import_id FROM warehouse.student;

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

-- TODO:  need an intelligent way to combine student into groups; something like given me students in the same grade that have the same session ids..?

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
