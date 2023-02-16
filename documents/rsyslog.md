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
    loghosts: {
      # minimal example, plain tcp
      tcp-loghost: { target: 'loghost1.example.com' },
      # minimal example with tls:
      tls-loghost: {
        tls: true,
        target_ip: 'loghost2.example.com'
	  },
      # tls, all options
	  tls-all: {
        ca_file: '/etc/ssl/certs/my_cert.pem',
        port: '1234',
        priority_filter: 'auth,authpriv.*',
        protocol: 'tcp',
        target: 'loghost3.example.org',
        tls: 'on',
        type: 'omfwd'
	  }
    }
  }
}
```
