SELECT
    sum(round(scale_score)),
    round(sum(scale_score_std_err), 1),
    sum(performance_level)
  FROM exam
  WHERE type_id = 1
    AND deleted = 0
    AND scale_score IS NOT NULL;
