name "sys_ldap_test"
description "Use to test the [sys::krb5] recipe."
run_list( "recipe[sys::ldap]" )
default_attributes(
  "sys" => {
    "ldap" => {
      "master" => "krb01.devops.test",
      "slave" => "krb02.devops.test",
      "searchbase" => "dc=devops,dc=test",
      "realm" => "devops.test"
    }
  }
)
