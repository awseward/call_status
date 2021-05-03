temp_dir := $(shell mktemp -d)

dw_misc_rev := 644bd6fb3209a0c1fc8ac274239eb7fc40b12584
dw_misc_url_base := https://github.com/awseward/dw-misc/raw/${dw_misc_rev}/bin

shmig_repo := git://github.com/mbucc/shmig.git
shmig_dir := ${temp_dir}/shmig

uplink_zip_name := uplink_linux_amd64.zip
uplink_zip_url := https://github.com/storj/storj/releases/latest/download/${uplink_zip_name}

# ---

heroku-local-bins: .bin/heroku_database_url_splitter .bin/shmig .bin/uplink dw-misc-bins
	chmod -v 700 .bin/*

dw-misc-bins: .bin/dw_push_sqlite .bin/dw_signal_sqlite .bin/dw_push

.bin:
	mkdir -p .bin

.bin/dw_push_sqlite: .bin
	curl -s -L "${dw_misc_url_base}/dw_push_sqlite" -o .bin/dw_push_sqlite

.bin/dw_signal_sqlite: .bin
	curl -s -L "${dw_misc_url_base}/dw_signal_sqlite" -o .bin/dw_signal_sqlite

.bin/dw_push: .bin
	curl -s -L "${dw_misc_url_base}/dw_push" -o .bin/dw_push

.bin/shmig: .bin
	mkdir -p "${shmig_dir}"
	git clone "${shmig_repo}" "${shmig_dir}"
	cp "${shmig_dir}/shmig" .bin/
	.bin/shmig -V

.bin/heroku_database_url_splitter: .bin
	cp "$(shell which heroku_database_url_splitter)" .bin/

.bin/uplink: .bin
	curl -s -L "${uplink_zip_url}" -o "${uplink_zip_name}"
	unzip -o "${uplink_zip_name}"
	rm -vf "${uplink_zip_name}"
	mv uplink .bin/
	touch .bin/uplink # Make seems to want to always re-run this target unless we touch this file
	.bin/uplink version
