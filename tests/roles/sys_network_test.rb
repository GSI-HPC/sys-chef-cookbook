name "sys_network_test"
description "Use to test the [sys::network] recipe."
run_list( "recipe[sys]" )
default_attributes(
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
  }
)
