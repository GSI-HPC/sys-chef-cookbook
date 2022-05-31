# x509_certificate

[Back to resource list](../../README.md#resources)

The resource deploys `x509`-certificates and keys. The certificate will have
owner `root` and group `root`, permissions will be `-rw-r--r--`.  The
key will have owner `root` and group `ssl-cert`, permissions will be
`-rw-r-----`.

The resource expects the certificate to be available as `file-content`
at the object `node['fqdn']` in the data bag `ssl_certs`.

The resource expects the key to be available as `file-content` at the
object `node['fqdn']` in the chef vault `ssl_keys`.

## Provides

- :x509_certificate

## Actions

- `:install`

## Properties

| Name               | Name? | Type   | Default                                         |
| ----               | ----- | ----   | -------                                         |
| `certificate_path` |       | String | `"/etc/ssl/certs/#{new_resource.bag_item}.pem"` |
| `key_path`         |       | String | `"/etc/ssl/private/#{new_resource.vault_item}.pem"` |
| `data_bag`         |       | String | `ssl_certs`                                     |
| `bag_item`         | ✓     | String |                                                 |
| `chef_vault`       |       | String | `ssl_keys`                                      |
| `vault_item`  |       | String | `new_resource.bag_item`                         |


## Examples

```ruby
x509_certificate 'some_certificate' do
  certificate_path '/alternate/path.pem'
  key_path '/super/secret/path.pem'
end
```

See the [recipe used for testing](../../test/fixtures/cookbooks/x509-test/recipes/default.rb).
