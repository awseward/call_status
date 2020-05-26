-- Migration: initial_setup
-- Created at: 2020-05-25 17:57:55
-- ====  UP  ====

BEGIN;

  -- Create table
  CREATE TABLE people (
    id         SERIAL PRIMARY KEY,
    name       TEXT NOT NULL,
    is_on_call BOOLEAN NOT NULL
  );

  -- Populate table
  INSERT INTO people
    (name, is_on_call) VALUES
    ('D', FALSE),
    ('N', FALSE);

COMMIT;

-- ==== DOWN ====

BEGIN;

  DROP TABLE people;

COMMIT;
