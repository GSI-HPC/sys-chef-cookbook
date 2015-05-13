name "sys_chef_test"
description "Use to test the [sys::chef] recipe."
run_list( "recipe[sys::chef]" )
default_attributes(
  :sys => {
    :chef => {
      :server_url => "http://chef.devops.test:443"
    }
  },
  :ohai => {
    :disabled_plugins => [ :Passwd, :Filesystem ]
  }
)
