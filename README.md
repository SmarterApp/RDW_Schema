## RDW_Schema 
The goal of this project is to create MySQL 5.6 db schema for Smarter Balanced Reporting Data Warehouse and load the core data.

This project uses [flyway](https://flywaydb.org/getstarted). Gradle will take care of getting flyway making sure things to work. 


#### To create the schema 
There are multiple schemas: a data warehouse ("warehouse") and data mart(s) ("reporting"). Each has a corresponding folder. 
Flyway configurations can be found in the `build.gradle` file for each schema subdirectory.
Gradle will perform the migrations or cleans.
To install or migrate, run:
```bash
RDW_Schema$ ./gradlew migrateWarehouse
OR
RDW_Schema$ ./gradlew migrateReporting
OR
RDW_Schema$ ./gradlew migrateAll
```

#### To wipe out the schema
```bash
RDW_Schema$ ./gradlew cleanWarehouse
OR
RDW_Schema$ ./gradlew cleanReporting
OR
RDW_Schema$ ./gradlew cleanAll
```

#### Alternate Data Source
The data source, user, password, etc. can be overridden on the command line, e.g.
```bash
RDW_Schema$ ./gradlew -Pflyway.url="jdbc:mysql://rdw-aurora-dev.cugsexobhx8t.us-west-2.rds.amazonaws.com:3306/" -Pflyway.user=sbac -Pflyway.password=mypassword cleanAll
```

#### Other Commands
Other flyway commands can be executed on the subproject besides clean and migrate by using "./gradlew :\<subproject\>:\<flyway command\>". See https://flywaydb.org/documentation/gradle/ for more info.

For example:
```bash
RDW_Schema$ ./gradlew :warehouse:flywayValidate
or
RDW_Schema$ ./gradlew :warehouse:flywayInfo
or
RDW_Schema$ ./gradlew :warehouse:flywayRepair
```



### Developing
Flyway requires prefixing each script with the version. To avoid a prefix collision use a timestamp for a prefix. 
This project uses the following pattern:yyyyMMddHHmmss. To get timestamp on MacOS:
```bash
date +'%Y%m%d%s'
```
