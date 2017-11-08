USE ${schemaName};

/************************************* Stored procedures ***************************************/

DROP PROCEDURE IF EXISTS student_upsert;

DELIMITER //
CREATE PROCEDURE student_upsert(IN  p_ssid                          VARCHAR(65),
                                IN  p_last_or_surname               VARCHAR(60),
                                IN  p_first_name                    VARCHAR(60),
                                IN  p_middle_name                   VARCHAR(60),
                                IN  p_gender_id                     TINYINT,
                                IN  p_first_entry_into_us_school_at DATE,
                                IN  p_lep_entry_at                  DATE,
                                IN  p_lep_exit_at                   DATE,
                                IN  p_birthday                      DATE,
                                IN  p_inferred_school_id            INT,
                                IN  p_inferred_effective_date       TIMESTAMP(6),
                                IN  p_import_id                     BIGINT,
                                OUT p_id                            INT,
                                OUT p_updated                       TINYINT)
  BEGIN
    --  handle duplicate entry: if there are two competing inserts, one will end up here
    DECLARE CONTINUE HANDLER FOR 1062
    BEGIN
      SELECT id, 0 INTO p_id, p_updated FROM student WHERE ssid = p_ssid;
    END;

    SELECT id, 0 INTO p_id, p_updated FROM student WHERE ssid = p_ssid;

    IF (p_id IS NOT NULL)
    THEN
       IF(p_inferred_school_id IS NULL)
         THEN
            SELECT e1.school_id, e1.completed_at INTO p_inferred_school_id, p_inferred_effective_date
                FROM (SELECT * FROM exam WHERE deleted = 0 and student_id = p_id) AS e1
                    LEFT OUTER JOIN (SELECT * FROM exam WHERE deleted = 0 and student_id = p_id) AS e2
                    ON e1.student_id = e2.student_id AND (e1.completed_at < e2.completed_at
                    OR (e1.completed_at = e2.completed_at AND e1.Id < e2.Id))
                WHERE e2.student_id IS NULL;
       END IF;

      -- check if there is anything to update
      SELECT CASE WHEN count(*) > 0 THEN 0 ELSE 1 END INTO p_updated FROM student
      WHERE id = p_id
            AND last_or_surname <=> p_last_or_surname
            AND first_name <=> p_first_name
            AND middle_name <=> p_middle_name
            AND gender_id <=> p_gender_id
            AND first_entry_into_us_school_at <=> p_first_entry_into_us_school_at
            AND lep_entry_at <=> p_lep_entry_at
            AND lep_exit_at <=> p_lep_exit_at
            AND birthday <=>  p_birthday
            AND (inferred_effective_date <=> p_inferred_effective_date OR (inferred_effective_date IS NOT NULL AND inferred_effective_date > COALESCE(p_inferred_effective_date,inferred_effective_date)))
            AND (inferred_school_id <=> p_inferred_school_id OR (inferred_effective_date IS NOT NULL AND inferred_effective_date > COALESCE(p_inferred_effective_date,inferred_effective_date)));

      IF (p_updated = 1)
      THEN
        UPDATE student
        SET
          last_or_surname               = p_last_or_surname,
          first_name                    = p_first_name,
          middle_name                   = p_middle_name,
          gender_id                     = p_gender_id,
          first_entry_into_us_school_at = p_first_entry_into_us_school_at,
          lep_entry_at                  = p_lep_entry_at,
          lep_exit_at                   = p_lep_exit_at,
          birthday                      = p_birthday,
          inferred_effective_date       = CASE WHEN (p_inferred_effective_date IS NULL OR p_inferred_effective_date >= COALESCE(inferred_effective_date, p_inferred_effective_date)) THEN p_inferred_effective_date ELSE inferred_effective_date END,
          inferred_school_id            = CASE WHEN (p_inferred_effective_date IS NULL OR p_inferred_effective_date >= COALESCE(inferred_effective_date, p_inferred_effective_date)) THEN p_inferred_school_id ELSE inferred_school_id END,
          update_import_id              = p_import_id
        WHERE id = p_id;
      END IF;
    ELSE
      INSERT INTO student (ssid, last_or_surname, first_name, middle_name, gender_id, first_entry_into_us_school_at, lep_entry_at, lep_exit_at, birthday, inferred_school_id, inferred_effective_date, import_id, update_import_id)
      VALUES (p_ssid, p_last_or_surname, p_first_name, p_middle_name, p_gender_id, p_first_entry_into_us_school_at, p_lep_entry_at, p_lep_exit_at, p_birthday, p_inferred_school_id, p_inferred_effective_date, p_import_id, p_import_id);

      SELECT id, 2 INTO p_id, p_updated FROM student WHERE ssid = p_ssid;
    END IF;
  END; //
DELIMITER ;