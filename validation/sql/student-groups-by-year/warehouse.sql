SELECT school_year, count(*) AS count
FROM student_group
WHERE deleted = 0
GROUP BY school_year;
