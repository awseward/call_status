import os

let CacheHome* = os.getEnv("XDG_CACHE_HOME", default = os.expandTilde "~/.cache/")
let ConfigHome* = os.getConfigDir()
let DataHome* = os.getEnv("XDG_DATA_HOME", default = os.expandTilde "~/.local/share")
