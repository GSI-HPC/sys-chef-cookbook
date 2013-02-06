Installs and configures the Network Information service (NIS).

↪ `attributes/nis.rb`  
↪ `recipes/nis.rb`  
↪ `templates/default/etc_yp.conf.erb`  
↪ `tests/roles/sys_nis_test.rb`  

**Attributes**

All attributes in `node.sys.nis`:

* `servers` (required) contains the list of NIS servers.
* `domain` (optional) defines the NIS domain  (the DNS domain is used by default).
* `nscd.enable` (default `false`) starts the Name Server Cache Daemon (NSCD).

**Example**

    "sys" => {
      "nis" => {
        "servers" => [ 
          "lxnis01.devops.test", 
          "lxnis02.devops.test" 
        ]
      },
      "nscd" => {
        "enable" => true
      }
    }

