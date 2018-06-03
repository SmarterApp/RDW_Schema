USE ${schemaName};

-- NOTE: consider removing this file from the production release
-- trigger migration of summative assessments to load asmt_target table in reporting data-mart
 INSERT INTO import (status, content, contentType, digest)
    SELECT 0, ic.id, 'force summative asmt migrate', left(uuid(), 8) from import_content ic where name = 'PACKAGE';

 SELECT LAST_INSERT_ID() INTO @import_id;

 UPDATE asmt
    SET update_import_id = @import_id
    WHERE type_id = 3;

 UPDATE import
    SET status = 1
    WHERE id = @import_id;
