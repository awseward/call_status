build: wifi_cred_up
	arduino-cli compile -v --fqbn espressif:esp32:esp32 main
	rm -rf main/wifiCredentials.h

flash: wifi_cred_up
	arduino-cli upload --fqbn espressif:esp32:esp32 -p /dev/cu.usbserial-0001 main
	rm -rf main/wifiCredentials.h

wifi_cred_up:
	envsubst < main/wifiCredentials.template.h > main/wifiCredentials.h

nuke:
	git clean -xdf -e .envrc
