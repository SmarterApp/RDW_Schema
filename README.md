## RDW_Schema 
The goal of this project is to create db schema for Smarter Balanced Reporting Data Warehouse and load the core data.

This project uses [flyway](https://flywaydb.org/getstarted). Gradle will take care of getting flyway making sure things work. 

### MySql
MySQL scripts are compatible with MySQL 5.6 and as well as AWS Aurora.

#### To create the schema 
There are multiple schemas in this project: a data warehouse ("warehouse") and a data mart ("reporting"). Each has a dev and integration-test-only instance on the server. 
The Flyway configuration can be found in the main `build.gradle` file.
Gradle can perform all of the flyway tasks defined [here](https://flywaydb.org/documentation/gradle/).

To install or migrate, run:
```bash
RDW_Schema$ ./gradlew migrateWarehouse (or migratewarehouse_test)
OR
RDW_Schema$ ./gradlew migrateReporting (or migratereporting_test)
OR
RDW_Schema$ ./gradlew migrateAll (migrates the dev and test instances for the schemas)
```

#### To wipe out the schema
```bash
RDW_Schema$ ./gradlew cleanWarehouse (or cleanwarehouse_test)
OR
RDW_Schema$ ./gradlew cleanReporting (or cleanreporting_test)
OR
RDW_Schema$ ./gradlew cleanAll 
```

#### Alternate Properties
The data source, user, password, etc. can be overridden on the command line, e.g.
```bash
RDW_Schema$ ./gradlew -Pflyway.url="jdbc:mysql://rdw-aurora-dev.cugsexobhx8t.us-west-2.rds.amazonaws.com:3306/" -Pflyway.user=sbac -Pflyway.password=mypassword cleanAll
or
RDW_Schema$ ./gradlew -Pflyway.url="jdbc:mysql://rdw-aurora-dev.cugsexobhx8t.us-west-2.rds.amazonaws.com:3306/" -Pflyway.user=sbac -Pflyway.password=mypassword -Pschemas=schema1 -Plocations=/migrateSql flywayMigrate

```

### Redshift
After configuring Redshift, connect to the instance and create a schema and a user (make sure to replace user and password with your values):

```sql
create schema reporting_olap;
create user your_user with password 'your_user_password';
grant all privileges on schema reporting_olap TO your_user;
alter user your_user set search_path = reporting_olap;
```
#### To wipe out and re-create tables in the schema
```bash
RDW_Schema$ ./gradlew -Pflyway.url=jdbc:redshift://rdw-dev.cibkulpjrgtr.us-west-2.redshift.amazonaws.com:5439/dev -Pflyway.user=your_user -Pflyway.password=your_user_password -Predshift_schema=reporting_olap cleanReporting_olap migrateReporting_olap
 ```
     
#### Other Commands
To see a listing of all of the tasks available, run
```bash
./gradlew tasks
```

Other task examples:
```bash
RDW_Schema$ ./gradlew validateWarehouse
or
RDW_Schema$ ./gradlew infoWarehouse
or
RDW_Schema$ ./gradlew repairWarehouse
```

### Developing
Flyway requires prefixing each script with the version. To avoid a prefix collision with version specificity, use a 
prefix that has the version followed by an incrementing number, e.g. `V1_0_1_23__add_stuff.sql` would be the 23rd
script for the 1.0.1 release. 

### Release Scripts

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
  (4, '1.1.0.0', 'update', 'SQL', 'V1_1_0_0__update.sql', -1057823690, 'root', '2017-12-22 17:04:22', 340542, 1),
  (5, '1.1.0.1', 'audit', 'SQL', 'V1_1_0_1__audit.sql', -1798766498, 'root', '2017-12-22 17:04:23', 621, 1);

USE reporting;
-- query schema_version and make sure the applied scripts match the list of pre-condensed scripts
-- as noted in the condensed script, the last entry should be for V1_1_0_16__migrate_embargo.sql
SELECT * FROM schema_version;
-- if things look good, reset entries to match condensed scripts:
DELETE FROM schema_version WHERE installed_rank > 3;
INSERT INTO schema_version VALUES
  (4, '1.1.0.0', 'update', 'SQL', 'V1_1_0_0__update.sql', -720126536, 'root', '2017-12-22 16:58:34', 9533, 1);
```
