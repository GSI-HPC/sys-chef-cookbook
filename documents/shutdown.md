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

