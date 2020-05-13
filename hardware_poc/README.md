# Hardware PoC Steps

1. Start w/ pretty typical Arduino IDE install for MacOS

2. Install ESP32 tools
   (https://github.com/espressif/arduino-esp32/blob/master/docs/arduino-ide/mac.md)

3. `python get.py` step didn't work, then had to do this:
```
# in ~/Documents/Arduino/hardware/espressif/esp32/tools

wget https://dl.espressif.com/dl/xtensa-esp32-elf-osx-1.22.0-80-g6c4433a-5.2.0.tar.gz
tar -zxvf xtensa-esp32-elf-osx-1.22.0-80-g6c4433a-5.2.0.tar.gz

wget https://dl.espressif.com/dl/esptool-2.6.1-macos.tar.gz
tar -zxvf esptool-2.6.1-macos.tar.gz
```

4. Select board (`Tools > Board > ESP32 Dev Module`)

5. Select port (`Tools > Port > something about USB`)

6. Add `ArduinoJson` dependency w/ Arduino IDE's built in library manager thing

7. Write poc.cpp, using articles from https://techtutorialsx.com extensively

8. Open up serial console for board output (`Tools > Serial Monitor`) (make
   sure it's set to the correct baud)
