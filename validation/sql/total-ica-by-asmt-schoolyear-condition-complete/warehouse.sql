SELECT
    count(*),
    e.asmt_id,
    e.school_year,
  ac.code AS administration_condition_code,
  c.code AS completeness_code
  FROM exam e
    LEFT JOIN administration_condition ac ON e.administration_condition_id = ac.id
    LEFT JOIN completeness c ON e.completeness_id = c.id
  WHERE e.type_id = 1
    AND e.deleted = 0
  GROUP BY
    e.asmt_id,
    e.school_year,
    e.administration_condition_id,
    e.completeness_id
  ORDER BY
    count(*),
    e.asmt_id,
    e.school_year,
    ac.code,
    c.code;