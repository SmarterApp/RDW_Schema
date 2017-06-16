## Tips and Tricks
This document has some SQL tips and tricks.

Just didn't know where else to put this.

#### Creating Fake Groups
Test results don't have group membership and there is no roster information available for legacy data. But the UI is 
oriented around groups. So these queries are a way to hack in some school-based groups.

```sql
use warehouse;

# create import record
insert into import (status, content, contentType, digest, creator) values (0, 5, 'text/plain', left(uuid(), 8), 'dwtest@example.com');
select max(id) from import into @IMPORT_ID;

# create groups, one per school
insert into student_group (name, school_id, school_year, active, creator, import_id, update_import_id)
select concat('S', es.school_id, '-G', es.grade_id) as name, es.school_id, 2017 as school_year, 1 as active,
  'dwtest@example.com' as creator, @IMPORT_ID as import_id, @IMPORT_ID as update_import_id
from exam_student es
  join exam e on e.exam_student_id = es.id
  join asmt a on a.id = e.asmt_id
  join school s on s.id = es.school_id
group by es.school_id;

# put students in groups
insert ignore into student_group_membership (student_group_id, student_id)
select sg.id, es.student_id
from exam_student es
  join student_group sg on sg.school_id = es.school_id;

# trigger migration
update import set status = 1 where id = @IMPORT_ID;
```

After this, there will be a bunch of groups (wait for migrate to move the group data to reporting). 
You'll still need to add your user to some of the groups. This adds the user to the five biggest groups:
```sql
use reporting;

insert into user_student_group (student_group_id, user_login)
select student_group_id, 'dwtest@example.com' from (
  select student_group_id, count(*) as cnt
    from student_group_membership
    group by (student_group_id)
    order by cnt desc limit 5) s;
```