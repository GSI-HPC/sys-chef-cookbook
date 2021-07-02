Installs and configures the Automounter facility.

↪ `attributes/autofs.rb`  
↪ `documents/autofs.md`  
↪ `files/default/etc_init.d_autofs`  
↪ `recipes/autofs.rb`  
↪ `templates/default/etc_auto.master.d_README.erb`  
↪ `templates/default/etc_auto.master.erb`  
↪ `templates/default/etc_autofs.conf.erb`  
↪ `templates/default/etc_autofs_ldap_auth.conf.erb`  
↪ `templates/default/etc_default_autofs.erb`  
↪ `test/integration/sys_autofs/serverspec/localhost/autofs_spec.rb`  
↪ `test/unit/recipes/autofs_spec.rb`  
↪ `tests/integration/sys_autofs`  
↪ `tests/roles/sys_autofs_test.rb`  
↪ `tests/unit/recipes/autofs_spec.rb`  


**Attributes (specify maps)**

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

**Attributes (nsswitch, files, ldap)**
By default, `automount` uses nsswitch, to lookup a map called
`auto.master`.  If `/etc/auto.master` is found, no further lookups
will be done, especially `auto.master` from ldap will be ignored.  If
the attribute `node['sys']['autofs']['ldap']['auto.master_from_ldap']`
evaluates to `true`, `/etc/auto.master` will be configured to further go
through the lookups specified in `/etc/nsswitch.conf`.

This mechanism can be used to choose the maps from ldap, that should
be available on your machine, see `Example (lookup)` below:

**Example (maps)**

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

**Example (lookup auto.master from ldap and include local maps)**
This example configures automount to use every map available in ldap,
and also `/etc/autofs.local`, which is configured locally.

```ruby
sys: {
  autofs: {
    maps: {
      local: {}
    }
    # node['sys']['autofs']['ldap'] must be non-empty for ldap to be
	# configured
	ldap: {
	  servers: 'ldap.example.com',
	  searchbase: 'dc=example,dc=com',
	  auto.master_from_ldap: true
	}
  }
}
```

**Example (lookup auto.master locally and maps from ldap)**
This example can be used, if not all maps from ldap should be visible
on a machine.  In this case, `/etc/auto.master` will contain the line
`/somemap autofs.somemap`.  Therefore `autofs.somemap` will be taken
from ldap, but since the line `+auto.master` will be missing, no other
maps are taken from ldap.

```ruby
sys: {
  autofs: {
    maps: {
      somemap: {}
    }
    # node['sys']['autofs']['ldap'] must be non-empty for ldap to be
	# configured
	ldap: {
	  servers: 'ldap.example.com',
	  searchbase: 'dc=example,dc=com',
	}
  }
}
```
