Installs and configures Linux Control Groups.

↪ `attributes/cgroups.rb`  
↪ `recipes/cgroups.rb`  
↪ `templates/*/etc_cgconfig.conf.erb`  

**Attributes**

All attributes in `node.sys.cgroups`:

* `path` (required) defines the location to mount the
   cgroups file-system.
* `subsys` (optional) list of cgroup subsystems to mount
   (contains `cpuset`,`cpu`,`cpuacct` by default).

**Examples**

Mount cgroups at a given path and add a couple of subsystems:

    [...SNIP...]
    "sys" => {
      "cgroups" => {
        "path" => "/cgroup",
        "subsys" => [ "devices", "blkio", "net_cls" ]
      }
      [...SNIP...]
    }

Mount the memory subsystem (including kernel boot parameters):

    [...SNIP...]
    "sys" => {
      "boot" => {
        "params" => [
          [...SNIP...]
          "cgroup_enable=memory",
          "swapaccount"
        ]
      },
      "cgroups" => {
        "path" => "/sys/fs/cgroup",
        "subsys" => [ 'memory' ]
      },
      [...SNIP...]
    }

