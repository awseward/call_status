# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Moved the local binaries' setup for heroku into a Makefile (https://github.com/awseward/call_status/pull/137)
- Use latest nim (1.6.0), dhall (1.40.2) (https://github.com/awseward/call_status/pull/154)
- Various CI changes

## [0.6.4] - 2021-05-02
### Added
- A favicon for web (https://github.com/awseward/call_status/pull/124)

### Changed
- Give XDG dirs their own module (https://github.com/awseward/call_status/pull/123)
- Use latest nim (1.4.6) (https://github.com/awseward/call_status/pull/127)
- Use latest dhall (1.38.1) (https://github.com/awseward/call_status/pull/128)
- Misc changes to dhall-generated GH Actions (https://github.com/awseward/call_status/pull/126/files, https://github.com/awseward/call_status/pull/129, https://github.com/awseward/call_status/pull/130, https://github.com/awseward/call_status/pull/134)

### Fixed
- Fix (kinda) the broken websocket-driven auto-refresh (https://github.com/awseward/call_status/pull/125)
- Address some compiler warnings coming from nimassets (https://github.com/awseward/call_status/pull/131, https://github.com/awseward/call_status/pull/133)
- Get heroku deploys working again (https://github.com/awseward/call_status/pull/135)

## [0.6.3] - 2021-03-27
### Added
- BSD 3-Clause License (https://github.com/awseward/call_status/pull/122)

## [0.6.2] - 2021-03-27
### Fixed
- Corrected project `nimble` file; forgot to increment its version before tagging `0.6.1`.

## [0.6.1] - 2021-03-27
### Changed
- DB file for `call_status_checker` now defaults to `$XDG_DATA_HOME/call_status/checker.db` (https://github.com/awseward/call_status/pull/118)
- Upgraded `nim` version: `1.4.2 → 1.4.4` (https://github.com/awseward/call_status/pull/117)

## [0.6.0] - 2021-03-26
### Changed
- Config file for `call_status_checker` now defaults to `$XDG_CONFIG_HOME/call_status/checker.conf.json` (https://github.com/awseward/call_status/pull/116)
- Fixed a minor bug with the ESP startup LED sequence (https://github.com/awseward/call_status/pull/114)
- Updated docs to reflect that a previously-planned feature is now implemented (https://github.com/awseward/call_status/pull/113)
- Upgraded `argparse` dependency: `0.10.1 → 2.0.0` (https://github.com/awseward/call_status/pull/115)

## [0.5.1] - 2021-03-10
### Added
- Diagram in README giving a high-level overview of how everything works (https://github.com/awseward/call_status/pull/109, https://github.com/awseward/call_status/pull/110)
- Support for a "control" MQTT topic; currently allows broadcasting a "reboot" signal over MQTT to all ESP devices (https://github.com/awseward/call_status/pull/111, https://github.com/awseward/call_status/pull/112)

### Changed
- RPi script which consumes ESP heartbeats now adds timestamps (https://github.com/awseward/call_status/pull/108)

## [0.4.12] - 2021-03-10
### Added
- Makefile for building ESP Arduino project (https://github.com/awseward/call_status/pull/96, https://github.com/awseward/call_status/pull/97, https://github.com/awseward/call_status/pull/98)
- Use an ESP32 heartbeat to indicate when polling Heroku site is actually necessary (can skip otherwise) (https://github.com/awseward/call_status/pull/102, https://github.com/awseward/call_status/pull/103)
- Notes on how RPi component is set up (https://github.com/awseward/call_status/pull/104)
- Add MQTT information to Heroku response-- it's becoming ever more just a configuration store as time goes on (https://github.com/awseward/call_status/pull/105)

### Changed
- Misc updates to CI in GitHub Actions (https://github.com/awseward/call_status/pull/94)
- Source WiFi Credentials for compilation onto ESP from an env-based temporary file, ignored by source control (https://github.com/awseward/call_status/pull/95, https://github.com/awseward/call_status/pull/99)
- Reboot ESP device when it looks like WiFi is unlikely to ever connect successfully (https://github.com/awseward/call_status/pull/101)

## [0.4.11] - 2021-01-18
### Changed
- Misc updates to CI in GitHub Actions (https://github.com/awseward/call_status/pull/93)

## [0.4.10] - 2021-01-05
### Changed
- Misc updates to CI in GitHub Actions (https://github.com/awseward/call_status/pull/88, https://github.com/awseward/call_status/pull/89, https://github.com/awseward/call_status/pull/90, https://github.com/awseward/call_status/pull/91, https://github.com/awseward/call_status/pull/92)

## [0.4.9] - 2020-12-31
### Fixed
- Account for several versions missing corresponding increment in project `nimble` file: `0.4.6 → 0.4.9` (https://github.com/awseward/call_status/commit/3903cc27db5e444c9971a18f4efeafcc287de9f1)

## [0.4.8] - 2020-12-31
### Added
- Introduce dhall-generated Actions (https://github.com/awseward/call_status/pull/82, https://github.com/awseward/call_status/pull/83, https://github.com/awseward/call_status/pull/84, https://github.com/awseward/call_status/pull/85, https://github.com/awseward/call_status/pull/87, https://github.com/awseward/call_status/pull/86)

### Fixed
- Use workaround for critical bug in `jester` dependency: `-d:useStdLib` (https://github.com/awseward/call_status/pull/81)

## [0.4.7] - ????-??-??
#### Mysteriously, nowhere to be found…
<img height="150" src="https://tenor.com/view/john-travolta-gif-19687041.gif" alt="Huh??"/>

## [0.4.6] - 2020-12-28
### Changed
- Misc tweaks to CI/Actions (https://github.com/awseward/call_status/pull/75, https://github.com/awseward/call_status/pull/76, https://github.com/awseward/call_status/pull/79)
- Upgraded `nim` version: `1.2.0 → 1.4.2` (https://github.com/awseward/call_status/pull/77)
- Upgraded `jester` dependency: `0.4.3 -> 0.5.0` (https://github.com/awseward/call_status/pull/77)
- Added nimble flags: `--stacktrace:on --linetrace:on` (https://github.com/awseward/call_status/pull/77)
- Use workaround for critical bug in `jester` dependency: `-d:useStdLib` (https://github.com/awseward/call_status/pull/77)

## [0.4.5] - 2020-12-28
### Changed
- Upgraded `nim` version: `1.2.0 → 1.4.2` (https://github.com/awseward/call_status/pull/73)
- Keep nimble file's `nim` version at `1.2.0` (https://github.com/awseward/call_status/commit/1efb30b753ce54aeb0750831ce6acd040478dba2)

## [0.4.4] - 2020-12-28
### Added
- Prune `people_history` regularly so it does not grow indefinitely (https://github.com/awseward/call_status/pull/69)

### Changed
- Builds should now include stacktrace, etc. on unhandled exceptions (https://github.com/awseward/call_status/pull/71)
- Various "warehousing"-related changes (https://github.com/awseward/call_status/pull/66, https://github.com/awseward/call_status/pull/67, https://github.com/awseward/call_status/pull/70)

## [0.4.3] - 2020-12-15
### Added
- Introduce "warehousing" of call_status data (https://github.com/awseward/call_status/pull/63)

### Changed
- Pin `nim` version in Actions workflows (https://github.com/awseward/call_status/pull/64)

## [0.4.2] - 2020-12-13
### Changed
- Fiddle around with, and/or resolve miscellaneous CI/Actions issues (https://github.com/awseward/call_status/pull/60, https://github.com/awseward/call_status/pull/61)

## [0.4.1] - 2020-12-12
### Changed
- Various tweaks to ESP behavior; most notably, flash all LEDs at startup (https://github.com/awseward/call_status/pull/54)
- Modify `people` table to be more amenable to tracking history; inspired by [this article](https://web.archive.org/web/20201125211840/http://www.revision-zero.org/logical-data-independence-2) (https://github.com/awseward/call_status/pull/55, https://github.com/awseward/call_status/pull/56, https://github.com/awseward/call_status/pull/57, https://github.com/awseward/call_status/pull/58)

### Fixed
- Correct some overlooked version incrementing (https://github.com/awseward/call_status/pull/53)

## [0.4.0] - 2020-07-28
### Added
- Introduce [shmig](https://github.com/mbucc/shmig) for migrations (https://github.com/awseward/call_status/pull/40)
- Enable ESP devices to follow redirects from Heroku app (https://github.com/awseward/call_status/pull/42)
- Messaging via https://patchbay.pub/ (https://github.com/awseward/call_status/pull/43)
- Messaging via MQTT (https://github.com/awseward/call_status/pull/51, https://github.com/awseward/call_status/pull/52)
- New endpoint: `/api/client/:clientId/up` (https://github.com/awseward/call_status/pull/45)
- Use separate pinned tasks on ESP devices for concurrency (https://github.com/awseward/call_status/pull/48)

### Changed
- Extract some utilities to [a separate repo](https://github.com/awseward/nim-junk-drawer) (https://github.com/awseward/call_status/pull/41)

### Removed
- Some deprecated endpoints (https://github.com/awseward/call_status/pull/46)

## [0.3.5] - 2020-05-22
### Fixed
- Pin version of automatic homebrew create Action (https://github.com/awseward/call_status/commit/7e484e859a0b79e78a11e14bd19e7c678b9425c0)

## [0.3.4] - 2020-05-22
### Added
- Web view now refreshes automatically via websockets if a status changes (https://github.com/awseward/call_status/pull/35)

### Fixed
- Ensure a directory exists before trying to write a file into it (https://github.com/awseward/call_status/pull/34)

## [0.3.3] - 2020-05-17
### Added
- Add `--info` flag which prints version _and_ revision (git SHA) (https://github.com/awseward/call_status/pull/29)
- Include contextual information in automated homebrew tap PRs (https://github.com/awseward/call_status/commit/1b3b388c897e4b96dc7e40527e74acadda257ae0)

## [0.3.2] - 2020-05-17
### Added
- Resolve compile-time source revision via env var, if provided (https://github.com/awseward/call_status/pull/25)
- Automate opening a PR into homebrew tap during release process (https://github.com/awseward/call_status/pull/26)

### Changed
- Modified `deprecations` module (https://github.com/awseward/call_status/pull/23)
- Temporarily skip a particular CI job (https://github.com/awseward/call_status/pull/27)

## [0.3.1] - 2020-05-17
### Added
- Print out help text if no args/flags/options given (https://github.com/awseward/call_status/pull/19)
- Get CI set up via GitHub Actions (https://github.com/awseward/call_status/pull/17, https://github.com/awseward/call_status/pull/20, https://github.com/awseward/call_status/pull/21)

## [0.3.0] - 2020-05-16
### Changed
- Binaries' names changed from `check_zoom` and `cli` to `call_status_checker`, `call_status_cli`, respectively (https://github.com/awseward/call_status/pull/16)
- Various other changes also included in https://github.com/awseward/call_status/pull/16

## [0.2.1] - 2020-05-16
### Changed
- Use env var `$DATABASE_FILEPATH` instead of `$DB_FILEPATH` (https://github.com/awseward/call_status/pull/15)
- Change person field from `user` to `name` (https://github.com/awseward/call_status/pull/15)

## [0.2.0] - 2020-05-15
### Changed
- Started tagging releases as opposed to simply operating off the main branch
