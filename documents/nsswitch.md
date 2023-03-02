# `sys::nsswitch`

↪ `resources/nsswitch.rb`  
↪ `resources/nsswitch_config.rb`  
↪ `recipes/nsswitch.rb`  

Configures the Name Service Switch (NSS) in the file `/etc/nsswitch.conf`
using node attributes and/or the `sys_nsswitch` custom ressource.

## Recipe

With Chef versions > 12.15 and in contrast to the *modus operandi* of other `sys` recipes,
adding `sys::nsswitch` to a node's *run list* without defining
corresponding attributes will **not** result in a no-op
but will enforce the vanilla nsswitch.conf settings normally shipped by Debian.

## Attributes

Define attributes beneath `node['sys']['nsswitch']` e.g.:

```ruby
default['sys']['nsswitch'] = {
  passwd:    ['files', 'ldap'],
  shadow:    ['files', 'ldap'],
  automount: ['files', 'ldap']
}
```

## Custom Resource

To avoid problems with attribute merging and recipe ivocation order
the `sys_nsswitch` resource can be utilized to configure a database
directly from another recipe:

```ruby
sys_nsswitch 'automount' do
  sources ['files', 'ldap']
end
```

In case of a conflict with other recipes, an order of the `sources` may be enforced by as a hash
with priorities as values.
If two or more sources have the same priority, they will be ordered lexically.

```ruby
sys_nsswitch 'automount' do
  sources ['files', 'ldap']
end
```

is equal to

```ruby
sys_nsswitch 'automount' do
  sources {
     'files' => 10,
     'ldap'  => 20,
  }
end
```

And from another recipe:

```ruby
sys_nsswitch 'automount_with_sssd' do
  database 'automount'
  sources {
     'files' => 10,
     'nis'   => 20,
     'sssd'  => 30,
  }
end
```

This will result in
`automount: files ldap nis sssd`

For more examples see the recipe [nsswitch-test::default](test/fixtures/cookbooks/nsswitch-test/recipes/default.rb).
