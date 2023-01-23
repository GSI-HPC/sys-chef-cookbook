# `recipe::fail2ban`

The fail2ban recipe installs and configures fail2ban jails.

↪ `recipes/fail2ban.rb`  

## Usage

```ruby
include_recipe 'sys::fail2ban'
```

Attributes have to be set, otherwise `sys::fail2ban` will do nothing.
Log messages are sent to syslog. This is not configurable by attributes at the moment.

### iptables vs. nftables

fail2ban can use iptables as well as nftables.
The nftables backend on Debian Buster needs some pre-configuration.
This can be done with `sys::nftables`.

## Attributes

Enable `sys::fail2ban` with default options as provided by the package maintainers:

```
sys: {
  fail2ban: {
    enable: 'Yes please!'
  }
}
```

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
