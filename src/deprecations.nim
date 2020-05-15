import os
import strUtils

proc isSupported(key: string, default: bool = true): bool =
  let fullKey = "DEPRECATION_SUPPORT_" & key
  parseBool getEnv(fullKey, default = $default)

let userKeySupported* = isSupported "USER_KEY"
let apiStatusEndpoints* = isSupported "API_STATUS_ENDPOINTS"
