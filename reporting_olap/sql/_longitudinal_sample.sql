
SELECT
  SUM(CASE WHEN years_in_one_org = 3 THEN 1 ELSE 0 END) AS cohort_size,
  count(*) AS total_size,
  avg(CASE WHEN years_in_one_org = 3 THEN scale_score ELSE NULL END) AS cohort_avg,
  avg(scale_score) AS avg,
  stddev_samp(CASE WHEN years_in_one_org = 3 THEN scale_score ELSE NULL END) AS cohort_stdev,
  stddev_samp(scale_score) AS stdev,
  s.grade_id,
  school_year,
  subject_id,
  school_id
FROM (
       SELECT
         fe.student_id,
         fe.scale_score,
         a.grade_id,
         fe.school_year,
         a.subject_id,
         fe.school_id,
         count(*) OVER (PARTITION BY student_id, school_id ) AS years_in_one_org
       FROM fact_student_exam fe
         JOIN asmt a ON a.id = fe.asmt_id
       WHERE
         a.subject_id = 1
         AND
         (
           (fe.school_year = 1997 AND a.grade_id = -3)
           OR (fe.school_year = 1998 AND a.grade_id = -4)
           OR (fe.school_year = 1999 AND a.grade_id = -5)
         )
         AND school_id = -8
       ORDER BY school_year, student_id
     ) s
-- this needs to match the number of years included, it removes students that are not found in all the years
GROUP BY
  grade_id,
  subject_id,
  school_year,
  school_id
ORDER BY subject_id,
  school_id,
  school_year,
  grade_id;