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

# Attributes and  Usage

## System Login Banner

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


