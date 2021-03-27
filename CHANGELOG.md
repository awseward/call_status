# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.2] - 2021-03-27
### Fixed
- Corrected project `nimble` file; forgot to increment its version before tagging `0.6.1`.

## [0.6.1] - 2021-03-27
### Changed
- DB file for `call_status_checker` now defaults to `$XDG_DATA_HOME/call_status/checker.db` (https://github.com/awseward/call_status/pull/118)
- Upgraded `nim` version `1.4.2 → 1.4.4` (https://github.com/awseward/call_status/pull/117)

## [0.6.0] - 2021-03-26
### Changed
- Config file for `call_status_checker` now defaults to `$XDG_CONFIG_HOME/call_status/checker.conf.json` (https://github.com/awseward/call_status/pull/116)
- Fixed a minor bug with the ESP startup LED sequence (https://github.com/awseward/call_status/pull/114)
- Updated docs to reflect that a previously-planned features is now implemented (https://github.com/awseward/call_status/pull/113)
- Upgraded `argparse` dependency `0.10.1 → 2.0.0` (https://github.com/awseward/call_status/pull/115)

## [0.5.1] - 2021-03-10
### Added
- Diagram in README giving a high-level overview of how everything works (https://github.com/awseward/call_status/pull/109, https://github.com/awseward/call_status/pull/110)
- Support for a "control" MQTT topic; currently allows broadcasting a "reboot" signal over MQTT to all ESP devices (https://github.com/awseward/call_status/pull/111, https://github.com/awseward/call_status/pull/112)

### Changed
- RPi script which consumes ESP heartbeats now adds timestamps (https://github.com/awseward/call_status/pull/108)

## [0.4.12] - 2021-03-10
#### TODO: Backfill details

## [0.4.11] - 2021-01-18
#### TODO: Backfill details

## [0.4.10] - 2021-01-05
#### TODO: Backfill details

## [0.4.9] - 2020-12-31
#### TODO: Backfill details

## [0.4.8] - 2020-12-31
#### TODO: Backfill details

## [0.4.7] - ????-??-??
#### Mysteriously, nowhere to be found

## [0.4.6] - 2020-12-28
#### TODO: Backfill details

## [0.4.5] - 2020-12-28
#### TODO: Backfill details

## [0.4.4] - 2020-12-28
#### TODO: Backfill details

## [0.4.3] - 2020-12-15
#### TODO: Backfill details

## [0.4.2] - 2020-12-13
#### TODO: Backfill details

## [0.4.1] - 2020-12-12
#### TODO: Backfill details

## [0.4.0] - 2020-07-28
#### TODO: Backfill details

## [0.3.5] - 2020-05-22
#### TODO: Backfill details

## [0.3.4] - 2020-05-22
#### TODO: Backfill details

## [0.3.3] - 2020-05-17
#### TODO: Backfill details

## [0.3.2] - 2020-05-17
#### TODO: Backfill details

## [0.3.1] - 2020-05-17
#### TODO: Backfill details

## [0.3.0] - 2020-05-16
#### TODO: Backfill details

## [0.2.1] - 2020-05-16
#### TODO: Backfill details

## [0.2.0] - 2020-05-15
#### TODO: Backfill details
