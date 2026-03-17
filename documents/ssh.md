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
* `managed` (default `false`) set to true to delete existing keys not on the given list `keys`.

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

## SSH host key management

`sys::ssh` can deploy ssh host keys from chef-vault and configures the SSHD service accordingly. To use this feature, following attributes must to be set:
* Name of the vault: `node['sys']['sshd']['host_keys_vault']`
* Name of the item: `node['sys']['sshd']['host_keys_item']`

Chef-vault-item structure needs two main attributes. `id`-Attribute as name of the item and a `keys`-Hash containing a combination of key_type as attribute name and the private key as attribute value.
```json
{
  "id": "itemname",
  "keys": {
    "ecdsa": "-----BEGIN OPENSSH...",
    "rsa": "...",
    ...
  }
}
```
For each private key in `keys` the corresponding public key will be computed on the host with `ssh-keygen`. If a public key cannot be computed from the private key, a warning will be logged and the deployment of this key is skipped. In addition the key_type field must be a legit ssh key_type. E.g: `ecdsa, rsa, ed25519...`. If the computed key type of ssh-keygen does not match the key_type given in the name, the key is skipped.



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
