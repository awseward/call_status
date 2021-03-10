arduino_fqbn = espressif:esp32:esp32
arduino_port = /dev/cu.usbserial-0001
env_header   = main/env.h
env_template = main/env.template.h

# ---

build: ${env_header}
	>&2 echo 'WARNING: So far I have only managed to get this to abort-loop, so YMMV...'
	arduino-cli compile -v --fqbn "${arduino_fqbn}" main
	rm -rf "${env_header}"

flash: ${env_header}
	arduino-cli upload --fqbn "${arduino_fqbn}" --port "${arduino_port}" main
	rm -rf "${env_header}"

env_header: ${env_header}

${env_header}:
	envsubst < "${env_template}" > "${env_header}"

tail:
	screen "${arduino_port}" 115200

nuke:
	git clean -xdf -e .envrc
