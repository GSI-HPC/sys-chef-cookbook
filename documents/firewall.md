# `sys::firewall`

Use the firewall recipe to configure nftables.

↪ `attributes/firewall.rb`  
↪ `recipes/firewall.rb`  
↪ `resources/firewall.rb`  
↪ `resources/firewall_rule.rb`  
↪ `libraries/sys_helpers_firewall.rb`  
↪ `documents/firewall.rb`  
↪ `test/unit/recipies/firewall_spec.rb`  

## Basic Usage

### Disable nftables

`node['sys']['firewall']['disable'] = true` will turn off *nftables*:

```ruby
node['sys']['firewall']['manage']  = true       # To manage nftables at all
node['sys']['firewall']['disable'] = true       # To disable nftables
```

### Enable nftables

The `sys::firewall` recipe **does nothing unless explicitly
activated**.  To active the recipe, the following steps are required:

1. Include the recipe in your run list.
1. Set `node['sys']['firewall']['manage']` to `true`
1. Set `node['sys']['firewall']['disable']` to `false`

This will give you a rather permissive default-set of rules, since the
following attributes default to `true`.  Adjust to your needs:
↪ `node['sys']['firewall']['allow_established']`  
↪ `node['sys']['firewall']['allow_icmp']`  
↪ `node['sys']['firewall']['allow_loopback']`  
↪ `node['sys']['firewall']['allow_ssh']`  

This will give you the following default rules:

    table inet filter {
            chain INPUT {
                    type filter hook input priority 0; policy drop;
                    iif "lo" accept comment "allow loopback"
                    icmp type echo-request accept comment "allow icmp"
                    tcp dport ssh accept comment "allow world to ssh"
                    ct state established,related accept comment "established"
            }
    
            chain OUTPUT {
                    type filter hook output priority 0; policy accept;
            }
    
            chain FOWARD {
                    type filter hook forward priority 0; policy drop;
            }
    }
    table ip6 nat {
            chain POSTROUTING {
                    type nat hook postrouting priority 100; policy accept;
            }
    
            chain PREROUTING {
                    type nat hook prerouting priority -100; policy accept;
            }
    }
    table ip nat {
            chain POSTROUTING {
                    type nat hook postrouting priority 100; policy accept;
            }
    
            chain PREROUTING {
                    type nat hook prerouting priority -100; policy accept;
            }
    }

### You are scared and just want to take a look

If you want to generate the nftables rule-set but not activate it, use
your own firewall-recipe, like so:

```RUBY
firewall 'default'       # Default action is :install

firewall_rule 'example-ips from rfc5737' do
  source ['192.0.2.0/24', '198.51.100.0/24', '203.0.113.0/24']
  port 22
end
```

Make sure to [disable](#1-disable-nftables) the firewall.  These steps
should disable nftables but still generate `/etc/nftables.conf`.

## Using `sys::firewall` from other recipes

Depend on the `sys`-cookbook in the `metadata.rb` and include
`sys::firewall` in the runlist.  If access via ports `443` and `80`
should be possible, write a resource like this:

```ruby
firewall_rule 'allow http(s)` do
  port [80,443]
end
```

If `sys::firewall` is not what you want, it is also sufficient to
define the resource `firewall['default']` instead of including
`sys::firewall` and build everything from scratch.


For further examples see the recipe
[sys::firewall](recipes/firewall.rb) and the recipe [firewall-test::default](test/fixtures/cookbooks/firewall-test/recipes/default.rb).
