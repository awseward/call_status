type Status* = enum
  OnCall,
  NotOnCall

proc isOnCall*(s: Status): bool =
  case s
    of OnCall:    true
    of NotOnCall: false

proc fromIsOnCall*(isOnCall: bool): Status =
  if isOnCall: OnCall
  else:        NotOnCall
