## Overview

### Warehouse
The warehouse DB contains data from different data sources. Every data element loaded into the warehouse is associated with an **import content type** and has an **import id**.
The import content types are define in the ```warehouse``` schema, ```import_content``` table.

#### Supported import content to table mapping
Content Type   | Table       |  Comment  | 
-------------- | ----------- |---------- |
N/A | asmt_type, subject, subject_claim_score import_content, import_status, import, language | Considered critical data. Must be pre-loaded as part of the initial schema set. Cannot be modified later.
CODES | administration_condition, common_core_standard, grade, completeness, ethnicity, gender, claim, depth_of_knowledge, math_practice, item_trait_score, target | Pre-loaded from SBAC blueprints and specifications. Allows for manual updates.
CODES | accommodation, accommodation_translation | Ingested using the [Import Service API](https://github.com/SmarterApp/RDW_Ingest/blob/develop/import-service/API.md) and [SBAC Accessbility Accomodataion Configuration](https://github.com/SmarterApp/AccessibilityAccommodationConfigurations/tree/RDW_DataWarehouse).
PACKAGES | **asmt**, asmt_score, item, item_common_core_standard, item_other_target | Ingested using the Import Service API and the output from the tabulator.
ORGANIZATION | **school**, district | Ingested using the ART Organizations extract.
GROUPS | **student_group**, student, student_group_membership, user_student_group | Uploaded via Group Management API. For ```student``` only student SSID is available from this source.
EXAM | **exam**, student, exam_student, exam_item, exam_available_accommodation, exam_claim_score | Ingested from TRTs.

#### Import table and Import ID

```import``` table is the main control table for importing the data. In order for the system to function properly any data modifications **must** be logged into the ```import``` table.
Each content type has a main table associated with it. It is listed as the first table on the table list above. These main tables have 3 common columns: 
- **import_id**: an id of the import record that created this entity and all its ‘children’.
- **update_import_id**: a last import id that modified this entity or any of its ‘children’. For the newly created entity ```update_import_id``` and ```import_id``` are the same.
Removing a child entry is considered an update to the main entity.
- **deleted**: a ‘soft’ delete flag.

All the data modifications to the children tables are tracked by import id via a corresponding main table. 

Tables of the content type CODES are different in a sense that there is no ‘main’ table. Changes to any of these tables are tracked via the same import content type.

### Reporting DB and migrate process
Reporting DB is the data source for the customer facing Reporting Data Warehouse web site. The data must never be manually loaded or modified in this DB. 
Instead they must be migrate from the warehouse. 

There is a minimum set of the ‘core’ tables that are created as part of the initial schema and are not supported for modifications:
- asmt_type
- subject
- subject_claim_score
- exam_claim_score_mapping
- migrate

The ```migrate``` table is the main control table for the migrate. It has the last successfully imported import id from the warehouse. 

The migrate process is managed by the “migrate-reporting” service.  

### Maintenance Guidelines
**Note 1:** 
>Only data updates are supported, not structural table changes.

**Note 2:**  
>The best practice is to use the Import API to ingest the data. In a rare case you need to update the data manually, follow the instructions below.

**Note 3:** 
>Changes to the tables of the PACKAGE content type is not supported at this time. Making the change may cause the system to fail or malfunction. 

#### Modify any code tables
-	Update data in the tables of entity type CODES.
-	Insert an entry into import table with the ‘CODES’ content type:
```sql
mysql>USE warehouse;
mysql>INSERT INTO import(status, content, contentType, digest) VALUES (1, 3, 'initial load', 'initial load');
```
- The migrate will pick this up. It will migrate all tables from this category.

#### Modify one main table and any of its children
- Create an import id to associate with your changes. Use an appropriate content type:
```sql
mysql> USE warehouse;
mysql> INSERT INTO import (status, content, contentType, digest, creator) VALUES (0, 5, 'text/plain', left(uuid(), 8), 'dwtest@example.com');
mysql> SELECT LAST_INSERT_ID() into @IMPORT_ID;
```
- Make data modifications.
- When you are done, update the main table with the import id value: 
    - If you are creating a new main entity, set both ```import_id``` and ```update_import_id``` to the same value, @IMPORT_ID.
    - If you are modifying an existing main entity or making any changes to the child tables, set the main table ```update_import_id``` to the @IMPORT_ID.
    - If you are deleting a main entity, set its ```deleted ``` flag to 1 and ```update_import_id``` to @IMPORT_ID.
- To complete the process, change the status of the import to 1:
```sql
# trigger migration
mysql> UDATE import SET status = 1 WHERE id = @IMPORT_ID;
```

#### Modify more than one main table and its children
While the process is the same as modifying one main table, there are a few things to note:
- The import ids should be created in the order of the main tables dependencies. Here is the hierarchy starting for the least dependent:
    - CODES
    - ORGANIZATION,PACKAGES
    - GROUPS, EXAMS
- The same import id could be reused for multiple main entities of the same content type. Keep in mind that this drives the number of records being migrated at once. 
It is recommended to keep this number relatively low.
			 