# `sys::ssl`

Deploys SSL certificates from data bags
and the corresponding keys from chef vaults.

↪ `recipes/ssl.rb`  
↪ `tests/integration/sys_ssl/`  

## Attributes

`node['sys']['ssl']['certs']` has to be defined as an *array of hashes*.
Each hash may contain three elements:

`data_bag`
: The name of the chef data bag

`data_bag_item`
: The id of the data bag item that contains the certificate

`file`
: The file name for the certificate file

Each of these elements has sensible defaults:

`data_bag`
: defaults to "ssl_certs"

`data_bag_item`
: defaults to the nodes FQDN

`file`
: defaults to "/etc/ssl/certs/*data_bag_item*.pem"

This minimal attribute definition is therefore vaild:

~~~ ruby
sys: {
  ssl: {
    certs: [ {} ]
  }
}
~~~

It will look into the data bag "ssl_certs" and create
the file "/etc/ssl/certs/*FQDN*.pem" from the contents
of an item with the nodes FQDN as its `id`.

## Data bag format

The data bag item must provide two attribute:

1. Its `id`
2. A `file-content` attribute containing the certificate contents as a plain string

~~~ json
{
  "id": "corona.example.org",
  "file-content": "-----BEGIN CERTIFICATE-----\nAAAA[…]ZZZZ\n-----END CERTIFICATE-----"
}
~~~

## Private keys

Private keys corresponding to SSL certificates con be read from chef vaults.
The management of the private key is controlled by attributes for the respective
cert in `node['sys']['ssl']['certs']`.

 `key_vault`
 : The vault name. Default  `ssl_keys`

`key_file`
: The file the key is written into. Default: "/etc/ssl/private/*data_bag_item*.key"  
  The file will be readable for the group `ssl-cert`.

Even without explicitly given options, `sys::ssl` will always look for
corresponding private key for every certificate found.
If no appropriate vault item is found, a warning is issued.
