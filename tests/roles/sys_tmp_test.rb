name "sys_tmp_test"
description "Use to test the [sys::tmp] recipe."
run_list( "recipe[sys]" )
default_attributes(
  "sys" => {
    "tmp" => {
      "reaper" => {
        "max_age" => "8d",
        "protected_patterns" => [],
        "dirs" => ['/tmp/','/var/tmp'],
        "options" => '--runtime=1800'
      }
    }
  }
)
