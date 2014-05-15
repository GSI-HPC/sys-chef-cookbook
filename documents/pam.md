Configures Linux authentication modules (PAM).

↪ `attributes/pam.rb`  
↪ `recipes/pam.rb`  
↪ `templates/*/etc_security_limits.conf.erb`  
↪ `templates/*/etc_security_access.conf.erb`  
↪ `templates/*/etc_pam.d_generic.erb`  
↪ `tests/roles/sys_pam_test.rb`  
↪ `files/*/etc_pam.d_sshd`  
↪ `files/*/etc_pam.d_login`  


**Attributes**

All attributes in `node.sys.pam`:

* `limits` holds an array of ulimits written to `/etc/security/limits.conf`.
* `access` holds an array of rules written to `/etc/security/access.conf`.
* `group` holds an array of rules written to `/etc/security/group.conf`.

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
        "group" => [
          # minimal specification using defaults:
          { 'usr' => 'tschipfel', 'grp' => 'sudo' }
          # complete example (allow dummbabbler to read syslog while 
          #                   logging in via console tty1 on workhours)
          {
            'usr'  => 'dummbabbler',
            'grp'  => 'adm',
            'srv'  => 'login',
            'tty'  => 'tty1',
            'time' => 'Wk0900-1800'
          }
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

`files/*/etc_pam.d_login` is deployed at `/etc/pam.d/login` if the `[:sys][:pam][:access]` attribute is set. It is the default file shipped with the `login` package and commented-in pam_access line.

`files/*/etc_pam.d_sshd` is deployed at `/etc/pam.d/sshd` if the `[:sys][:pam][:access]` attribute is set and the file `/etc/ssh/sshd_config` exists (meaning `openssh-server` package is installed). It is the default file shipped with the `openssh-server` package and commented-in pam_access line.
