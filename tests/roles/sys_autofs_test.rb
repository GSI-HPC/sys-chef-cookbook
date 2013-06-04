name "sys_autofs_test"
description "Use to test the [sys::autofs] recipe."
run_list( "recipe[sys::autofs]" )
default_attributes(
  :sys => {
    :autofs => {
      "/path" => {
         :map => "/etc/auto.master.d/map/path.map",
         :options => "--timeout=600"
      },
      "/data/local" => {
         :map => "/etc/auto.master.d/map/data_local.map"
      },
      "/var/spool/service" => {
         :map => "/etc/auto.master.d/map/var_spool_service.map"
      }
    }
  }
)
