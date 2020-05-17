import logs
import os
import strUtils
import sugar

type Deprecation = distinct string

proc warnOrError*(deprecation: Deprecation, supported: bool) =
  if supported:
    warn "Deprecated (but still supported) functionality triggered: ", deprecation.string
  else:
    error "Deprecated (and no longer supported) functionality triggered: ", deprecation.string

template check*(deprecation, supported, logProc, actions: untyped): untyped =
  let key = "DEPRECATION_SUPPORT_" & deprecation.string
  let supported = parseBool getEnv(key, default = "true")
  let logProc = () => deprecation.warnOrError supported
  actions

# ---

const USER_KEY* = Deprecation "USER_KEY"
const API_STATUS_ENDPOINTS* = Deprecation "API_STATUS_ENDPOINTS"
