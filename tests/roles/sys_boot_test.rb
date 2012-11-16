name "sys_boot_test"
description "Use to test the [sys::boot] recipe."
run_list( "recipe[sys]" )
default_attributes(
  "sys" => {
    "boot" => {
      "params" => [
        "earlyprintk",
        "selinux=0",
        "panic=10"
      ]
    }
  }
)
