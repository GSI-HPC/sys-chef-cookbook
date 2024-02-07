# `sys` Cookbook Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [2.3.0] - 2024-02-07

### Added
- [helpers] Fix verification of systemd units in `chroot`s (by skipping verification) cf. !47

### Fixed
- [`ldap`] Explicitly install `libldap-common` (where it is available, cf. #43)

### Changed
- [helpers] Give credit to cinc in `template_header()` where it is due
- [`systemd`] Delete `ifupdown` interface definitions in a more Cheffy way
              (that should create backups)
- [`time`] NTP removed in favor of NTPSEC in Debian Bookworm

## [2.2.0] - 2023-06-26

### Changed
- [`krb5`] Do not use realm when asking for keytabs from wallet server

## [2.1.0] - 2023-03-29

### Changed
- [`rsyslog`] Refactor loghost configuration to allow configuration of multiple loghosts
  with different filters and/or log protocols

## [2.0.3] - 2023-03-23

### Fixed
- [`chef`] Don't link /etc/chef to /etc/chef

## [2.0.2] - 2023-03-22

### Fixed
- [`resource::sys_mail_alias`]
  * Only converge if the resource actually changed (fixes #40)
  * Don't fail on `:remove` action if the aliases file does not exist (fixes #39)

## [2.0.1] - 2023-03-10

### Fixed
- [`autofs`] Invoke `sys_nsswitch` the proper way
- [`chef`] systemd-timer mode requires chef-client >= 12.11
- [`ldap`] Don't explicitly install `libldap-common`: Does not exist on Jessie, implicitly installed elsewhere
- [`resolv`] Do not define an empty default_unless for `node['sys']['resolv']['servers']`
- [`resources/x509_certificate`] Gracefully handle load error of chef-vault

## **[2.0.0]** - 2023-03-09

- **Support for Debian Bullseye and cinc-client (omnibus)**
- Drop dependency on `line` cookbook
- [`chef`] Detect `ChefUtils::Dist::Infra::SHORT` and install to `/etc/cinc` if appropriate
- [`nsswitch`] Use new custom resource following accumulator pattern (cf. !32)
- [`resource::sys_mail_alias`] Replace `line` resources with `Chef::Util::FileEdit`

## [1.72.2] - 2023-02-28

### Added
- [`resources/x509_certificate`] Add info where keys are coming from to loglevel info.

## [1.72.1] - 2023-01-20

### Changed
- [`libraries/sys_helpers_nftables`] Debugging output removed.

## [1.72.0] - 2023-01-19

### Added
- [`libraries/sys_helpers_nftables`] Add support for multiple actions in nftables rules.

## [1.71.1] - 2023-01-19

### Changed
- [`chef`] Rename service unit to `chef-client-oneshot.service` when configuring in systemd-timer mode

## [1.71.0] - 2023-01-16

### Added
- [`resource::nftables_rule`] Handle unknown protocols

## [1.70.1] - 2022-12-10

### Changed
- [`resource::nftables_rule`] handles arbitrary strings correctly

## [1.70.0] - 2022-12-09

### Added
- [`sys::fail2ban`] New recipe to [install and configure fail2ban](documents/fail2ban.md)

### Changed
- [kitchen] Pin net-ssh gem in serverspec test suite installation for Ruby 2.5
  compatibility.

## [1.69.7] - 2022-12-09

### Changed
- [`resource::nftables_rule`] allows arbitrary strings as source and
  destination, so that named sets may be used

## [1.69.6] - 2022-12-06

### Changed
- [`resource::nftables`] deploys default rules, if no rules are provided.

## [1.69.5] - 2022-10-12

### Changed
- [`sys::apt`] `ignore_failure` when running `dpkg --configure -a`  
  This is a workaround for Stretch→Buster upgrade issues
  when chef-client is configured for systemd-timer mode  :
  postinst script of chef restarts chef-client.service  
  which triggers chef-client run  
  which triggers `dpkg --configure -a`  
  which fails because dpkg started the whole thing and is locked

## [1.69.4] - 2022-09-20

### Fixed
- [`sys_x509_certificate`] Fix resource name when called from other cookbooks (cf. !52)

## [1.69.3] - 2022-09-08

### Fixed
- [`sys::snmp`] Fix snmpd systemd unit startup type (cf !51)

## [1.69.2] - 2022-08-10

### Added
- [`sys::multipath`] Add option to disable multipathd service and add test suite

## [1.69.1] - 2022-07-19

### Changed
- [`sys::systemd`] [documentation update](documents/systemd.md)
- [`resource::nftables`] [documentation update](documents/resources/nftables.md)
- [`resource::nftables_rule`] [documentation update](documents/resources/nftables_rule.md)

### Fixed
- [`sys::chef`] reverted 59794a47a0 due to unexpectedly different lockfile handling of `dpkg` and `apt`,
                replacement with `lockfile-check` not working due to systemd being too old for `ExecCondition`

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
