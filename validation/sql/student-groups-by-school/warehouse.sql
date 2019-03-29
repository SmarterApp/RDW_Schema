SELECT d.name, d.natural_id, s.name, s.natural_id, count(*) AS count
FROM student_group sg
  JOIN school s on sg.school_id = s.id
  JOIN district d on s.district_id = d.id
WHERE sg.deleted = 0
GROUP BY sg.school_id;
