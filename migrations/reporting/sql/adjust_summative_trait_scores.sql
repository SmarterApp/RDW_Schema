-- Before 2.4, writing trait scores were associated with items. For the generated data this worked
-- for both summative and interim tests. However, in the wild, summative tests don't have any item
-- data at all. To display writing trait scores, the UI would (?verify?) iterate through the items
-- and aggregate the scores, presenting them in a table. For the ISR's, the item level data was
-- rolled up and stored at the exam level. The trait category was hard-coded and denormalized: each
-- item has three columns, one for each category. The trait purpose was stored with the assessment
-- item definition.
--
-- In 2.4, exam-level trait scores were introduced. For summative tests, the writing trait scores
-- are reported and stored at the exam level. The system still supports the legacy writing trait
-- scores associated with items.
--
-- This script does two things for summative assessments (it doesn't touch interims). First, it
-- copies the item-level writing trait scores to the exam level: each of the three columns
-- results in a row in the table (the purpose is extracted by joining the assessment item table).
-- After doing that, ALL the item level data for summative assessments is deleted; this better
-- emulates data in the wild.

-- NOTE: this script may be run on both reporting and warehouse databases without modification.
-- It should be run after the migration scripts (V2_4_0_3__wer_purpose.sql).
-- NOTE: it is not appropriate to run this on production databases.

-- For the local developer data dump, there are 592 exam items for summative exams;
-- x3 should produce 1776 exam-level records

-- i'm sure there is a more elegant way to to do this but ...
-- The innermost subselect gets the item-level scores for summative exams, looks like:
--  exam_id,     wt,      con, evi, org
--      956, Explanatory,   0,   1,   3
-- The next level out (repeated three times) extracts the category and maps the purpose, looks like:
--  exam_id, purpose, category, score
--      956,    EXPL,      ORG,     3
-- The outer level joins with subject_trait to get the trait id.
INSERT INTO exam_trait_score (exam_id, trait_id, score)
select exam_id, st.id as trait_id, score
from (select exam_id,
             performance_task_writing_type,
             'ORG' as category,
             org as score
      from (select e.id as exam_id,
                   i.performance_task_writing_type,
                   ei.trait_conventions_score as con,
                   ei.trait_evidence_elaboration_score as evi,
                   ei.trait_organization_purpose_score as org
            from exam e
                     join exam_item ei on e.id = ei.exam_id
                     join item i on ei.item_id = i.id
            where e.type_id = 3
              and i.performance_task_writing_type is not null
              and ei.trait_organization_purpose_score is not null) i1
      UNION
      select exam_id,
             performance_task_writing_type,
             'EVI' as category,
             evi as score
      from (select e.id as exam_id,
                   i.performance_task_writing_type,
                   ei.trait_conventions_score as con,
                   ei.trait_evidence_elaboration_score as evi,
                   ei.trait_organization_purpose_score as org
            from exam e
                     join exam_item ei on e.id = ei.exam_id
                     join item i on ei.item_id = i.id
            where e.type_id = 3
              and i.performance_task_writing_type is not null
              and ei.trait_evidence_elaboration_score is not null) i2
      UNION
      select exam_id,
             performance_task_writing_type,
             'CON' as category,
             con as score
      from (select e.id as exam_id,
                   i.performance_task_writing_type,
                   ei.trait_conventions_score as con,
                   ei.trait_evidence_elaboration_score as evi,
                   ei.trait_organization_purpose_score as org
            from exam e
                     join exam_item ei on e.id = ei.exam_id
                     join item i on ei.item_id = i.id
            where e.type_id = 3
              and i.performance_task_writing_type is not null
              and ei.trait_conventions_score is not null) i3
    ) s1
join wer_purpose wp on wp.wer_type = performance_task_writing_type
join subject_trait st on st.purpose = wp.purpose and st.category = s1.category;


-- fyi, 52796 rows being deleted in local database
delete exam_item
    from exam_item join exam on exam_item.exam_id = exam.id
where exam.type_id = 3;
