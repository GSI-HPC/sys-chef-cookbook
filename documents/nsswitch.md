
Configure the Network Service Switch (NSS) in the file `/etc/nsswitch.conf`.

Define an attribute `node.sys.nsswitch` containing a single string with the configuration, e.g.:

    "sys" => {
      "nsswitch" => "
        passwd:         files ldap
        group:          files ldap
        shadow:         files 
        hosts:          files dns ldap
        networks:       files ldap
        protocols:      db files
        services:       db files
        ethers:         db files
        rpc:            db files
        netgroup:       nis
      "
    }

