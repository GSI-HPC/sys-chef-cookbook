Installs and configures the Automounter facility.

↪ `attributes/autofs.rb`  
↪ `recipes/autofs.rb`  
↪ `templates/default/etc_auto.master.erb`  
↪ `tests/roles/sys_autofs_test.rb`  

**Attributes**

All attributes in `node.sys.autofs`

The `master` attribute contains a hash with a list of directories
as keys representing the mount points. The values need to contain
a `map` key pointing to the automounter map file and an optional
`options` key.

**Example**

    "sys" => {
      "autofs" => {
        "master" => {
          "/path" => {
            "map" => "/etc/autofs/path.map",
            "options" => "--timeout=600"
          },
          "/foo" => {
            "map" => "/etc/autofs/foo.map"
          }
        }
      }
    }

