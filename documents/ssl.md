# `sys::ssl`

Deploys SSL certificates from data bags.

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

It will look into the data bag "ssl_certs" and create the file "/etc/ssl/certs/*FQDN*.pem" from the contents of an item with the nodes FQDN as its `id`.

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
