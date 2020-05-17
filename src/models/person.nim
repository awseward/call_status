import json
import seqUtils

import ../deprecations
import ./status

# This is a duplicate of db_*'s `Row`.
# I'd rather not have it, but for now it's fine.
type Row = seq[string]

type Person* = object
  name*: string
  status*: Status

proc fromPgRow*(row: Row): Person =
  Person(
    name: row[0],
    status: fromIsOnCall(row[1] == "t"),
  )

proc fromJson*(jsonNode: JsonNode): Person =
  let status = status.fromIsOnCall(jsonNode["is_on_call"].getBool())

  USER_KEY.checkSupport(supported, message):
    let name = getStr(
      if supported:
        try:
          jsonNode["name"]
        except KeyError:
          echo message
          jsonNode["user"]
      else:
        jsonNode["name"]
    )

    Person(name: name, status: status)

proc fromJsonMany*(jsonNode: JsonNode): seq[Person] =
  jsonNode.getElems().map fromJson

proc isOnCall*(person: Person): bool =
  status.isOnCall person.status

proc `%`*(person: Person): JsonNode =
  %*{
    "name": %person.name,
    "is_on_call": %person.isOnCall(),
  }
