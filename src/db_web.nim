import db_postgres
import sequtils

import ./db
import ./logs
import ./misc
import ./models/person

let db_open = open_pg

proc updatePerson*(person: Person) =
  let query = sql misc.dedent """
    UPDATE people_statuses
    SET is_on_call = $1
    WHERE name = $2;"""
  db_open.use conn:
    debug query.string
    let prepared = conn.prepare("update_status", query, 2)
    conn.exec prepared, $person.isOnCall(), person.name

proc nameExists*(name: string): bool =
  let query = sql misc.dedent """
    SELECT name
    FROM people_statuses
    WHERE name = $1
    LIMIT 1;"""
  db_open.use conn:
    debug query.string
    let prepared = conn.prepare("check_name", query, 1)
    conn.getValue(prepared, name) == name

proc getPeople*(): seq[Person] =
  let query = sql misc.dedent """
    SELECT
      name
    , is_on_call
    FROM people_statuses
    WHERE name IN ($1, $2)
    ORDER BY name;"""
  let rows = db_open.use conn:
    debug query.string
    let prepared = conn.prepare("get_people", query, 2)
    conn.getAllrows prepared, "D", "N"

  rows.map fromPgRow
