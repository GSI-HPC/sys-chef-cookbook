# Chef cookbook `sys`

[![Pipeline Status](https://git.gsi.de/chef/cookbooks/sys/badges/master/pipeline.svg?ignore_skipped=true)](https://git.gsi.de/chef/cookbooks/sys/-/pipelines)
[![Code Climate](https://codeclimate.com/github/GSI-HPC/sys-chef-cookbook/badges/gpa.svg)](https://codeclimate.com/github/GSI-HPC/sys-chef-cookbook)

## Description

The "sys" cookbook helps integrating a (Debian) node into an enterprise computing infrastructure.
It configures various services in a single cookbook eg. apt repositories,
automount, NTP, IPMI BMCs, postfix, SNMP, aso.
*But* it concentrates on client setup and does not configure the respective central services.

**Requirements**

* Chef version >= 12
* The `chef-vault` cookbook

**Platforms**

The "sys" cookbook development is focussed on Debian GNU/Linux.
Debian derivatives like Ubuntu usually work (with minor tweaks).

* Supported flavors:
  - Debian
    - 7 (_Wheezy_) (with Chef client > 12.0) [**deprecated**]
    - 8 (_Jessie_) (with Chef client > 12.0) [**deprecated**]
    - 9 (_Stretch_) (with Debian-packaged Chef client 12.14)
    - 10 (_Buster_) (with Debian-packaged Chef client 13.8)
    - 11 (_Bullseye_) (with latest Cinc client)
    - 12 (_Bookworm_) (with latest Cinc client)
    - Testing (_Trixie_) (with latest Cinc client)

  - Ubuntu
    - 18.04 (_Bionic_) (with Ubuntu-packaged Chef client 12.14)
    - 20.04 (_Focal_) (with Ubuntu-packaged Chef client 15.8)
    - 22.04 (_Jammy_) [*work in progress*]

The sys cookbook is partially operable and occassionally tested with
Debian Testing as well as
CentOS7, CentOS Stream 8, Alma Linux 8 and Cumulus Linux.

## Usage

The "sys" cookbook can be added to a nodes run-list anytime.
**By default the cookbook does not deploy or configure anything.**
The individual recipes are only activated by defining the corresponding
attributes.

The `sys_*` resources can be invoked directly
from wrapper cookbooks.

### Recipes

* [apt](documents/apt.md) – Configure APT in `/etc/apt/apt.conf.d/`,
  set APT preferences in `/etc/apt/preferences.d`,
  define package repositories in `/etc/apt/sources.list.d` and
  manage the APT keyring.
* [autofs](documents/autofs.md) – Setup automatic mounting of NFS servers in
  `/etc/auto.master.d/`. Supports setup to read automounter maps from LDAP.
* [banner](documents/banner.md) – Sets a welcome message displayed at login.
* [boot](documents/boot.md) – Set Grub boot parameters in `/etc/default/grub`.
* [control](documents/sysctl.md) (`sysctl`) – Define kernel variables in `/etc/sysctl.d/`.
* [directory](documents/directory.md) – Provides an attribute interface to the directory resource.
* [fuse](documents/fuse.md) – Setup FUSE in `/etc/fuse.conf`.
* [hosts](documents/hosts.md) – Local `/etc/hosts`, `/etc/hosts.allow`, and `/etc/hosts.deny` configuration.
* [krb5](documents/krb5.md) – Use Kerberos to manage credential security (authentication).
* [ldap](documents/ldap.md) – Connect to a local LDAP account management (authorization) by configuring `/etc/ldap/ldap.conf`.
* [modules](documents/modules.md) – Load kernel modules.
* [network](documents/interfaces.md) – Setup the local network in `/etc/network/interfaces.d/`.
* [nis](documents/nis.md) – Connect to local NIS servers by configuring `/etc/yp.conf`.
* [nsswitch](documents/nsswitch.md) – Manage `/etc/nsswitch.conf`.
* [mail](documents/mail.md) – Forward mails to an mail relay with Postfix.
* [pam](documents/pam.md) – Configure the authentication modules in `/etc/pam.d/`.
* [resolv](documents/resolv.md) – Adjust `/etc/resolve.conf` to lookup at your site DNS server.
* [route](documents/route.md) – Configure routeing by attributes.
* [serial](documents/serial.md) – Configure `/etc/inittab`.
* [ssh](documents/ssh.md) – Configure the SSH daemon and deploy/manage authorized keys.
* [ssl](documents/ssl.md) – Distribute SSL certs and keys via data bags and chef-vault.
* [sudo](documents/sudo.md) – Add Sudo privileges to `/etc/sudoers.d/`.
* [time](documents/time.md) – Connect to site NTP server and set local time zone.
* [tmp](documents/tmp.md) – Deploy [Tmpreaper][reaper] to clean directories like `/tmp/`.

### Resources
* [`nftables`](documents/resources/nftables.md)
* [`nftables_rule`](documents/resources/nftables_rule.md)
* [`sys_x509_certificate`](documents/resources/sys_x509_certificate.md)
* [`sys_ca_certificates`](documents/ca_certificates.md) – Install/remove CA certificates.
* [`sys_shutdown`](documents/shutdown.md) – Resource to restart and power down the node at a defined time.

[reaper]: http://packages.debian.org/search?keywords=tmpreaper

## Library

The `Sys::Secret` enables [transport of encrypted data between nodes](documents/secret.md)
using the private/public key infrastructure of Chef.
This functionality is deprecated
in favor of [chef-vault](https://docs.chef.io/workstation/chef_vault).

## Motivation

**Why writing a cookbook like "sys"?**

The general philosophy for writing cookbooks is to implement a specific service (e.g. Syslog, SNMP, OpenSSH, NTP) or system component (e.g. PAM, Sudo, Limits) within a single cookbook. For a community cookbook, where it is the goal to be platform independent, as generic as possible and cross-infrastructure sharable, this makes absolute sense. Unfortunately this approach in the most cases leads to a very complex dependency hierarchy with roles including dozens of cookbooks (with specific version) and a deep attributes structure, just to integrate a node into your environment. The "sys" cookbook is basically the opposite approach, implement everything for a basic integration of a node into the site infrastructure within a single cookbook. As soon as a node is integrated by the "sys" cookbook only a very limited number of cookbooks should be required to deploy the service the machine is intended to host.

**Focus on the Client-Side**

For example the "sys" cookbook is capable to deploy a mail relay configuration in order to enable all machines part of the infrastructure to send mails to an MTA. Get the right package and do minor changes to the configuration. Very easy, a couple of lines of code. This means 99% of all nodes will never see a dedicated cookbook related to mail. In order to deploy an MTA server a Postfix/Sendmail cookbook will be needed, but only on a handful of nodes. This approach is different to almost all Chef cookbooks you will find out there. Server and client deployment is usually within a single cookbook, and this is the right way to implement it (from a single cookbook's perspective). Mostly 90% (if not more) of the code part of a cookbook used to deploy a service is dedicated to the server side. Many services common in bigger computing infrastructures like NIS/LDAP, Mail, DNS, Samba, NFS, etc. have very complex server-side configuration, and logically nearly trivial client side setup. The "sys" cookbook approach removes dependencies to cookbooks including the server deployment.

**Minimize Dependencies**

Cookbooks like `timezone`,`resolv` or `ntp` consist of a single recipe with a handful of attributes. The "sys" cookbook approach wants to remove dependencies to trivial cookbooks for simplicity. More complex cookbooks for system component configurations like PAM or Sudo have a light-weight implementation in the "sys" cookbook also. Since in big clusters these things tend to be relatively homogeneous for the majority of machines and tend to be more comprehensive on a small number of user-facing nodes.

**Design Principles**

1. Reduce cookbook dependencies to one for the integration of all nodes into the environment on a site.
2. **No changes by default!** This means unless attributes are set, no deployment and configuration happens. Lets say the boot configuration which the "sys" cookbook is capable of deploying with attributes in `node.sys.boot` doesn't match the needs for a specific node, you are still free to use a more general `grub` cookbook or even a `site-grub` cookbook.
3. The **"sys" cookbook doesn't deploy the server-side of services**. It configures a node to use a mail relay, but doesn't install a mail-server.
4. The name of **a definition is prefixed with `sys_`** to prevent name space collision with other cookbooks.
5. Attributes defined with `default_unless` in the `attributes/` directory.

## Authors

* Sergey Boldyrev
* Matteo Dessalvi
* Stefan Haller
* Christopher Huhn
* Gabriele Iannetti
* André Kerkhoff
* Dennis Klein
* Ilona Neis
* Bastian Neuburger
* Matthias Pausch
* Victor Penso
* Thomas Roth
* Christian Tacke

## Copyright and License

Copyright:: 2012-2022 [GSI Helmholtzzentrum fuer Schwerionenforschung GmbH](https://gsi.de)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
