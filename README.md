## RDW_Schema 
The goal of this project is to create MySQL 5.6 db schema for Smarter Balanced Reporting Data Warehouse and load the core data.

This project uses [flyway](https://flywaydb.org/getstarted). Gradle will take care of getting flyway making sure things work. 


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
Flyway requires prefixing each script with the version. To avoid a prefix collision use a timestamp for a prefix. 
This project uses the following pattern:yyyyMMddHHmmss. To get timestamp on MacOS:
```bash
date +'%Y%m%d%s'
```

### Release Script

The V1_0_0 release scripts are condensed from the initial and incremental scripts created during development. Those 
scripts ranged from V201702061486427077__initial_ddl.sql to V201708291504028600__add_school_year_table.sql. To reset 
a db instance that had those incremental scripts applied so that the flyway table represents as if this script had 
been used instead:
```sql
USE warehouse;
-- query schema_version and make sure the applied scripts match the list of pre-condensed scripts
SELECT * FROM schema_version;
-- if things look good, reset entries to match condensed scripts:
TRUNCATE TABLE schema_version;
INSERT INTO schema_version VALUES
  (1,NULL,'<< Flyway Schema Creation >>','SCHEMA','`warehouse`',NULL,'root','2017-08-31 00:40:17',0,1),
  (2,'1.0.0.0','ddl','SQL','V1_0_0_0__ddl.sql',146944660,'root','2017-08-31 00:40:18',693,1),
  (3,'1.0.0.1','dml','SQL','V1_0_0_1__dml.sql',150661189,'root','2017-08-31 00:40:18',124,1);  
  
USE reporting;
-- query schema_version and make sure the applied scripts match the list of pre-condensed scripts
SELECT * FROM schema_version;
-- if things look good, reset entries to match condensed scripts:
TRUNCATE TABLE schema_version;
INSERT INTO schema_version VALUES
  (1,NULL,'<< Flyway Schema Creation >>','SCHEMA','`reporting`',NULL,'root','2017-08-31 00:40:16',0,1),
  (2,'1.0.0.0','ddl','SQL','V1_0_0_0__ddl.sql',1611308431,'root','2017-08-31 00:40:17',1290,1),
  (3,'1.0.0.1','dml','SQL','V1_0_0_1__dml.sql',-1800229231,'root','2017-08-31 00:40:17',6,1);
```
