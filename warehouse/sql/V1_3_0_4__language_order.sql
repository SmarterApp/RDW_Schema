-- Add display order for languages

USE ${schemaName};

ALTER TABLE language
  ADD COLUMN display_order smallint NULL;

UPDATE language
  SET display_order = CASE WHEN altcode = 'UU' THEN 99 ELSE CAST(altcode AS UNSIGNED) END
  WHERE altcode IS NOT NULL;
