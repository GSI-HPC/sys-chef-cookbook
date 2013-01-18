name "sys_banner_test"
description "Use to test the [sys::banner] recipe."
run_list( "recipe[sys]" )
default_attributes(
  "sys" => {
    "banner" => {
      "info" => true,
      "header" => "Welcome to Linux...",
      "message" => "The Banner Test Machine",
      "footer" => "Report problems by sending mails to devops@localhost"
    }
  }
)
