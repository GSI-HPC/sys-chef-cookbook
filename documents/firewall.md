# `resource::firewall`

Use the firewall resource to configure nftables.

↪ `resources/firewall.rb`  
↪ `resources/firewall_rule.rb`  
↪ `libraries/sys_helpers_firewall.rb`  
↪ `documents/firewall.rb`  
↪ `test/unit/recipies/firewall_spec.rb`  

## Basic Usage

### Disable nftables

```ruby
firewall 'default' do
  action :disable
end
```

### Enable nftables

```ruby
firewall 'default'
```

This will give you the following default rules:

    table inet filter {
            chain input {
                    type filter hook input priority 0; policy accept;
            }
    
            chain output {
                    type filter hook output priority 0; policy accept;
            }
    
            chain foward {
                    type filter hook forward priority 0; policy drop;
            }
    }

### You are scared and just want to take a look

If you want to generate the nftables rule-set but not activate it, use
your own firewall-recipe, like so:

```RUBY
firewall 'default' do
 action [:rebuild, :disable]
end

firewall_rule 'example-ips from rfc5737' do
  source ['192.0.2.0/24', '198.51.100.0/24', '203.0.113.0/24']
  port 22
end
```

Setting `action` to [:rebuild, :disable] will disable nftables but
still generate `/etc/nftables.conf`.

## Using the `firewall`-resource

Depend on the `sys`-cookbook in the `metadata.rb`.  Write a recipe to
configure nftables, e.g. to configure a ruleset which only allows
access via port `22`, write a recipe like this

```ruby
firewall 'default' do
  input_policy 'drop'
end

firewall_rule 'allow http(s)' do
  port [80,443]
end
```

For further examples see [firewall-test::default](test/fixtures/cookbooks/firewall-test/recipes/default.rb).
