/**
* DWR-413 Reporting datamart: denormalize code fields for student and student_ethnicity
**/

USE ${schemaName};

-- add gender_code
ALTER TABLE student ADD COLUMN gender_code varchar(255);
update student s
  join gender g on s.gender_id = g.id
 set s.gender_code = g.code;

-- add ethnicity code
ALTER TABLE student_ethnicity ADD COLUMN ethnicity_code varchar(255);
update student_ethnicity se
   join ethnicity e on e.id = se.ethnicity_id
  set se.ethnicity_code = e.code;

ALTER TABLE student MODIFY COLUMN gender_code varchar(255) NOT NULL;
ALTER TABLE student_ethnicity MODIFY COLUMN ethnicity_code varchar(255) NOT NULL;

-- add asmt_score columns to asmt
ALTER TABLE asmt ADD COLUMN cut_point_1 smallint;
ALTER TABLE asmt ADD COLUMN cut_point_2 smallint;
ALTER TABLE asmt ADD COLUMN cut_point_3 smallint;
ALTER TABLE asmt ADD COLUMN min_score smallint;
ALTER TABLE asmt ADD COLUMN max_score smallint;

UPDATE asmt a
	JOIN asmt_score ascore ON ascore.asmt_id = a.id
   SET a.cut_point_1 = ascore.cut_point_1, a.cut_point_2 = ascore.cut_point_2,
      a.cut_point_3 = ascore.cut_point_3, a.min_score = ascore.min_score, a.max_score = ascore.max_score;

ALTER TABLE asmt MODIFY COLUMN cut_point_2 smallint NOT NULL;
ALTER TABLE asmt MODIFY COLUMN min_score smallint NOT NULL;
ALTER TABLE asmt MODIFY COLUMN max_score smallint NOT NULL;

-- add administration_condition_code
ALTER TABLE exam ADD COLUMN administration_condition_code varchar(20);

UPDATE exam e 
    JOIN administration_condition ac on ac.id = e.administration_condition_id
   SET e.administration_condition_code = ac.code;

ALTER TABLE exam MODIFY COLUMN administration_condition_code varchar(20) NOT NULL;

-- add completeness_code
ALTER TABLE exam ADD COLUMN completeness_code varchar(10);

UPDATE exam e 
    JOIN completeness c on c.id = e.completeness_id
   SET e.completeness_code = c.code;

ALTER TABLE exam MODIFY COLUMN completeness_code varchar(10) NOT NULL;