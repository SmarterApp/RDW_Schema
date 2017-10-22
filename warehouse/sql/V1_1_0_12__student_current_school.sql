-- create a view that represents a student current school
USE ${schemaName};

CREATE VIEW student_current_school AS
SELECT
  e1.school_id,
  e1.student_id,
  e1.completed_at as last_exam_at,
  e1.import_id,
  e1.created,
  e1.update_import_id,
  e1.updated
FROM exam AS e1
  LEFT OUTER JOIN exam AS e2
    ON e1.student_id = e2.student_id
       AND (e1.completed_at < e2.completed_at
            OR (e1.completed_at = e2.completed_at AND e1.Id < e2.Id))
WHERE e2.student_id IS NULL;