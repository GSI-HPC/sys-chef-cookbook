name "sys_fuse_test"
description "Use to test the [sys::fuse] recipe."
run_list( "recipe[sys]" )
default_attributes(
  "sys" => {
    "fuse" => {
      "config" => {
        "mount_max" => 1000,
        "user_allow_other" => ""
      }
    }
  }
)
