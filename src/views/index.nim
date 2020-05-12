import htmlgen as h
import ../models/person
import ../models/status

include "./index.html.nimf"

type Presenter = object
  description:  string
  callToAction: string
  statusClass:  string

proc presenterFor(person: Person): Presenter =
  case person.status
  of OnCall:
    Presenter(
      description:  "is on a call",
      callToAction: "Set status to \"not on a call\"",
      statusClass:  "is-on-call",
    )
  of NotOnCall:
    Presenter(
      description:  "is not on a call",
      callToAction: "Set status to \"on a call\"",
      statusClass:  "",
    )

proc renderPerson*(person: Person): string =
  let presenter   = presenterFor person
  let statusClass = presenter.statusClass

  h.div(
    class = statusClass & " half",
    h.form(
      action   = "set_status/" & person.name,
      `method` = "POST",
      class    = statusClass,
      h.input(
        `type` = "hidden",
        name="is_on_call",
        value=($ not person.isOnCall())
      ),
      h.h1(person.name),
      h.h2(presenter.description),
      h.details(
        h.summary("Status not accurate?"),
        h.button(type = "submit", presenter.callToAction),
      )
    )
  )
