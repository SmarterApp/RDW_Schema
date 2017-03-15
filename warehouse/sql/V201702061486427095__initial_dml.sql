
/**
** 	Initial data load
**/

USE warehouse;

INSERT INTO application_schema_version (major_version) VALUES (0);

INSERT INTO subject (id, name) VALUES
  (1, 'Math'),
  (2, 'ELA');

INSERT INTO grade (id, code, name) VALUES
  (16, 'IT', 'Infant/toddler'),
  (17, 'PR', 'Preschool'),  
  (18, 'PK', 'Prekindergarten'),
  (19, 'TK', 'Transitional Kindergarten'),
  (0,  'KG', 'Kindergarten'),
  (1,  '01', 'First grade'),
  (2,  '02', 'Second grade'),
  (3,  '03', 'Third grade'),
  (4,  '04', 'Fourth grade'),
  (5,  '05', 'Fifth grade'),
  (6,  '06', 'Sixth grade'),
  (7,  '07', 'Seventh grade'),
  (8,  '08', 'Eighth grade'),
  (9,  '09', 'Ninth grade'),
  (10, '10', 'Tenth grade'),
  (11, '11', 'Eleventh grade'), 
  (12, '12', 'Twelfth grade'), 
  (13, '13', 'Grade 13'),
  (14, 'PS', 'Postsecondary'), 
  (15, 'UG', 'Ungraded');

INSERT INTO asmt_type (id, code, name) VALUES
  (1, 'ica', 'Interim Comrehensive'),
  (2, 'iab', 'Interim Assessment Block'),
  (3, 'summative', 'Summative');

INSERT INTO subject_claim_score (subject_id, asmt_type_id, code) VALUES
  (1, 1, '1'),
  (1, 1, 'SOCK_2'),
  (1, 1, '3'),
  (2, 1, 'SOCK_R'),
  (2, 1, 'SOCK_LS'),
  (2, 1, '2-W'),
  (2, 1, '4-CR'),
  (1, 3, '1'),
  (1, 3, 'SOCK_2'),
  (1, 3, '3'),
  (2, 3, 'SOCK_R'),
  (2, 3, 'SOCK_LS'),
  (2, 3, '2-W'),
  (2, 3, '4-CR');

INSERT INTO completeness (id, name) VALUES
  (0, 'undefined'),
  (1, 'partial'),
  (2, 'complete');

INSERT INTO administration_condition (id, name) VALUES
  (0, 'undefined'),
  (1, 'valid'),
  (2, 'standardized'),
  (3, 'nonstandardized'),
  (4, 'invalid');

INSERT INTO ethnicity (id, name) VALUES
  (0, 'undefined'),
  (1, 'HispanicOrLatino'),
  (2, 'AmericanIndianOrAlaskaNative'),
  (3, 'Asian'),
  (4, 'BlackOrAfricanAmerican'),
  (5, 'NativeHawaiianOrOtherPacificIslander'),
  (6, 'DemographicRaceTwoOrMoreRaces');

INSERT INTO gender (id, name) VALUES
  (0, 'undefined'),
  (1, 'male'),
  (2, 'female');

INSERT INTO accommodation (code) VALUES
  ('TDS_ASL0'),
  ('TDS_ASL1'), 
  ('TDS_BT0'), 
  ('TDS_BT_EXN1'), 
  ('TDS_BT_ECN'), 
  ('TDS_BT_UXN'), 
  ('TDS_BT_UCN'), 
  ('TDS_BT_UXT'), 
  ('TDS_BT_UCT'), 
  ('TDS_TS_Modern'),
  ('TDS_SLMO'),
  ('TDS_TS_Accessibility'), 
  ('TDS_SLM1'),
  ('TDS_ST1'), 
  ('TDS_ST0'), 
  ('TDS_SVC1'), 
  ('TDS_TTS0'), 
  ('TDS_TTS_Item'), 
  ('TDS_TTS_Stim'), 
  ('TDS_WL0'), 
  ('TDS_WL_Glossary'), 
  ('TDS_WL_ArabicGloss'), 
  ('TDS_WL_CantoneseGloss'), 
  ('TDS_WL_ESNGloss'), 
  ('TDS_WL_KoreanGloss'), 
  ('TDS_WL_MandarinGloss'), 
  ('TDS_WL_PunjabiGloss'), 
  ('TDS_WL_RussianGloss'), 
  ('TDS_WL_TagalGloss'), 
  ('TDS_WL_UkrainianGloss'), 
  ('TDS_WL_VietnameseGloss'), 
  ('Multiple'), 
  ('NEDS0'), 
  ('NEDS_BD'), 
  ('NEDS_CC'), 
  ('NEDS_CO'), 
  ('NEDS_Mag'), 
  ('NEDS_RA_Items'), 
  ('NEDS_RA_Stimuli'), 
  ('NEDS_RA_ESN'), 
  ('NEDS_RA_Stimuli_ESN'), 
  ('NEDS_SC_Items'), 
  ('NEDS_SS'), 
  ('NEDS_TArabic'), 
  ('NEDS_TCantonese'), 
  ('NEDS_TFilipino'), 
  ('NEDS_TKorean'), 
  ('NEDS_TMandarin'), 
  ('NEDS_TPunjabi'), 
  ('NEDS_TRussianGta'), 
  ('NEDS_TSpanish'), 
  ('NEDS_TUkrainian'), 
  ('NEDS_TVietnamese'), 
  ('NEDS_TransDirs'), 
  ('NEDS_SimpDirs'), 
  ('NEDS_NoiseBuf'), 
  ('NEDS_Other'),
  ('NEA0'), 
  ('NEA_AR'), 
  ('NEA_RA_Stimuli'), 
  ('NEA_SC_WritItems'), 
  ('NEA_STT'), 
  ('NEA_Abacus'), 
  ('NEA_Calc'), 
  ('NEA_MT'), 
  ('NEA_NumTbl'), 
  ('NEA_NoiseBuf');

INSERT INTO item_trait_score (id, dimension) VALUES
  (1, 'Evidence/Elaboration'),
  (2, 'Organization/Purpose'),
  (3, 'Conventions');

INSERT INTO import_content (id, name) VALUES
  (1, 'EXAM');

INSERT INTO import_status (id, name) VALUES
  (-5, 'UNKNOWN_ASMT'),
  (-4, 'UNAUTHORIZED'),
  (-3, 'BAD_DATA'),
  (-2, 'BAD_FORMAT'),
  (-1, 'INVALID'),
  (0, 'ACCEPTED'),
  (1, 'PROCESSED'),
  (2, 'PUBLISHED');