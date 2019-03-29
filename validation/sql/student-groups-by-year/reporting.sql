SELECT school_year, count(*) AS count
FROM student_group
GROUP BY school_year;
