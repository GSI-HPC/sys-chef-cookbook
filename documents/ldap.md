Configure the client to use LDAP as name service.

↪ `attributes/ldap.rb`  
↪ `recipe/ldap.rb`  
↪ `templates/default/etc_default_nslcd.conf.erb`  
↪ `templates/default/etc_nslcd_conf.erb`  
↪ `templates/default/etc_ldap_ldap.conf.erb`  
↪ `tests/roles/sys_ldap.test.rb`  

## Configuration

It is assumed that LDAP is used in conjunction with Kerberos. Without a Kerberos server you need to disable GSSIAPI. The rough outline is like this:

`nslcd` connects to the LDAP-server, to query information for users. Since the communication between client and server should be encrypted and Kerberos is there, this is done via SASL/GSSAPI. That is why `nslcd` needs its own keytab, to authenticate with the LDAP server. In order to securely transport the keytabs from server to client the library `sys::secret` is used. The keytabs are used by the `k5start` to periodically get tickets for the LDAP service from the Kerberos KDC.

It is assumed, that the LDAP-server is setup in some sort of master-slave configuration. `nslcd` usually talks to the master, but can use the slave as a fail over.  The `searchbase` tells `nslcd` in which subtree of the directory information tree to search for the users. Finally `nslcd` needs to provide a realm to the LDAP-server for the use of the SASL/GSSAPI-mechanism.

**Attributes**

All attributes in `node.ldap`:

    "sys" => {
      "ldap" => {
        "master" => "ldap1.example.com",
        "slave" => "ldap2.example.com",
        "realm" => "example.com",
        "searchbase" => "ou=people,dc=example,dc=com"
      }
    }

This recipe does not touch any PAM files.  They need to be configured with `sys::pam`.
