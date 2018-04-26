-- Prepare for configurable subjects by creating the tables required to ingest and store
-- subject xml payloads.
-- Question: auditing?  What's required?

USE ${schemaName};

-- Warehouse translation table for holding English message translations provided
-- with the subject XML
CREATE TABLE translation (
  namespace VARCHAR(10) NOT NULL,
  label_code VARCHAR(128) NOT NULL,
  language_code VARCHAR(3) NOT NULL,  -- Should this be assumed as "eng" ?
  label TEXT,
  PRIMARY KEY(namespace, label_code, language_code)
);

-- Table for holding subject configurations in the context of an assessment type
CREATE TABLE subject_asmt_type (
  asmt_type_id TINYINT NOT NULL,
  subject_id TINYINT NOT NULL,
  performance_level_count TINYINT NOT NULL,
  performance_level_standard_cutoff TINYINT,
  sub_score_performance_level_count TINYINT,
  sub_score_performance_level_standard_cutoff TINYINT,
  created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY(asmt_type_id, subject_id),
  CONSTRAINT fk__subject_asmt_type__asmt_type FOREIGN KEY (asmt_type_id) REFERENCES asmt_type(id),
  CONSTRAINT fk__subject_asmt_type__subject FOREIGN KEY (subject_id) REFERENCES subject(id)
);

-- Table for holding hierarchical item categories (replaces claim and target tables)
CREATE TABLE item_category (
  id SMALLINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  subject_id TINYINT NOT NULL,
  parent_id SMALLINT,
  code VARCHAR(10) NOT NULL,
  code_hierarchy VARCHAR(100) NOT NULL, -- Looks like "1-1|1-LT|SOCK_R" for an ELA target, should we also store the reverse for easy hierarchy loading?
  created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk__item_category__parent FOREIGN KEY (parent_id) REFERENCES item_category(id) ON DELETE CASCADE,
  CONSTRAINT fk__item_category__subject FOREIGN KEY (subject_id) REFERENCES subject(id),
  UNIQUE INDEX idx__item_category__code_hierarchy(code_hierarchy)
);

-- Create sub-score table for holding category (claim and target) scores.
CREATE TABLE exam_sub_scores (
  exam_id BIGINT NOT NULL,
  category_id SMALLINT NOT NULL,
  scale_score FLOAT,
  scale_score_std_err FLOAT,
  performance_level TINYINT,
  theta_score FLOAT,
  theta_score_std_err FLOAT,
  residual_overall_score FLOAT,
  residual_overall_score_std_err FLOAT,
  residual_standard_met_score FLOAT,
  residual_standard_met_score_std_err FLOAT,
  created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(exam_id, category_id),
  CONSTRAINT fk__exam_sub_scores__exam FOREIGN KEY (exam_id) REFERENCES exam(id),
  CONSTRAINT fk__exam_sub_scores__item_category FOREIGN KEY (category_id) REFERENCES item_category(id)
);

-- Add category references to assessment items
ALTER TABLE item
  ADD COLUMN category_id SMALLINT, -- This should reference the target (leaf) category
  ADD CONSTRAINT fk__item__item_category FOREIGN KEY (category_id) REFERENCES item_category(id);

ALTER TABLE item_other_target
  ADD COLUMN category_id SMALLINT,
  ADD CONSTRAINT fk__item_other_target__item_category FOREIGN KEY (category_id) REFERENCES item_category(id);

-- TODO after Ingest completion:
-- migrate existing item claim/target references to category references
-- migrate existing exam_claim_score rows to exam_sub_scores

-- TODO after Feature completion:
-- drop item.claim_id, item.target_id columns
-- drop exam_claim_score table
-- drop descriptions from tables, display text should come from translation table
-- drop claim, target tables