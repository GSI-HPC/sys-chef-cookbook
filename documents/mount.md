Mount file systems and manage `/etc/fstab`

↪ `attributes/mount.rb`  
↪ `recipes/mount.rb`  
↪ `spec/unit/recipes/mount_spec.rb `

**Attributes**

All attributes in `node.sys.mount` reflect attributes and actions for the `mount` resource.

For example:

    :sys => {
      :mount => {
        '/opt' => {
          :device => '/dev/sdb1',
          :fstype => 'ext4'
        },
        '/network/path' => {
          :device => 'lxfs01.devops.test:/export/path',
          :fstype => 'nfs',
          :options => ['ro','nosuid'],
          :action => [:mount,:enable]
        }
      }
    }

