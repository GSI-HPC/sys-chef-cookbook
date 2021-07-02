# `sys::nsswitch`

↪ `resources/nsswitch.rb`  
↪ `recipes/nsswitch.rb`  

Configures the Network Service Switch (NSS) in the file `/etc/nsswitch.conf`.

Entries in `/etc/nsswitch.conf` that are not explictly handled by the Chef will be left untouched.

## Attributes

Define attributes beneath `node['sys']['nsswitch']` e.g.:

```ruby
default['sys']['nsswitch'] = {
  passwd:    'files ldap',
  shadow:    'files ldap',
  automount: 'files ldap'
}
```

## Custom Resource

Entries in `nsswitch.conf` can be tweaked from inside recipes:

```ruby
sys_nsswitch sudo' do
  sources 'files ldap'
end
```
