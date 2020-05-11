import json

# This is a duplicate of db_*'s `Row`.
# I'd rather not have it, but for now it's # fine.
type Row = seq[string]

type Person* = object
  name*:       string
  is_on_call*: bool

proc fromPgRow*(row: Row): Person =
  return Person(
    name:       row[0],
    is_on_call: row[1] == "t",
  )

proc fromJson*(jsonNode: JsonNode): Person =
  return Person(
    name:       jsonNode["user"].getStr(),
    is_on_call: jsonNode["is_on_call"].getBool(),
  )
