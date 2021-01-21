-- v2.5.0_4 flyway script
-- Inserts an entry into the the import table to force embargoes and exam counts to migrate the first time.
INSERT IGNORE INTO import (status, content, contentType, digest, batch)
VALUES (1, 6, 'admin embargo modification', 'init embargoes and exam counts', 'embargo update');
