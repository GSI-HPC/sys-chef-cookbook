Configures Linux authentication modules (PAM).

↪ `attributes/pam.rb`  
↪ `recipes/pam.rb`  
↪ `templates/*/etc_security_limits.conf.erb`  
↪ `templates/*/etc_security_access.conf.erb`  
↪ `templates/*/etc_pam.d_generic.erb`  
↪ `tests/roles/sys_pam_test.rb`

**Attributes**

All attributes in `node.sys.pam`:

* `limits` holds an array of ulimits written to `/etc/security/limits.conf`.
* `access` holds an array of rules written to `/etc/security/access.conf`.

It is possible to write any file in the `/etc/pam.d/` directory using attributes in `node.sys.pamd`. The key needs to be called like the file to be altered (e.g. `common-session` or `common-auth`) and the value is a string containing the entire configuration. (A single string is used to prevent merge problems.)

For Example:

    "sys" => {
      "pam" => {
        "access" => [
          "+:devops:10.1.1.1 LOCAL",
          "+:ALL:.devops.test LOCAL",
          "+:ALL:LOCAL",
          "-:ALL:ALL" 
        ],
        "limits" => [
          "*    hard memlock unlimited",
          "*    soft memlock unlimited"
        ]
      },
      "pamd" => {
        "common-session" => "
          session [default=1]     pam_permit.so
          session requisite       pam_deny.so
          session required        pam_permit.so
          session required        pam_unix.so
        ",
        "common-auth" => "
          password [success=1 default=ignore] pam_unix.so obscure sha512
          password requisite                  pam_deny.so
          password required                   pam_permit.so
        "
      }
    }

