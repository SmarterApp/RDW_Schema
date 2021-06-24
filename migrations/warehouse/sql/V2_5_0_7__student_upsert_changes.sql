-- v2.5.0_7 flyway script
-- Add event timestamp to student upsert routine.
use
${schemaName};

ALTER TABLE student ADD COLUMN latest_info_update timestamp(6) default CURRENT_TIMESTAMP(6) not null;

DROP PROCEDURE IF EXISTS student_upsert;
DELIMITER //
CREATE PROCEDURE student_upsert(IN  p_ssid                          VARCHAR(65),
                                IN  p_last_or_surname               VARCHAR(60),
                                IN  p_first_name                    VARCHAR(60),
                                IN  p_middle_name                   VARCHAR(60),
                                IN  p_alias_name                    VARCHAR(60),
                                IN  p_gender_id                     TINYINT,
                                IN  p_first_entry_into_us_school_at DATE,
                                IN  p_lep_entry_at                  DATE,
                                IN  p_lep_exit_at                   DATE,
                                IN  p_birthday                      DATE,
                                IN  p_exam_school_id                INT,
                                IN  p_exam_completed_at             TIMESTAMP(6),
                                IN  p_import_id                     BIGINT,
                                OUT p_id                            INT,
                                OUT p_updated                       TINYINT)
BEGIN
--  handle duplicate entry: if there are two competing inserts, one will end up here
DECLARE CONTINUE HANDLER FOR 1062
BEGIN
SELECT id, 0 INTO p_id, p_updated FROM student  WHERE ssid = p_ssid;
END;

SELECT id, 0 INTO p_id, p_updated FROM student WHERE ssid = p_ssid;

IF (p_id IS NOT NULL) THEN
  -- infer a school based on the given effective date and existing exams
  SELECT CASE WHEN count(*) > 0 THEN 1 ELSE 0 END INTO p_updated
  FROM exam WHERE student_id = p_id AND deleted = 0
  LIMIT 1;

  IF (p_updated = 1) THEN
    SELECT
       CASE WHEN p_exam_completed_at IS NULL OR completed_at > p_exam_completed_at THEN school_id ELSE p_exam_school_id END,
       CASE WHEN p_exam_completed_at IS NULL OR completed_at > p_exam_completed_at THEN completed_at ELSE p_exam_completed_at END
    INTO p_exam_school_id, p_exam_completed_at
    FROM exam WHERE student_id = p_id AND deleted = 0
    ORDER BY completed_at DESC LIMIT 1;
  END IF;

  -- Default null exam completion time to current timestamp
  SELECT CASE WHEN p_exam_completed_at IS NULL THEN CURRENT_TIMESTAMP(6) ELSE p_exam_completed_at END
  INTO p_exam_completed_at;

  -- check if there is anything to update
  SELECT CASE WHEN count(*) > 0 THEN 0 ELSE 1 END INTO p_updated
  FROM student
  WHERE id = p_id
    AND last_or_surname <=> p_last_or_surname
    AND first_name <=> p_first_name
    AND middle_name <=> p_middle_name
    AND alias_name <=> p_alias_name
    AND gender_id <=> p_gender_id
    AND first_entry_into_us_school_at <=> p_first_entry_into_us_school_at
    AND lep_entry_at <=> p_lep_entry_at
    AND lep_exit_at <=> p_lep_exit_at
    AND birthday <=> p_birthday
    AND inferred_school_id <=> p_exam_school_id;

  SELECT CASE WHEN count(*) > 0 THEN 0 ELSE p_updated END INTO p_updated
  FROM student
  WHERE id  = p_id AND p_exam_completed_at < student.latest_info_update;

  IF (p_updated = 1) THEN
    UPDATE student
    SET
    last_or_surname               = p_last_or_surname,
    first_name                    = p_first_name,
    middle_name                   = p_middle_name,
    alias_name                    = p_alias_name,
    gender_id                     = p_gender_id,
    first_entry_into_us_school_at = p_first_entry_into_us_school_at,
    lep_entry_at                  = p_lep_entry_at,
    lep_exit_at                   = p_lep_exit_at,
    birthday                      = p_birthday,
    inferred_school_id            = p_exam_school_id,
    update_import_id              = p_import_id,
    latest_info_update            = p_exam_completed_at
    WHERE id = p_id;
  END IF;
ELSE
  -- Default null exam completion time to current timestamp
  SELECT CASE WHEN p_exam_completed_at IS NULL THEN CURRENT_TIMESTAMP(6) ELSE p_exam_completed_at END
  INTO p_exam_completed_at;

  INSERT INTO student (ssid, last_or_surname, first_name, middle_name, alias_name, gender_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, birthday, inferred_school_id, import_id, update_import_id, latest_info_update)
  VALUES (p_ssid, p_last_or_surname, p_first_name, p_middle_name, p_alias_name, p_gender_id, p_first_entry_into_us_school_at, p_lep_entry_at, p_lep_exit_at, p_birthday, p_exam_school_id, p_import_id, p_import_id, p_exam_completed_at);

  SELECT id, 2 INTO p_id, p_updated FROM student WHERE ssid = p_ssid;
END IF;
END;
//
DELIMITER ;

