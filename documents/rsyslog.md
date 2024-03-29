# `sys::rsyslog`

Configure rsyslog ie. logging to one or more central loghosts.

↪ `attributes/rsyslog.rb`  
↪ `recipes/rsyslog.rb`  
↪ `templates/*/etc_rsyslog.d_loghost.conf.erb`  
↪ `templates/*/etc_rsyslog.d_loghost-generic.conf.erb`  

**Attributes**

Loghosts are specified by hashes in `node['sys']['rsyslog']['loghosts']`
in the form of `{ name: cfg }`. Name should be a valid hostname of the syslog-server.
The following options may be specified in cfg:


| attribute          | type                    | default                            | mandatory | descripton                                                                                                               |
|--------------------|-------------------------|------------------------------------|-----------|--------------------------------------------------------------------------------------------------------------------------|
| `:port`            | String                  | `'514'`                            | no        | Destination port to send logs to                                                                                         |
| `:protocol`        | String                  | `'tcp'`                            | no        | Valid values are 'tcp' and 'udp'                                                                                         |
| `:priority_filter` | String                  | `'*.*,*.!=debug'`                            | no        | Argument for `prifilt()`, see [documentation](https://www.rsyslog.com/doc/master/rainerscript/functions/rs-prifilt.html) |
| `:type`            | String                  | `'omfwd'`                          | no        | Output module, see [documentation](https://www.rsyslog.com/doc/master/configuration/modules/idx_output.html)             |
| `:tls`             | Boolean                 | false                              | no        | Set to `true` to encrypt log messages during transport  |
| `:ca_file`         | String                  | `'/etc/ssl/certs/ca-certificates'` | no        | Tell rsyslog which CAs to trust                     |
| `:target`          | String (hostname or ip) | defaults to `name`                 | no        |                      |

**Example**

```ruby
sys: {
  rsyslog: {
    loghosts: {
      # minimal example, plain tcp
      'tcp-loghost.example.com': { },
      # minimal example with tls:
      'tls-loghost.example.org': {
        tls: true,
        target: 'loghost2.example.com'
      },
      # tls, all options
      'tls-all.example.com': {
        ca_file: '/etc/ssl/certs/my_cert.pem',
        port: '1234',
        priority_filter: 'auth,authpriv.*',
        protocol: 'tcp',
        target: 'loghost3.example.org',
        tls: true,
        type: 'omfwd'
      }
    }
  }
}
```
