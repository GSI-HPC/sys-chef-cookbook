Configure TCP wrapper with the files `/etc/hosts.allow` and `/etc/hosts.deny`.

↪ `attributes/hosts.rb`  
↪ `recipes/hosts.rb`  
↪ `templates/*/etc_hosts.allow.erb`  
↪ `templates/*/etc_hosts.deny.erb`  
↪ `tests/roles/sys_hosts_test.rb`

**Attributes**

All attributes in `node.sys.hosts`:

* `allow` (optional) is an array of rules.
* `deny` (optional) is an array of rules.

For example:

    "sys" => {
      "hosts" => {
        "deny" => [ "ALL: ALL"],
        "allow" => [
          "sshd: 10.1",
          "snmpd: 10.1.1.2"
        ]
      }
    }

