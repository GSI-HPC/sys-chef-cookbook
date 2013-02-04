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

