-- Add school-year to accommodation translation
--
-- The assumption is that the current accommodation translations are valid for
-- the current school year of 2019. Like assessment packages, the accommodation
-- translations have to be loaded each year, whether they've changed or not.
-- So, copy the current values for all previous years.

USE ${schemaName};

ALTER TABLE accommodation_translation
  ADD COLUMN school_year smallint,
  DROP PRIMARY KEY,
  ADD PRIMARY KEY (accommodation_id, language_code, school_year);

UPDATE accommodation_translation SET school_year = 2019;

INSERT INTO accommodation_translation (accommodation_id, label, language_code, school_year, updated)
  SELECT accommodation_id, label, language_code, year, updated FROM accommodation_translation JOIN school_year ON year != 2019;

ALTER TABLE accommodation_translation
  MODIFY COLUMN school_year smallint NOT NULL;

-- trigger CODES migration
INSERT INTO import (status, content, contentType, digest) VALUES
  (1, 3, 'reload codes', 'reload codes V1_3_0_3');
