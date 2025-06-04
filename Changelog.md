# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2025-06-01
### Added
- Initial version of `minidust`


## [0.1.1] - 2025-06-01
### Added
- Color-coded terminal output
- Changelog


## [0.1.2] - 2025-06-01
### Added
- Usage section of readme
- Wrapper for minidust - now you can just add Minidust.enable! to your test_helper

## [0.1.3] - 2025-06-02
### Added
- Add ability to run minidust on a specific file - you can run `minidust <filename>`. This will execute the test file and show coverage.

## [0.1.4] - 2025-06-02
### Added
- Update README
- Add ability to run minidust cli command on multiple files - you can run `minidust <filename_1> <filename_2>`

## [0.1.5] - 2025-06-02
### Added
- Update README
- Each minidust cli process now runs with its own pid. Thus giving file coverage for the file being tested and not an overall file coverage score.

## [0.1.6] - 2025-06-03
### Added
- Update README
- Added a default minidust.yml - you can override which paths are to be included and excluded in your coverage
- Added unused methods to minidust coverage report