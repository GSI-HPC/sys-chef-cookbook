# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## Unreleased
## [1.64.0]
### Added
- New recipe [`sys::firewall`](recipes/firewall.rb)
- New resource [`firewall`](resources/firewall_rule.rb)
- New resource [`firewall_rule`](resources/firewall_rule.rb)
- New attributes for configuring [`firewall`](attributes/firewall.rb)
- [`Documentation`](documents/firewall.md)
- Tests

### Changed
- Updated [documentation for `sys::pam`](documents/pam.md)
- Send chef-client output to logfile in systemd-timer mode (!39)

## [1.63.0] - 2022-02-07

### Added
- New recipe [`sys::linuxlogo`](recipes/linuxlogo.rb) for
  [linuxlogo banners](documents/linuxlogo.md) in text consoles

## [1.62.3] - 2022-02-02

### Changed
- Improved setup and testing of systemd-timer and service
  for chef-client
