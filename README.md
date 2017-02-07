
## RDW_Schema 
The goal of this project is to create MySQL 5.6 db schema for Smarter Balanced Reporting Data Warehouse and load the core data.

This project uses [flyway](https://flywaydb.org/getstarted). You must have Flyway installed and running for things to work. For MacOS: 
```bash
brew install flyway 
```

### To install
There are multiple schemas: a data warehouse and data mart(s). Each has a corresponding folder. To install, go to a corresponding folder and run:
```bash
flyway -configFile=flyway.properties migrate
```

## To wipe out the database
```bash
flyway -configFile=flyway.properties clean
```

### Developing
Flyway requires prefixing each script with the version. To avoid a prefix collision use a timestamp for a prefix. This project uses the following pattern:yyyyMMddHHmmss. To get timestamp on MacOS:
```bash
date +'%Y%m%d%s'
```

Flyway configurations can be found in the _flyway.properties_ file. 
