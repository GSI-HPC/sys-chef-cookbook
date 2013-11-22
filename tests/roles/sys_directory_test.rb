name "sys_apt_test"
description "Use to test the [sys::directory] recipe."
run_list( "recipe[sys]" )
default_attributes(
  "sys" => {
    "directory" => {
      "/uss/enterprise" => {
        "owner" => "root",
        "group" => "adm",
        "mode" => "0707",
        "recursive" => true
      },
      "/uss/voyager" => {
        "recursive" => true
      }
    }
  }
)
