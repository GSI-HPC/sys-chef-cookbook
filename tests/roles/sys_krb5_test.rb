name "sys_krb5_test"
description "Use to test the [sys::krb5] recipe."
run_list( "recipe[sys::krb5]" )
default_attributes(
  "sys" => {
    "krb5" => {
      "realm" => "devops.test",
      "admin_server" => "krb01.devops.test",
      "master" => "krb01.devops.test",
      "slave" => "krb02.devops.test",
      "domain" => "devops.test"
    }
  }
)
