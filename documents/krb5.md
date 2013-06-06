Setup a client to communicate with a kerberos server.

↪ `attributes/krb5.rb`
↪ `recipes/krb5.rb`

## Client Configuration

The basic requirements for talking to a kerberos-server are the kerberos-realm, the adress of the admin-server, as well as possible slaves and a domain which is mapped to the kerberos-realm.  Atrributes might look like this:


	"sys" => {
	  "krb5" => {
	    "realm" => "EXAMPLE.COM",
		"admin_server" => "kdc1.h5l.example.com",
		"master" => "kdc1.h5l.example.com",
		"slave" => "kdc2.h5l.example.com",
		"domain" => "example.com"
		}
	}

This cookbook does not change any files in `/etc/pam.d/`.  So after the client is setup and working, the corresponding pam-mechanisms still need to be enabled in order to use authentication via kerberos.  Use `sys::pam` to do that.

