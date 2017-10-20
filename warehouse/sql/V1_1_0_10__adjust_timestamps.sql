-- change timestamp to be more precise

USE ${schemaName};

ALTER TABLE exam
    MODIFY COLUMN started_at timestamp(6),
    MODIFY COLUMN force_submitted_at timestamp(6),
    MODIFY COLUMN status_date timestamp(6);

ALTER TABLE audit_exam
    MODIFY COLUMN started_at timestamp(6),
    MODIFY COLUMN force_submitted_at timestamp(6),
    MODIFY COLUMN status_date timestamp(6);

ALTER TABLE exam_item
    MODIFY COLUMN administered_at timestamp(6),
    MODIFY COLUMN submitted_at timestamp(6);

ALTER TABLE audit_exam_item
    MODIFY COLUMN administered_at timestamp(6),
    MODIFY COLUMN submitted_at timestamp(6);