-- Fix the claim data order for ELA
--
-- The data order for ELA scorable claims has been Reading, Listening, Writing, Research.
-- The middle two need to be flipped so it is Reading, Writing, Listening, Research.
-- In the warehouse, the only change is to set the data order values properly.

use ${schemaName};

UPDATE subject_claim_score SET data_order = 2 WHERE subject_id = 2 AND code = '2-W';
UPDATE subject_claim_score SET data_order = 3 WHERE subject_id = 2 AND code = 'SOCK_LS';



