-- create missing schools
-- this is a hack since the schools need to be created in ART

use legacy_load;

INSERT INTO warehouse.import (status, content, contentType, digest) VALUES (0, 4, 'missing legacy schools', 'missing legacy schools');
SELECT LAST_INSERT_ID() INTO @importid;


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
      SELECT id, 0 INTO p_id, p_updated FROM warehouse.district WHERE natural_id = p_natural_id;
    END;

    SELECT id, name, 0 INTO p_id, cur_name, p_updated FROM warehouse.district WHERE natural_id = p_natural_id;

    IF (p_id IS NULL) THEN
      INSERT INTO warehouse.district (name, natural_id) VALUES (p_name, p_natural_id);
      SELECT id, 2 INTO p_id, p_updated FROM warehouse.district WHERE natural_id = p_natural_id;
    ELSEIF (p_name != cur_name) THEN
      UPDATE warehouse.district SET name = p_name WHERE id = p_id;
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
      SELECT id INTO p_id FROM warehouse.school WHERE natural_id = p_natural_id;
    END;

    -- there is no transaction since the worse that could happen a district will be created without a school
    CALL district_upsert(p_district_name, p_district_natural_id, p_district_id, p_district_updated);
    SELECT p_district_updated, p_district_id;

    SELECT id, name, district_id INTO p_id, cur_name, cur_district_id FROM warehouse.school WHERE natural_id = p_natural_id;

    IF (p_id IS NULL) THEN
      INSERT INTO warehouse.school (district_id, name, natural_id, import_id, update_import_id)
      VALUES (p_district_id, p_name, p_natural_id, p_import_id, p_import_id);
      SELECT id INTO p_id FROM warehouse.school WHERE natural_id = p_natural_id;
    ELSEIF (p_district_updated != 0 OR p_name != cur_name OR p_district_id != cur_district_id) THEN
      UPDATE warehouse.school SET name = p_name, district_id = p_district_id, update_import_id = p_import_id WHERE id = p_id;
    END IF;
  END; //
DELIMITER ;

-- the only way to apply a procedure to each row in a result set is to use another procedure
DELIMITER //
CREATE PROCEDURE create_missing_schools_helper()
BEGIN
  DECLARE done TINYINT DEFAULT FALSE;
  DECLARE id INT;
  DECLARE did, sid VARCHAR(40);
  DECLARE dname, sname VARCHAR(60);
  DECLARE cur CURSOR FOR select district_id, district_name, school_id, school_name from dim_inst_hier where warehouse_school_id is null;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;

  read_loop: LOOP
    FETCH cur INTO did, dname, sid, sname;
    IF done THEN
      LEAVE read_loop;
    END IF;
    CALL school_upsert(dname, did, sname, sid, @importid, id);
  END LOOP;

  CLOSE cur;
END //
DELIMITER ;

CALL create_missing_schools_helper();

DROP PROCEDURE create_missing_schools_helper;
DROP PROCEDURE school_upsert;
DROP PROCEDURE district_upsert;

-- now we can set dim_inst_hier.warehouse_school_id for the records that were missing it
UPDATE dim_inst_hier dih
  JOIN warehouse.school ws ON dih.school_id = ws.natural_id
SET warehouse_school_id = ws.id
WHERE warehouse_load_id = 1 AND warehouse_school_id IS NULL;

UPDATE warehouse.import
 SET status = 1
WHERE id = @importid;
