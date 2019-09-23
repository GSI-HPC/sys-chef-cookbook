Installs and configures the Automounter facility.

↪ `attributes/autofs.rb`  
↪ `recipes/autofs.rb`  
↪ `templates/default/etc_auto.master.d_generic.erb`  
↪ `tests/unit/recipes/autofs_spec.rb`  
↪ `tests/integration/sys_autofs`  


**Attributes**

The attribute `node['sys']['autofs']['maps']` contains a hash
of automounter map definitions hashes.

The definitiion hashes may contain the following attributes:

`mountpoint`
: The base directory for this autofs map's mounts

`mapname`
: path (for map files etc) or name (eg- for LDAP maps)
pointing to the automounter map. Names will be resovled according
to nsswitch.conf configuration.

`options`
: options for the automounter map, eg. `nobrowse`, `--timeout 600`, …

See `man 5 auto.master` for further informations.

Missing attibutes well be derived from the map name, eg.

`node['sys']['autofs']['maps']['misc'] = {}`
will lead to this entry in /etc/auto.master:
`/misc autofs.misc` (no default options).

**Example**

```ruby
sys: {
  autofs: {
    maps: {
      my_map: {
        mountpoint: '/path',
        mapname:    '/etc/autofs/autofs.map1',
        options:    '--timeout=600'
      },
      other_map: {
        mountpoint: '/foo/bar',
        mapname:    '/path/to/autofs.map2'
      }
      'auto/magic' => {
        ## an empty hash will automatically derive values from the key:
        # mountpoint: '/auto/magic',
        # mapname:    'autofs.auto_magic',
        # options:    ''
      }
    }
  }
}
```
