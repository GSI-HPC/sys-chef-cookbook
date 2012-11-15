# Description

The "sys" Chef cookbook combines small configuration steps common to most Linux deployments, but not worth of writing a dedicated cookbook (since they would comprise only of a single recipe). Furthermore it defines resources commonly used by other cookbooks but not really related to a specific service other then Linux itself (e.g. system reboot or loading a Linux kernel module).

**Requirements**

* Chef version >= 10.12
* No dependencies to other cookbooks.

**Platforms**

* Debian (Wheezy)
* No other platforms supported yet.

# Definitions and Providers

## Linux Module

Load a Linux kernel module with `linux_module` followed by the name of the module (↪ `definitions/linux_module.rb`):

    linux_module "ext3"

The module will be added to `/etc/modules`.

## Mail Aliases

Add or change (Postfix) account to mail address aliases in `/etc/aliases` with `mail_alias` (↪ `definitions/mail_alias.rb`) like:

    mail_alias "jdoe" do
      to "jdoe@devops.test"
    end

Note that you cannot remove aliases this this definition.

## Shutdown

The provider `sys_shutdown` can be used to restart or power down the node (↪ `resources/shutdown.rb` and `providers/shutdown.rb`). 

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

## Control Groups (cgroups)

Installs and configures Linux Control Groups (↪ `recipes/cgroups.rb` and `templates/*/etc_cgconfig.conf.erb`).

**Attributes**

All attributes in `node.sys.cgroups` (↪ `attributes/cgroups.rb`):

* `path` (required) defines the location to mount the cgroups file-system.
* `subsys` (optional) list of cgroup subsystems to mount (contains `cpuset`,`cpu`,`cpuacct` by default).

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

Mount a the memory subsystem (including kernel boot parameters):

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

Configures Init and Grub for a defined serial console (↪ `recipes/serial.rb`, `templates/*/etc_default_grub.erb` and `templates/*/etc_inittab.erb`).

**Attributes**

All attributes in `node.sys.serial` (↪ `attributes/serial.rb`):

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

Alters the Grub configuration and **reboots the node** to apply changes (↪ `recipes/boot.rb` and `templates/*/etc_default_grub.erb`).

**Attributes**

All attributes in `node.sys.boot` (↪ `attributes/boot.rb`):

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

Set Linux kernel variables in `/etc/sysctl.d/` and load them immediately (↪ `recipes/control.rb`).

**Attribute**

Requires the configuration of `node.sys.control` with a structure representing the `sysctl` format (see example) (↪ `attributes/control.rb`). 

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

Configure the system time and timezone (↪ `recipes/time.rb`).

**Attributes**

All attributes in `node.sys.time` (↪ `attributes/time.rb`):

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

## Login Banner

Banner message printed at interactive login (↪ `recipes/banner.rb` and `templates/*/etc_motd.erb`).

**Attributes**

All attributes in `node.sys.banner` (↪ `attributes/banner.rb`):

* `message` (required) text normally describing the purpose of the node.
* `header` (optional) text printed in front of the banner message.
* `footer` (optional) text printed after the banner message.

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
