-- v2.4.0.1 flyway script
--
-- adjust trait messages (for ELA)

use ${schemaName};

DELETE FROM subject_translation WHERE label_code IN (
    'subject.ELA.trait.purpose.ARGU',
    'subject.ELA.trait.purpose.EXPL',
    'subject.ELA.trait.purpose.INFO',
    'subject.ELA.trait.purpose.NARR',
    'subject.ELA.trait.purpose.OPIN',
    'subject.ELA.trait.category.ORG',
    'subject.ELA.trait.category.CON',
    'subject.ELA.trait.category.EVI'
);

INSERT INTO subject_translation (subject_id, label_code, label) VALUES
  (2, 'subject.ELA.trait.purpose.ARGU.name', 'Argumentative'),
  (2, 'subject.ELA.trait.purpose.EXPL.name', 'Explanatory'),
  (2, 'subject.ELA.trait.purpose.INFO.name', 'Informative'),
  (2, 'subject.ELA.trait.purpose.NARR.name', 'Narrative'),
  (2, 'subject.ELA.trait.purpose.OPIN.name', 'Opinion'),
  (2, 'subject.ELA.trait.category.ORG.name', 'Organization/Purpose'),
  (2, 'subject.ELA.trait.category.CON.name', 'Conventions'),
  (2, 'subject.ELA.trait.category.EVI.name', 'Evidence/Elaboration');

INSERT INTO subject_translation (subject_id, label_code, label) VALUES
  (2, 'subject.ELA.trait.purpose.ARGU.description', 'Description of Argumentative purpose'),
  (2, 'subject.ELA.trait.purpose.EXPL.description', 'Description of Explanatory purpose'),
  (2, 'subject.ELA.trait.purpose.INFO.description', 'Description of Informative purpose'),
  (2, 'subject.ELA.trait.purpose.NARR.description', 'Description of Narrative purpose'),
  (2, 'subject.ELA.trait.purpose.OPIN.description', 'Description of Opinion purpose');
