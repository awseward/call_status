temp_dir := $(shell mktemp -d)

dw-misc_rev := 0.0.4
dw-misc_url_base := https://github.com/awseward/dw-misc/raw/${dw-misc_rev}/bin

shmig_repo := git://github.com/mbucc/shmig.git
shmig_dir := ${temp_dir}/shmig

uplink_zip_name := uplink_linux_amd64.zip
uplink_zip_url := https://github.com/storj/storj/releases/latest/download/${uplink_zip_name}

# ---

heroku-local-bins: .local/bin/heroku_database_url_splitter .local/bin/shmig .local/bin/uplink dw-misc-bins
	chmod -v 700 .local/bin/*

dw-misc-bins: .local/bin/dw

.local/bin:
	mkdir -p .local/bin

.local/bin/dw: .local/bin
	curl -s -L "${dw-misc_url_base}/dw" -o .local/bin/dw

.local/bin/shmig: .local/bin
	mkdir -p "${shmig_dir}"
	git clone "${shmig_repo}" "${shmig_dir}"
	cp "${shmig_dir}/shmig" .local/bin/
	.local/bin/shmig -V

.local/bin/heroku_database_url_splitter: .local/bin
	cp "$(shell which heroku_database_url_splitter)" .local/bin/

.local/bin/uplink: .local/bin
	curl -s -L "${uplink_zip_url}" -o "${uplink_zip_name}"
	unzip -o "${uplink_zip_name}"
	rm -vf "${uplink_zip_name}"
	mv uplink .local/bin/
	touch .local/bin/uplink # Make seems to want to always re-run this target unless we touch this file
