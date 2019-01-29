-- Fix the claim data order for ELA
--
-- The data order for ELA scorable claims has been Reading, Listening, Writing, Research.
-- The middle two need to be flipped so it is Reading, Writing, Listening, Research.
-- Because claims are denormalized in the reporting database we have to update asmt and exam.

use ${schemaName};

UPDATE subject_claim_score SET data_order = 2 WHERE subject_id = 2 AND code = '2-W';
UPDATE subject_claim_score SET data_order = 3 WHERE subject_id = 2 AND code = 'SOCK_LS';

UPDATE asmt SET claim2_score_code = '2-W', claim3_score_code = 'SOCK_LS'
WHERE subject_id = 2 AND type_id IN (1,3) AND claim2_score_code = 'SOCK_LS' AND claim3_score_coode = '2-W';

-- MySQL doesn't do swaps like other databases, so some trickery.
-- This effectively swaps the three claim2/claim3 column values.
UPDATE exam e JOIN asmt a on e.asmt_id = a.id SET
  claim2_scale_score = @tmp_score := claim2_scale_score, claim2_scale_score = claim3_scale_score, claim3_scale_score = @tmp_score,
  claim2_scale_score_std_err = @tmp_stderr := claim2_scale_score_std_err, claim2_scale_score_std_err = claim3_scale_score_std_err, claim3_scale_score_std_err = @tmp_stderr,
  claim2_category = @tmp_cat := claim2_category, claim2_category = claim3_category, claim3_category = @tmp_cat
WHERE a.subject_id = 2 AND a.type_id IN (1,3);
