-- Flyway script to add grade order

USE ${schemaName};

ALTER TABLE grade ADD COLUMN sequence tinyint;

UPDATE grade g
   JOIN (
      SELECT 0  AS sequence, 'UG' AS code UNION ALL
      SELECT 1  AS sequence, 'IT' AS code UNION ALL
      SELECT 2  AS sequence, 'PR' AS code UNION ALL
      SELECT 3  AS sequence, 'PK' AS code UNION ALL
      SELECT 4  AS sequence, 'TK' AS code UNION ALL
      SELECT 5  AS sequence, 'KG' AS code UNION ALL
      SELECT 6  AS sequence, '01' AS code UNION ALL
      SELECT 7  AS sequence, '02' AS code UNION ALL
      SELECT 8  AS sequence, '03' AS code UNION ALL
      SELECT 9  AS sequence, '04' AS code UNION ALL
      SELECT 10 AS sequence, '05' AS code UNION ALL
      SELECT 11 AS sequence, '06' AS code UNION ALL
      SELECT 12 AS sequence, '07' AS code UNION ALL
      SELECT 13 AS sequence, '08' AS code UNION ALL
      SELECT 14 AS sequence, '09' AS code UNION ALL
      SELECT 15 AS sequence, '10' AS code UNION ALL
      SELECT 16 AS sequence, '11' AS code UNION ALL
      SELECT 17 AS sequence, '12' AS code UNION ALL
      SELECT 18 AS sequence, '13' AS code UNION ALL
      SELECT 19 AS sequence, 'PS' AS code
    ) grade_order ON grade_order.code = g.code
     SET g.sequence = grade_order.sequence;

ALTER TABLE grade MODIFY COLUMN sequence tinyint NOT NULL;