-- improve performance of school_upsert

DROP PROCEDURE IF EXISTS district_upsert;
DELIMITER //
CREATE PROCEDURE district_upsert(IN  p_name       VARCHAR(100),
                                 IN  p_natural_id VARCHAR(40),
                                 OUT p_id         INT,
                                 OUT p_updated    TINYINT)
  BEGIN
    DECLARE cur_name VARCHAR(100);

    --  handle duplicate entry: if there are two competing inserts, one will end up here
    DECLARE CONTINUE HANDLER FOR 1062
    BEGIN
      SELECT id, 0 INTO p_id, p_updated FROM district WHERE natural_id = p_natural_id;
    END;

    SELECT id, name, 0 INTO p_id, cur_name, p_updated FROM district WHERE natural_id = p_natural_id;

    IF (p_id IS NULL) THEN
      INSERT INTO district (name, natural_id) VALUES (p_name, p_natural_id);
      SELECT id, 2 INTO p_id, p_updated FROM district WHERE natural_id = p_natural_id;
    ELSEIF (p_name != cur_name) THEN
      UPDATE district SET name = p_name WHERE id = p_id;
      SELECT 1 INTO p_updated;
    END IF;
  END; //
DELIMITER ;


DROP PROCEDURE IF EXISTS school_upsert;
DELIMITER //
CREATE PROCEDURE school_upsert(IN  p_district_name       VARCHAR(100),
                               IN  p_district_natural_id VARCHAR(40),
                               IN  p_name                VARCHAR(100),
                               IN  p_natural_id          VARCHAR(40),
                               IN  p_import_id           BIGINT,
                               OUT p_id                  INT)
  BEGIN
    DECLARE p_district_updated TINYINT;
    DECLARE p_district_id INT;
    DECLARE cur_name VARCHAR(100);
    DECLARE cur_district_id INT;

    --  handle duplicate entry: if there are two competing inserts, one will end up here
    DECLARE CONTINUE HANDLER FOR 1062
    BEGIN
      SELECT id INTO p_id FROM school WHERE natural_id = p_natural_id;
    END;

    -- there is no transaction since the worse that could happen a district will be created without a school
    CALL district_upsert(p_district_name, p_district_natural_id, p_district_id, p_district_updated);
    SELECT p_district_updated, p_district_id;

    SELECT id, name, district_id INTO p_id, cur_name, cur_district_id FROM school WHERE natural_id = p_natural_id;

    IF (p_id IS NULL) THEN
      INSERT INTO school (district_id, name, natural_id, import_id, update_import_id)
      VALUES (p_district_id, p_name, p_natural_id, p_import_id, p_import_id);
      SELECT id INTO p_id FROM school WHERE natural_id = p_natural_id;
    ELSEIF (p_district_updated != 0 OR p_name != cur_name OR p_district_id != cur_district_id) THEN
      UPDATE school SET name = p_name, district_id = p_district_id, update_import_id = p_import_id WHERE id = p_id;
    END IF;
  END; //
DELIMITER ;