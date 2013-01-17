name "sys_ssh_test"
description "Use to test the [ssh] recipe."
run_list( "recipe[sys]" )
default_attributes(
  "sys" => {
    "sshd" => {
      "config" => {
        "PermitRootLogin" => "no",
        "UseDNS" => "no",
        "X11Forwarding" => "no"
      }
    },
    "ssh" => {
      "authorize" => {
        "root" => {
          "managed" => true,
          "keys" => [
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDzh1d1GvDtj6MgOD8okGW0RxQFqfC1UXPQ5eJ4I8+LO6T3gCZRyvIrz8IWLfttu0NLp7oODdQW7DqA9KB01wZweQnE9WAnpOFEphNq4SH0R1xoJt+Xbcmb/3XdwNc224TCfr5UYPkYFD3ThBBaA6xKxc/PPnTxB6EjYfilskWvKe8tzg9gVJRFezMtT9lOjUXx9kZZl8S8ORCzNKAG3Nw4NpJwuGOI+oBYU9yBknFsr1j/HJOcwPIsYqm3slcLDD+USUbxHd2mLo5JNLzmD9CTienMy6QDuRqoND5bcuJ4edduJFuiH65n+ciZAX429R36ezEjU+tyMkJ/N0D0C21J",
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDzh1d1GvDtj6MgOD8okGW0RxQFqfC1UXPQ5eJ4I8+LO6T3gCZRyvIrz8IWLfttu0NLp7oODdQW7DqA9KB01wZweQnE9WAnpOFEphNq4SH0R1xoJt+Xbcmb/3XdwNc224TCfr5UYPkYFD3ThBBaA6xKxc/PPnTxB6EjYfilskWvKe8tzg9gVJRFezMtT9lOjUXx9kZZl8S8ORCzNKAG3Nw4NpJwuGOI+oBYU9yBknFsr1j/HJOcwPIsYqm3slcLDD+USUbxHd2mLo5JNLzmD9CTienMy6QDuRqoND5bcuJ4edduJFuiH65n+ciZAX429R36ezEjU+tyMkJ/N0D0DFGH"
          ]
        },
        "jdow" => {}
      }
    }
  }
)
