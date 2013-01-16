name "sys_sudo_test"
description "Use to test the [sys::sudo] recipe."
run_list( "recipe[sys]" )
default_attributes(
  "sys" => {
    "sudo" => {
    }
  }
)
