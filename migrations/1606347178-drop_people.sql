-- Migration: drop_people
-- Created at: 2020-11-25 15:32:58
-- ====  UP  ====

BEGIN;

  DROP VIEW people;

COMMIT;

-- ==== DOWN ====

BEGIN;

  -- Temporary, will be eventually removing
  CREATE VIEW people AS SELECT * FROM people_statuses;
  COMMENT ON VIEW people IS 'Temporary-- callers should instead reference `people_statuses`.';

COMMIT;
