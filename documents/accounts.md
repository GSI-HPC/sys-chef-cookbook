# `sys::accounts`

Create user accounts.

↪ `attributes/accounts.rb`  
↪ `recipes/accounts.rb`  
↪ `tests/roles/sys_accounts_test.rb`  

## Standard user ressource attributes

Attributes are set beneath `node['sys']['accounts'][_username_]`.
It wraps the `user` resources, thus supports all of its options.

### Example

    :sys => {
      :accounts => {
        :kirk => {
          :uid => 1111,
          :shell => '/bin/bash'
        },
        :spock => {
          :system => true
        },
        :sulu => {
          :action => :remove
        },
        :uhura => {
          :home => '/home/uhura',
          :password => '$6$M4oxTop4k/2kd1nmrsiZdFfzKr1Q/',
          :manage_home => true
        }
      }
    }


## Non-standard attributes

`sys::accounts` supports additional attributes:

### Remote access

`node['sys'}['accounts'][_username_]['remote']` will add a rule
to `/etc/security/access.conf` cf. `recipes/pam.rb`, eg:

    sys: {
      accounts: {
        picard: {
          remote: 'ALL'
        }
        riker: {
          remote: 'ncc.1701.de'
        }
      }
    }

### sudo permissions

`node['sys'}['accounts'][_username_]['sudo']` will add a rule
to `/etc/sudoers.d/localadmin` cf. `recipes/sudo.rb`, eg:

    sys: {
      accounts: {
        q: {
          sudo: 'NOPASSWD: ALL'
        }
        picard: {
          sudo: '/sbin/shutdown'
        }
      }
    }
