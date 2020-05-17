import logs
import os
import strUtils

type Deprecation = distinct string

proc log(deprecation: Deprecation, supported: bool) =
  if supported:
    discard
    # warn "Deprecated (but supported) functionality triggered: ", deprecation.string
  else:
    error "Deprecated (and no longer supported) functionality triggered: ", deprecation.string

template checkSupport*(deprecation, supported, message, actions: untyped): untyped =
  let key = "DEPRECATION_SUPPORT_" & deprecation.string
  let supported = parseBool getEnv(key, default = "true")
  let message = "FIXME"
  actions

proc isSupported*(deprecation: Deprecation, default: bool = true): bool =
  let key = "DEPRECATION_SUPPORT_" & deprecation.string
  result = parseBool getEnv(key, default = $default)
  log deprecation, result

# ---

const USER_KEY* = Deprecation "USER_KEY"
const API_STATUS_ENDPOINTS* = Deprecation "API_STATUS_ENDPOINTS"
