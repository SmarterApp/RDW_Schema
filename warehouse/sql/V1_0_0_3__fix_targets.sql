-- fixes two errant targets
--
-- there is a corresponding patch script in reporting, so this doesn't trigger a migrate

USE ${schemaName};

UPDATE target SET description = 'Statistics and Probability: Summarize, represent, and interpret data on a single count or measurement variable.'
  WHERE natural_id = 'S-ID|P';
DELETE FROM target WHERE natural_id = 'S-ID|Q';

UPDATE target SET description = 'Geometry: Define trigonometric ratios and solve problems involving right triangles.'
  WHERE natural_id = 'G-SRT|O';
DELETE FROM target WHERE natural_id = 'G-SRT|P';
