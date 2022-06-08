source 'https://supermarket.chef.io'

metadata

# test cookbook for LWRP testing
cookbook 'fixtures', path: 'test/unit/fixtures', group: :chefspec

# avoid https://github.com/sous-chefs/line/issues/92
#  by pulling directly from github:
cookbook 'line' #, github: 'sous-chefs/line', tag: "v0.6.3"

group :integration do
  cookbook 'nftables-test', path: 'test/fixtures/cookbooks/nftables-test'
end
