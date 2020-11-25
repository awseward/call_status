-- Migration: add_people_statuses
-- Created at: 2020-11-25 14:36:28
-- ====  UP  ====

BEGIN;

  LOCK people IN EXCLUSIVE MODE;

  ALTER VIEW people RENAME TO people_statuses;

  -- Temporary, will be eventually removing
  CREATE VIEW people AS SELECT * FROM people_statuses;
  COMMENT ON VIEW people IS 'Temporary-- callers should instead reference `people_statuses`.';

COMMIT;

-- ==== DOWN ====

BEGIN;

  LOCK people IN EXCLUSIVE MODE;
  LOCK people_statuses IN EXCLUSIVE MODE;

  DROP VIEW people;

  ALTER VIEW people_statuses RENAME to people;

COMMIT;
