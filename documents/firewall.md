Use the firewall recipe to configure nftables.

↪ `attributes/firewall.rb`  
↪ `recipes/firewall.rb`  
↪ `resources/firewall.rb`  
↪ `resources/firewall_rule.rb`  
↪ `libraries/sys_helpers_firewall.rb`  
↪ `documents/firewall.rb`  
↪ `test/unit/recipies/firewall_spec.rb`  

# Examples

## Disable nftables

Use attributes in `node['sys']['firewall']`, e.g. to switch off nftables:

    node['sys']['firewall']['manage']  = true       # To manage nftables at all
    node['sys']['firewall']['disable'] = true       # To disable nftables

## Default rules

If you want to use `sys::firewall`, just include the recipe and set
`node['sys']['firewall']['manage']  = true`.  Adjust the follwing
self-explaining attributes to your needs.  They all default to true:

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


## Using `sys::firewall` from other recipes

Depend on the `sys`-cookbook in the `metadata.rb` and include
`sys::firewall` in the runlist.  If access via ports `443` and `80`
should be possible, write a resource like this:

    firewall_rule 'allow http(s)` do
      port [80,443]
    end

For further examples see the recipe
[sys::firewall](recipes/firewall.rb) and the recipe [firewall-test::default](test/fixtures/cookbooks/firewall-test/recipes/default.rb).
