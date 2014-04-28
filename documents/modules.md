Load kernel modules, and add the to `/etc/modules`.

↪ `definitions/sys_module.rb`
↪ `definitions/sys_module.rb`

**Attributes**

Add modules to the attribute `node.sys.modules`, e.g.:

    :sys => {
      :modules => ['fuse']
    }

**Resources**
 
Load a Linux kernel module with `sys_module` resource:

    sys_module 'fuse'

