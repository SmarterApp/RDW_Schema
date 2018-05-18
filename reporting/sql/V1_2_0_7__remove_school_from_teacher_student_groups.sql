-- Removes the school column from the teacher student group table

use ${schemaName};

ALTER TABLE teacher_student_group
  DROP FOREIGN KEY fk__teacher_student_group__school,
  DROP INDEX idx__teacher_student_group__school_name_year,
  ADD UNIQUE INDEX idx__teacher_student_group__user_login_name_school_year (user_login, name, school_year),
  DROP COLUMN school_id;
