# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.3.0] - 2017-08-07

### Changed

- Fix bug in json_generate_decrement_depth which would lead to
  generating invalid JSON, thanks to Travis Smith
- To stop the above happening in future, add a test suite
- Add an unused backend to the Fastly service to avoid a new error

## [0.2.1] - 2017-03-30

### Changed

- Removed unnecessary capturing in two regular expressions. No external
  changes.

## [0.2.0] - 2017-03-29

### Added

- This Change log

### Changed

- No longer escape solidus, as it is not strictly required by the JSON
  specification.

## [0.1.0] - 2017-03-14

- Initial release
