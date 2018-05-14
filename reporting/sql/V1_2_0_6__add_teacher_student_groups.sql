-- Adds teacher student group related tables

use ${schemaName};

CREATE TABLE teacher_student_group (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name varchar(255) NOT NULL,
  school_id int NOT NULL,
  school_year smallint NOT NULL,
  subject_id tinyint,
  user_login varchar(255) NOT NULL,
  UNIQUE INDEX idx__teacher_student_group__school_name_year (user_login, school_id, name, school_year),
  INDEX idx__teacher_student_group__subject (subject_id),
  INDEX idx__teacher_student_group__school_year (school_year),
  INDEX idx__teacher_student_group__user_login (user_login),
  CONSTRAINT fk__teacher_student_group__school FOREIGN KEY (school_id) REFERENCES school(id),
  CONSTRAINT fk__teacher_student_group__subject FOREIGN KEY (subject_id) REFERENCES subject(id),
  CONSTRAINT fk__teacher_student_group__school_year FOREIGN KEY (school_year) REFERENCES school_year(year)
);

CREATE TABLE teacher_student_group_membership (
  teacher_student_group_id int NOT NULL,
  student_id int NOT NULL,
  UNIQUE INDEX idx__teacher_student_group_membership (teacher_student_group_id, student_id),
  INDEX idx__teacher_student_group_membership__student (student_id),
  CONSTRAINT fk__teacher_student_group_membership__student_group FOREIGN KEY (teacher_student_group_id) REFERENCES teacher_student_group(id),
  CONSTRAINT fk__teacher_student_group_membership__student FOREIGN KEY (student_id) REFERENCES student(id)
);