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
        "/path" => {
          "map" => "/etc/auto.master.d/map/path.map",
          "options" => "--timeout=600"
        },
        "/foo/bar" => {
           "map" => "/etc/auto.master.d/map/foo_bar.map"
        }
      }
    }

