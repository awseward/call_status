# Notes `esp-idf`

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
