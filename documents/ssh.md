Configures the SSH daemon and deploys a list of SSH public keys
for a given user account.

↪ `attributes/ssh.rb`  
↪ `recipes/ssh.rb`  
↪ `definitions/sys_ssh_authorize.rb`  
↪ `tests/roles/sys_ssh_test.rb`  

**Resource**

Deploy SSH public keys for a given account in `~/.ssh/authorized_keys`

    sys_ssh_authorize "devops" do
      keys [
        "ssh-rsa AAAAB3Nza.....",
        "ssh-rsa AAAADAQAB....."
      ]
      managed true
    end

The name attribute is the user account name (here devops) where the list of `keys` will be deployed. The attribute `managed` (default false) indicates if deviating keys should be removed.

**Attributes**

Configure the SSH daemon using attributes in the hash `node.sys.sshd.config` (read the `sshd_config` manual for a list of all available key-value pairs). Note that when the daemon configuration is empty the original `/etc/ssh/sshd_config` file wont be modified.

All keys in `node.sys.ssh.authorize[account]` (where account is an existing user) have the following attributes:

* `keys` (required) contains at least one SSH public key per user account.
* `managed` (default false) overwrites existing keys deviating form the given list `keys` when true.

For example:

    [...SNIP...]
    "sys" => {
      "sshd" => {
        "config" => {
          "UseDNS" => "no",
          "X11Forwarding" => "no",
          [...SNIP...]
        }
      },
      "ssh" => {
        "authorize" => {
          "root" => {
            "keys" => [
              "ssh-rsa AAAAB3Nza.....",
              "ssh-rsa AAAABG4DF....."
            ],
            "managed" => true
          },
          "devops" => {
            "keys" => [
              "ssh-rsa AAAAB3Gb4.....",
            ]
          }
          [...SNIP...]
        }
      }
      [...SNIP...]
