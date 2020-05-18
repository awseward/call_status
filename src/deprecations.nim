import logs
import os
import strUtils
import sugar

type Deprecation = distinct string

proc isSupported(deprecation: Deprecation): bool =
  let key = "DEPRECATION_SUPPORT_" & deprecation.string
  parseBool getEnv(key, default = "true")

proc warnOrError*(deprecation: Deprecation, supported: bool) =
  if supported:
    warn "Deprecated (but still supported) functionality triggered: ", deprecation.string
  else:
    error "Deprecated (and no longer supported) functionality triggered: ", deprecation.string

template check*(deprecation, supported, logProc, actions: untyped): untyped =
  let supported = isSupported(deprecation)
  let logProc = () => deprecation.warnOrError supported
  actions

# ---

const UserKey* = Deprecation "USER_KEY"
const ApiStatusEndpoints* = Deprecation "API_STATUS_ENDPOINTS"
