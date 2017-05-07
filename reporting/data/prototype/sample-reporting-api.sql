USE reporting;

-- Below are sample of simplified queries, they need to be further developed during API/UI development

-- Assumptions:
-- 1. Data Mart has only active groups. Migrate will have to take care of it
-- 2. Groups that have no students with the exams will still be in the data mart.
-- 3. Only students with the exams will be in the data mart student_group_membership table.

-- TODOs:
--   decide how to handle 'ids to names' translation. Probably better to do it in Java
--   decide how to populate the filters on the screen? In java?
--   indexes
--   group subject restriction - do we want/need to have it in the SQL or can the app provide it? Note that some SQL have asmt ids that implicitly means a subject

-- https://confluence.fairwaytech.com/display/SWF/0.1+My+Groups+Widget
SELECT
  g.id
  , g.name
  , g.school_id
  , sch.name
  , g.subject_id
FROM student_group g
  JOIN school sch ON sch.id = g.school_id
  JOIN user_student_group ug ON ug.student_group_id = g.id
WHERE ug.user_login = 'user8';

-- https://confluence.fairwaytech.com/display/SWF/1.0+Student+Group+Test+Results
-- IAB tab:
-- Notes:
-- assumes pre-verified access to the group id
-- assumes additional filtering is done in the Java
explain
SELECT st.*, iab.*, asmt.*
FROM student_group_membership gm
  JOIN iab_exam iab ON iab.student_id = gm.student_id
  JOIN student st on st.id = iab.student_id
  JOIN school sch ON sch.id = iab.school_id
  JOIN asmt asmt on asmt.id = iab.asmt_id
WHERE (sch.id IN (-1) OR sch.district_id IN (-1) OR 1 = 1) AND gm.student_group_id = 2
       and iab.school_year = 2016 and asmt.subject_id = 1

-- ICA tab:
-- Notes:
-- assumes pre-verified access to the group id
-- assumes additional filtering is done in the Java
explain
SELECT st.*, exam.*, asmt.*
FROM student_group_membership gm
  JOIN exam exam ON exam.student_id = gm.student_id
  JOIN student st on st.id = exam.student_id
  JOIN school sch ON sch.id = exam.school_id
  JOIN asmt asmt on asmt.id = exam.asmt_id
WHERE (sch.id IN (-1) OR sch.district_id IN (-1) OR 1 = 1) AND gm.student_group_id = 2
      and exam.school_year = 2016 and asmt.subject_id = 1

-----------------------------------------------------------------------------------------
-- https://confluence.fairwaytech.com/display/SWF/3.0+School+Grade+Test+Results
-- similar to the above, but instead of gm.student_group_id = 2 use asmt.grade_id
-----------------------------------------------------------------------------------------


-- https://confluence.fairwaytech.com/display/SWF/1.0.1+Aggregate+Tabs
-- TODO:
-- assumes pre-verified access to the group id
-- consider de-normalization if "IF" does not perform
-- joins seems to interfere with the indexes; check performance to see if more de-normalization could help with getting it to pick up an index (assuming one is created)
SELECT
  min(iab.completed_at) as date,
  iab.session_id,
  count(*),
  iab.asmt_id,
  avg(iab.scale_score) as avg_scale_score,
  sum(IF(iab.category = 1 ,1, 0)) as category1_count,
  sum(IF(iab.category = 2 ,1, 0)) as category2_count,
  sum(IF(iab.category = 3 ,1, 0)) as category3_count,
  sqrt(sum(iab.scale_score_std_err*iab.scale_score_std_err)/count(*)) as avg_scale_score_std_err
FROM iab_exam iab
  JOIN student_group_membership gm ON iab.student_id = gm.student_id and gm.student_group_id = 2
  JOIN school sch ON sch.id = iab.school_id
  JOIN asmt a ON a.id = iab.asmt_id
  -- this is probably not needed
  JOIN subject s ON s.id = a.subject_id
WHERE
  (sch.id IN (-1) OR sch.district_id IN (-1) OR 1 = 1)
  AND iab.school_year = 2016
  -- AND iab.asmt_id in(40, 93, 84) -- passed in based on the users selection for the 'combine' feature, the subject is probably not needed in this case since
  -- assessments are subject specific
  AND s.id = 1
GROUP BY session_id, asmt_id;


-- https://confluence.fairwaytech.com/display/SWF/1.0.3+Items+By+Points+Earned
-- TODO:
-- assumes pre-verified access to the group id
-- need to decide how to handle different max scores for the items in the selection
SELECT
  iab.*,
  i.claim_id
FROM (
       SELECT
         iab.item_id                   AS item_id,
         iab.position                  AS position,
         sum(IF(iab.score = -1, 1, 0)) AS unscored,
         sum(IF(iab.score = 0, 1, 0))  AS score_0,
         sum(IF(iab.score = 1, 1, 0))  AS score_1,
         sum(IF(iab.score = 2, 1, 0))  AS score_2,
         sum(IF(iab.score = 3, 1, 0))  AS score_3,
         sum(IF(iab.score = 4, 1, 0))  AS score_4
       FROM iab_exam_item iab
         JOIN iab_exam e ON iab.iab_exam_id = e.id
         JOIN student_group_membership gm ON e.student_id = gm.student_id
         JOIN school sch ON sch.id = e.school_id
         JOIN asmt asmt on asmt.id = e.asmt_id
       WHERE
         e.session_id is null AND -- TODO: this needs to be real values with IN clause
         e.asmt_id IN (40, 93, 84) AND -- passed in based on the users selection
         (sch.id IN (-1) OR sch.district_id IN (-1) OR 1 = 1) AND gm.student_group_id = 2
         AND e.school_year = 2016 AND asmt.subject_id = 1
       GROUP BY iab.item_id, iab.position
     ) AS iab
  JOIN item i ON i.id = iab.item_id

-- https://confluence.fairwaytech.com/display/SWF/1.0.4+View+Selected+Test+Results
-- TODO:
-- assumes pre-verified access to the group id
SELECT
  st.id,
  st.first_name,
  st.middle_name,
  st.last_or_surname,
  e.grade_id,
  e.scale_score,
  e.scale_score_std_err,
  e.category,
  e.completed_at,
  e.opportunity
FROM iab_exam e
  JOIN student_group_membership gm ON e.student_id = gm.student_id
  JOIN school sch ON sch.id = e.school_id
  JOIN asmt asmt ON asmt.id = e.asmt_id
  JOIN student st ON st.id = e.student_id
WHERE
  e.session_id is null AND -- TODO: this needs to be real values with IN clause
  e.asmt_id IN (40, 93, 84) AND -- passed in based on the users selection
  (sch.id IN (-1) OR sch.district_id IN (-1) OR 1 = 1) AND gm.student_group_id = 2
  AND e.school_year = 2016 AND asmt.subject_id = 1

-- https://confluence.fairwaytech.com/display/SWF/1.0.3.0+Points+Earned+Item+List
-- NOTE: we may want to pull all items and do filtering in Java
-- assumes pre-verified access to the group id
SELECT
  st.id,
  st.first_name,
  st.middle_name,
  st.last_or_surname,
  e.grade_id,
  e.completed_at,
  e.opportunity,
  iab.item_id,
  iab.score,
  iab.response
FROM iab_exam e
  JOIN iab_exam_item iab ON iab.iab_exam_id = e.id
  JOIN item i ON i.id = iab.item_id
  JOIN student_group_membership gm ON e.student_id = gm.student_id
  JOIN school sch ON sch.id = e.school_id
  JOIN asmt asmt ON asmt.id = e.asmt_id
  JOIN student st ON st.id = e.student_id
WHERE
 -- i.claim_id is null AND -- replace with the IN clause
 -- iab.item_id = 1
  e.session_id is null AND -- replace with the IN clause
  e.asmt_id IN (40, 93, 84) AND
  (sch.id IN (-1) OR sch.district_id IN (-1) OR 1 = 1) AND gm.student_group_id = 2
  AND e.school_year = 2016 AND asmt.subject_id = 1

----------------------------------------------------------------------------------------------
-- Common between groups and not groups
----------------------------------------------------------------------------------------------

-- https://confluence.fairwaytech.com/display/SWF/2.0+Student+History+Test+Results
-- TODO:
--  assumes pre-verified access to the given student (based on the group or all groups?)
SELECT st.*, iab.*, asmt.*
FROM  iab_exam iab
  JOIN student st on st.id = iab.student_id
  JOIN school sch ON sch.id = iab.school_id
  JOIN asmt asmt on asmt.id = iab.asmt_id
WHERE (sch.id IN (-1) OR sch.district_id IN (-1) OR 1 = 1)
      and iab.student_id = 1020
      and asmt.subject_id in (1, 2)

-- https://confluence.fairwaytech.com/display/SWF/C.0.1+Full+Page+ICA+Report
-- TODO:
--  assumes pre-verified access to the given student (based on the group or all groups?) and Exam based on the subject
SELECT st.*, iab.*, asmt.*
FROM  iab_exam iab
  JOIN student st on st.id = iab.student_id
  JOIN school sch ON sch.id = iab.school_id
  JOIN asmt asmt on asmt.id = iab.asmt_id
WHERE (sch.id IN (-1) OR sch.district_id IN (-1) OR 1 = 1) -- do we even need this if it is pre-verified?
      and iab.id = 76

-- https://confluence.fairwaytech.com/display/SWF/C.1+Test+Result+Item+List
-- TODO:
--  assumes pre-verified access to the given student (based on the group or all groups?) and Exam based on the subject
SELECT st.*, iab.*, asmt.*, i.*
FROM  iab_exam iab
  JOIN iab_exam_item i on i.iab_exam_id = iab.id
  JOIN student st on st.id = iab.student_id
  JOIN school sch ON sch.id = iab.school_id
  JOIN asmt asmt on asmt.id = iab.asmt_id
WHERE (sch.id IN (-1) OR sch.district_id IN (-1) OR 1 = 1) -- do we even need this if it is pre-verified?
      and iab.id = 76