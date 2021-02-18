build: wifi_cred
	arduino-cli compile -v --fqbn espressif:esp32:esp32 main

flash: wifi_cred
	arduino-cli upload --fqbn espressif:esp32:esp32 -p /dev/cu.usbserial-0001 main

wifi_cred:
	./wifi_credentials.sh
