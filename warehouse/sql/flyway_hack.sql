-- This script can be used to trick flyway into being happy with consolidated scripts.
--
-- The values need to be figured out by running flyway clean/migrate against an empty database and then querying
-- the contents of schema_version. Then run this script against any database that is up-to-date wrt flyway migration.
-- Be careful to ensure you do this only when the consolidated script corresponds to the database state.

USE warehouse;
TRUNCATE TABLE schema_version;
INSERT INTO schema_version (installed_rank, version, description, type, script, checksum, installed_by, execution_time, success) VALUES
  (1, NULL, '<< Flyway Schema Creation >>', 'SCHEMA', '`warehouse`', NULL, 'root', 0, 1),
  (2, '201702061486427077', 'initial ddl', 'SQL', 'V201702061486427077__initial_ddl.sql', 1556581586, 'root', 688, 1),
  (3, '201702061486427095', 'initial dml', 'SQL', 'V201702061486427095__initial_dml.sql', 351694737, 'root', 258, 1);
