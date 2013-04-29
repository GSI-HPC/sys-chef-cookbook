## Configure the client to use ldap as nameservice ##

### Files ###

↪ `templates/default/etc_default_nslcd.conf.erb`
↪ `templates/default/etc_nslcd_conf.erb`
↪ `templates/default/etc_ldap_ldap.conf.erb`
↪ `attributes/default/ldap.rb`

## Configuration of the client ##
It is assumed, that ldap is used in conjunction with kerberos.  Since this requires an existing kerberos-server, it is therfore assume that it is already setup.  The rought outline is like this:

`nslcd` connects to the ldap-server, to query information for users.  Since the communication between client and server should be encrypted and kerberos is already there, this is done via SASL/GSSAPI.  That is why nslcd needs its own keytab, to authenticate to the ldap server.  In order to securely transport the keytabs from server to client the library `sys::secret` is used.

## attributes ##
The following attributes are required by the cookbook.  It is assumed, that the ldap-server is setup in some sort of master-slave configuration.  nslcd usually talks to the master, but can use the slave as a failover.  The searchbase tells nslcd in which subtree of the directory information tree to search for the users.  Finally nslcd needs to provide a realm to the ldap-server for the use of the SASL/GSSAPI-mechanism.


	"sys" => {
	  "ldap" => {
	    "master" => "ldap1.example.com",
		"slave" => "ldap2.example.com",
		"realm" => "example.com",
		"searchbase" => "ou=people,dc=example,dc=com"
	  }
	}

## pam ##
This recipe does not touch any pam-files.  They need to be configured with the pam-cookbook.
