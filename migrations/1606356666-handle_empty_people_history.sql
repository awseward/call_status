-- Migration: handle_empty_people_history
-- Created at: 2020-11-25 18:11:06
-- ====  UP  ====

BEGIN;

  CREATE OR REPLACE VIEW people_statuses ( id, name, is_on_call, since ) AS
    WITH curr AS (
      SELECT DISTINCT ON (people_id)
        people_id, is_on_call, timestamp
      FROM people_history
      ORDER BY people_id, timestamp DESC
    ) SELECT
      ppl.id,
      ppl.name,
      COALESCE(curr.is_on_call, false),
      curr.timestamp
    FROM people_v2 ppl
    FULL OUTER JOIN curr ON ppl.id = curr.people_id;

COMMIT;

-- ==== DOWN ====

BEGIN;

  CREATE OR REPLACE VIEW people_statuses ( id, name, is_on_call, since ) AS
    WITH curr AS (
      SELECT DISTINCT ON (people_id)
        people_id, is_on_call, timestamp
      FROM people_history
      ORDER BY people_id, timestamp DESC
    ) SELECT
      ppl.id,
      ppl.name,
      curr.is_on_call,
      curr.timestamp
    FROM people_v2 ppl
    JOIN curr ON ppl.id = curr.people_id;

COMMIT;
