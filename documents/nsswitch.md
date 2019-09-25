Configures the Network Service Switch (NSS) in the file `/etc/nsswitch.conf`.

Define attributes beneath `node['sys']['nsswitch']` e.g.:

```ruby
default['sys']['nsswitch'] = {
  passwd:    'files ldap',
  shadow:    'files ldap',
  automount: 'files ldap'
}
```

Defaults will automatically be writtem into `/etc/nsswitch.conf`.
Without attributes defined, the file will be left untouched
when calling `sys::nsswitch`.
