-- more code cleanup

USE ${schemaName};

-- Although we'd like to do this, we can't with existing data
-- If a full data wipe is done (and scripts consolidated) most UNKNOWN claim targets should be eliminated
-- DELETE FROM target WHERE description = 'UNKNOWN' AND natural_id NOT IN ('S-ID|P', 'G-SRT|O');

INSERT INTO common_core_standard (subject_id, natural_id, description) VALUES
  (1,'G-CO.B','Understand congruence in terms of rigid motions.'),
  (1,'G-CO.C','Prove geometric theorems.'),
  (1,'G-CO.D','Make geometric constructions.'),
  (1,'G-GMD.A','Explain volume formulas and use them to solve problems.'),
  (1,'G-GMD.B','Visualize relationships between two-dimensional and three-dimensional objects.'),
  (1,'G-MG.A','Apply geometric concepts in modeling situations'),
  (1,'N-RN.A','Extend the properties of exponents to rational exponents.'),
  (1,'N-RN.B','Use properties of rational and irrational numbers.'),
  (1,'A-SSE.A','Interpret the structure of expressions.'),
  (1,'A-SSE.B','Write expressions in equivalent forms to solve problems.');

  -- trigger migration
INSERT INTO import (status, content, contentType, digest) VALUES
  (1, 3, 'more code cleanup', 'more code cleanup');
