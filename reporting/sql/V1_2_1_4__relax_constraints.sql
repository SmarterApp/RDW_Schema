-- Relax not null constraints on nullable columns.

use ${schemaName};

ALTER TABLE item
  MODIFY COLUMN target_code VARCHAR(10) DEFAULT NULL;