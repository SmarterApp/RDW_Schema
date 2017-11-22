SELECT
    sum(round(scale_score)),
    sum(scale_score_std_err),
    sum(performance_level)
  FROM exam
  WHERE type_id = 2
    AND deleted = 0;