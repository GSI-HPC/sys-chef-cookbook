Create user accounts.

↪ `attributes/accounts.rb`  
↪ `recipes/accounts.rb`  
↪ `tests/roles/sys_accounts_test.rb`  

**Attributes**

All attributes in `node.sys.accounts`, where each key is a user 
name with a configuration value. It wraps the `user` resources,
thus supports all of its options.

**Example**

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
          :supports => {
            :manage_home => true
          }
        }
      }
    }

