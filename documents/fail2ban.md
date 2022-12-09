# `recipe::fail2ban`

Use the nftable recipe to enable jails.

↪ `recipes/fail2ban.rb`  

## Usage

```ruby
include_recipe 'sys::fail2ban
```

## Attributes

Use `node['sys']['fail2ban']['jail.local']` to provide a hash of
default options like so:

```ruby
sys: {
  fail2ban: {
    jail.local: {
      DEFAULT: {
        bantime: '10m',
        maxretry: '30',
        findtime: '60m',
        # if you need emails:
        action: '%(action_mw)s',
      },
      'apache-auth': {
        enable: true
      }
    }
  }
}
```
