# `resource::nftables`

Use the nftables resource to configure nftables.

↪ `resources/nftables.rb`  
↪ `resources/nftables_rule.rb`  
↪ `libraries/sys_helpers_nftables.rb`  
↪ `documents/nftables.rb`  
↪ `documents/resources/nftables.rb`  
↪ `documents/resources/nftables_rule.rb`  
↪ `test/unit/recipes/nftables_spec.rb`  

## Basic Usage

### Disable nftables

```ruby
nftables 'default' do
  action :disable
end
```

### Enable nftables

```ruby
nftables 'default'
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
your own nftables-recipe, like so:

```RUBY
nftables 'default' do
 action [:rebuild, :disable]
end

nftables_rule 'example-ips from rfc5737' do
  source ['192.0.2.0/24', '198.51.100.0/24', '203.0.113.0/24']
  port 22
end
```

Setting `action` to [:rebuild, :disable] will disable nftables but
still generate `/etc/nftables.conf`.

## Using the `nftables`-resource

Depend on the `sys`-cookbook in the `metadata.rb`.  Write a recipe to
configure nftables, e.g. to configure a ruleset which only allows
access via port `22`, write a recipe like this

```ruby
nftables 'default' do
  input_policy 'drop'
end

nftables_rule 'allow http(s)' do
  port [80,443]
end
```

For further examples see [nftables-test::default](test/fixtures/cookbooks/nftables-test/recipes/default.rb) and the documentation for the [`nftables`-resource](documents/resources/nftables.md) and the [`nftables_rule`-resource](documents/resources/nftables_rule.md)
