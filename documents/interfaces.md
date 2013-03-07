Configures the node network with individual files for each interface in  `/etc/network/interfaces.d/*`. Furthermore it creates a file `/etc/network/interfaces` to source all files within this directory.

↪ `attributes/network.rb`  
↪ `recipes/network.rb`  
↪ `files/*/etc_network_interfaces`  
↪ `templates/*/etc_network_interfaces.d_generic.erb`

**Attributes**

All attributes in `node.sys.network`:

* `interfaces` (required) is a hash with interface name as keys and its configuration as value. The interface configuration hash holds an `inet` key (default `manual`) and `auto` (default true) also. Read the manuals `interfaces`, `vlan-interfaces` and `bridge-utils-interfaces`.
* `restart` (optional) default true. Networking is automatically restarted upon configuration change.

**Examples**

Configure a couple of NICs, a VLAN and a network bridge:

    "sys" => {
      "network" => {
        "interfaces" => {
          "eth0" => { "inet" => "dhcp" },
          "eth1" => {
            "inet" => "static",
            "address" => "10.1.1.4",
            "netmask" => "255.255.255.0",
            "broadcast" => "10.1.1.255",
            "gateway" => '10.1.1.1',
            "up" => "route add -net 10.0.0.0 netmask 255.0.0.0 gw 10.8.0.1",
            "down" => "down route del -net 10.0.0.0 netmask 255.0.0.0 gw 10.8.0.1"
          },
          "vlan1" => { 
            "vlan_raw_device" => "eth0", 
            "up" => "ifup br1"
          },
          "br1" => { 
            "auto" => false,
            "bridge_ports" => "vlan1" 
          }
        }
      }
      [...SNIP...]
