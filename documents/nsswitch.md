# `sys::nsswitch`

↪ `resources/nsswitch.rb`  
↪ `resources/nsswitch_config.rb`  
↪ `recipes/nsswitch.rb`  

Configures the Name Service Switch (NSS) in the file `/etc/nsswitch.conf`.

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

Use the `sys_nsswitch`-resource to configure a database like so

```ruby
sys_nsswitch 'automount' do
  sources ['files', 'ldap']
end
```

In case of conflict with other recipes, provide a sources as hash with priority as value.
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
