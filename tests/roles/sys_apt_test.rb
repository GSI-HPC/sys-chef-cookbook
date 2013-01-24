name "sys_apt_test"
description "Use to test the [sys::apt] recipe."
run_list( "recipe[sys]" )
default_attributes(
  "sys" => {
    "apt" => {
      "preferences" => {
        "testing" => {
          "pin" => "release o=Debian,a=testing",
          "priority" => 900
        },
        "unstable" => {
          "pin" => "release o=Debian,a=unstable",
          "priority" => 400
        }
      }
    }
  }
)
