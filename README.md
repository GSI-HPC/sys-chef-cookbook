# Description

The "sys" cookbook integrates a node into the site-infrastructure.

**Requirements**

* Chef version >= 10.12
* No dependencies to other cookbooks.

**Platforms**

* Debian (Wheezy)
* No other platforms supported yet.

# Motivation

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

# Usage

The "sys" cookbook can be added to a nodes run-list anytime. **By default the cookbook doesn't deploy or configures anything.** The individual recipes will be automatically applied when the corresponding attributes are defined or the `sys_*` resources are called.

* [APT](documents/apt.md) – Configure APT in `/etc/apt/apt.conf.d/`, set APT preferences in `/etc/apt/preferences.d`, define package repositories in `/etc/apt/sources.list.d` and manage the APT keyring.
* [Control Groups](documents/cgroups.md) – Define `cgroups` in `/etc/cgconfig.conf` and load sub-systems.
* [Serial Console](documents/serial.md) – Configure `/etc/inittab`.
* [Boot Configuration](documents/boot.md) – Set Grub boot parameters in `/etc/default/grub`.
* [Modules](documents/modules.md) – Load kernel modules.
* [System Control](documents/sysctl.md) (`sysctl`) – Define kernel variables in `/etc/sysctl.d/`.
* [Network Interfaces](documents/interfaces.md) – Setup the local network in `/etc/network/interfaces.d/`.
* [Sudo](documents/sudo.md) – Add Sudo privileges to `/etc/sudoers.d/`.
* [Time Configuration](documents/time.md) – Connect to site NTP server and set local time zone. 
* [Network Service Switch](documents/nsswitch.md) – Overwrite `/etc/nsswitch.conf`.
* [NIS](documents/nis.md) – Connect to local NIS servers by configuring `/etc/yp.conf`.
* [LDAP](documents/ldap.md) – Connect to a local LDAP account management (authorization) by configuring `/etc/ldap/ldap.conf`.
* [Kerberos](documents/krb5.md) – Use Kerberos to manage credential security (authentication).
* [TCP Wrapper](documents/hosts.md) – Local `/etc/hosts`, `/etc/hosts.allow`, and `/etc/hosts.deny` configuration.
* [DNS Resolution](documents/resolv.md) – Adjust `/etc/resolve.conf` to lookup at your site DNS server.
* [Mail Relay](documents/mail.md) – Forward mails to an mail relay with Postfix. 
* [PAM](documents/pam.md) – Configure the authentication modules in `/etc/pam.d/`.
* [CA Certificates](documents/ca_certificates.md) – Install/remove CA certificates.
* [SSH](documents/ssh.md) – Configure the SSH daemon and deploy/manage authorized keys.
* [AutoFS](documents/autofs.md) – Setup automatic mounting of NFS servers in `/etc/auto.master.d/`.
* [FUSE](documents/fuse.md) – Setup FUSE in `/etc/fuse.conf`.
* [Temporary Directories](documents/tmp.md) – Deploy [Tmpreaper][reaper] to clean directories like `/tmp/`.
* [Login Banner](documents/banner.md) – Sets a welcome message displayed at login. 
* [Shutdown](documents/shutdown.md) – Resource to restart and power down the node at a defined time.

# Library

The `Sys::Secret` enables [transport of encrypted data between nodes](documents/secret.md) using the private/public key infrastructure of Chef. 


[reaper]: http://packages.debian.org/search?keywords=tmpreaper


# License

Copyright 2012-2013 Victor Penso

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
