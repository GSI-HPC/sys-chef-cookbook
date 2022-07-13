# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## Unreleased

### Changed
- [`sys::systemd`] [documentation update](documents/systemd.md)
- [`resource::nftables`] [documentation update](documents/resources/nftables.md)
- [`resource::nftables_rule`] [documentation update](documents/resources/nftables_rule.md)

## [1.69.0] - 2022-07-07

### Added
- [`sys::ssl`] New custom resource [`sys_x509_certificate`](documents/resources/sys_x509_certificate.md) for deployment of SSL certificates

## [1.68.0] - 2022-07-05

### Changed
- [`sys::chef`] prevent startup of `chef-client.service` in systemd-timer mode while `dpkg` is running.

### Fixed
- [`sys::snmp`] proper systemd detection instead of shaky Debian version heuristic.

### Added
- [`sys::systemd`] Support for configuration of `systemd-journald` via attributes

## [1.67.1] - 2022-06-09

### Added
- New Ohai plugin [`sysctl.rb`](files/default/ohai_plugins/sysctl.rb) added to collect
  information on sysctl settings

## [1.67.0] - 2022-06-08

### Changed
- Ohai plugin [`dpkg.rb`](files/default/ohai_plugins/dpkg.rb) now extends `node['packages']`

### Removed
- Package information is no longer collected beneath `node['debian']['packages']`

## [1.66.1] - 2022-05-18

### Added
- Ohai plugin [`dpkg.rb`](files/default/ohai_plugins/dpkg.rb) now also collects
  information on architecture and source package name of installed packages

## [1.66.0] - 2022-05-05

### Changed
- Use a more modern approach for the `firewall` and `firewall_rule` resources.
- No attributes to configure the `firewall` or `firewall_rule` resources
- No default recipe
- Rename the resources to `nftables` and `nftables_rule`.

## [1.65.1] - 2022-05-04

### Changed
- Revised the [README](README.md)

## [1.65.0] - 2022-04-29

### Added
- [`sys::ssh`] [Manage `/etc/ssh/ssh_known_hosts`](https://git.gsi.de/chef/cookbooks/sys/-/merge_requests/44)

## [1.64.3] - 2022-04-27

### Added
- Ubuntu 20.04 *focal* added as test platform
- [`sys::chef`] Detect Chef system installation following the latest Ruby packaging schema
  on Ubuntu Focal

### Fixed
- Improved error handling in `sys::accounts`

## [1.64.2] - 2022-03-28

### Added
- Support for Arrays of CIDRs in firewall rules

### Fixed
- Firewall rule for outgoing SSH setup

## [1.64.1] - 2022-03-28

### Fixed
- Firewall ruleq for established connections rearranged

## [1.64.0]

### Added
- New recipe [`sys::firewall`](recipes/firewall.rb)
- New resource [`firewall`](resources/firewall_rule.rb)
- New resource [`firewall_rule`](resources/firewall_rule.rb)
- New attributes for configuring [`firewall`](attributes/firewall.rb)
- [`Documentation`](documents/firewall.md)
- Tests

## [1.63.1] - 2022-02-28

## Changed
- Updated [documentation for `sys::pam`](documents/pam.md)
- Send chef-client output to logfile in systemd-timer mode (!39)
- Shorter PGP key for `apt-key` test - goodbye fefe (!41)
- Catch missing home dir write permissions in `sys_ssh_authorize`

## [1.63.0] - 2022-02-07

### Added
- New recipe [`sys::linuxlogo`](recipes/linuxlogo.rb) for
  [linuxlogo banners](documents/linuxlogo.md) in text consoles

## [1.62.3] - 2022-02-02

### Changed
- Improved setup and testing of systemd-timer and service
  for chef-client
