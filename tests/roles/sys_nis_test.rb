name "sys_nis_test"
description "Use to test the [sys::nis] recipe."
run_list( "recipe[sys]" )
default_attributes(
  :sys => {
    :nis => {
      :servers => [
        "lxnis01.devops.test",
        "lxnis02.devops.test"
      ]
    },
    :nscd => {
      :enable => true
    }
  }
)
