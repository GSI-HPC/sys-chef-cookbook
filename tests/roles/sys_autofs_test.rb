name "sys_autofs_test"
description "Use to test the [sys::autofs] recipe."
run_list( "recipe[sys::autofs]" )
default_attributes(
  :sys => {
    :autofs => {
      :master => {
        "/path" => {
          :map => "/etc/autofs/auto.path",
          :options => "--timeout=600"
        }
      }
    }
  }
)
