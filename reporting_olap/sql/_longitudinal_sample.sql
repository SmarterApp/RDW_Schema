-- -------------------------------------------------------------------------------------------------
-- School level report
-- -------------------------------------------------------------------------------------------------
SELECT
  SUM(CASE WHEN years_in_one_org = 3 THEN 1 ELSE 0 END) AS cohort_size,
  count(*) AS total_size,
  avg(CASE WHEN years_in_one_org = 3 THEN scale_score ELSE NULL END) AS cohort_avg,
  avg(scale_score) AS avg,
  stddev_samp(CASE WHEN years_in_one_org = 3 THEN scale_score ELSE NULL END) AS cohort_stdev,
  stddev_samp(scale_score) AS stdev,
  asmt_id,
  school_year,
  'School' AS organization_type,
  school_id AS organization_id
-- other dimension here
FROM (
       -- school cohort
       SELECT
         fe.scale_score,
         fe.asmt_id,
         fe.school_year,
         fe.school_id,
         -- add dimension column if not Overall, alternatively list all; will listing all make it slower?
         count(*) OVER (PARTITION BY student_id, school_id ) AS years_in_one_org
       FROM fact_student_exam fe
         JOIN asmt a ON a.id = fe.asmt_id
       WHERE
         a.subject_id = 1
         AND a.type_id = 1
         AND
         (
           (fe.school_year = 1997 AND a.grade_id = -3)
           OR (fe.school_year = 1998 AND a.grade_id = -4)
           OR (fe.school_year = 1999 AND a.grade_id = -5)
           -- pad to X years?
           OR (fe.school_year = -1 AND a.grade_id = -1)
           OR (fe.school_year = -2 AND a.grade_id = -2)
         )
         AND school_id IN (-9)
       -- AND other filters here, including embargo one
     ) cfe
-- Alternatively other filters could be here. This would make the query builder simpler since it would resemble the current query more,
--  but it could be slower.  Worth researching? I think this will allow for re-using the existing query builder code.
GROUP BY
  school_year,
  asmt_id,
  school_id;
-- dimension here

-- -------------------------------------------------------------------------------------------------
-- District level
-- -------------------------------------------------------------------------------------------------
SELECT
  SUM(CASE WHEN years_in_one_org = 3 THEN 1 ELSE 0 END) AS cohort_size,
  count(*) AS total_size,
  avg(CASE WHEN years_in_one_org = 3 THEN scale_score ELSE NULL END) AS cohort_avg,
  avg(scale_score) AS avg,
  stddev_samp(CASE WHEN years_in_one_org = 3 THEN scale_score ELSE NULL END) AS cohort_stdev,
  stddev_samp(scale_score) AS stdev,
  asmt_id,
  school_year,
  'District' AS organization_type,
  district_id AS organization_id
-- other dimension here
FROM (
       -- district cohort
       SELECT
         fe.scale_score,
         fe.asmt_id,
         fe.school_year,
         s.district_id,
         -- add dimension column if not Overall
         count(*) OVER (PARTITION BY student_id, district_id ) AS years_in_one_org
       FROM fact_student_exam fe
         JOIN asmt a ON a.id = fe.asmt_id
         JOIN school s on fe.school_id = s.id
       WHERE
         a.subject_id = 1
         AND a.type_id = 1
         AND
         (
           (fe.school_year = 1997 AND a.grade_id = -3)
           OR (fe.school_year = 1998 AND a.grade_id = -4)
           OR (fe.school_year = 1999 AND a.grade_id = -5)
         )
         AND district_id IN (-19)
       -- AND other filters here, including embargo one
     ) cfe
GROUP BY
  school_year,
  asmt_id,
  district_id;
-- dimension here

-- -------------------------------------------------------------------------------------------------
-- State level
-- -------------------------------------------------------------------------------------------------
SELECT
  SUM(CASE WHEN years_in_one_org = 3 THEN 1 ELSE 0 END) AS cohort_size,
  count(*) AS total_size,
  avg(CASE WHEN years_in_one_org = 3 THEN scale_score ELSE NULL END) AS cohort_avg,
  avg(scale_score) AS avg,
  stddev_samp(CASE WHEN years_in_one_org = 3 THEN scale_score ELSE NULL END) AS cohort_stdev,
  stddev_samp(scale_score) AS stdev,
  asmt_id,
  school_year,
  'State' AS organization_type,
  NULL AS organization_id
-- other dimension here
FROM (
       -- state cohort
       SELECT
         fe.scale_score,
         fe.asmt_id,
         fe.school_year,
         -- add dimension column if not Overall
         count(*) OVER (PARTITION BY student_id ) AS years_in_one_org
       FROM fact_student_exam fe
         JOIN asmt a ON a.id = fe.asmt_id
       WHERE
         a.subject_id = 1
         AND a.type_id = 1
         AND
         (
           (fe.school_year = 1997 AND a.grade_id = -3)
           OR (fe.school_year = 1998 AND a.grade_id = -4)
           OR (fe.school_year = 1999 AND a.grade_id = -5)
         )
       -- AND other filters here, including embargo one
     ) cfe
GROUP BY
  school_year,
  asmt_id;
-- dimension here
