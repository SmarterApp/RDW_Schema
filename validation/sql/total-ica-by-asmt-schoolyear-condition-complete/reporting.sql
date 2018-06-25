SELECT
    count(*),
    e.asmt_id,
    e.school_year,
    e.administration_condition_code,
    e.completeness_code
  FROM exam e
  WHERE e.type_id = 1
  GROUP BY
    e.asmt_id,
    e.school_year,
    e.administration_condition_code,
    e.completeness_code
  ORDER BY
    count(*),
    e.asmt_id,
    e.school_year,
    e.administration_condition_code,
    e.completeness_code;