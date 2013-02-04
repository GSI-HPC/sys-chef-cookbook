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



# Attributes and Recipes

The "sys" cookbook can be added to a nodes run-list anytime. **By default the cookbook doesn't deploy or configures anything.** The individual recipes will be automatically applied when the corresponding attributes are defined or the `sys_*` resources are called.

[APT](documents/apt.md)

### Repositories

Add APT repositories with individual files in the `/etc/apt/sources.list.d/` directory using the **`sys_apt_repository`** resource.

**Actions**

* `add` (default) writes a new APT repository configuration file.
* `remove` deletes an APT repository configuration file.

**Attributes:**

* `name` (name attribute) is the filename used for the configuration.
* `config` (required) to be written to the configuration file.

**Example**

Add unstable and remove experimental repositories:

    sys_apt_repository "unstable" do
      config "
        deb http://ftp.de.debian.org/debian/ unstable main
        deb-src http://ftp.de.debian.org/debian/ unstable main
      "
    end
    
    sys_apt_repository "experimental" do
      action :remove
    end

Alternatively use attributes in `node.sys.apt.repositories` to configure, e.g.:

    "sys" => {
      "apt" => {
        [...SNIP...]
        "repositories" => {
          "unstable" => "
            deb http://ftp.de.debian.org/debian/ unstable main
            deb-src http://ftp.de.debian.org/debian/ unstable main
          ",
          "experimental" => "
            deb http://ftp.de.debian.org/debian/ experimental main
            deb-src http://ftp.de.debian.org/debian/ experimental main
          "
        }
      }
    }

## Control Groups (cgroups)

Installs and configures Linux Control Groups.

↪ `attributes/cgroups.rb`  
↪ `recipes/cgroups.rb`  
↪ `templates/*/etc_cgconfig.conf.erb`  

**Attributes**

All attributes in `node.sys.cgroups`:

* `path` (required) defines the location to mount the
   cgroups file-system.
* `subsys` (optional) list of cgroup subsystems to mount
   (contains `cpuset`,`cpu`,`cpuacct` by default).

**Examples**

Mount cgroups at a given path and add a couple of subsystems:

    [...SNIP...]
    "sys" => {
      "cgroups" => {
        "path" => "/cgroup",
        "subsys" => [ "devices", "blkio", "net_cls" ]
      }
      [...SNIP...]
    }

Mount the memory subsystem (including kernel boot parameters):

    [...SNIP...]
    "sys" => {
      "boot" => {
        "params" => [
          [...SNIP...]
          "cgroup_enable=memory",
          "swapaccount"
        ]
      },
      "cgroups" => {
        "path" => "/sys/fs/cgroup",
        "subsys" => [ 'memory' ]
      },
      [...SNIP...]
    }


## Serial Console

Configures Init and Grub for a defined serial console.

↪ `attributes/serial.rb`  
↪ `recipes/serial.rb`  
↪ `templates/*/etc_default_grub.erb`  
↪ `templates/*/etc_inittab.erb`)  

**Attributes**

All attributes in `node.sys.serial`:

* `port` (required) port number for serial console.
* `speed` (optional) link speed.

**Example**

Enable serial console on port 1:

    [...SNIP...]
    "sys" => {
      "serial" => { "port" => 2 },
      [...SNIP...]
    }

## Boot Configuration

Alters the Grub configuration and **reboots the node** to
apply changes.

↪ `attributes/boot.rb`  
↪ `recipes/boot.rb`  
↪ `templates/*/etc_default_grub.erb`  
↪ `tests/roles/sys_boot_test.rb`  

**Attributes**

All attributes in `node.sys.boot`:

* `params` (optional) list of Linux kernel boot parameters.
* `config` (optional) additional configuration for Grub.


**Example**

Define a set of additional Linux kernel boot parameters:

    [...SNIP...]
    "sys" => {
      "boot" => {
        "params" => [ "noacpi", "panic=10" ]
      },
      [...SNIP...]
    }

## Kernel Modules

Load a Linux kernel module with `sys_module` followed by
the name of the module.

↪ `definitions/sys_module.rb`

    sys_module "ext3"

The module will be added to `/etc/modules`.

## Kernel Control (sysctl)

Set Linux kernel variables in `/etc/sysctl.d/` and load them
immediately.

↪ `attributes/control.rb`  
↪ `recipes/control.rb`  
↪ `tests/roles/sys_control_test.rb`  

**Attribute**

Requires the configuration of `node.sys.control` with a
structure representing the `sysctl` format (see example).

**Examples**

    [...SNIP...]
    "sys" => {
      "control" => {
        "net.ipv6" => { "conf.all.disable_ipv6" => 1 },
        "net.ipv6.conf.default" => {
          "autoconf" => 0,
          "router_solicitations" => 0,
          "accept_ra_rtr_pref" => 0
        },
        "net.ipv4" => {
          "icmp_echo_ignore_broadcasts" => 1,
          "ip_forward" => 0
        },
        "kernal" => {
          "exec-shield" => 1,
          "randomize_va_space" => 1
        },
        "vm" => { "zone_reclaim_mode" => 0  }
      },
      [...SNIP...]


## Network Interfaces

Configures the node network with individual files for each interface in  `/etc/network/interfaces.d/*`. Furthermore it creates a file `/etc/network/interfaces` to source all files within this directory.

↪ `attributes/network.rb`  
↪ `recipes/network.rb`  
↪ `files/*/etc_network_interfaces`  
↪ `templates/*/etc_network_interfaces.d_generic.erb`

**Attributes**

All attributes in `node.sys.network`:

* `interfaces` (required) is a hash with interface name as keys and its configuration as value. The interface configuration hash holds an `inet` key (default `manual`) also. Read the manuals `interfaces`, `vlan-interfaces` and `bridge-utils-interfaces`.
* `restart` (optional) default true. Networking is automatically restarted upon configuration change.

**Examples**

Configure a couple of NICs, a VLAN and a network bridge:

    "sys" => {
      "network" => {
        "interfaces" => {
          "eth0" => { "inet" => "dhcp" },
          "eth1" => {
            "inet" => "static",
            "address" => "10.1.1.4",
            "netmask" => "255.255.255.0",
            "broadcast" => "10.1.1.255",
            "gateway" => '10.1.1.1',
            "up" => "route add -net 10.0.0.0 netmask 255.0.0.0 gw 10.8.0.1",
            "down" => "down route del -net 10.0.0.0 netmask 255.0.0.0 gw 10.8.0.1"
          },
          "vlan1" => { "vlan_raw_device" => "eth0" },
          "br1" => { "bridge_ports" => "vlan1" }
        }
      }
      [...SNIP...]

## Sudo

Configures Sudo with files in the directory `/etc/sudoers.d/*` containing user,host, and command aliases as well as rules. Furthermore is creates a file `/etc/sudoers` to source all files within this directory.

↪ `attributes/sudo.rb`  
↪ `recipes/sudo.rb`  
↪ `definitions/sys_sudo.rb`  
↪ `templates/*/etc_sudoers.erb`  
↪ `templates/*/etc_network_sudoers.d_generic.erb`  
↪ `tests/roles/sys_sudo_test.rb`

**Resources**

The following code deploys a file called `/etc/sudoers.d/admin`.

    sys_sudo "admin" do
      users 'ADMIN' => ["joe","bob","ted"]
      rules(
        "ADMIN ALL = NOPASSWD: /usr/bin/chef-client",
        "ADMIN ALL = ALL"
      )
    end

It defining and `User_Alias` called "ADMIN" and a pair of rules for this group of users. Similar the following code deploys a file `/etc/sudoers.d/monitor` including `Cmnd_Alias`s and a single rule.

    sys_sudo "monitor" do
       commands(
         "IB" => [ "/usr/sbin/perfquery" ],
         "NET" => [ "/bin/netstat", "/usr/sbin/iftop", "/sbin/ifconfig" ]
       )
       rules "mon LOCAL = NOPASSWD: IB, NET"
    end

The `sys_sudo` resource supports `users`, `hosts`, `commands`, and `rules`.

**Attributes**

All attributes in `node.sys.sudo`:

* `users` (optional) defines a hash of user aliases.
* `hosts` (optional) defines a hash of host aliases.
* `commands` (optional) defines a hash of command aliases.
* `rules` (required) defines an array of rules.

Configure command execution for a group of administrators:

    "sys" => {
      "sudo" => {
        "admin" => {
          "users" => { "ADMIN" => ["joe","bob","ted"] },
          "rules" => [
            "ADMIN ALL = NOPASSWD: /usr/bin/chef-client",
            "ADMIN ALL = ALL"
          ]
        },
        "monitor" => {
          "commands" => {
            "IB" => [ "/usr/sbin/perfquery" ],
            "NET" => [ "/bin/netstat", "/usr/sbin/iftop", "/sbin/ifconfig" ]
          },
          "rules" => [ "mon LOCAL = NOPASSWD: IB, NET" ]
        },
        "users" => {
          "users" => { "KILLERS" => ["maria","anna"] },
          "hosts" => { "LAN" => ["10.1.1.0/255.255.255.0"] },
          "commands" => {
            "KILL" => [ "/usr/bin/kill", "/usr/bin/killall" ],
            "SHUTDOWN" => [ "/usr/sbin/shutdown", "/usr/sbin/reboot" ]
          },
          "rules" => [
            "KILLERS LOCAL = KILL",
            "%users LAN = SHUTDOWN"
          ]
        }
      }
    }

Furthermore some extra command for a monitoring user `mon`, and extra privileges for users.


## Time Configuration

Configure the system time and timezone.

↪ `attributes/time.rb`  
↪ `recipes/time.rb`  

**Attributes**

All attributes in `node.sys.time`:

* `zone` (optional) sets the system timezone.
* `servers` (optional) list of NTP servers (↪ `templates/*/etc_ntp.conf.erb`).

**Example**

Set the timezone to "Europe/Berlin" and a couple of NTP server are defined like:

    "sys" => {
      [...SNIP...]
      "time" {
        "zone" => "Europe/Berlin",
        "servers" => [
          "0.debian.pool.ntp.org",
          "1.debian.pool.ntp.org"
        ]
      },
      [...SNIP...]

## Network Service Switch

Configure the Network Service Switch (NSS) in the file `/etc/nsswitch.conf`.

Define an attribute `node.sys.nsswitch` containing a single string with the configuration, e.g.:

    "sys" => {
      "nsswitch" => "
        passwd:         files ldap
        group:          files ldap
        shadow:         files 
        hosts:          files dns ldap
        networks:       files ldap
        protocols:      db files
        services:       db files
        ethers:         db files
        rpc:            db files
        netgroup:       nis
      "
    }



## TCP Wrapper

Configure TCP wrapper with the files `/etc/hosts.allow` and `/etc/hosts.deny`.

↪ `attributes/hosts.rb`  
↪ `recipes/hosts.rb`  
↪ `templates/*/etc_hosts.allow.erb`  
↪ `templates/*/etc_hosts.deny.erb`  
↪ `tests/roles/sys_hosts_test.rb`

**Attributes**

All attributes in `node.sys.hosts`:

* `allow` (optional) is an array of rules.
* `deny` (optional) is an array of rules.

For example:

    "sys" => {
      "hosts" => {
        "deny" => [ "ALL: ALL"],
        "allow" => [
          "sshd: 10.1",
          "snmpd: 10.1.1.2"
        ]
      }
    }

## Domain Name Service Lookup

Configure Domain Name Service (DNS) resolution.

↪ `attributes/resolv.rb`  
↪ `recipes/resolv.rb`  
↪ `templates/*/etc_resolv.conf.erb`  

**Attributes**

All attributes in `node.sys.resolv`:


* `servers` (required) list a DNS server hosts.
* `domain` (optional) local domain name.
* `search` (optional) list for host-name lookup.

**Example**

    "sys" => {
      [...SNIP...]
      "resolv" => {
        "servers" => [ "10.1.1.1","10.1.1.2" ],
        "domain" => "devops.test",
        "search" => "sub.devops.test devops.test"
      }
    }

## Mail Relay (Postfix)

Configures Postfix to forward outgoing messages to a mail relay.

↪ `attributes/mail.rb`  
↪ `recipes/mail.rb`  
↪ `definitions/sys_mail_alias.rb`  

**Resource**

Add or change (Postfix) account to mail address aliases in
`/etc/aliases` with `sys_mail_alias`.


    sys_mail_alias "jdoe" do
      to "jdoe@devops.test"
    end

Note that you cannot remove aliases with this resource.

**Attributes**

All attributes in `node.sys.mail`:

* `relay` (required) defines the mail relay host FQDN.
* `aliases` (optional) hash of account name, mail address pairs.

For example:

    [...SNIP...]
    "sys" => {
      "mail" => {
        "relay" => "smtp.devops.test",
        "aliases => {
          "root" => jdoe@devops.test",
          "logcheck" => "root"
        }
      }
      [...SNIP...]

## PAM 

Configures Linux authentication modules (PAM).

↪ `attributes/pam.rb`  
↪ `recipes/pam.rb`  
↪ `templates/*/etc_security_limits.conf.erb`  
↪ `templates/*/etc_security_access.conf.erb`  
↪ `templates/*/etc_pam.d_generic.erb`  
↪ `tests/roles/sys_pam_test.rb`

**Attributes**

All attributes in `node.sys.pam`:

* `limits` holds an array of ulimits written to `/etc/security/limits.conf`.
* `access` holds an array of rules written to `/etc/security/access.conf`.

It is possible to write any file in the `/etc/pam.d/` directory using attributes in `node.sys.pamd`. The key needs to be called like the file to be altered (e.g. `common-session` or `common-auth`) and the value is a string containing the entire configuration. (A single string is used to prevent merge problems.)

For Example:

    "sys" => {
      "pam" => {
        "access" => [
          "+:devops:10.1.1.1 LOCAL",
          "+:ALL:.devops.test LOCAL",
          "+:ALL:LOCAL",
          "-:ALL:ALL" 
        ],
        "limits" => [
          "*    hard memlock unlimited",
          "*    soft memlock unlimited"
        ]
      },
      "pamd" => {
        "common-session" => "
          session [default=1]     pam_permit.so
          session requisite       pam_deny.so
          session required        pam_permit.so
          session required        pam_unix.so
        ",
        "common-auth" => "
          password [success=1 default=ignore] pam_unix.so obscure sha512
          password requisite                  pam_deny.so
          password required                   pam_permit.so
        "
      }
    }

## CA Certificates

The provider `sys_ca_certificate_file` deploys CA certificate container files.

↪ `resources/ca_certificate_file.rb`  
↪ `providers/ca_certificate_file.rb` 

**Actions**

* `:add` (default) deploy a certificate file from the cookbook.
* `:remove` deletes a certificate file.

**Attributes**

* `name` (name attribute) of the file to be deployed to `/usr/local/share/ca-certificates`.
* `source` is the basename of the file in the cookbook. (Uses the `cookbook_file` resource for deployment)

**Example**

Install a certificate container file to `/usr/local/share/ca-certificates/site.domain`

    sys_ca_certificate_file 'site.domain' do
      source 'site_ca_global_2012.crt'
    end

Remove a certificate file

    sys_ca_certificate_file 'ca-org.domain' do
      action :remove
    end

## SSH 

Configures the SSH daemon and deploys a list of SSH public keys
for a given user account.

↪ `attributes/ssh.rb`  
↪ `recipes/ssh.rb`  
↪ `definitions/sys_ssh_authorize.rb`  
↪ `tests/roles/sys_ssh_test.rb`  

**Resource**

Deploy SSH public keys for a given account in `~/.ssh/authorized_keys`

    sys_ssh_authorize "devops" do
      keys [
        "ssh-rsa AAAAB3Nza.....",
        "ssh-rsa AAAADAQAB....."
      ]
      managed true
    end

The name attribute is the user account name (here devops) where the list of `keys` will be deployed. The attribute `managed` (default false) indicates if deviating keys should be removed.

**Attributes**

Configure the SSH daemon using attributes in the hash `node.sys.sshd.config` (read the `sshd_config` manual for a list of all available key-value pairs). Note that when the daemon configuration is empty the original `/etc/ssh/sshd_config` file wont be modified.

All keys in `node.sys.ssh.authorize[account]` (where account is an existing user) have the following attributes:

* `keys` (required) contains at least one SSH public key per user account.
* `managed` (default false) overwrites existing keys deviating form the given list `keys` when true.

For example:

    [...SNIP...]
    "sys" => {
      "sshd" => {
        "config" => {
          "UseDNS" => "no",
          "X11Forwarding" => "no",
          [...SNIP...]
        }
      },
      "ssh" => {
        "authorize" => {
          "root" => {
            "keys" => [
              "ssh-rsa AAAAB3Nza.....",
              "ssh-rsa AAAABG4DF....."
            ],
            "managed" => true
          },
          "devops" => {
            "keys" => [
              "ssh-rsa AAAAB3Gb4.....",
            ]
          }
          [...SNIP...]
        }
      }
      [...SNIP...]

## Temporary Directories

Deploy a procedure to clean directories like `/tmp/`.

↪ `attributes/tmp.rb`  
↪ `recipes/tmp.rb`  
↪ `templates/*/tmpreaper.conf.erb`  
↪ `tests/roles/sys_tmp_test.rb`  

**Attributes**

All attributes in `node.sys.tmp`:

* `reaper` configures tmpreaper in `/etc/tmpreaper.conf` see manual.

Example:

    [...SNIP...]
    "sys" => {
      "tmp" => {
        "reaper" => {
          "max_age" => "8d",
          "protected_patterns" => [],
          "dirs" => ['/tmp/','/var/tmp'],
          "options" => '--runtime=1800'
        }
      }
      [...SNIP...]

## Login Banner

Display a static login message by creating `/etc/motd`.

↪ `attributes/banner.rb`  
↪ `recipes/banner.rb`  
↪ `templates/*/etc_motd.erb`  
↪ `templates/*/etc_profile.d_info.sh.erb`  
↪ `tests/roles/sys_banner_test.rb`  

**Attributes**

All attributes in `node.sys.banner`:

* `message` (required) text normally describing the purpose of the node.
* `header` (optional) text printed in front of the banner message.
* `footer` (optional) text printed after the banner message.
* `info` (default `true`) deploys a script in `/etc/profile.d/info.sh` displaying system statistics and information about the Chef deployment.

**Example**

A generic role for the infrastructure may contain global header and footer content.

    [...SNIP]
    default_attributes(
      "sys" => {
        "banner" => {
          "header" => "Welcome to Linux...",
          "footer" => "Report problems by sending mails to devops@localhost"
        }
        [...SNIP...]
      }
      [...SNIP...]
    )

For specific roles/nodes the message describes the hosts purpose.

    [...SNIP...]
    "sys" => {
      "banner" => {
        "message" => "Interactive login pool to huge compute cluster"
      }
      [...SNIP...]




## Shutdown

The provider `sys_shutdown` can be used to restart or power
down the node.

↪ `resources/shutdown.rb`  
↪ `providers/shutdown.rb`  

**Actions**

* `:shutdown` (default) executes sync and system shutdown.
* `:reboot` executes sync and system reboot.

**Attributes**

* `time` (name attribute) delays action, minutes or time e.g. 19:30.
* `message` optional broadcast message to the system users.

**Examples**

Reboot the system immediately:

    sys_shutdown "now" do
      action :reboot
    end

Shutdown systems in 20 minutes:

    sys_shutdown "20" do
      message "Hardware maintenance required. We apologize for trouble caused."
    end

Shutdown system at a given point in time:

    sys_shutdown "18:15"


# License

Copyright 2012 Victor Penso

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
