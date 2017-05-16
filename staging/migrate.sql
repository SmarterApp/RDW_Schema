use staging;
-- -----------------------------------------------------------------------------------------
-- MOVE FROM WAREHOUSE TO STAGING
-- -----------------------------------------------------------------------------------------
-- TODO: this is a temp hack/simulation that I needed to test
DELETE FROM reporting.migrate WHERE id = -11;
-- In the real life this will be done at the beginning of the migration
INSERT INTO reporting.migrate (id, status, first_import_id, last_import_id)
VALUES (-11, 10, -1, -1);

-- TODO: the steps below will be controlled by the migrate job and will be driven by the type of the import content
-- -----------------------------------------------------------------------------------------
-- clean up
-- -----------------------------------------------------------------------------------------
TRUNCATE TABLE staging_grade;
TRUNCATE TABLE staging_completeness;
TRUNCATE TABLE staging_administration_condition;
TRUNCATE TABLE staging_ethnicity;
TRUNCATE TABLE staging_gender;
TRUNCATE TABLE staging_accommodation;
TRUNCATE TABLE staging_claim;
TRUNCATE TABLE staging_target;
TRUNCATE TABLE staging_depth_of_knowledge;
TRUNCATE TABLE staging_math_practice;
TRUNCATE TABLE staging_item_trait_score;
TRUNCATE TABLE staging_item_difficulty_cuts;

TRUNCATE TABLE staging_iab_exam_student;
TRUNCATE TABLE staging_iab_exam;
TRUNCATE TABLE staging_iab_exam_item;
TRUNCATE TABLE staging_iab_exam_available_accommodation;

TRUNCATE TABLE staging_exam_student;
TRUNCATE TABLE staging_exam;
TRUNCATE TABLE staging_exam_item;
TRUNCATE TABLE staging_exam_available_accommodation;
TRUNCATE TABLE staging_exam_claim_score;

TRUNCATE TABLE staging_school;
TRUNCATE TABLE staging_district;

TRUNCATE TABLE staging_student;
TRUNCATE TABLE staging_student_ethnicity;

TRUNCATE TABLE staging_student_group;
TRUNCATE TABLE staging_student_group_membership;
TRUNCATE TABLE staging_user_student_group;

TRUNCATE TABLE staging_asmt;
TRUNCATE TABLE staging_asmt_score;
TRUNCATE TABLE staging_item;

-- ----------------------------------------------------------------------
-- load data into staging table
-- ----------------------------------------------------------------------

-- Codes  ---------------------------------------------------------------
-- Codes do not have import ids or delete flag.
-- Since this should be a very infrequent event, we will just synchronize all the data
-- It is assumed that the data warehouse does all the hard work of insuring that
-- nothing will break if a code is modified
INSERT INTO staging_grade (id, code, name)
  SELECT id, code, name from warehouse.grade;

INSERT INTO staging_completeness (id, name)
  SELECT id, name from warehouse.completeness;

INSERT INTO staging_administration_condition (id, name)
  SELECT id, name from warehouse.administration_condition;

INSERT INTO staging_ethnicity (id, name)
  SELECT id, name from warehouse.ethnicity;

INSERT INTO staging_gender (id, name)
  SELECT id, name from warehouse.gender;

INSERT INTO staging_accommodation (id, code)
  SELECT id, code from warehouse.accommodation;

INSERT INTO staging_claim (id, subject_id, code, name, description)
  SELECT id, subject_id, code, name, description from warehouse.claim;

INSERT INTO staging_target (id, claim_id, code, description)
  SELECT id, claim_id, code, description from warehouse.target;

INSERT INTO staging_depth_of_knowledge (id, level, subject_id, description, reference)
  SELECT id, level, subject_id, description, reference from warehouse.depth_of_knowledge;

INSERT INTO staging_math_practice (practice, description)
  SELECT practice, description from warehouse.math_practice;

INSERT INTO staging_item_trait_score (id, dimension)
  SELECT id, dimension from warehouse.item_trait_score;

INSERT INTO staging_item_difficulty_cuts (id, asmt_type_id, subject_id,grade_id, moderate_low_end, difficult_low_end)
  SELECT id, asmt_type_id, subject_id,grade_id, moderate_low_end, difficult_low_end from warehouse.item_difficulty_cuts;

-- School  --------------------------------------------------------------

-- this includes updates/inserts but not deletes
INSERT INTO staging_district (id, natural_id, name, migrate_id)
  SELECT
    wd.id,
    wd.natural_id,
    wd.name,
    -11 -- TODO: this id will be passed in from the previous migrate task
  FROM warehouse.district wd
  WHERE EXISTS(
      SELECT id from warehouse.school ws
      WHERE district_id = wd.id
            AND ws.deleted = 0 -- delete will be taken care on the 'master' level
            -- TODO: this ids will be passed in from the previous migrate task
            AND import_id  IN ( SELECT id FROM warehouse.import WHERE id >= -1));

INSERT INTO staging_school (id, natural_id, name, import_id, deleted, district_id, migrate_id)
  SELECT
    ws.id,
    ws.natural_id,
    ws.name,
    ws.import_id,
    ws.deleted,
    ws.district_id,
    -11 -- TODO: this id will be passed in from the previous migrate task
  FROM warehouse.school ws
    JOIN warehouse.district wd ON wd.id = ws.district_id
  WHERE
    -- TODO: this ids will be passed in from the previous migrate task
    ws.import_id IN (SELECT id FROM warehouse.import WHERE id >= -1);

-- Student  ---------------------------------------------------------------------------------
INSERT INTO staging_student (id, ssid, last_or_surname, first_name, middle_name, gender_id, first_entry_into_us_school_at,
                             lep_entry_at, lep_exit_at, birthday, import_id, deleted, migrate_id)
  SELECT
    ws.id,
    ws.ssid,
    ws.last_or_surname,
    ws.first_name,
    ws.middle_name,
    ws.gender_id,
    ws.first_entry_into_us_school_at,
    ws.lep_entry_at,
    ws.lep_exit_at,
    ws.birthday,
    ws.import_id,
    ws.deleted,
    -11 -- TODO: this id will be passed in from the previous migrate task
  FROM warehouse.student ws
  WHERE
    -- TODO: this ids will be passed in from the previous migrate task
    ws.import_id IN (SELECT id FROM warehouse.import WHERE id >= -1);

-- this includes updates/inserts but not deletes
INSERT INTO staging_student_ethnicity (id, ethnicity_id, student_id)
  SELECT
    wse.id,
    wse.ethnicity_id,
    wse.student_id
  FROM warehouse.student_ethnicity wse
    JOIN warehouse.student ws ON ws.id = wse.student_id
  WHERE
    -- TODO: this ids will be passed in from the previous migrate task
    ws.import_id IN (SELECT id FROM warehouse.import WHERE id >= -1)
    AND ws.deleted = 0;  -- delete will be taken care on the 'master' level

-- Student Groups --------------------------------------------------------------------------
INSERT INTO  staging_student_group ( id, name, school_id, school_year, subject_id, active,
                                     creator, created, import_id, deleted, migrate_id)
  SELECT
    wsg.id,
    wsg.name,
    wsg.school_id,
    wsg.school_year,
    wsg.subject_id,
    wsg.active,
    wsg.creator,
    wsg.created,
    wsg.import_id,
    wsg.deleted,
    -11 -- TODO: this id will be passed in from the previous migrate task
  FROM warehouse.student_group wsg
  WHERE
    -- TODO: this ids will be passed in from the previous migrate task
    wsg.import_id IN (SELECT id FROM warehouse.import WHERE id >= -1);

INSERT INTO staging_student_group_membership (student_group_id, student_id)
  SELECT
    wsgm.student_group_id,
    wsgm.student_id
  FROM warehouse.student_group_membership wsgm
    JOIN warehouse.student_group wsg ON wsg.id= wsgm.student_group_id
  WHERE
    -- TODO: this ids will be passed in from the previous migrate task
    wsg.import_id IN (SELECT id FROM warehouse.import WHERE id >= -1)
    AND ( wsg.deleted = 0 and wsg.active = 1);  -- delete/inactive will be taken care on the 'master' level

INSERT INTO staging_user_student_group (student_group_id, user_login)
  SELECT
    wusg.student_group_id,
    wusg.user_login
  FROM warehouse.user_student_group wusg
    JOIN warehouse.student_group wsg ON wsg.id= wusg.student_group_id
  WHERE
    -- TODO: this ids will be passed in from the previous migrate task
    wsg.import_id IN (SELECT id FROM warehouse.import WHERE id >= -1)
    AND ( wsg.deleted = 0 and wsg.active = 1);  -- delete/inactive will be taken care on the 'master' level

-- Assessment ------------------------------------------------------------------------------

INSERT INTO staging_asmt ( id, natural_id, grade_id, type_id, subject_id, school_year, name,
                           label, version, import_id, deleted, migrate_id)
  SELECT
    wa.id,
    wa.natural_id,
    wa.grade_id,
    wa.type_id,
    wa.subject_id,
    wa.school_year,
    wa.name,
    wa.label,
    wa.version,
    wa.import_id,
    wa.deleted,
    -11 -- TODO: this id will be passed in from the previous migrate task
  FROM warehouse.asmt wa
  WHERE
    -- TODO: this ids will be passed in from the previous migrate task
    wa.import_id IN (SELECT id FROM warehouse.import WHERE id >= -1);

-- this includes updates/inserts but not deletes
INSERT INTO staging_asmt_score ( asmt_id, cut_point_1, cut_point_2, cut_point_3, min_score, max_score, migrate_id)
  SELECT
    was.asmt_id,
    round(was.cut_point_1),
    round(was.cut_point_2),
    round(was.cut_point_3),
    round(was.min_score),
    round(was.max_score),
    -11 -- TODO: this id will be passed in from the previous migrate task
  FROM warehouse.asmt_score  was
    JOIN warehouse.asmt wa ON wa.id = was.asmt_id
  WHERE
    -- TODO: this ids will be passed in from the previous migrate task
    wa.import_id IN (SELECT id FROM warehouse.import WHERE id >= -1)
    AND wa.deleted = 0;  -- delete will be taken care on the 'master' level

INSERT INTO staging_item ( id, claim_id, target_id, natural_id, asmt_id, math_practice, allow_calc, dok_id,
                           difficulty, max_points, migrate_id)
  SELECT
    wi.id,
    wi.claim_id,
    wi.target_id,
    wi.natural_id,
    wi.asmt_id,
    wi.math_practice,
    wi.allow_calc,
    wi.dok_id,
    wi.difficulty,
    round(wi.max_points),
    -11 -- TODO: this id will be passed in from the previous migrate task
  FROM warehouse.item  wi
    JOIN warehouse.asmt wa ON wa.id = wi.asmt_id
  WHERE
    -- TODO: this ids will be passed in from the previous migrate task
    wa.import_id IN (SELECT id FROM warehouse.import WHERE id >= -1)
    AND wa.deleted = 0;  -- delete will be taken care on the 'master' level

-- IAB Exams ------------------------------------------------------------------------------


INSERT INTO staging_iab_exam_student (id, grade_id, student_id, school_id, iep, lep, section504,
                                      economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type,
                                      language_code, prim_disability_type, migrate_id)
  SELECT
    wies.id,
    wies.grade_id,
    wies.student_id,
    wies.school_id,
    wies.iep,
    wies.lep,
    wies.section504,
    wies.economic_disadvantage,
    wies.migrant_status,
    wies.eng_prof_lvl,
    wies.t3_program_type,
    wies.language_code,
    wies.prim_disability_type,
    -11 -- TODO: this id will be passed in from the previous migrate task
  FROM warehouse.iab_exam  wie
    JOIN warehouse.iab_exam_student wies ON wie.iab_exam_student_id = wies.id
  WHERE
    -- TODO: this ids will be passed in from the previous migrate task
    wie.import_id IN (SELECT id FROM warehouse.import WHERE id >= -1)
    AND wie.scale_score is not null
    AND wie.deleted = 0; -- delete will be taken care on the 'master' level

INSERT INTO staging_iab_exam (id, iab_exam_student_id, school_year, asmt_id, asmt_version, opportunity, status,
                              completeness_id, administration_condition_id, session_id, category, scale_score, scale_score_std_err,
                              completed_at, deleted, import_id, migrate_id)
  SELECT
    wie.id,
    wie.iab_exam_student_id,
    wie.school_year,
    wie.asmt_id,
    wie.asmt_version,
    wie.opportunity,
    wie.status,
    wie.completeness_id,
    wie.administration_condition_id,
    wie.session_id,
    wie.category,
    round(wie.scale_score),
    wie.scale_score_std_err,
    wie.completed_at,
    wie.deleted,
    wie.import_id,
    -11 -- TODO: this id will be passed in from the previous migrate task
  FROM warehouse.iab_exam wie
  WHERE
    -- TODO: this ids will be passed in from the previous migrate task
    wie.import_id IN (SELECT id FROM warehouse.import WHERE id >= -1)
    AND wie.scale_score is not null;

INSERT INTO staging_iab_exam_item (id, iab_exam_id, item_id, score, score_status, position, response,
                                   trait_evidence_elaboration_score, trait_evidence_elaboration_score_status,
                                   trait_organization_purpose_score, trait_organization_purpose_score_status,
                                   trait_conventions_score, trait_conventions_score_status, migrate_id)
  SELECT
    wiei.id,
    wiei.iab_exam_id,
    wiei.item_id,
    round(wiei.score),
    wiei.score_status,
    wiei.position,
    wiei.response,
    round(wiei.trait_evidence_elaboration_score),
    wiei.trait_evidence_elaboration_score_status,
    round(wiei.trait_organization_purpose_score),
    wiei.trait_organization_purpose_score_status,
    round(wiei.trait_conventions_score),
    wiei.trait_conventions_score_status,
    -11 -- TODO: this id will be passed in from the previous migrate task
  FROM warehouse.iab_exam_item wiei
    JOIN warehouse.iab_exam wie ON wiei.iab_exam_id = wie.id
  WHERE
    -- TODO: this ids will be passed in from the previous migrate task
    wie.import_id IN (SELECT id
                      FROM warehouse.import
                      WHERE id >= -1)
    AND wie.scale_score IS NOT NULL
    AND wie.deleted = 0; -- delete will be taken care on the 'master' level

INSERT INTO staging_iab_exam_available_accommodation (iab_exam_id, accommodation_id)
  SELECT
    wieaa.iab_exam_id,
    wieaa.accommodation_id
  FROM warehouse.iab_exam_available_accommodation wieaa
    JOIN warehouse.iab_exam wie ON wieaa.iab_exam_id = wie.id
  WHERE
    -- TODO: this ids will be passed in from the previous migrate task
    wie.import_id IN (SELECT id FROM warehouse.import WHERE id >= -1)
    AND wie.scale_score is not null
    AND wie.deleted = 0; -- delete will be taken care on the 'master' level

-- ICA and Summative Exams ----------------------------------------------------------------------------

INSERT INTO staging_exam_student (id, grade_id, student_id, school_id, iep, lep, section504,
                                  economic_disadvantage, migrant_status, eng_prof_lvl, t3_program_type,
                                  language_code, prim_disability_type, migrate_id)
  SELECT
    wes.id,
    wes.grade_id,
    wes.student_id,
    wes.school_id,
    wes.iep,
    wes.lep,
    wes.section504,
    wes.economic_disadvantage,
    wes.migrant_status,
    wes.eng_prof_lvl,
    wes.t3_program_type,
    wes.language_code,
    wes.prim_disability_type,
    -11 -- TODO: this id will be passed in from the previous migrate task
  FROM warehouse.exam  we
    JOIN warehouse.exam_student wes ON we.exam_student_id = wes.id
  WHERE
    -- TODO: this ids will be passed in from the previous migrate task
    we.import_id IN (SELECT id FROM warehouse.import WHERE id >= -1)
    AND we.deleted = 0; -- delete will be taken care on the 'master' level

INSERT INTO staging_exam (id, exam_student_id, school_year, asmt_id, asmt_version, opportunity, status,
                          completeness_id, administration_condition_id, session_id, achievement_level, scale_score, scale_score_std_err,
                          completed_at, deleted, import_id, migrate_id)
  SELECT
    we.id,
    we.exam_student_id,
    we.school_year,
    we.asmt_id,
    we.asmt_version,
    we.opportunity,
    we.status,
    we.completeness_id,
    we.administration_condition_id,
    we.session_id,
    we.achievement_level,
    round(we.scale_score),
    we.scale_score_std_err,
    we.completed_at,
    we.deleted,
    we.import_id,
    -11 -- TODO: this id will be passed in from the previous migrate task
  FROM warehouse.exam we
  WHERE
    -- TODO: this ids will be passed in from the previous migrate task
    we.import_id IN (SELECT id FROM warehouse.import WHERE id >= -1);

INSERT INTO staging_exam_item (id, exam_id, item_id, score, score_status, position, response,
                               trait_evidence_elaboration_score, trait_evidence_elaboration_score_status,
                               trait_organization_purpose_score, trait_organization_purpose_score_status,
                               trait_conventions_score, trait_conventions_score_status, migrate_id)
  SELECT
    wei.id,
    wei.exam_id,
    wei.item_id,
    round(wei.score),
    wei.score_status,
    wei.position,
    wei.response,
    round(wei.trait_evidence_elaboration_score),
    wei.trait_evidence_elaboration_score_status,
    round(wei.trait_organization_purpose_score),
    wei.trait_organization_purpose_score_status,
    round(wei.trait_conventions_score),
    wei.trait_conventions_score_status,
    -11 -- TODO: this id will be passed in from the previous migrate task
  FROM warehouse.exam_item wei
    JOIN warehouse.exam we ON wei.exam_id = we.id
  WHERE
    -- TODO: this ids will be passed in from the previous migrate task
    we.import_id IN (SELECT id FROM warehouse.import WHERE id >= -1)
    AND we.deleted = 0; -- delete will be taken care on the 'master' level

INSERT INTO staging_exam_available_accommodation (exam_id, accommodation_id)
  SELECT
    weaa.exam_id,
    weaa.accommodation_id
  FROM warehouse.exam_available_accommodation weaa
    JOIN warehouse.exam we ON weaa.exam_id = we.id
  WHERE
    -- TODO: this ids will be passed in from the previous migrate task
    we.import_id IN (SELECT id FROM warehouse.import WHERE id >= -1)
    AND we.deleted = 0; -- delete will be taken care on the 'master' level


INSERT INTO staging_exam_claim_score (id, exam_id, subject_claim_score_id, scale_score, scale_score_std_err, category)
  SELECT
    wecs.id,
    wecs.exam_id,
    wecs.subject_claim_score_id,
    round(wecs.scale_score),
    wecs.scale_score_std_err,
    wecs.category
  FROM warehouse.exam_claim_score wecs
    JOIN warehouse.exam we ON wecs.exam_id = we.id
  WHERE
    -- TODO: this ids will be passed in from the previous migrate task
    we.import_id IN (SELECT id FROM warehouse.import WHERE id >= -1)
    AND we.deleted = 0; -- delete will be taken care on the 'master' level

-- -----------------------------------------------------------------------------------------
-- MOVE FROM STAGING TO REPORTING
-- -----------------------------------------------------------------------------------------

-- Codes  ----------------------------------------------------------------------------------
-- the following three steps should be repeated for each code table
-- step 1: update existing codes
-- step 2: insert new codes
-- step 3: remove codes that do not exists in the staging/warehouse
-- the last step must be done after all other migration to make sure that the code can be safely removed

-- ------------ Grade --------------------------------------------------------------------
UPDATE reporting.grade rg
  JOIN staging_grade sg ON sg.id = rg.id
SET
  rg.name = sg.name,
  rg.code = sg.code;

INSERT INTO reporting.grade ( id, code, name)
  SELECT
    sg.id,
    sg.code,
    sg.name
  FROM staging_grade sg
    LEFT JOIN reporting.grade rg ON rg.id = sg.id
  WHERE rg.id IS NULL;


-- ------------ Completeness --------------------------------------------------------------------
UPDATE reporting.completeness rc
  JOIN staging_completeness sc ON sc.id = rc.id
SET
  rc.name = sc.name;

INSERT INTO reporting.completeness ( id, name)
  SELECT
    sc.id,
    sc.name
  FROM staging_completeness sc
    LEFT JOIN reporting.completeness rc ON rc.id = sc.id
  WHERE rc.id IS NULL;

-- ------------ Administration Condition ---------------------------------------------------------
UPDATE reporting.administration_condition rac
  JOIN staging_administration_condition sac ON sac.id = rac.id
SET
  rac.name = sac.name;

INSERT INTO reporting.administration_condition ( id, name)
  SELECT
    sac.id,
    sac.name
  FROM staging_administration_condition sac
    LEFT JOIN reporting.administration_condition rac ON rac.id = sac.id
  WHERE rac.id IS NULL;


-- ------------ Ethnicity ------------------------------------------------------------------------
UPDATE reporting.ethnicity re
  JOIN staging_ethnicity se ON se.id = re.id
SET
  re.name = se.name;

INSERT INTO reporting.ethnicity ( id, name)
  SELECT
    se.id,
    se.name
  FROM staging_ethnicity se
    LEFT JOIN reporting.ethnicity re ON re.id = se.id
  WHERE re.id IS NULL;


-- ------------ Gender ------------------------------------------------------------------------
UPDATE reporting.gender rg
  JOIN staging_gender sg ON sg.id = rg.id
SET
  rg.name = sg.name;

INSERT INTO reporting.gender ( id, name)
  SELECT
    sg.id,
    sg.name
  FROM staging_gender sg
    LEFT JOIN reporting.gender rg ON rg.id = sg.id
  WHERE rg.id IS NULL;


-- ------------ Accommodation ------------------------------------------------------------------------
UPDATE reporting.accommodation ra
  JOIN staging_accommodation sa ON sa.id = ra.id
SET
  ra.code = sa.code;

INSERT INTO reporting.accommodation ( id, code)
  SELECT
    sa.id,
    sa.code
  FROM staging_accommodation sa
    LEFT JOIN reporting.accommodation ra ON ra.id = sa.id
  WHERE ra.id IS NULL;


-- ------------ Claim ------------------------------------------------------------------------
UPDATE reporting.claim rc
  JOIN staging_claim sc ON sc.id = rc.id
SET
  rc.code = sc.code,
  rc.subject_id = sc.subject_id,
  rc.name = sc.name,
  rc.description = sc.description;

INSERT INTO reporting.claim ( id, subject_id, code, name, description)
  SELECT
    sc.id,
    sc.subject_id,
    sc.code,
    sc.name,
    sc.description
  FROM staging_claim sc
    LEFT JOIN reporting.claim rc ON rc.id = sc.id
  WHERE rc.id IS NULL;

-- ------------ Subject Claim Score --------------------------------------------------------------------
UPDATE reporting.subject_claim_score rc
  JOIN staging_subject_claim_score sc ON sc.id = rc.id
SET
  rc.subject_id = sc.subject_id,
  rc.asmt_type_id = sc.asmt_type_id,
  rc.code = sc.code,
  rc.name = sc.name;

INSERT INTO reporting.subject_claim_score ( id, subject_id, asmt_type_id, code, name)
  SELECT
    sc.id,
    sc.subject_id,
    sc.asmt_type_id,
    sc.code,
    sc.name
  FROM staging_subject_claim_score sc
    LEFT JOIN reporting.subject_claim_score rc ON rc.id = sc.id
  WHERE rc.id IS NULL;

-- ------------ Target ---------------------------------------------------------------------------
UPDATE reporting.target rt
  JOIN staging_target st ON st.id = rt.id
SET
  rt.claim_id = st.claim_id,
  rt.code = st.code,
  rt.description = st.description;

INSERT INTO reporting.target ( id, claim_id, code, description)
  SELECT
    st.id,
    st.claim_id,
    st.code,
    st.description
  FROM staging_target st
    LEFT JOIN reporting.target rt ON rt.id = st.id
  WHERE rt.id IS NULL;

-- ------------ Depth of knowledge ---------------------------------------------------------------------------
UPDATE reporting.depth_of_knowledge rdok
  JOIN staging_depth_of_knowledge sdok ON sdok.id = rdok.id
SET
  rdok.level = sdok.level,
  rdok.subject_id = sdok.subject_id,
  rdok.reference = sdok.reference,
  rdok.description = sdok.description;

INSERT INTO reporting.depth_of_knowledge ( id, level, subject_id, description, reference)
  SELECT
    sdok.id,
    sdok.level,
    sdok.subject_id,
    sdok.description,
    sdok.reference
  FROM staging_depth_of_knowledge sdok
    LEFT JOIN reporting.depth_of_knowledge rdok ON rdok.id = sdok.id
  WHERE rdok.id IS NULL;


-- ------------ Math Practice ---------------------------------------------------------------------------
UPDATE reporting.math_practice rmp
  JOIN staging_math_practice smp ON smp.practice = rmp.practice
SET
  rmp.description = smp.description;

INSERT INTO reporting.math_practice ( practice, description)
  SELECT
    smp.practice,
    smp.description
  FROM staging_math_practice smp
    LEFT JOIN reporting.math_practice rmp ON rmp.practice = smp.practice
  WHERE rmp.practice IS NULL;


-- ------------ Item Trait Score ---------------------------------------------------------------------------
UPDATE reporting.item_trait_score rit
  JOIN staging_item_trait_score sit ON sit.id = rit.id
SET
  rit.dimension = sit.dimension;

INSERT INTO reporting.item_trait_score ( id, dimension)
  SELECT
    sit.id,
    sit.dimension
  FROM staging_item_trait_score sit
    LEFT JOIN reporting.item_trait_score rit ON rit.id = sit.id
  WHERE rit.id IS NULL;


-- ------------ Item Difficulty Cuts ---------------------------------------------------------------------------
UPDATE reporting.item_difficulty_cuts ridc
  JOIN staging_item_difficulty_cuts sidc ON sidc.id = ridc.id
SET
  ridc.asmt_type_id = sidc.asmt_type_id,
  ridc.subject_id = sidc.subject_id,
  ridc.grade_id = sidc.grade_id,
  ridc.moderate_low_end = sidc.moderate_low_end,
  ridc.difficult_low_end = sidc.difficult_low_end;

INSERT INTO reporting.item_difficulty_cuts (id, asmt_type_id, subject_id, grade_id, moderate_low_end, difficult_low_end)
  SELECT
    sidc.id,
    sidc.asmt_type_id,
    sidc.subject_id,
    sidc.grade_id,
    sidc.moderate_low_end,
    sidc.difficult_low_end
  FROM staging_item_difficulty_cuts sidc
    LEFT JOIN reporting.item_difficulty_cuts ridc ON ridc.id = sidc.id
  WHERE ridc.id IS NULL;


-- -----------------------------------------------------------------------------------------
-- handle delete first
-- -----------------------------------------------------------------------------------------
-- IAB Exams -------------------------------------------------------------------------------
DELETE FROM reporting.iab_exam_available_accommodation WHERE iab_exam_id IN
                                                             (SELECT id from staging_iab_exam WHERE deleted = 1 );
DELETE FROM reporting.iab_exam_item WHERE iab_exam_id IN (SELECT id from staging_iab_exam WHERE deleted = 1 );
DELETE FROM reporting.iab_exam WHERE id IN (SELECT id from staging_iab_exam WHERE deleted = 1 );

-- ICA and Summative Exams -------------------------------------------------------------------------------
DELETE FROM reporting.exam_available_accommodation WHERE exam_id IN
                                                         (SELECT id from staging_exam WHERE deleted = 1 );
DELETE FROM reporting.exam_item WHERE exam_id IN (SELECT id from staging_exam WHERE deleted = 1 );
DELETE FROM reporting.exam WHERE id IN (SELECT id from staging_exam WHERE deleted = 1 );

-- Student Group ----------------------------------------------------------------------------
DELETE from reporting.student_group_membership WHERE student_group_id IN
                                                     (SELECT id FROM staging_student_group WHERE deleted = 1 or active = 0);
DELETE from reporting.user_student_group WHERE student_group_id IN
                                               (SELECT id FROM staging_student_group WHERE deleted = 1 or active = 0);
DELETE FROM reporting.student_group WHERE id IN
                                          (SELECT id FROM staging_student_group WHERE deleted = 1 or active = 0);

-- School  ---------------------------------------------------------------------------------
-- student groups and exams depend on the school.
-- Assume that all the dependent deletes were processed first
-- TODO: how to handle errors in this case?
DELETE FROM reporting.school WHERE id IN (SELECT id FROM staging_school WHERE deleted = 1);

-- remove districts if it is not associated with a school
DELETE FROM reporting.district
WHERE id in (SELECT district_id from staging_school WHERE deleted = 1)
      AND NOT EXISTS(SELECT id from reporting.school WHERE district_id = id);

-- Student  ---------------------------------------------------------------------------------
-- student groups and exams depend on the school.
-- Assume that all the dependent deletes were processed first
-- TODO: how to handle errors in this case?
DELETE FROM reporting.student_ethnicity WHERE student_id IN (SELECT id FROM staging_student WHERE deleted = 1);
DELETE FROM reporting.student WHERE id in (SELECT id FROM staging_student WHERE deleted = 1);

-- Assessment ------------------------------------------------------------------------------
-- exam depend on the asmt
-- Assume that all the dependent deletes were processed first
DELETE FROM reporting.asmt_score WHERE asmt_id IN (SELECT id FROM staging_asmt WHERE deleted = 1);
DELETE FROM reporting.item WHERE asmt_id IN (SELECT id FROM staging_asmt WHERE deleted = 1);
DELETE FROM reporting.asmt WHERE id IN (SELECT id FROM staging_asmt WHERE deleted = 1);

-- -----------------------------------------------------------------------------------------
-- Update/insert
-- Note that updates comes before insert to avoid updating newly inserted records
-- -----------------------------------------------------------------------------------------

-- School  ---------------------------------------------------------------------------------
-- District first. This covers a use case when a school gets re-assigned to a new district
-- -----------------------------------------------------------------------------------------
UPDATE reporting.district d
  JOIN staging_district sd ON sd.id = d.id
SET d.name = sd.name;

INSERT INTO reporting.district(id, natural_id,name)
  SELECT
    sd.id,
    sd.natural_id,
    sd.name
  FROM staging_district sd
    LEFT JOIN reporting.district rd ON rd.id = sd.id
  WHERE rd.id IS NULL;

UPDATE reporting.school rs
  JOIN staging_school ss ON ss.id = rs.id
SET rs.name = ss.name,
  rs.district_id = ss.district_id,
  rs.import_id = ss.import_id
WHERE ss.deleted = 0;

INSERT INTO reporting.school (id, natural_id, name, district_id, import_id)
  SELECT
    ss.id,
    ss.natural_id,
    ss.name,
    ss.district_id,
    ss.import_id
  FROM staging_school ss
    LEFT JOIN reporting.school rs ON rs.id = ss.id
  WHERE rs.id IS NULL AND ss.deleted = 0;

-- Student  ---------------------------------------------------------------------------------
-- Process students update/inserts first, and then all the ethnicity at once

-- TODO: do we need to wrap the below into a transaction? does it really matter?
UPDATE reporting.student rs
  JOIN staging_student ss ON ss.id = rs.id
SET
  rs.last_or_surname = ss.last_or_surname,
  rs.first_name = ss.first_name,
  rs.middle_name = ss.middle_name,
  rs.gender_id = ss.gender_id,
  rs.first_entry_into_us_school_at = ss.first_entry_into_us_school_at,
  rs.lep_entry_at = ss.lep_entry_at,
  rs.lep_exit_at = ss.lep_exit_at,
  rs.birthday = ss.birthday,
  rs.import_id = ss.import_id
WHERE ss.deleted = 0;

INSERT INTO reporting.student (id, ssid, last_or_surname, first_name, middle_name, gender_id, first_entry_into_us_school_at,
                               lep_entry_at, lep_exit_at, birthday, import_id)
  SELECT
    ss.id,
    ss.ssid,
    ss.last_or_surname,
    ss.first_name,
    ss.middle_name,
    ss.gender_id,
    ss.first_entry_into_us_school_at,
    ss.lep_entry_at,
    ss.lep_exit_at,
    ss.birthday,
    ss.import_id
  FROM staging_student ss
    LEFT JOIN reporting.student rs ON rs.id = ss.id
  WHERE rs.id IS NULL and ss.deleted = 0;

-- TODO: clean this up:
DELETE FROM reporting.student_ethnicity WHERE student_id in (SELECT id FROM staging_student);
INSERT INTO reporting.student_ethnicity( id, student_id, ethnicity_id)
  SELECT id, student_id, ethnicity_id from staging_student_ethnicity;


-- Student Group ---------------------------------------------------------------------------
UPDATE reporting.student_group rsg
  JOIN staging_student_group ssg ON ssg.id = rsg.id
SET
  rsg.name = ssg.name,
  rsg.school_id = ssg.school_id,
  rsg.school_year = ssg.school_year,
  rsg.subject_id = ssg.subject_id,
  rsg.creator = ssg.creator,
  rsg.created = ssg.created,
  rsg.import_id = ssg.import_id
WHERE ssg.deleted = 0 AND ssg.active = 1;

INSERT INTO reporting.student_group (id, name, school_id, school_year, subject_id, creator, created, import_id)
  SELECT
    ssg.id,
    ssg.name,
    ssg.school_id,
    ssg.school_year,
    ssg.subject_id,
    ssg.creator,
    ssg.created,
    ssg.import_id
  FROM staging_student_group ssg
    LEFT JOIN reporting.student_group rsg ON rsg.id = ssg.id
  WHERE rsg.id IS NULL AND ssg.deleted = 0 AND ssg.active = 1;

INSERT INTO reporting.student_group_membership ( student_group_id, student_id)
  SELECT
    ssgm.student_group_id,
    ssgm.student_id
  FROM staging_student_group_membership ssgm
    LEFT JOIN reporting.student_group_membership rsgm
      ON (rsgm.student_group_id = ssgm.student_group_id AND rsgm.student_id = ssgm.student_id)
  WHERE rsgm.student_group_id IS NULL;

DELETE rsgm FROM reporting.student_group_membership rsgm
WHERE student_group_id in (select id from staging_student_group where deleted = 0 and active = 1)
      AND NOT EXISTS(SELECT student_group_id FROM staging_student_group_membership
WHERE student_group_id = rsgm.student_group_id AND student_id = rsgm.student_id);

INSERT INTO reporting.user_student_group ( student_group_id, user_login)
  SELECT
    susg.student_group_id,
    susg.user_login
  FROM staging_user_student_group susg
    LEFT JOIN reporting.user_student_group rusg
      ON (rusg.student_group_id = susg.student_group_id AND rusg.user_login = susg.user_login)
  WHERE rusg.student_group_id IS NULL;

DELETE rsug FROM reporting.user_student_group rsug
WHERE student_group_id in (select id from staging_student_group where deleted = 0 and active = 1)
      AND NOT EXISTS(SELECT student_group_id FROM staging_user_student_group
WHERE student_group_id = rsug.student_group_id AND user_login = rsug.user_login);

-- Assessment ------------------------------------------------------------------------------
UPDATE reporting.asmt ra
  JOIN staging_asmt sa ON sa.id = ra.id
SET
  ra.grade_id    = sa.grade_id,
  ra.type_id     = sa.type_id,
  ra.subject_id  = sa.subject_id,
  ra.school_year = sa.school_year,
  ra.name        = sa.name,
  ra.label       = sa.label,
  ra.version     = sa.version,
  ra.import_id   = sa.import_id
WHERE sa.deleted = 0;

INSERT INTO reporting.asmt (id, natural_id, grade_id, type_id, subject_id, school_year, name,
                            label, version, import_id)
  SELECT
    sa.id,
    sa.natural_id,
    sa.grade_id,
    sa.type_id,
    sa.subject_id,
    sa.school_year,
    sa.name,
    sa.label,
    sa.version,
    sa.import_id
  FROM staging_asmt sa
    LEFT JOIN reporting.asmt ra ON ra.id = sa.id
  WHERE ra.id IS NULL and sa.deleted = 0;

-- Dependent tables' changes are considered 'updates' to the asmt
-- We need to processes them independently
-- Note that dependent tables do not have any 'root' deletes
-- Deleted to the depended tables are considered 'root' updates.

UPDATE reporting.asmt_score ras
  JOIN staging_asmt_score sas ON ras.asmt_id = sas.asmt_id
SET
  ras.cut_point_1 = sas.cut_point_1,
  ras.cut_point_2 = sas.cut_point_2,
  ras.cut_point_3 = sas.cut_point_3,
  ras.min_score   = sas.min_score,
  ras.max_score   = sas.max_score;

INSERT INTO reporting.asmt_score ( asmt_id, cut_point_1, cut_point_2, cut_point_3, min_score, max_score)
  SELECT
    sas.asmt_id,
    sas.cut_point_1,
    sas.cut_point_2,
    sas.cut_point_3,
    sas.min_score,
    sas.max_score
  FROM staging_asmt_score sas
    LEFT JOIN reporting.asmt_score ras ON ras.asmt_id = sas.asmt_id
  WHERE ras.asmt_id IS NULL;

DELETE rs FROM reporting.asmt_score rs
WHERE rs.asmt_id in (select asmt_id from staging_asmt where deleted = 0)
      AND NOT EXISTS(SELECT asmt_id FROM staging_asmt_score WHERE asmt_id = rs.asmt_id);

UPDATE reporting.item ri
  JOIN staging_item si ON ri.id = si.id
SET
  ri.claim_id      = si.claim_id,
  ri.target_id     = si.target_id,
  ri.asmt_id       = si.asmt_id,
  ri.math_practice = si.math_practice,
  ri.allow_calc    = si.allow_calc,
  ri.dok_id        = si.dok_id,
  ri.difficulty    = si.difficulty,
  ri.max_points    = si.max_points;

INSERT INTO reporting.item ( id, claim_id, target_id, natural_id, asmt_id, math_practice, allow_calc, dok_id,
                             difficulty, max_points)
  SELECT
    si.id,
    si.claim_id,
    si.target_id,
    si.natural_id,
    si.asmt_id,
    si.math_practice,
    si.allow_calc,
    si.dok_id,
    si.difficulty,
    si.max_points
  FROM staging_item si
    LEFT JOIN reporting.item ri ON ri.id = si.id
  WHERE ri.id IS NULL;

DELETE ri FROM reporting.item ri
WHERE ri.asmt_id in (select id from staging_asmt where deleted = 0)
      AND  NOT EXISTS(SELECT id FROM staging_item WHERE id = ri.id);

-- IAB Exams -----------------------------------------------------------------------------------------------

UPDATE reporting.iab_exam rie
  JOIN staging_iab_exam sie ON sie.id = rie.id
  JOIN staging_iab_exam_student sies ON sie.iab_exam_student_id = sies.id
SET
  rie.grade_id = sies.grade_id,
  rie.student_id = sies.student_id,
  rie.school_id = sies.school_id,
  rie.iep = sies.iep,
  rie.lep = sies.lep,
  rie.section504 = sies.section504,
  rie.economic_disadvantage = sies.economic_disadvantage,
  rie.migrant_status = sies.migrant_status,
  rie.eng_prof_lvl = sies.eng_prof_lvl,
  rie.t3_program_type = sies.t3_program_type,
  rie.language_code = sies.language_code,
  rie.prim_disability_type = sies.prim_disability_type,
  rie.school_year = sie.school_year,
  rie.asmt_id = sie.asmt_id,
  rie.asmt_version = sie.asmt_version,
  rie.opportunity = sie.opportunity,
  rie.status = sie.status,
  rie.completeness_id = sie.completeness_id,
  rie.administration_condition_id = sie.administration_condition_id,
  rie.session_id = sie.session_id,
  rie.category = sie.category,
  rie.scale_score = sie.scale_score,
  rie.scale_score_std_err = sie.scale_score_std_err,
  rie.completed_at = sie.completed_at,
  rie.import_id = sie.import_id
WHERE sie.deleted = 0;

INSERT INTO reporting.iab_exam (id, grade_id, student_id, school_id, iep, lep, section504, economic_disadvantage,
                                migrant_status, eng_prof_lvl, t3_program_type, language_code, prim_disability_type,
                                school_year, asmt_id, asmt_version, opportunity, status, completeness_id,
                                administration_condition_id, session_id, category, scale_score, scale_score_std_err,
                                import_id)
  SELECT
    sie.id,
    sies.grade_id,
    sies.student_id,
    sies.school_id,
    sies.iep,
    sies.lep,
    sies.section504,
    sies.economic_disadvantage,
    sies.migrant_status,
    sies.eng_prof_lvl,
    sies.t3_program_type,
    sies.language_code,
    sies.prim_disability_type,
    sie.school_year,
    sie.asmt_id,
    sie.asmt_version,
    sie.opportunity,
    sie.status,
    sie.completeness_id,
    sie.administration_condition_id,
    sie.session_id,
    sie.category,
    sie.scale_score,
    sie.scale_score_std_err,
    sie.import_id
  FROM staging_iab_exam sie JOIN staging_iab_exam_student sies ON sie.iab_exam_student_id = sies.id
    LEFT JOIN reporting.iab_exam rie ON rie.id = sie.id
  WHERE rie.id IS NULL AND sie.deleted = 0;

UPDATE reporting.iab_exam_item ri
  JOIN staging_iab_exam_item si ON ri.id = si.id
SET
  ri.iab_exam_id                             = si.iab_exam_id,
  ri.item_id                                 = si.item_id,
  ri.score                                   = si.score,
  ri.score_status                            = si.score_status,
  ri.position                                = si.position,
  ri.response                                = si.response,
  ri.trait_evidence_elaboration_score        = si.trait_evidence_elaboration_score,
  ri.trait_evidence_elaboration_score_status = si.trait_evidence_elaboration_score_status,
  ri.trait_organization_purpose_score        = si.trait_organization_purpose_score,
  ri.trait_organization_purpose_score_status = si.trait_organization_purpose_score_status,
  ri.trait_conventions_score                 = si.trait_conventions_score,
  ri.trait_conventions_score_status          = si.trait_conventions_score_status,
  ri.trait_evidence_elaboration_score_status = si.trait_evidence_elaboration_score_status;

INSERT INTO reporting.iab_exam_item (id, iab_exam_id, item_id, score, score_status, position, response,
                                     trait_evidence_elaboration_score, trait_evidence_elaboration_score_status,
                                     trait_organization_purpose_score, trait_organization_purpose_score_status,
                                     trait_conventions_score, trait_conventions_score_status)
  SELECT
    si.id,
    si.iab_exam_id,
    si.item_id,
    si.score,
    si.score_status,
    si.position,
    si.response,
    si.trait_evidence_elaboration_score,
    si.trait_evidence_elaboration_score_status,
    si.trait_organization_purpose_score,
    si.trait_organization_purpose_score_status,
    si.trait_conventions_score,
    si.trait_conventions_score_status
  FROM staging_iab_exam_item si
    LEFT JOIN reporting.iab_exam_item ri ON ri.id = si.id
  WHERE ri.id IS NULL;

DELETE ri FROM reporting.iab_exam_item ri
WHERE ri.iab_exam_id in (select id from staging_iab_exam where deleted = 0)
      AND  NOT EXISTS(SELECT id FROM staging_iab_exam_item WHERE id = ri.id);

INSERT INTO reporting.iab_exam_available_accommodation ( iab_exam_id, accommodation_id)
  SELECT
    s.iab_exam_id,
    s.accommodation_id
  FROM staging_iab_exam_available_accommodation s
    LEFT JOIN reporting.iab_exam_available_accommodation r
      ON (r.iab_exam_id = s.iab_exam_id AND r.accommodation_id = s.accommodation_id)
  WHERE r.iab_exam_id IS NULL;

DELETE r FROM reporting.iab_exam_available_accommodation r
WHERE iab_exam_id in (select id from staging_iab_exam where deleted = 0)
      AND NOT EXISTS(SELECT iab_exam_id FROM staging_iab_exam_available_accommodation
WHERE iab_exam_id = r.iab_exam_id AND accommodation_id = r.accommodation_id);

-- ICA and Summative Exams -----------------------------------------------------------------------------------------------

UPDATE reporting.exam re
  JOIN staging_exam se ON se.id = re.id
  JOIN staging_exam_student ses ON se.exam_student_id = ses.id
  INNER JOIN (
               SELECT exam_id
                 ,scale_score
                 ,scale_score_std_err
                 ,category
               FROM staging_exam_claim_score s
                 INNER JOIN reporting.exam_claim_score_mapping m ON m.subject_claim_score_id = s.subject_claim_score_id
                                                                    AND m.num = 1
             ) AS claim1 ON claim1.exam_id = se.id
  INNER JOIN (
               SELECT exam_id
                 ,scale_score
                 ,scale_score_std_err
                 ,category
               FROM staging_exam_claim_score s
                 INNER JOIN reporting.exam_claim_score_mapping m ON m.subject_claim_score_id = s.subject_claim_score_id
                                                                    AND m.num = 2
             ) AS claim2 ON claim2.exam_id = se.id
  INNER JOIN (
               SELECT exam_id
                 ,scale_score
                 ,scale_score_std_err
                 ,category
               FROM staging_exam_claim_score s
                 INNER JOIN reporting.exam_claim_score_mapping m ON m.subject_claim_score_id = s.subject_claim_score_id
                                                                    AND m.num = 3
             ) AS claim3 ON claim3.exam_id = se.id
  LEFT JOIN (
              SELECT exam_id
                ,scale_score
                ,scale_score_std_err
                ,category
              FROM staging_exam_claim_score s
                INNER JOIN reporting.exam_claim_score_mapping m ON m.subject_claim_score_id = s.subject_claim_score_id
                                                                   AND m.num = 4
            ) AS claim4 ON claim4.exam_id = se.id
SET
  re.grade_id = ses.grade_id,
  re.student_id = ses.student_id,
  re.school_id = ses.school_id,
  re.iep = ses.iep,
  re.lep = ses.lep,
  re.section504 = ses.section504,
  re.economic_disadvantage = ses.economic_disadvantage,
  re.migrant_status = ses.migrant_status,
  re.eng_prof_lvl = ses.eng_prof_lvl,
  re.t3_program_type = ses.t3_program_type,
  re.language_code = ses.language_code,
  re.prim_disability_type = ses.prim_disability_type,
  re.school_year = se.school_year,
  re.asmt_id = se.asmt_id,
  re.asmt_version = se.asmt_version,
  re.opportunity = se.opportunity,
  re.status = se.status,
  re.completeness_id = se.completeness_id,
  re.administration_condition_id = se.administration_condition_id,
  re.session_id = se.session_id,
  re.achievement_level = se.achievement_level,
  re.scale_score = se.scale_score,
  re.scale_score_std_err = se.scale_score_std_err,
  re.completed_at = se.completed_at,
  re.import_id = se.import_id,
  re.claim1_scale_score = claim1.scale_score,
  re.claim1_scale_score_std_err = claim1.scale_score_std_err,
  re.claim1_category = claim1.category,
  re.claim2_scale_score  = claim2.scale_score,
  re.claim2_scale_score_std_err = claim2.scale_score_std_err,
  re.claim2_category = claim2.category,
  re.claim3_scale_score = claim3.scale_score,
  re.claim3_scale_score_std_err = claim3.scale_score_std_err,
  re.claim3_category = claim3.category,
  re.claim4_scale_score = claim4.scale_score,
  re.claim4_scale_score_std_err = claim4.scale_score_std_err,
  re.claim4_category = claim4.category
WHERE se.deleted = 0;

INSERT INTO reporting.exam (id, grade_id, student_id, school_id, iep, lep, section504, economic_disadvantage,
                            migrant_status, eng_prof_lvl, t3_program_type, language_code, prim_disability_type,
                            school_year, asmt_id, asmt_version, opportunity, status, completeness_id,
                            administration_condition_id, session_id, achievement_level, scale_score, scale_score_std_err,
                            import_id,
                            claim1_scale_score, claim1_scale_score_std_err, claim1_category,
                            claim2_scale_score, claim2_scale_score_std_err, claim2_category,
                            claim3_scale_score, claim3_scale_score_std_err, claim3_category,
                            claim4_scale_score, claim4_scale_score_std_err, claim4_category)
  SELECT
    se.id,
    ses.grade_id,
    ses.student_id,
    ses.school_id,
    ses.iep,
    ses.lep,
    ses.section504,
    ses.economic_disadvantage,
    ses.migrant_status,
    ses.eng_prof_lvl,
    ses.t3_program_type,
    ses.language_code,
    ses.prim_disability_type,
    se.school_year,
    se.asmt_id,
    se.asmt_version,
    se.opportunity,
    se.status,
    se.completeness_id,
    se.administration_condition_id,
    se.session_id,
    se.achievement_level,
    se.scale_score,
    se.scale_score_std_err,
    se.import_id,
    claim1.scale_score as claim1_scale_score,
    claim1.scale_score_std_err as claim1_scale_score_std_err,
    claim1.category as claim1_category,
    claim2.scale_score as claim2_scale_score,
    claim2.scale_score_std_err as claim2_scale_score_std_err,
    claim2.category as claim2_category,
    claim3.scale_score as claim3_scale_score,
    claim3.scale_score_std_err as claim3_scale_score_std_err,
    claim3.category as claim3_category,
    claim4.scale_score as claim4_scale_score,
    claim4.scale_score_std_err as claim4_scale_score_std_err,
    claim4.category as claim4_category
  FROM staging_exam se
    JOIN staging_exam_student ses ON se.exam_student_id = ses.id
    INNER JOIN (
                 SELECT exam_id
                   ,scale_score
                   ,scale_score_std_err
                   ,category
                 FROM staging_exam_claim_score s
                   INNER JOIN reporting.exam_claim_score_mapping m ON m.subject_claim_score_id = s.subject_claim_score_id
                                                                      AND m.num = 1
               ) AS claim1 ON claim1.exam_id = se.id
    INNER JOIN (
                 SELECT exam_id
                   ,scale_score
                   ,scale_score_std_err
                   ,category
                 FROM staging_exam_claim_score s
                   INNER JOIN reporting.exam_claim_score_mapping m ON m.subject_claim_score_id = s.subject_claim_score_id
                                                                      AND m.num = 2
               ) AS claim2 ON claim2.exam_id = se.id
    INNER JOIN (
                 SELECT exam_id
                   ,scale_score
                   ,scale_score_std_err
                   ,category
                 FROM staging_exam_claim_score s
                   INNER JOIN reporting.exam_claim_score_mapping m ON m.subject_claim_score_id = s.subject_claim_score_id
                                                                      AND m.num = 3
               ) AS claim3 ON claim3.exam_id = se.id
    LEFT JOIN (
                SELECT exam_id
                  ,scale_score
                  ,scale_score_std_err
                  ,category
                FROM staging_exam_claim_score s
                  INNER JOIN reporting.exam_claim_score_mapping m ON m.subject_claim_score_id = s.subject_claim_score_id
                                                                     AND m.num = 4
              ) AS claim4 ON claim4.exam_id = se.id
    LEFT JOIN reporting.exam re ON re.id = se.id
  WHERE re.id IS NULL AND se.deleted = 0;

UPDATE reporting.exam_item ri
  JOIN staging_exam_item si ON ri.id = si.id
SET
  ri.exam_id                             = si.exam_id,
  ri.item_id                                 = si.item_id,
  ri.score                                   = si.score,
  ri.score_status                            = si.score_status,
  ri.position                                = si.position,
  ri.response                                = si.response,
  ri.trait_evidence_elaboration_score        = si.trait_evidence_elaboration_score,
  ri.trait_evidence_elaboration_score_status = si.trait_evidence_elaboration_score_status,
  ri.trait_organization_purpose_score        = si.trait_organization_purpose_score,
  ri.trait_organization_purpose_score_status = si.trait_organization_purpose_score_status,
  ri.trait_conventions_score                 = si.trait_conventions_score,
  ri.trait_conventions_score_status          = si.trait_conventions_score_status,
  ri.trait_evidence_elaboration_score_status = si.trait_evidence_elaboration_score_status;

INSERT INTO reporting.exam_item (id, exam_id, item_id, score, score_status, position, response,
                                 trait_evidence_elaboration_score, trait_evidence_elaboration_score_status,
                                 trait_organization_purpose_score, trait_organization_purpose_score_status,
                                 trait_conventions_score, trait_conventions_score_status)
  SELECT
    si.id,
    si.exam_id,
    si.item_id,
    si.score,
    si.score_status,
    si.position,
    si.response,
    si.trait_evidence_elaboration_score,
    si.trait_evidence_elaboration_score_status,
    si.trait_organization_purpose_score,
    si.trait_organization_purpose_score_status,
    si.trait_conventions_score,
    si.trait_conventions_score_status
  FROM staging_exam_item si
    LEFT JOIN reporting.exam_item ri ON ri.id = si.id
  WHERE ri.id IS NULL;

DELETE ri FROM reporting.exam_item ri
WHERE ri.exam_id in (select id from staging_exam where deleted = 0)
      AND  NOT EXISTS(SELECT id FROM staging_exam_item WHERE id = ri.id);

INSERT INTO reporting.exam_available_accommodation ( exam_id, accommodation_id)
  SELECT
    s.exam_id,
    s.accommodation_id
  FROM staging_exam_available_accommodation s
    LEFT JOIN reporting.exam_available_accommodation r
      ON (r.exam_id = s.exam_id AND r.accommodation_id = s.accommodation_id)
  WHERE r.exam_id IS NULL;

DELETE r FROM reporting.exam_available_accommodation r
WHERE exam_id in (select id from staging_exam where deleted = 0)
      AND NOT EXISTS(SELECT exam_id FROM staging_exam_available_accommodation
WHERE exam_id = r.exam_id AND accommodation_id = r.accommodation_id);

-- Remove codes (step 3 for code migration) ----------------------------------------------------------------
DELETE rg FROM reporting.grade rg
WHERE NOT EXISTS(SELECT id FROM staging_grade WHERE id = rg.id);

DELETE rc FROM reporting.completeness rc
WHERE NOT EXISTS(SELECT id FROM staging_completeness WHERE id = rc.id);

DELETE rac FROM reporting.administration_condition rac
WHERE NOT EXISTS(SELECT id FROM staging_administration_condition WHERE id = rac.id);

DELETE re FROM reporting.ethnicity re
WHERE NOT EXISTS(SELECT id FROM staging_ethnicity WHERE id = re.id);

DELETE rg FROM reporting.gender rg
WHERE NOT EXISTS(SELECT id FROM staging_gender WHERE id = rg.id);

DELETE ra FROM reporting.accommodation ra
WHERE NOT EXISTS(SELECT id FROM staging_accommodation WHERE id = ra.id);

DELETE rc FROM reporting.claim rc
WHERE NOT EXISTS(SELECT id FROM staging_claim WHERE id = rc.id);

DELETE rt FROM reporting.target rt
WHERE NOT EXISTS(SELECT id FROM staging_target WHERE id = rt.id);

DELETE rdok FROM reporting.depth_of_knowledge rdok
WHERE NOT EXISTS(SELECT id FROM staging_depth_of_knowledge WHERE id = rdok.id);

DELETE rmp FROM reporting.math_practice rmp
WHERE NOT EXISTS(SELECT practice FROM staging_math_practice WHERE practice = rmp.practice);

DELETE rit FROM reporting.item_trait_score rit
WHERE NOT EXISTS(SELECT id FROM staging_item_trait_score WHERE id = rit.id);

DELETE ridc FROM reporting.item_difficulty_cuts ridc
WHERE NOT EXISTS(SELECT id FROM staging_item_difficulty_cuts WHERE id = ridc.id);

UPDATE reporting.migrate
 SET
   status = 20,
   updated = CURRENT_TIMESTAMP,
   message = 'manual migrate'
WHERE id = -11;

select * from reporting.migrate where id = -11;