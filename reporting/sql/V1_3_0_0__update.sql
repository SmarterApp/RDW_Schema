-- Consolidated v1.2.1 -> v1.3.0 flyway script.
--
-- This script should be run against v1.2.1 installations where the schema_version table looks like:
-- +----------------+---------+------------------------------+--------+----------------------+-------------+---------+
-- | installed_rank | version | description                  | type   | script               | checksum    | success |
-- +----------------+---------+------------------------------+--------+----------------------+-------------+---------+
-- |              1 | NULL    | << Flyway Schema Creation >> | SCHEMA | `reporting`          |        NULL |       1 |
-- |              2 | 1.0.0.0 | ddl                          | SQL    | V1_0_0_0__ddl.sql    |   986463590 |       1 |
-- |              3 | 1.0.0.1 | dml                          | SQL    | V1_0_0_1__dml.sql    | -1123132459 |       1 |
-- |              4 | 1.1.0.0 | update                       | SQL    | V1_1_0_0__update.sql | -1706757701 |       1 |
-- |              5 | 1.2.0.0 | update                       | SQL    | V1_2_0_0__update.sql |  1999355730 |       1 |
-- |              6 | 1.2.1.0 | update                       | SQL    | V1_2_1_0__update.sql |  1586448759 |       1 |
-- +----------------+---------+------------------------------+--------+----------------------+-------------+---------+
--
-- When first created, RDW_Schema was on build #403 and this incorporated:
--   V1_3_0_0__target_report.sql
--   V1_3_0_1__language.sql
--   V1_3_0_2__school_year.sql
--   V1_3_0_4__language_order.sql
--   V1_3_0_5__alias_name.sql
--   military_connected was added during consolidation


USE ${schemaName};

INSERT IGNORE INTO school_year (year) VALUES (2019);


CREATE TABLE IF NOT EXISTS military_connected (
  id TINYINT NOT NULL PRIMARY KEY,
  code VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS staging_military_connected (
  id TINYINT NOT NULL PRIMARY KEY,
  code VARCHAR(30) NOT NULL
);

ALTER TABLE exam
  ADD COLUMN military_connected_code VARCHAR(30) NULL;


ALTER TABLE subject_asmt_type ADD COLUMN target_report tinyint;
UPDATE subject_asmt_type SET target_report = IF(asmt_type_id = 3, 1, 0);
ALTER TABLE subject_asmt_type MODIFY COLUMN target_report tinyint NOT NULL;

ALTER TABLE staging_subject_asmt_type ADD COLUMN target_report tinyint NOT NULL;


ALTER TABLE student
  ADD COLUMN alias_name VARCHAR(60) NULL COMMENT 'optional alias for first name';

ALTER TABLE staging_student
  ADD COLUMN alias_name VARCHAR(60) NULL;


CREATE TABLE IF NOT EXISTS language (
  id smallint NOT NULL PRIMARY KEY,
  code char(3) NOT NULL UNIQUE   COMMENT 'CEDS / ISO 639-2 code',
  altcode char(2) NULL           COMMENT 'optional (CALPADS) code',
  name varchar(100) NOT NULL UNIQUE,
  display_order smallint NULL
);

CREATE TABLE IF NOT EXISTS staging_language (
  id smallint NOT NULL PRIMARY KEY,
  code char(3) NOT NULL,
  altcode char(2) NULL,
  name varchar(100) NOT NULL,
  display_order smallint NULL
);

-- have to duplicate this so we can update the exam table using it
INSERT INTO language (id, code, altcode, name, display_order) VALUES
(0,  'eng', '00', 'English', 0),
(1,  'spa', '01', 'Spanish', 51),
(2,  'vie', '02', 'Vietnamese', 65),
(3,  'chi', '03', 'Chinese; Cantonese', 14),
(4,  'kor', '04', 'Korean', 32),
(5,  'fil', '05', 'Filipino; Pilipino', 16),
(6,  'por', '06', 'Portuguese', 44),
(7,  'mnd', '07', 'Mandarin', 36),  -- code is unofficial
(8,  'jpn', '08', 'Japanese', 28),
(9,  'mkh', '09', 'Mon-Khmer languages', 39),
(10, 'lao', '10', 'Lao', 35),
(11, 'ara', '11', 'Arabic', 4),
(12, 'arm', '12', 'Armenian', 5),
(13, 'bur', '13', 'Burmese', 10),
(15, 'dut', '15', 'Dutch', 15),
(16, 'per', '16', 'Persian; Farsi', 42),
(17, 'fre', '17', 'French', 17),
(18, 'ger', '18', 'German', 18),
(19, 'gre', '19', 'Greek', 19),
(20, 'cha', '20', 'Chamorro', 12),
(21, 'heb', '21', 'Hebrew', 21),
(22, 'hin', '22', 'Hindi', 22),
(23, 'hmn', '23', 'Hmong; Mong', 23),
(24, 'hun', '24', 'Hungarian', 24),
(25, 'ilo', '25', 'Iloko; Ilocano', 25),
(26, 'ind', '26', 'Indonesian', 26),
(27, 'ita', '27', 'Italian', 27),
(28, 'pan', '28', 'Panjabi; Punjabi', 41),
(29, 'rus', '29', 'Russian', 47),
(30, 'smo', '30', 'Samoan', 48),
(32, 'tha', '32', 'Thai', 57),
(33, 'tur', '33', 'Turkish', 61),
(34, 'ton', '34', 'Tongan', 60),
(35, 'urd', '35', 'Urdu', 63),
(36, 'ceb', '36', 'Cebuano; Visayan', 11),
(37, 'sgn', '37', 'Sign Languages', 49),
(38, 'ukr', '38', 'Ukrainian', 62),
(39, 'chz', '39', 'Chaozhou; Chiuchow; Teochew', 13),  -- code is unofficial
(40, 'pus', '40', 'Pushto; Pashto', 45),
(41, 'pol', '41', 'Polish', 43),
(42, 'syr', '42', 'Syriac; Assyrian', 53),
(43, 'guj', '43', 'Gujarati', 20),
(44, 'yao', '44', 'Yao; Mien', 66),
(45, 'rum', '45', 'Romanian; Moldavian; Moldovan', 46),
(46, 'taw', '46', 'Taiwanese', 54),  -- code is unofficial
(47, 'lau', '47', 'Lahu', 34),  -- code is unofficial
(48, 'mah', '48', 'Marshallese', 38),
(49, 'oto', '49', 'Otomian languages; Mixteco', 40),
(50, 'map', '50', 'Austronesian languages; Khmu', 6),
(51, 'kur', '51', 'Kurdish', 33),
(52, 'bat', '52', 'Baltic languages', 7),
(53, 'toi', '53', 'Toishanese', 59),  -- code is unofficial
(54, 'afa', '54', 'Afro-Asiatic languages; Chaldean', 1),
(56, 'alb', '56', 'Albanian', 2),
(57, 'tir', '57', 'Tigrinya', 58),
(60, 'som', '60', 'Somali', 50),
(61, 'ben', '61', 'Bengali', 8),
(62, 'tel', '62', 'Telugu', 56),
(63, 'tam', '63', 'Tamil', 55),
(64, 'mar', '64', 'Marathi', 37),
(65, 'kan', '65', 'Kannada', 29),
(66, 'amh', '66', 'Amharic', 3),
(67, 'bul', '67', 'Bulgarian', 9),
(68, 'kik', '68', 'Kikuyu; Gikuyu', 31),
(69, 'kas', '69', 'Kashmiri', 30),
(70, 'swe', '70', 'Swedish', 52),
(71, 'zap', '71', 'Zapotec', 67),
(72, 'uzb', '72', 'Uzbek', 64),
(99, 'mis', '99', 'Uncoded languages', 99),
(98, 'und', 'UU', 'Undetermined', 99);

-- create helper
DROP PROCEDURE IF EXISTS loop_by_exam_id;
DELIMITER //
CREATE PROCEDURE loop_by_exam_id(IN p_sql VARCHAR(1000))
BEGIN
  DECLARE batch, iter INTEGER;
  SET batch = 500000;
  SET iter = 0;

  SELECT 1 + FLOOR(MAX(id) / batch) INTO @max_iter FROM exam;

  partition_loop: LOOP
    SET @stmt = CONCAT(p_sql, ' AND e.id >= ', iter * batch, ' AND e.id < ', (iter + 1) * batch);
    PREPARE stmt FROM @stmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SELECT CONCAT('executed partition:', iter);

    SET iter = iter + 1;
    IF iter < @max_iter THEN
      ITERATE partition_loop;
    END IF;
    LEAVE partition_loop;
  END LOOP partition_loop;
END;
//
DELIMITER ;

-- do the work
-- unlike the warehouse, keep language_code and update it with the correct code value
CALL loop_by_exam_id('UPDATE exam e JOIN language l ON LOWER(e.language_code) = l.code SET e.language_code = l.code, e.updated = e.updated WHERE e.language_code IS NOT NULL');
CALL loop_by_exam_id('UPDATE exam e JOIN language l ON l.altcode IS NOT NULL AND e.language_code = l.altcode SET e.language_code = l.code, e.updated = e.updated WHERE e.language_code IS NOT NULL');

ALTER TABLE staging_exam
  ADD COLUMN language_id SMALLINT NULL,
  DROP COLUMN language_code,
  ADD COLUMN military_connected_id TINYINT NULL;

-- drop helper
DROP PROCEDURE loop_by_exam_id;

