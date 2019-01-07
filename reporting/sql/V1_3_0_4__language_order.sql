-- Add display order for languages.
-- Remove all languages without an altcode / display order.

USE ${schemaName};

ALTER TABLE language
  ADD COLUMN display_order smallint NULL;

UPDATE language
  SET display_order = CASE WHEN altcode = 'UU' THEN 99 ELSE CAST(altcode AS UNSIGNED) END
  WHERE altcode IS NOT NULL;
DELETE FROM language WHERE display_order IS NULL;

ALTER TABLE language
  DROP COLUMN altcode;

ALTER TABLE staging_language
  ADD COLUMN display_order smallint NULL,
  DROP COLUMN altcode;

