import logging
import os
import strUtils

type Deprecation = distinct string

proc isSupported*(deprecation: Deprecation, default: bool = true): bool =
  let key = "DEPRECATION_SUPPORT_" & deprecation.string
  result = parseBool getEnv(key, default = $default)
  debug "Deprecated functionality triggered: ", deprecation.string
  flushFile stdout

const USER_KEY* = Deprecation "USER_KEY"
const API_STATUS_ENDPOINTS* = Deprecation "API_STATUS_ENDPOINTS"
