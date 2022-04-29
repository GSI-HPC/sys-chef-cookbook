# `sys::ssh`

Globally configures the SSH daemon and client and deploys public keys and configs for given user accounts.

↪ `attributes/ssh.rb`  
↪ `recipes/ssh.rb`  
↪ `definitions/sys_ssh_authorize.rb`  
↪ `definitions/sys_ssh_config.rb`  
↪ `tests/roles/sys_ssh_test.rb`  

## Global Daemon Configuration 
 
Configure the SSH daemon using attributes in `node['sys']['sshd']['config']`
(read the `sshd_config` manual for a list of all available configuration key-value pairs).  
The original `/etc/ssh/sshd_config` file will be left untouched if `node['sys']['sshd']['config']` is empty.

    "sys" => {
      "sshd" => {
        "config" => {
          "UseDNS" => "no",
          "X11Forwarding" => "no",
          [...SNIP...]
        }
      }
    }

## User Configuration

All hashes in `node['sys']['ssh']['config'][account]` (where account is an existing user) represent an SSH configuration
(read the `ssh_config` manual for a list of all available configuration options).
The user specific configuration is written to `$HOME/.ssh/config`.
A key defines the `Host` keywords restriction pattern, and the
value contains a list of configuration key-value pairs stored in a hash:

    "sys" => {
      "ssh" => {
        "config" => {
          "devops" => {
            "*.devops.test" => {
              "StrictHostKeyChecking" => "no"
            },
            "10.1.1.2" => {
              "HostName" => "lxdns01.devops.test",
              "Port" => 2200
            }
          },
          "noops" => {
            "*" => {
              "ForwardX11" => "no"
            }
          } 
        }
      }
    }

The example above writes configuration files for the users `devops` and `noops` into their `~/.ssh/config`.

Alternatively use the resource `sys_ssh_config`:

    sys_ssh_config "devops" do
      config ({
        "*.devops.test" => {
          "CheckHostIP" => "no",
          "StrictHostKeyChecking" => "no"
        },
        "dns" => {
          "HostName" => "lxdns01.devops.test"
        }
      })
    end

## User Authorized Keys

All hashes in `node['sys']['ssh']['authorize'][account]` (where account is an existing user)
have the following attributes:

* `keys` (required) contains at least one SSH public key per user account.
* `managed` (default false) overwrites existing keys deviating form the given list `keys` when true.

For example:

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
        }
      }

Alternatively use the resource `sys_ssh_authorize` like:

    sys_ssh_authorize "devops" do
      keys [
        "ssh-rsa AAAAB3Nza.....",
        "ssh-rsa AAAADAQAB....."
      ]
      managed true
    end

## Known Hosts

`sys::ssh` can manage the system-wide `/etc/ssh/ssh_known_hosts`.
This is controlled via `node['sys']['ssh']['known_hosts']`.
The attribute format is a hash with the hostnames or IPs pointing to
a hash of keytypes as keys and the base64-encoded keys as velues.
The keytypes and keys can be acquired with `ssh-keyscan`.
The format and options of the `known_hosts` file is explained in the [`sshd` man page](https://manpages.debian.org/openssh-server/sshd.8.en.html#SSH_KNOWN_HOSTS_FILE_FORMAT).

Example:

```ruby
  sys: {
    ssh: {
      known_hosts: {
        'login.example.com': {
          'ssh-rsa': 'AAAA…==',
          'ssh-ed25519': 'AAAA…'
        },
        'gitlab.com': {
          …
        }
      }
    }
  }
```
