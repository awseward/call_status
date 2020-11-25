-- Migration: add_history
-- Created at: 2020-11-25 12:02:56
-- ====  UP  ====

BEGIN;

  CREATE TABLE people_v2 (
    id   SERIAL PRIMARY KEY,
    name TEXT NOT NULL
  );

  LOCK TABLE people IN EXCLUSIVE MODE;
  LOCK TABLE people_v2 IN EXCLUSIVE MODE;

  INSERT INTO people_v2 (id, name) SELECT id, name FROM people;
  SELECT SETVAL('people_v2_id_seq', COALESCE((SELECT MAX(id)+1 FROM people), 1), false);
  CREATE TABLE people_history (
    people_id  INT REFERENCES people_v2(id),
    timestamp  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_on_call BOOLEAN NOT NULL,
    PRIMARY KEY(people_id, timestamp)
  );
  INSERT INTO people_history (people_id, is_on_call) SELECT id, is_on_call FROM people;
  DROP TABLE people;

  CREATE VIEW people (id, name, is_on_call, since) AS
    WITH current_status AS (
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
    JOIN current_status curr ON ppl.id = curr.people_id;

  -- No inserts to preserve (only done through initial migration so far)

  CREATE RULE rl_people_update AS
    ON UPDATE TO people DO INSTEAD
    INSERT INTO people_history
             (people_id, is_on_call)
      VALUES (new.id,    new.is_on_call);

COMMIT;

-- ==== DOWN ====

BEGIN;

  LOCK TABLE people_v2 IN EXCLUSIVE MODE;

  CREATE TEMPORARY TABLE temp_people AS SELECT id, name, is_on_call FROM people;
  DROP VIEW people;
  CREATE TABLE people (
    id         SERIAL PRIMARY KEY,
    name       TEXT NOT NULL,
    is_on_call BOOLEAN NOT NULL
  );
  INSERT INTO people (id, name, is_on_call) SELECT * FROM temp_people;
  SELECT SETVAL('people_id_seq', COALESCE((SELECT MAX(id)+1 FROM people), 1), false);
  DROP TABLE temp_people;

  DROP TABLE people_history;
  DROP TABLE people_v2;
COMMIT;
