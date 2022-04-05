Installs and configures net-snmpd

* `recipes/snmp.rb`
* `templates/default/etc_snmp_snmpd.conf.erb`

## Basic configuration

The attributes for snmpd configuration are located beneath `node["sys"]["snmp"]`:

`community`:  
  Sets the community for read access, defaults to `public`

`full_access`:  
  Allow the reader to walk the full tree, otherwise `systemonly`. Default: false

`sys_contact` and `sys_location`:
  Standard SNMP attributes for admin contact and location of the system.

`log_level`:  
  messages with the given log level and above will be logged to syslog (facility `daemon`)

Other minor tweaks can be set via attributes,
check the template `etc_snmp_snmpd.conf.erb` for hints.

## Defining snmpd extensions

Extensions for snmpd can be configured via attributes, eg. 

```
"sys" => {
  "snmp" => {
    "extensions => [ {
        "type" => "pass-persist",
        "oid" => ".1.3.6.1.4.1.43231.42",
        "executable" => "/usr/local/share/snmp/cool_snmp_extension" # or any other place
      }
    ]
  }
}
```

## Restricting access to snmpd

It is recommended to restrict the access to snmpd via tcpwrappers and the hosts recipe:

```
node['sys']['hosts']['deny']  = [ "snmpd: ALL" ]
node['sys']['hosts']['allow'] = [ "snmpd: 93.184.216.119" ]
```

Apparently snmpd performs no DNS lookups so only IPs will work for tcpwrappers.
