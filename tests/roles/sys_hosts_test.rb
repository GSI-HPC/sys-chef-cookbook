name "sys_hosts_test"
description "Use to test the [sys::hosts] recipe."
run_list( "recipe[sys]" )
default_attributes(
  "sys" => {
    "hosts" => {
      "file" => {
        "10.1.1.12" => "lxdev02.devops.test lxdev02",
        "10.1.1.13" => "lxdev03.devops.test lxdev03"
      },
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
