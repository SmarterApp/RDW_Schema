## Reporting prototype

Everything in this folder is a temporary work around to 
- move the data from warehouse into reporting data mart 
- run sample queries.

To create a dump:
```bash
mysqldump --user=root warehouse > warehouse.sql
```
To restore the dump:
```bash
flyway -configFile=flyway.properties clean

mysql -u root -p 
mysql> create database warehouse;
mysql> exit;

mysql -u root -p -h localhost warehouse < warehouse.sql

```
migrate-hack.sql would move the data from warehouse to the reporting mart. 