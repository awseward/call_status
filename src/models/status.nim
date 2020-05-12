type Status* = enum
  OnCall,
  NotOnCall

proc isOnCall*(s: Status): bool =
  return case s
    of OnCall:    true
    of NotOnCall: false

proc fromIsOnCall*(isOnCall: bool): Status =
  return
    if isOnCall: OnCall
    else:        NotOnCall
