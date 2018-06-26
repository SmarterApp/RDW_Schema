use ${schemaName};

UPDATE subject_claim_score SET display_order = 2 WHERE code = '2-W' AND subject_id = 2;
UPDATE subject_claim_score SET display_order = 3 WHERE code = 'SOCK_LS' AND subject_id = 2;