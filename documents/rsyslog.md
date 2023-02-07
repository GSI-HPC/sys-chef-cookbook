Configure Domain Name Service (DNS) resolution.

↪ `attributes/rsyslog.rb`  
↪ `recipes/rsyslog.rb`  
↪ `templates/*/etc_rsyslog.d_loghost.conf.erb`
↪ `templates/*/etc_rsyslog.d_loghost-generic.conf.erb`  

**Attributes**

All attributes in `node.sys.resolv`:

| Attribute | Type                    | mandatory | Descripton                                                                                         |
|-----------+-------------------------+-----------+----------------------------------------------------------------------------------------------------|
| `Servers` | Array                   | yes       | list a DNS server IPs                                                                              |
| `domain`  | String                  | no        | local domain name                                                                                  |
| `search`  | Array or String         | no        | list for host-name lookup                                                                          |
| `options` | Array                   | no        | list of options                                                                                    |
| `force`   | Boolean, default: false | no        | make sys::resolv overwrite `/etc/resolv.conf` even though it is a link (eg. managed by resolvconf) |


**Example**

```ruby
sys: {
  rsylog: {
    loghosts: [
      # minimal example with tls:
      { name: '50-tls-loghost.conf',
        tls: true,
        target_ip: '192.2.0.1' },
      # minimal example, plain tcp
      { name: '51-tcp-loghost.conf',
        target_ip: '192.2.0.2' }
      # tls, all options
      { name: 52-tls-all.conf,
        target_ip: '192.2.0.3',
        port: '1234',
        type: 'omfwd',
        protocol: 'tcp',
        tls: 'on',
        ca_file: '/etc/ssl/certs/my_cert.pem' }
    ]
  }
}
```
