## RDW_Schema 
The goal of this project is to create db schema for Smarter Balanced Reporting Data Warehouse and load the core data.

This project uses [flyway](https://flywaydb.org/getstarted). Gradle will take care of getting flyway making sure things work. 

### MySql
MySQL scripts are compatible with MySQL 5.6 and as well as AWS Aurora.

#### To create the schema 
There are multiple schemas in this project: a data warehouse ("warehouse"), a data mart ("reporting") and an OLAP
store ("reporting_olap"). For warehouse and reporting there are two schemas: one for running the apps, the other 
for running integration tests (with suffix _test). Gradle is configured to proxy all the flyway tasks defined 
[here](https://flywaydb.org/documentation/gradle/).

To install or migrate, run:
```bash
RDW_Schema$ ./gradlew migrateWarehouse (or migratewarehouse_test)
OR
RDW_Schema$ ./gradlew migrateReporting (or migratereporting_test)
OR
RDW_Schema$ ./gradlew migrateAll (migrates the dev instances for the schemas)
```

#### To wipe out the schema
```bash
RDW_Schema$ ./gradlew cleanWarehouse (or cleanwarehouse_test)
OR
RDW_Schema$ ./gradlew cleanReporting (or cleanreporting_test)
OR
RDW_Schema$ ./gradlew cleanAll 
```

#### Other Commands
To see a listing of all of the tasks available, run (output will depend on properties):
```bash
RDW_Schema$ ./gradlew tasks

------------------------------------------------------------
All tasks runnable from root project
------------------------------------------------------------

... 

Schema tasks
------------
cleanReporting - Drops all objects in the configured schemas.
cleanReporting_test - Drops all objects in the configured schemas.
cleanWarehouse - Drops all objects in the configured schemas.
cleanWarehouse_test - Drops all objects in the configured schemas.
...
migrateReporting - Migrates the schema to the latest version.
migrateReporting_test - Migrates the schema to the latest version.
migrateWarehouse - Migrates the schema to the latest version.
migrateWarehouse_test - Migrates the schema to the latest version.

Schema (disabled) tasks
-----------------------
cleanMigrate_olap - Disabled cleanMigrate_olap schema task, set properties [database_url, database_user, migrate_olap_schema] to enable
cleanReporting_olap - Disabled cleanReporting_olap schema task, set properties [redshift_url, redshift_schema, redshift_user] to enable
...
migrateMigrate_olap - Disabled migrateMigrate_olap schema task, set properties [database_url, database_user, migrate_olap_schema] to enable
migrateReporting_olap - Disabled migrateReporting_olap schema task, set properties [redshift_url, redshift_schema, redshift_user] to enable

SchemaGroup tasks
-----------------
cleanAll - Custom group task for: cleanReporting, cleanWarehouse, cleanMigrate_olap, cleanReporting_olap
cleanAll_test - Custom group task for: cleanReporting_test, cleanWarehouse_test, cleanMigrate_olap, cleanReporting_olap
migrateAll - Custom group task for: migrateReporting, migrateWarehouse, migrateMigrate_olap, migrateReporting_olap
migrateAll_test - Custom group task for: migrateReporting_test, migrateWarehouse_test, migrateMigrate_olap, migrateReporting_olap
```

Other task examples:
```bash
RDW_Schema$ ./gradlew validateWarehouse
or
RDW_Schema$ ./gradlew infoWarehouse
or
RDW_Schema$ ./gradlew repairWarehouse
```

#### Alternate Properties
The flyway tasks use gradle properties to set the database url, schema, user, password, etc. These can be set in the
`gradle.properties` file or overridden on the command line, e.g.
```bash
RDW_Schema$ ./gradlew -Pdatabase_url="jdbc:mysql://rdw-aurora-dev.cugsexobhx8t.us-west-2.rds.amazonaws.com:3306/" -Pdatabase_user=sbac -Pdatabase_password=mypassword infoReporting
```

### Redshift
After configuring Redshift, connect to the instance and create a user/schema, for example for developer Bob to
do some testing, using the CI instance and ci database:
```sql
create schema bob_reporting_test;
create user bob with password 'bob_redshift_password';
grant all privileges on schema bob_reporting_test to bob;
alter user bob set search_path to bob_reporting_test;
```

IntelliJ developers: https://stackoverflow.com/questions/32319052/connect-intellij-to-amazon-redshift

#### To wipe out and re-create tables for redshift
To deal with just the redshift tables, use the `reporting_olap` tasks. Using the same example developer Bob:
```bash
RDW_Schema$ gradle -Pschema_prefix=bob_ \ 
    -Predshift_url=jdbc:redshift://rdw-qa.cibkulpjrgtr.us-west-2.redshift.amazonaws.com:5439/ci \
    -Predshift_user=bob -Predshift_password=bob_redshift_password \
    cleanReporting_olap_test migrateReporting_olap_test
```

When testing the OLAP migration process, there is also the MySQL migrate_olap schema to worry about. The additional
tasks can be specified but it requires a lot of settings dealing with two separate AWS databases. Continuing with
Bob, assume they have created `bob_migrate_olap_test` schema in the dev instance of Aurora:
```bash
RDW_Schema$ gradle -Pschema_prefix=bob_ \
    -Predshift_url=jdbc:redshift://rdw-qa.cibkulpjrgtr.us-west-2.redshift.amazonaws.com:5439/ci -Predshift_user=bob -Predshift_password=bob_redshift_password \
    -Pdatabase_url=jdbc:mysql://rdw-aurora-ci.cugsexobhx8t.us-west-2.rds.amazonaws.com:3306 -Pdatabase_user=bob -Pdatabase_password=bob_aurora_password \
    cleanReporting_olap_test cleanMigrate_olap_test migrateReporting_olap_test migrateMigrate_olap_test    
```

#### CI and QA
For CI, only the test schemas exist (with no schema prefix):
```bash
gradle \
-Predshift_url=jdbc:redshift://rdw-qa.cibkulpjrgtr.us-west-2.redshift.amazonaws.com:5439/ci -Predshift_user=ci -Predshift_password= \
-Pdatabase_url=jdbc:mysql://rdw-aurora-ci.cugsexobhx8t.us-west-2.rds.amazonaws.com:3306 -Pdatabase_user=sbac -Pdatabase_password= \
cleanAll_test migrateAll_test
```

For the `awsqa` instance there is one Aurora database and we should never be cleaning the data:
```bash
gradle \
-Pdatabase_url=jdbc:mysql://rdw-aurora-qa.cugsexobhx8t.us-west-2.rds.amazonaws.com:3306/ -Pdatabase_user=sbac -Pdatabase_password= \
-Predshift_url=jdbc:redshift://rdw-qa.cibkulpjrgtr.us-west-2.redshift.amazonaws.com:5439/qa -Predshift_user=awsqa -Predshift_password= \
migrateWarehouse migrateMigrate_olap migrateReporting_olap migrateReporting
```

### Developing
Flyway requires prefixing each script with the version. To avoid a prefix collision with version specificity, use a 
prefix that has the version followed by an incrementing number, e.g. `V1_0_1_23__add_stuff.sql` would be the 23rd
script for the 1.0.1 release. 

### Release Scripts

#### v1.0

The V1_0_0 release scripts are condensed from the initial and incremental scripts created during
development. To reset a db instance that had the incremental scripts applied so that the flyway
table represents as if this script had been used instead:
```sql
USE warehouse;
-- query schema_version and make sure the applied scripts match the list of pre-condensed scripts
SELECT * FROM schema_version;
-- if things look good, reset entries to match condensed scripts:
TRUNCATE TABLE schema_version;
INSERT INTO schema_version VALUES
  (1, null, '<< Flyway Schema Creation >>', 'SCHEMA', '`warehouse`', null, 'root', '2017-09-02 18:26:14', 0, 1),
  (2, '1.0.0.0', 'ddl', 'SQL', 'V1_0_0_0__ddl.sql', 751759817, 'root', '2017-09-02 18:26:15', 655, 1),
  (3, '1.0.0.1', 'dml', 'SQL', 'V1_0_0_1__dml.sql', 1955603172, 'root', '2017-09-02 18:26:15', 116, 1);  
  
USE reporting;
-- query schema_version and make sure the applied scripts match the list of pre-condensed scripts
SELECT * FROM schema_version;
-- if things look good, reset entries to match condensed scripts:
TRUNCATE TABLE schema_version;
INSERT INTO schema_version VALUES
  (1, null, '<< Flyway Schema Creation >>', 'SCHEMA', '`reporting`', null, 'root', '2017-09-02 18:26:13', 0, 1),
  (2, '1.0.0.0', 'ddl', 'SQL', 'V1_0_0_0__ddl.sql', 986463590, 'root', '2017-09-02 18:26:14', 1209, 1),
  (3, '1.0.0.1', 'dml', 'SQL', 'V1_0_0_1__dml.sql', -1123132459, 'root', '2017-09-02 18:26:14', 6, 1);
```
Since v1.0.0 has been released **DO NOT MODIFY OR CONDENSE THE RELEASE (V1_0_0_0/1) SCRIPTS EVER.** From this point, 
condensing should happen for the next revision, perhaps V1_1_0_*.

#### v1.1

The V1_1_0 release scripts are condensed from the incremental scripts created during the development
of release v1.1. As noted above, a db instance may be reset so the flyway table represents as if
this script had been used instead of incremental updates.
```sql
USE warehouse;
-- query schema_version and make sure the applied scripts match the list of pre-condensed scripts
-- as noted in the condensed script, the last entry should be for V1_1_0_26__embargo_cleanup.sql:
SELECT * FROM schema_version;
-- if things look good, reset entries to match condensed scripts:
DELETE FROM schema_version WHERE installed_rank > 3;
INSERT INTO schema_version VALUES
  (4, '1.1.0.0', 'update', 'SQL', 'V1_1_0_0__update.sql', 518740504, 'root', '2018-02-28 12:00:00', 340542, 1),
  (5, '1.1.0.1', 'audit', 'SQL', 'V1_1_0_1__audit.sql', -1236730527, 'root', '2018-02-28 12:00:00', 621, 1);

USE reporting;
-- query schema_version and make sure the applied scripts match the list of pre-condensed scripts
-- as noted in the condensed script, the last entry should be for V1_1_0_16__migrate_embargo.sql
SELECT * FROM schema_version;
-- if things look good, reset entries to match condensed scripts:
DELETE FROM schema_version WHERE installed_rank > 3;
INSERT INTO schema_version VALUES
  (4, '1.1.0.0', 'update', 'SQL', 'V1_1_0_0__update.sql', -1706757701, 'root', '2018-02-28 12:00:00', 9533, 1);
```

#### v1.1.1

The V1_1_1 script(s) are patches to v1.1. They have been applied to production so should not be 
condensed. If you do insist on condensing them, please modify the update instructions to deal with 
tweaking the flyway table. They add the following row(s) to the flyway table:
```sql
INSERT INTO schema_version VALUES
  (6,'1.1.1.0','student upsert','SQL','V1_1_1_0__student_upsert.sql',-223870699,'root','2018-03-11 15:58:28',1,1);
```

#### v1.2

The V1_2_0 release scripts are condensed from the incremental scripts created during the development
of release v1.2. As noted above, a db instance may be reset so the flyway table represents as if
this script had been used instead of incremental updates.
```sql
USE warehouse;
-- query schema_version and make sure the applied scripts match the list of pre-condensed scripts
-- as noted in the condensed script, the sixth entry should be V1_1_1_0__student_upsert.sql and the
-- last entry should be for V1_2_0_18__student_group_index:
SELECT * FROM schema_version;
-- if things look good, reset entries to match condensed scripts:
DELETE FROM schema_version WHERE installed_rank > 6;
INSERT INTO schema_version VALUES
  (7, '1.2.0.0', 'update', 'SQL', 'V1_2_0_0__update.sql', -680448587, 'root', '2018-06-18 12:00:00', 10000, 1);

USE reporting;
-- query schema_version and make sure the applied scripts match the list of pre-condensed scripts
-- as noted in the condensed script, the fourth entry should be V1_1_0_0__update.sql and the last
-- entry should be for V1_2_0_13__optional_data.sql
SELECT * FROM schema_version;
-- if things look good, reset entries to match condensed scripts:
DELETE FROM schema_version WHERE installed_rank > 4;
INSERT INTO schema_version VALUES
  (5, '1.2.0.0', 'update', 'SQL', 'V1_2_0_0__update.sql', 1999355730, 'root', '2018-06-18 12:00:00', 10000, 1);
```

#### v1.2.1

The V1_2_1 script(s) are patches to v1.2. They were condensed from the incremental scripts created during the
development of the release. As noted above, a db instance may be reset so the flyway table represents as if
this script had been used instead of incremental updates.
```sql
USE warehouse;
-- query schema_version and make sure the applied scripts match the list of pre-condensed scripts
-- as noted in the condensed script, the seventh entry should be V1_2_0_0__update.sql and the last
-- entry should be for V1_2_1_4__config_subject_cleanup.sql:
SELECT * FROM schema_version;
-- if things look good, reset entries to match condensed scripts:
DELETE FROM schema_version WHERE installed_rank > 7;
INSERT INTO schema_version VALUES
  (8, '1.2.1.0', 'update', 'SQL', 'V1_2_1_0__update.sql', 518721551, 'root', '2018-07-06 12:00:00', 10000, 1);

USE reporting;
-- query schema_version and make sure the applied scripts match the list of pre-condensed scripts
-- as noted in the condensed script, the fifth entry should be V1_2_0_0__update.sql and the last
-- entry should be for V1_2_1_5__config_subject_cleanup.sql
SELECT * FROM schema_version;
-- if things look good, reset entries to match condensed scripts:
DELETE FROM schema_version WHERE installed_rank > 5;
INSERT INTO schema_version VALUES
  (6, '1.2.1.0', 'update', 'SQL', 'V1_2_1_0__update.sql', 1586448759, 'root', '2018-07-06 12:00:00', 10000, 1);
```

#### v1.3.0

The v1_3_0 script is a patch to v1.2.1. They were condensed from the incremental scripts created during the
development of the release. As noted above, a db instance may be reset so the flyway table represents as if
this script had been used instead of incremental updates.
```sql
USE warehouse;
-- query schema_version and make sure the applied scripts match the list of pre-condensed scripts
-- as noted in the condensed script, the eighth entry should be V1_2_1_0__update.sql and the last
-- entry should be for V1_3_0_5__alias_name.sql
SELECT * FROM schema_version;
-- if things look good, reset entries to match condensed scripts:
DELETE FROM schema_version WHERE installed_rank > 8;
INSERT INTO schema_version (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) VALUES
  (9, '1.3.0.0', 'update', 'SQL', 'V1_3_0_0__update.sql', 1686260239, 'root', '2019-01-23 12:00:00', 10000, 1);

USE reporting;
-- query schema_version and make sure the applied scripts match the list of pre-condensed scripts
-- as noted in the condensed script, the sixth entry should be V1_2_1_0__update.sql and the last
-- entry should be for V1_3_0_5__alias_name.sql
SELECT * FROM schema_version;
-- if things look good, reset entries to match condensed scripts:
DELETE FROM schema_version WHERE installed_rank > 6;
INSERT INTO schema_version (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) VALUES
  (7, '1.3.0.0', 'update', 'SQL', 'V1_3_0_0__update.sql', -1130240588, 'root', '2019-01-23 12:00:00', 10000, 1);
```
