# Description

# Requirements


# Definitions

## Linux Module

Load a Linux kernel module with `linux_module` followed by the name of the module:

    linux_module "ext3"

The module will be added to `/etc/modules`.

# Resources and Providers

## Shutdown

The provider `sys_shutdown` can be used to restart or power down the node. 

**Actions**

* `:shutdown` (default) executes sync and system shutdown
* `:reboot` executes sync and system reboot

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

Installs and configures Linux Control Groups.

**Attributes**

All attributes in `node.sys.cgroups`:

* `path` (required) defines the location to mount the cgroups file-system.
* `subsys` list of cgroups subsystems to mount (contains `cpuset`,`cpu`,`cpuacct`).

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
          {...SNIP...]
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

Configures `/etc/inittab` and Grub for a defined serial console.

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

Alters the Grub configuration using `/etc/default/grub` and **reboots the node**.

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

Set Linux kernel variables in `/etc/sysctl.d/` and load them immediately.

**Attribute**

Requires the configuration of `node.sys.ctl` with a structure representing the `sysctl` format (see example). 

**Examples**

    [...SNIP...]
    "sys" => {
      "ctl" => {
        "net.ipv6" => { "conf.all.disable_ipv6" => 1 },
        "net.ipv4" => { 
          "icmp_echo_ignore_broadcasts" => 1,
          "ip_forward" => 0
        },
        "vm" => { "zone_reclaim_mode" => 0  }
      },
      [...SNIP...]

## Timezone

Configure the system timezone in `/etc/timezone`.

**Attributes**

The attribute `node.sys.timezone` (default UTC) sets the system timezone.

**Example**

    "sys" => {
      [...SNIP...]
      "timezone" => "Europe/Berlin",
      [...SNIP...]
    }


## Login Banner

Banner message printed at interactive login (in `/etc/motd`) 

**Attributes**

All attributes in `node.sys.banner`:

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


