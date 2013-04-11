Configure FUSE in `/etc/fuse.conf`

↪ `attributes/fuse.rb`  
↪ `recipes/fuse.rb`  
↪ `templates/*/etc_fuse.conf.erb`  
↪ `tests/roles/sys_fuse_test.rb`

**Attributes**

All attributes in `node.sys.fuse.config`.

For example:

    "sys" => {
      "fuse" => {
        "config" => {
          "mount_max" => 1000,
          "user_allow_other" => ""
        }
      }
    }

