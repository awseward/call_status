## Notes on `Lua-RTOS`

Repo: https://github.com/whitecatboard/Lua-RTOS-ESP32

I've played around with this and it's super nice to have an interactive
console; feels pretty promising. It's very straightforward to get onto Wifi, it
looks like it's got a native MQTT client, and native JSON functionality.

The "getting started" is [right in the
README](https://github.com/whitecatboard/Lua-RTOS-ESP32#method-1-get-a-precompiled-firmware).
As a note to my future self, I used something like "Generic ESP32" **without**
OTA (OTA didn't seem to work; it'd be nice, but oh well, hardly the end of the
world).

~**However**, it looks like there's no simple or straightforward way to get an
HTTP client running on-device. So far, searching has only turned up:
https://twitter.com/loboris2/status/833012792139644928~

This might actually work, if I can get `luasocket` to show up on the device
filesystem. There's some potential leads here, maybe:

https://github.com/whitecatboard/Lua-RTOS-ESP32/issues?q=is%3Aissue+luasocket+is%3Aclosed

It _might_ be a good idea to remove the HTTP requirement anyway; instead, just
have the devices go straight to MQTT. I'd first like to see just how much
effort getting an HTTP client onboard ends up being, though.

## Notes on `esp-idf`

Notes here pertain to [the official esp-idf "getting started"
guide](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/linux-macos-setup.html#get-started-prerequisites).

The `hello_world` project pretty much "just worked", which was a _really_ nice
surprise coming from Arduino IDE…

#### Some highlights from the doc

```sh
# PORT:
#   Linux: starting with `/dev/tty`
#   macOS: starting with `/dev/cu.`

# build
idf.py -p <PORT> build

# flash
idf.py -p <PORT> flash

# monitor (see serial console output)
#   to quit: `ctrl+]`
idf.py -p <PORT> monitor
```

#### "Wrong boot mode" error when flashing

```
A fatal error occurred: Failed to connect to ESP32: Wrong boot mode detected
(0x13)! The chip needs to be in download mode.
```

The solution to this is to hold the button when running `idf.py … flash`, the
same as was requried when using the Arduino IDE. I found the search results led
to the solution pretty quickly when pasting this error into the search bar, but
still worth noting for posterity's sake.
