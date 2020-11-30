# `sys::networkd`

Configures network interfaces with **`systemd-networkd`**

**Caution! Unless `node['sys']['networkd']['keep_interfaces']` is set,
any existing config beneath `/etc/systemd/network` will be deleted
when `sys::networkd` is added to the run_list.**

## `link` definitions

Link definitions allow to assing custom network interface names
that do not follow the standard [*predictable interface names*](https://systemd.io/PREDICTABLE_INTERFACE_NAMES/) schema.

Example:

~~~ ruby
sys: {
 networkd: {
   link: {
     karen: {
       'Link'  => { 'Name' => 'imspecial' },
       'Match' => { 'MACAddress' => 'AB:AD:BA:BE:DO:OD' }
     }
  }
}
~~~

## `netdev` definitions

Netdev definitions define special network devices, eg. bridge, vlan or bond devices.

Example:

~~~ ruby
sys: {
  networkd: {
    netdev: {
      avlan: {
        'Netdev' => {
          'Kind' => 'vlan',
          'Name' => 'vlan420'
        },
        'VLAN' => { 'Id' => '420' }
      },
      abridge: {
        'Netdev' => {
          'Kind' => 'bridge',
          'Name' => 'br31'
         }
      }
    }
  }
}
~~~

## `network` definitions

Defines the IP config of an interface.

Example:

~~~ ruby
sys: {
 networkd: {
   network: {
     eno1: {
       'Address' => { 'Address' => '10.20.30.40/31' },
       'Match'   => { 'Name' => 'imspecial' }
       'Network' => {
         'Gateway' => '10.20.30.33',
         'VLAN' => %w[avlan]
       }
     }
  }
}
~~~
