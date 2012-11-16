# Description

The "sys" Chef cookbook combines small configuration steps 
common to most Linux deployments, but not worth of writing 
a dedicated cookbook (since they would comprise only of a 
single recipe). Furthermore it defines resources commonly 
used by other cookbooks but not really related to a specific 
service other then Linux itself (e.g. system reboot or 
loading a Linux kernel module).

**Requirements**

* Chef version >= 10.12
* No dependencies to other cookbooks.

**Platforms**

* Debian (Wheezy)
* No other platforms supported yet.

# Definitions and Providers

## SSH Authorize

Deploy SSH public keys for a given account in `~/.ssh/authorized_keys`

↪ `definitions/ssh_authorize.rb`

    ssh_authorize "devops" do
      keys [
        "ssh-rsa AAAAB3Nza.....",
        "ssh-rsa AAAADAQAB....."
      ]
      managed true
    end

The name attribute is the user account name (here devops) 
where the list of `keys` will be deployed. The attribute
`managed` (default false) indicates if deviating keys should
be removed. 

## Linux Module

Load a Linux kernel module with `linux_module` followed by 
the name of the module.

↪ `definitions/linux_module.rb`

    linux_module "ext3"

The module will be added to `/etc/modules`.

## Mail Aliases

Add or change (Postfix) account to mail address aliases in 
`/etc/aliases` with `mail_alias`.

↪ `definitions/mail_alias.rb` 

    mail_alias "jdoe" do
      to "jdoe@devops.test"
    end

Note that you cannot remove aliases this this definition.

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

# Attributes and Recipes

The "sys" cookbook can be added to a nodes run-list 
anytime. **By default the cookbook doesn't deploy or
configures anything.** The individual recipes will
be automatically applied when the corresponding 
attributes are defined. 

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


## Kernel Control (sysctl)

Set Linux kernel variables in `/etc/sysctl.d/` and load them 
immediately.

↪ `attributes/control.rb`  
↪ `recipes/control.rb`

**Attribute**

Requires the configuration of `node.sys.control` with a 
structure representing the `sysctl` format (see example).

**Examples**

    [...SNIP...]
    "sys" => {
      "control" => {
        "net.ipv6" => { "conf.all.disable_ipv6" => 1 },
        "net.ipv4" => { 
          "icmp_echo_ignore_broadcasts" => 1,
          "ip_forward" => 0
        },
        "vm" => { "zone_reclaim_mode" => 0  }
      },
      [...SNIP...]

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


## Network Interfaces

Configures the node network with individual files for each interface in  `/etc/network/interfaces.d/*`. Fruthermore it create a file `/etc/network/interfaces` to source all wihtin the configuration directory 

↪ `attributes/network.rb`  
↪ `recipes/network.rb`  
↪ `files/*/etc_network_interfaces`   
↪ `templates/*/etc_network_interfaces.d_generic.erb`

**Attributes**

All attributes in `node.sys.network`:

* `interfaces` (required) is a hash with interface names as keys and the their configuration as values. The interface configuration hash holds an `inet` key (default `manual`) also. Read the manuals `interfaces`, `vlan-interfaces` and `bridge-utils-interfaces`.
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
     

## Domain Name Service Lookup

Configure domain name service resolution (↪ `recipes/resolv.rb` and `templates/*/etc_resolv.conf.erb`).

**Attributes**

All attributes in `node.sys.resolv` (↪ `attributes/resolv.rb`):

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

## Mail Delivery

Configures Postfix to forward outgoing messages to a mail relay (↪ `recipes/mail.rb`).

**Attributes**

All attributes in `node.sys.mail` (↪ `attributes/mail.rb`):

* `relay` (required) defines the mail relay host FQDN.
* `aliases` (optional) hash of account name, mail address pairs.

**Example**

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

## Remote Login

Configures the SSH daemon and deploys a list of SSH public keys 
for a given user account.

↪ `attributes/ssh.rb`  
↪ `recipes/ssh.rb`  
↪ `tests/roles/sys_ssh_test.rb`  

**Attributes**

Configure the SSH daemon using attributes in the hash 
`node.sys.sshd.config` (read the `sshd_config` manual for a list
of all available key-value pairs). Note that when the daemon 
configuration is empty the original `/etc/ssh/sshd_config` file
wont be modified.

All keys in `node.sys.ssh.authorize[account]` (where account
is an existing user) have the following attributes: 

* `keys` (required) contains at least one SSH public key per 
  user account.
* `managed` (default false) overwrites existing keys deviating 
  form the given list `keys` when true. 

**Example**

    [...SNIP...]
    "sys" => {
      "sshd" => { 
        "config" => {
          "UseDNS" => "no",
          "X11Forwarding" => "no"
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
        }
      }
      [...SNIP...]


## Login Banner

Display a static login message by creating `/etc/motd`.

↪ `attributes/banner.rb`  
↪ `recipes/banner.rb`  
↪ `templates/*/etc_motd.erb`  
↪ `templates/*/etc_profile.d_info.sh.erb`

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

# License

Copyright 2012 Victor Penso

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
