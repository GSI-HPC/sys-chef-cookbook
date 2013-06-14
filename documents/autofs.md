Installs and configures the Automounter facility.

↪ `attributes/autofs.rb`  
↪ `recipes/autofs.rb`  
↪ `templates/default/etc_auto.master.d_generic.erb`  
↪ `tests/roles/sys_autofs_test.rb`  

**Attributes**

The attribute `node.sys.autofs` contain keys of paths to be mounted. The values needs to contain a `map` key pointing to the automounter map file and an optional `options` key.

**Example**

    "sys" => {
      "autofs" => {
        "maps" => {
          "/path" => {
            "map" => "/etc/autofs/autofs.map1",
            "options" => "--timeout=600"
          },
          "/foo/bar" => {
             "map" => "/path/to/autofs.map2"
          }
        }
      }
    }

