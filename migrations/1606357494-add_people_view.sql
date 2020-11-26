-- Migration: add_people_view
-- Created at: 2020-11-25 18:24:54
-- ====  UP  ====

BEGIN;

  CREATE VIEW people AS SELECT id, name FROM people_v2;

COMMIT;

-- ==== DOWN ====

BEGIN;

  DROP VIEW people;

COMMIT;
