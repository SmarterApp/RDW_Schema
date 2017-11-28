-- SAMPLE insertion of assessment-wide System instructional resources.
-- Modify this sample script to insert assessment-wide or performance-level
--  instructional resources for the system.

use reporting;

INSERT INTO instructional_resource (asmt_name, org_level, performance_level, resource) VALUES
  ('SBAC-IAB-FIXED-G3M-NBT-MATH-3', 'System', 0, 'https://portal.smarterbalanced.org/library/en/v1.0/digital-library-connections-grade-3-number-and-operations-in-base-ten.docx'),
  ('SBAC-IAB-FIXED-G4E-Revision-ELA-4', 'System', 0, 'https://portal.smarterbalanced.org/library/en/digital-library-connections-grade-4-revision.docx'),
  ('SBAC-IAB-FIXED-G4E-BriefWrites-ELA-4', 'System', 0, 'https://portal.smarterbalanced.org/library/en/v1.0/digital-library-connections-grade-4-brief-writes.docx'),
  ('SBAC-IAB-FIXED-G5M-NF-MATH-5', 'System', 0, 'https://portal.smarterbalanced.org/library/en/digital-library-connections-grade-5-fractions.docx'),
  ('SBAC-IAB-FIXED-G6M-G-Calc-MATH-6', 'System', 0, 'https://portal.smarterbalanced.org/library/en/digital-library-connections-grade-6-geometry.docx'),
  ('SBAC-IAB-FIXED-G7E-ReadLit-ELA-7', 'System', 0, 'https://portal.smarterbalanced.org/library/en/digital-library-connections-grade-7-read-literary-texts.docx'),
  ('SBAC-IAB-FIXED-G7M-RP-Calc-MATH-7', 'System', 0, 'https://portal.smarterbalanced.org/library/en/digital-library-connections-grade-7-ratio-and-proportional-relationships.docx'),
  ('SBAC-IAB-FIXED-G8E-Research-ELA-8', 'System', 0, 'https://portal.smarterbalanced.org/library/en/digital-library-connections-grade-8-research.docx'),
  ('SBAC-IAB-FIXED-G11E-BriefWrites-ELA-11', 'System', 0, 'https://portal.smarterbalanced.org/library/en/digital-library-connections-high-school-brief-writes.docx'),
  ('SBAC-IAB-FIXED-G11E-Revision-ELA-11', 'System', 0, 'https://portal.smarterbalanced.org/library/en/digital-library-connections-high-school-revision.docx'),
  ('SBAC-IAB-FIXED-G11M-SP-Calc-MATH-11', 'System', 0, 'https://portal.smarterbalanced.org/library/en/digital-library-connections-high-school-statistics-and-probability.docx');