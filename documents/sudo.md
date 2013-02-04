Configures Sudo with files in the directory `/etc/sudoers.d/*` containing user,host, and command aliases as well as rules. Furthermore is creates a file `/etc/sudoers` to source all files within this directory.

↪ `attributes/sudo.rb`  
↪ `recipes/sudo.rb`  
↪ `definitions/sys_sudo.rb`  
↪ `templates/*/etc_sudoers.erb`  
↪ `templates/*/etc_network_sudoers.d_generic.erb`  
↪ `tests/roles/sys_sudo_test.rb`

**Resources**

The following code deploys a file called `/etc/sudoers.d/admin`.

    sys_sudo "admin" do
      users 'ADMIN' => ["joe","bob","ted"]
      rules(
        "ADMIN ALL = NOPASSWD: /usr/bin/chef-client",
        "ADMIN ALL = ALL"
      )
    end

It defining and `User_Alias` called "ADMIN" and a pair of rules for this group of users. Similar the following code deploys a file `/etc/sudoers.d/monitor` including `Cmnd_Alias`s and a single rule.

    sys_sudo "monitor" do
       commands(
         "IB" => [ "/usr/sbin/perfquery" ],
         "NET" => [ "/bin/netstat", "/usr/sbin/iftop", "/sbin/ifconfig" ]
       )
       rules "mon LOCAL = NOPASSWD: IB, NET"
    end

The `sys_sudo` resource supports `users`, `hosts`, `commands`, and `rules`.

**Attributes**

All attributes in `node.sys.sudo`:

* `users` (optional) defines a hash of user aliases.
* `hosts` (optional) defines a hash of host aliases.
* `commands` (optional) defines a hash of command aliases.
* `rules` (required) defines an array of rules.

Configure command execution for a group of administrators:

    "sys" => {
      "sudo" => {
        "admin" => {
          "users" => { "ADMIN" => ["joe","bob","ted"] },
          "rules" => [
            "ADMIN ALL = NOPASSWD: /usr/bin/chef-client",
            "ADMIN ALL = ALL"
          ]
        },
        "monitor" => {
          "commands" => {
            "IB" => [ "/usr/sbin/perfquery" ],
            "NET" => [ "/bin/netstat", "/usr/sbin/iftop", "/sbin/ifconfig" ]
          },
          "rules" => [ "mon LOCAL = NOPASSWD: IB, NET" ]
        },
        "users" => {
          "users" => { "KILLERS" => ["maria","anna"] },
          "hosts" => { "LAN" => ["10.1.1.0/255.255.255.0"] },
          "commands" => {
            "KILL" => [ "/usr/bin/kill", "/usr/bin/killall" ],
            "SHUTDOWN" => [ "/usr/sbin/shutdown", "/usr/sbin/reboot" ]
          },
          "rules" => [
            "KILLERS LOCAL = KILL",
            "%users LAN = SHUTDOWN"
          ]
        }
      }
    }

Furthermore some extra command for a monitoring user `mon`, and extra privileges for users.
