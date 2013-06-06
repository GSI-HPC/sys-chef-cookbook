name "sys_ldap_test"
description "Use to test the [sys::krb5] recipe."
run_list( "recipe[sys::ldap]" )
default_attributes(
  "sys" => {
    "ldap" => {
      "master" => "ldap1.example.com",
      "slave" => "ldap2.example.com",
      "searchbase" => "ou=people,dc=example,dc=com",
      "realm" => "example.com"
    }
  }
)
