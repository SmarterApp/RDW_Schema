-- Add target_report flag to subject assessment type

SET SEARCH_PATH to ${schemaName};
SET client_encoding = 'UTF8';


CREATE TEMPORARY TABLE subject_asmt_type_temp AS SELECT * FROM subject_asmt_type;

DROP TABLE subject_asmt_type;
CREATE TABLE subject_asmt_type (
  asmt_type_id smallint NOT NULL,
  subject_id smallint NOT NULL SORTKEY,
  performance_level_count smallint NOT NULL,
  performance_level_standard_cutoff smallint,
  claim_score_performance_level_count smallint,
  target_report boolean NOT NULL,
  UNIQUE (asmt_type_id, subject_id),
  CONSTRAINT fk__subject_asmt_type__type FOREIGN KEY(asmt_type_id) REFERENCES asmt_type(id),
  CONSTRAINT fk__subject_asmt_type__subject FOREIGN KEY(subject_id) REFERENCES subject(id)
) DISTSTYLE ALL;

INSERT INTO subject_asmt_type (asmt_type_id, subject_id, performance_level_count, performance_level_standard_cutoff, claim_score_performance_level_count, target_report)
  (SELECT asmt_type_id, subject_id, performance_level_count, performance_level_standard_cutoff, claim_score_performance_level_count,
          CASE asmt_type_id WHEN 3 THEN true ELSE false END
   FROM subject_asmt_type_temp);

DROP TABLE subject_asmt_type_temp;


DROP TABLE staging_subject_asmt_type;
CREATE TABLE staging_subject_asmt_type (
  asmt_type_id smallint NOT NULL,
  subject_id smallint NOT NULL,
  performance_level_count smallint NOT NULL,
  performance_level_standard_cutoff smallint,
  claim_score_performance_level_count smallint,
  target_report boolean NOT NULL,
  migrate_id bigint NOT NULL
);
