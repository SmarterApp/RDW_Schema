-- remove exam item client id
USE ${schemaName};

ALTER TABLE exam_item DROP COLUMN client_id;
ALTER TABLE audit_exam_item DROP COLUMN client_id;

-- ------------------------------------------------------------------------------------------------------------------------------------
--  exam_item audit triggers
-- ------------------------------------------------------------------------------------------------------------------------------------

-- UPDATE
DROP TRIGGER trg__exam_item__update;

CREATE TRIGGER trg__exam_item__update
BEFORE UPDATE ON exam_item
FOR EACH ROW
  INSERT INTO audit_exam_item (
    action, database_user, exam_item_id, exam_id, item_id, score,
    score_status, position, response, trait_evidence_elaboration_score,
    trait_evidence_elaboration_score_status, trait_organization_purpose_score,
    trait_organization_purpose_score_status, trait_conventions_score, trait_conventions_score_status,
    administered_at,
    submitted,
    submitted_at,
    number_of_visits,
    response_duration,
    response_content_type,
    page_number,
    page_visits,
    page_time,
    response_type_id
  )
    SELECT
      'update',
      USER(),
      OLD.id,
      OLD.exam_id,
      OLD.item_id,
      OLD.score,
      OLD.score_status,
      OLD.position,
      OLD.response,
      OLD.trait_evidence_elaboration_score,
      OLD.trait_evidence_elaboration_score_status,
      OLD.trait_organization_purpose_score,
      OLD.trait_organization_purpose_score_status,
      OLD.trait_conventions_score,
      OLD.trait_conventions_score_status,
      OLD.administered_at,
      OLD.submitted,
      OLD.submitted_at,
      OLD.number_of_visits,
      OLD.response_duration,
      OLD.response_content_type,
      OLD.page_number,
      OLD.page_visits,
      OLD.page_time,
      OLD.response_type_id
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';

-- DELETE
DROP TRIGGER trg__exam_item__delete;

CREATE TRIGGER trg__exam_item__delete
BEFORE DELETE ON exam_item
FOR EACH ROW
  INSERT INTO audit_exam_item (
    action, database_user, exam_item_id, exam_id, item_id, score,
    score_status, position, response, trait_evidence_elaboration_score,
    trait_evidence_elaboration_score_status, trait_organization_purpose_score,
    trait_organization_purpose_score_status, trait_conventions_score, trait_conventions_score_status,
    administered_at,
    submitted,
    submitted_at,
    number_of_visits,
    response_duration,
    response_content_type,
    page_number,
    page_visits,
    page_time,
    response_type_id
  )
    SELECT
      'delete',
      USER(),
      OLD.id,
      OLD.exam_id,
      OLD.item_id,
      OLD.score,
      OLD.score_status,
      OLD.position,
      OLD.response,
      OLD.trait_evidence_elaboration_score,
      OLD.trait_evidence_elaboration_score_status,
      OLD.trait_organization_purpose_score,
      OLD.trait_organization_purpose_score_status,
      OLD.trait_conventions_score,
      OLD.trait_conventions_score_status,
      OLD.administered_at,
      OLD.submitted,
      OLD.submitted_at,
      OLD.number_of_visits,
      OLD.response_duration,
      OLD.response_content_type,
      OLD.page_number,
      OLD.page_visits,
      OLD.page_time,
      OLD.response_type_id
    FROM setting s
    WHERE s.name = 'AUDIT_TRIGGER_ENABLE' AND s.value = 'TRUE';