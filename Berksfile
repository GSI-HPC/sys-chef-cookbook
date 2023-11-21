source 'https://supermarket.chef.io'

metadata

# test cookbook for LWRP testing
cookbook 'fixtures', path: 'test/unit/fixtures', group: :chefspec

group :integration do
  cookbook 'nsswitch-test', path: 'test/fixtures/cookbooks/nsswitch-test'
  cookbook 'mail-test',     path: 'test/fixtures/cookbooks/mail-test'
  cookbook 'nftables-test', path: 'test/fixtures/cookbooks/nftables-test'
  cookbook 'x509-test',     path: 'test/fixtures/cookbooks/x509-test'
end
