name "sys_nsswitch_test"
description "Use to test the [sys::nsswitch] recipe."
run_list( "recipe[sys]" )
default_attributes(
  "sys" => {
    "nsswitch" => "
      passwd:         compat
      group:          compat
      shadow:         compat
      hosts:          files dns dns
      networks:       files
      protocols:      db files
      services:       db files
      ethers:         db files
      rpc:            db files
      netgroup:       nis
    "
  }
)
