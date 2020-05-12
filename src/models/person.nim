import json
import ./status

# This is a duplicate of db_*'s `Row`.
# I'd rather not have it, but for now it's fine.
type Row = seq[string]

type Person* = object
  name*:   string
  status*: Status

proc fromPgRow*(row: Row): Person =
  return Person(
    name:   row[0],
    status: fromIsOnCall(row[1] == "t"),
  )

proc fromJson*(jsonNode: JsonNode): Person =
  let status = status.fromIsOnCall(jsonNode["is_on_call"].getBool())

  return Person(
    name:   jsonNode["user"].getStr(),
    status: status,
  )
