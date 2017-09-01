-- fixes two errant targets
--
-- instead of relying on migrate, this just patches in the changes
-- (when consolidating scripts that means you can just ignore this file)

USE ${schemaName};

DELETE FROM target WHERE code = 'Q' AND description = 'Statistics and Probability: Summarize, represent, and interpret data on a single count or measurement variable.';
DELETE FROM target WHERE code = 'P' AND description = 'Geometry: Define trigonometric ratios and solve problems involving right triangles.';

UPDATE target SET description = 'Statistics and Probability: Summarize, represent, and interpret data on a single count or measurement variable.'
  WHERE code = 'P' AND description = 'UNKNOWN';
UPDATE target SET description = 'Geometry: Define trigonometric ratios and solve problems involving right triangles.'
  WHERE code = 'O' AND description = 'UNKNOWN';
