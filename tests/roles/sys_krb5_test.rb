name "sys_krb5_test"
description "Use to test the [sys::krb5] recipe."
run_list( "recipe[sys::krb5]" )
default_attributes(
  "sys" => {
    "krb5" => {
      # this is upcased in the recipe
      "realm" => "example.com",
      "admin_server" => "kdc1.h5l.example.com",
      "master" => "kdc1.h5l.example.com",
      "slave" => "kdc2.h5l.example.com",
      "domain" => "example.com"
    }
  }
)
