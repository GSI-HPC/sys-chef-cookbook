name "sys_systemd_test"
description "Use to test the [sys::systemd] recipe."
run_list( "recipe[sys::systemd]" )
default_attributes(
  sys: {
    systemd: {
      networkd: { enable: true },
      unit: {
       '00-foo.conf' => {
          directory: '/etc/systemd/system/systemd-foo.service.d',
          config: {
            'Service' => {
              'FooSec' => '90s'
            }
          },
          action: [:create]
        }
      }
    }
  }
)
