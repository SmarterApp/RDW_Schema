/**
** Misc. updates
**/

USE warehouse;

ALTER TABLE iab_exam
  ADD COLUMN completed_at date NOT NULL;

ALTER TABLE exam
  ADD COLUMN completed_at date NOT NULL;
