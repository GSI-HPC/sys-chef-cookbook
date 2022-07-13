source 'https://api.berkshelf.com'

metadata

# test cookbook for LWRP testing
cookbook 'fixtures', path: 'test/unit/fixtures', group: :chefspec

# avoid https://github.com/sous-chefs/line/issues/92
#  by pulling directly from github:
cookbook 'line', github: 'sous-chefs/line', tag: "v0.6.3"

group :integration do
 cookbook 'nsswitch-test', path: 'test/fixtures/cookbooks/nsswitch-test'
 cookbook 'nftables-test', path: 'test/fixtures/cookbooks/nftables-test'
 cookbook 'x509-test', path: 'test/fixtures/cookbooks/x509-test'
end
