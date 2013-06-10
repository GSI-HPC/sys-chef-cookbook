
Setup a client to communicate with a Kerberos server.

↪ `attributes/krb5.rb`  
↪ `recipes/krb5.rb`  
↪ `tests/roles/sys_krb5_test.rb`  

## Configuration

The basic requirements for talking to a Kerberos-server are the kerberos-realm, the adress of the admin-server, as well as possible slaves and a domain which is mapped to the kerberos-realm.  Atrributes might look like this:

All attributes in `node.krb5`: 


    "sys" => {
      "krb5" => {
        "realm" => "EXAMPLE.COM",
        "admin_server" => "kdc1.h5l.example.com",
        "master" => "kdc1.h5l.example.com",
        "slave" => "kdc2.h5l.example.com",
        "domain" => "example.com"
      }
    }

This cookbook does not change any files in `/etc/pam.d/`. After the client is configured to use Kerberos the corresponding PAM mechanisms needs to be enabled with the `sys::pam` recipe.

