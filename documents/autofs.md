Installs and configures the Automounter facility.

↪ `attributes/autofs.rb`  
↪ `recipes/autofs.rb`  
↪ `templates/default/etc_auto.master.erb`  
↪ `tests/roles/sys_autofs_test.rb`  

**Attributes**

All attributes in `node.sys.autofs`

Each member of sys.autofs contains a hash an arbitrary string pointing to a list of directories as keys representing the mount points. 
For each entry an auto.master sniplet will be created in /etc/auto.master.d.
The values need to contain a `map` key pointing to the automounter map file and an optional `options` key.

**Example**

    "sys" => {
      "autofs" => {
        # written to /etc/auto.master.d/foo.autofs:
        "foo" => {
          "/path" => {
            "map" => "/etc/autofs/path.map",
            "options" => "--timeout=600"
          },
          "/foo" => {
            "map" => "/etc/autofs/foo.map"
          }
        },
        # written to /etc/auto.master.d/bar.autofs:
        "bar" => {
          "/path" => {
            "map" => "/etc/autofs/path.map"
          }
        }
      }
    }

