-- Relax UNIQUE requirements to allow for re-ordering scorable claim data orders

use ${schemaName};

ALTER TABLE subject_claim_score
  DROP INDEX idx__subject_claim_score__subject_asmt_data_order;