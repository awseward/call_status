import htmlgen as h
import ../models/person
import ../models/status

include "./index.html.nimf"

proc renderPerson*(person: Person): string =
  let isOnACall = isOnCall person.status
  let descText  =
    if isOnACall: "is on a call"
            else: "is not on a call"
  let submitText =
    if isOnACall: "Set status to \"not on a call\""
            else: "Set status to \"on a call\""
  let statusClass =  if isOnACall: "is-on-call"
                             else: ""
  return h.div(
    class = statusClass & " half",
    h.form(
      action   = "set_status/" & person.name,
      `method` = "POST",
      class    = statusClass,
      h.input(
        `type` = "hidden",
        name="is_on_call",
        value=($ not isOnACall)
      ),
      h.h1(person.name),
      h.h2(descText),
      h.details(
        h.summary("Status not accurate?"),
        h.button(type = "submit", submitText),
      )
    )
  )
