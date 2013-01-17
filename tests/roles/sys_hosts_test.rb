name "sys_hosts_test"
description "Use to test the [sys::hosts] recipe."
run_list( "recipe[sys]" )
default_attributes(
  "sys" => {
    "hosts" => {
      "allow" => [ 
        "sshd: 10.1.",
        "snmpd: 10.1.1.14"
      ],
      "deny" => [
        "ALL: ALL"
      ]
    }
  }
)
