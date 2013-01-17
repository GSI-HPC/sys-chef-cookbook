name "sys_pam_test"
description "Use to test the [sys::pam] recipe."
run_list( "recipe[sys]" )
default_attributes(
  "sys" => {
    "pam" => {
      "limits" => [ 
        "*    hard memlock unlimited",
        "*    soft memlock unlimited"
      ]
    }
  }
)
