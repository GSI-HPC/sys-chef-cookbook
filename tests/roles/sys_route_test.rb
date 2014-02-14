name "sys_route_test"
description "Use to test the [sys::route] recipe."
run_list( "recipe[sys::route]" )
default_attributes(
  :sys => {
    :route => {
      '10.1.1.10' => {
        :gateway => '10.1.1.20',
        :device => 'eth0'
      },
      '10.1.3.0' => {},
      '10.1.2.0' => {
        :gateway => '10.1.1.15',
        :netmask => '255.255.255.0'
      },
      '10.0.2.0' => {
        :gateway => '10.1.1.15',
        :delete => true
      }
    }
  }
)
