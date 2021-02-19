header_template = main/wifiCredentials.template.h
header_file     = main/wifiCredentials.h

arduino_fqbn = espressif:esp32:esp32
arduino_port = /dev/cu.usbserial-0001

build: ${header_file}
	arduino-cli compile -v --fqbn "${arduino_fqbn}" main
	rm -rf "${header_file}"

flash: ${header_file}
	arduino-cli upload --fqbn "${arduino_fqbn}" --port "${arduino_port}" main
	rm -rf "${header_file}"

${header_file}:
	envsubst < "${header_template}" > "${header_file}"

wifi_cred_up: ${header_file}

nuke:
	git clean -xdf -e .envrc
