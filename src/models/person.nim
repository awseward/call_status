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

  let name = getStr(
    try: jsonNode["name"]
    except KeyError:
      deprecations.USER_KEY.check supported, logProc:
        logProc()
        if not supported: raise
        else:
          jsonNode["user"]
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
