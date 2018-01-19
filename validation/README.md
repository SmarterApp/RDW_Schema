### Migration Validation

This script runs SQL queries against the various RDW data stores to validate the data migration process. 
Test result information is retrieved and stored as CSV files, and any differences in the data are calculated.

#### Prerequisites
1. `mysql`
1. `psql`

#### Preparation
First, clone the repository and make sure the script is executable.
```bash
git clone https://github.com/SmarterApp/RDW_Schema
cd RDW_Schema/validation
chmod 755 validate-migration.sh
``` 
Next create an environment-specific secrets file under the git-ignored `secrets` directory.
It is important to place them somewhere that will not get checked in.
Below is an example of creating a secret file for the local environment and setting the file permissions to the owner.
```bash
touch secrets/local.sh && chmod 600 secrets/local.sh
```
Next, enter the below variables into the secrets file and replace the placeholders with the appropriate values.
```bash
#!/usr/bin/env bash

warehouse_host=localhost
warehouse_port=3306
warehouse_schema=warehouse
warehouse_user=root
warehouse_password=

reporting_host=localhost
reporting_port=3306
reporting_schema=reporting
reporting_user=root
reporting_password=

reporting_olap_host=localhost
reporting_olap_port=5439
reporting_olap_db=dev
reporting_olap_user=root
reporting_olap_password=
```
#### Running
1. To validate both reporting and aggregate reporting (aka OLAP), simply execute it and pass in the file path to your secrets file.
```bash
./validate-migration.sh secrets/local.sh
```
2. To validate both reporting only
```bash
./validate-migration.sh secrets/local.sh reporting
```
3. To validate aggregate reporting only
```bash
./validate-migration.sh secrets/local.sh olap
```

To investigate a failed test, open the printed directory link in the terminal output.
If the comparison between warehouse and reporting_olap failed for instance, you would see the following files:
```
validation/results-2018-01-08-091053/total-ica-scores
├── reporting.csv
├── warehouse.csv
└── warehouse_reporting.diff

#### Example Output
```
 __   __                   __   __       ___    __                            __       ___  __   __  
|__) |  \ |  |     |\/| | / _` |__)  /\   |  | /  \ |\ |    \  /  /\  |    | |  \  /\   |  /  \ |__) 
|  \ |__/ |/\|     |  | | \__> |  \ /~~\  |  | \__/ | \|     \/  /~~\ |___ | |__/ /~~\  |  \__/ |  \ 

validating...
  output folder: /tmp/validation/results-2018-01-19-143702
  warehouse connection:      sbac @ rdw-aurora-qa-warehouse.cugsexobhx8t.us-west-2.rds.amazonaws.com:3306/warehouse
  reporting connection:      sbac @ rdw-aurora-qa-reporting.cugsexobhx8t.us-west-2.rds.amazonaws.com:3306/reporting
  reporting olap connection: awsqa @ rdw-qa.cibkulpjrgtr.us-west-2.redshift.amazonaws.com:5439/qa

************ Running reporting olap tests ************
22:37:03 Running Test: total-ica
getting data from warehouse
getting data from reporting
  olap_warehouse/olap_reporting (passed)

22:37:03 Running Test: total-ica-scores
getting data from warehouse
getting data from reporting
  olap_warehouse/olap_reporting (1 differences) /tmp/validation/results-2018-01-19-143702/total-ica-scores/olap_warehouse_olap_reporting.diff

22:37:04 Running Test: total-ica-by-asmt-schoolyear-condition-complete
getting data from warehouse
getting data from reporting
  olap_warehouse/olap_reporting (passed)

22:37:04 Running Test: total-ica-by-school-district
getting data from warehouse
getting data from reporting
  olap_warehouse/olap_reporting (passed)

************ Running reporting tests ************
22:37:05 Running Test: total-ica
getting data from warehouse
getting data from reporting
  warehouse/reporting (passed)

22:37:06 Running Test: total-ica-scores
getting data from warehouse
getting data from reporting
  warehouse/reporting (1 differences) /tmp/validation/results-2018-01-19-143702/total-ica-scores/warehouse_reporting.diff

22:37:06 Running Test: total-ica-by-asmt-schoolyear-condition-complete
getting data from warehouse
getting data from reporting
  warehouse/reporting (passed)

22:37:07 Running Test: total-ica-by-school-district
getting data from warehouse
getting data from reporting
  warehouse/reporting (passed)

22:37:07 Running Test: total-iab
getting data from warehouse
getting data from reporting
  warehouse/reporting (passed)

22:37:08 Running Test: total-iab-scores
getting data from warehouse
getting data from reporting
  warehouse/reporting (1 differences) /tmp/validation/results-2018-01-19-143702/total-iab-scores/warehouse_reporting.diff

22:37:08 Running Test: total-iab-by-asmt-schoolyear-condition-complete
getting data from warehouse
getting data from reporting
  warehouse/reporting (passed)

22:37:09 Running Test: total-iab-by-school-district
getting data from warehouse
getting data from reporting
  warehouse/reporting (passed)

completed in 00:00:07
9 tests passed with no differences
differences found:
  /tmp/validation/results-2018-01-19-143702/total-ica-scores/olap_warehouse_olap_reporting.diff
  /tmp/validation/results-2018-01-19-143702/total-ica-scores/warehouse_reporting.diff
  /tmp/validation/results-2018-01-19-143702/total-iab-scores/warehouse_reporting.diff
```
