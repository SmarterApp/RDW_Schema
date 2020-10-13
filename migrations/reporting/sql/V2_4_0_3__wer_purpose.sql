-- v2.4.0.3 flyway script
--
-- add lookup table for WER types
-- additional subject translation entries

use ${schemaName};

-- reference table for hard-coded mapping of WER item type to purpose
CREATE TABLE wer_purpose (
  wer_type varchar(20) not null,
  purpose varchar(10) not null
);

INSERT INTO wer_purpose (wer_type, purpose) VALUES
  ('Argumentative', 'ARGU'),
  ('Explanatory', 'EXPL'),
  ('Informative', 'INFO'),
  ('Narrative', 'NARR'),
  ('Opinion', 'OPIN');

INSERT INTO subject_translation (subject_id, label_code, label) VALUES
  (2, 'subject.ELA.trait.category.CON.0', 'The response demonstrates little or no command of conventions.'),
  (2, 'subject.ELA.trait.category.CON.1', 'The response demonstrates a partial command of conventions.'),
  (2, 'subject.ELA.trait.category.CON.2', 'The response demonstrates an adequate command of conventions.'),
  (2, 'subject.ELA.trait.category.EVI.0', 'The evidence in the response is insufficient.'),
  (2, 'subject.ELA.trait.category.EVI.1', 'The response provides minimal elaboration of the support/evidence for the thesis that includes little or no use of source material. The response is vague, lacks clarity, or is confusing.'),
  (2, 'subject.ELA.trait.category.EVI.2', 'The response provides uneven, cursory elaboration of the support/evidence for the thesis that includes some reasoned analysis and partial or uneven use of source material. The response develops ideas unevenly, using simplistic language.'),
  (2, 'subject.ELA.trait.category.EVI.3', 'The response provides adequate elaboration of the support/evidence for the thesis that includes reasoned analysis and the use of source material. The response adequately develops ideas, employing a mix of precise with more general language.'),
  (2, 'subject.ELA.trait.category.EVI.4', 'The response provides thorough and convincing elaboration of the support/evidence for the thesis including reasoned, in depth analysis and the effective use of source material. The response clearly and effectively develops ideas, using precise language.'),
  (2, 'subject.ELA.trait.category.ORG.0', 'The organization of the response is insufficient.'),
  (2, 'subject.ELA.trait.category.ORG.1', 'The response has little or no discernible organizational structure. The response may be related to the topic but may provide little or no focus.'),
  (2, 'subject.ELA.trait.category.ORG.2', 'The response has an inconsistent organizational structure. Some flaws are evident, and some ideas may be loosely connected. The organization is somewhat sustained between and within paragraphs. The response may have a minor drift in focus.'),
  (2, 'subject.ELA.trait.category.ORG.3', 'The response has an evident organizational structure and a sense of completeness. Though there may be minor flaws, they do not interfere with the overall coherence. The organization is adequately sustained between and within paragraphs. The response is generally focused.'),
  (2, 'subject.ELA.trait.category.ORG.4', 'The response has a clear and effective organizational structure, creating a sense of unity and completeness. The organization is fully sustained between and within paragraphs. The response is consistently and purposefully focused.');
