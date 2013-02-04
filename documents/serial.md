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

