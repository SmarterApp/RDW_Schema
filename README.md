## RDW_Schema 
The goal of this project is to create MySQL 5.6 db schema for Smarter Balanced Reporting Data Warehouse and load the core data.

This project uses [flyway](https://flywaydb.org/getstarted). Gradle will take care of getting flyway making sure things work. 


#### To create the schema 
There are multiple schemas in this project: a data warehouse ("warehouse") and a data mart ("reporting"). Each has a dev and integration-test-only instance on the server. 
The Flyway configuration can be found in the main `build.gradle` file.
Gradle can perform all of the flyway tasks defined [here](https://flywaydb.org/documentation/gradle/).

To install or migrate, run:
```bash
RDW_Schema$ ./gradlew migrateWarehouse (or migrateWarehouse-test)
OR
RDW_Schema$ ./gradlew migrateReporting (or migrateReporting-test)
OR
RDW_Schema$ ./gradlew migrateAll (migrates the dev and test instances for the schemas)
```

#### To wipe out the schema
```bash
RDW_Schema$ ./gradlew cleanWarehouse (or cleanWarehouse-test)
OR
RDW_Schema$ ./gradlew cleanReporting (or cleanReporting-test)
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
