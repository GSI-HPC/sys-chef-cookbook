Configure Domain Name Service (DNS) resolution.

↪ `attributes/rsyslog.rb`  
↪ `recipes/rsyslog.rb`  
↪ `templates/*/etc_rsyslog.d_loghost.conf.erb`  
↪ `templates/*/etc_rsyslog.d_loghost-generic.conf.erb`  

**Attributes**

TODO


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
      { ca_file: '/etc/ssl/certs/my_cert.pem',
        name: '52-tls-all.conf',
        port: '1234',
        priority_filter: 'auth,authpriv.*',
        protocol: 'tcp',
        target_ip: '192.2.0.3',
        tls: 'on',
        type: 'omfwd' }
    ]
  }
}
```
