# `sys_x509_certificate` resource

[Back to resource list](../../README.md#resources)

This resource deploys `x509` certificates and keys, with the following defaults:

- The certificate will have owner `root` and group `root`, permissions will be `-rw-r--r--`
- The key will have owner `root` and group `ssl-cert`, permissions will be `-rw-r-----`.
- By default, the resource expects the certificate to be available as
`file-content` at the object `bag_item` (which defaults the resource
name) in the data bag `ssl_certs`. This can be configured by the
`data_bag` and `bag_item` properties.
- By default, the resource expects the key to be available as `file-content` at the
object `vault_item` (which defaults to `bag_item` in the chef vault
`ssl_keys`. This can be configured by the `chef_vault` and
`vault_item` properties.

The structure of the private key can be obtained on the command line by running, e.g.
```
knife vault create ssl_keys $(fqdn) -A admin1,admin2 -C $(fqdn) --file /tmp/privkey.pem
```
which by default will store the contents of `/tmp/privkey.pem` as `file-content` vault item `$(fqdn)` in the vaul `ssl_keys`.

## Provides

- :sys_x509_certificate

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
sys_x509_certificate 'some_certificate' do
  certificate_path '/alternate/path.pem'
  key_path '/super/secret/path.pem'
end
```

See the [recipe used for testing](../../test/fixtures/cookbooks/x509-test/recipes/default.rb).
