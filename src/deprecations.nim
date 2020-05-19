import hashes
import logs
import os
import strUtils
import sugar
import tables

type DeprecationKey* = distinct string

type Deprecation* = object
  key: DeprecationKey
  supported: bool

proc hash(x: DeprecationKey): Hash =
  result = x.string.hash
  result = !$result

proc `==`(x, y: DeprecationKey): bool =
  x.string == y.string

proc isSupported(deprecation: DeprecationKey): bool =
  let key = "DEPRECATION_SUPPORT_" & deprecation.string
  parseBool getEnv(key, default = "true")

proc load(keys: seq[DeprecationKey]): Table[DeprecationKey, Deprecation] =
  result = initTable[DeprecationKey, Deprecation]()
  for _, key in keys:
    result[key] = Deprecation(key: key, supported: isSupported key)

proc warnOrError*(deprecation: DeprecationKey, supported: bool) =
  if supported:
    warn "Deprecated (but still supported) functionality triggered: ", deprecation.string
  else:
    error "Deprecated (and no longer supported) functionality triggered: ", deprecation.string

# ---

const UserKey* = DeprecationKey "USER_KEY"
const ApiStatusEndpoints* = DeprecationKey "API_STATUS_ENDPOINTS"

let deprecations = load @[UserKey, ApiStatusEndpoints]

template check*(key, supported, logProc, actions: untyped): untyped =
  let deprecation = deprecations[key]
  let supported = deprecation.supported
  let logProc = () => key.warnOrError supported
  actions
