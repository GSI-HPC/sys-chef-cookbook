name "sys_accounts_test"
description "Use to test the [sys::accounts] recipe."
run_list( "recipe[sys]" )
default_attributes(
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
        :password => '$6$M4oxTop4$LUMq8D7opKEJKN2G8E7i58RqvcKeVfeRqrMDOdGf2gpSF4mz8S0kYDu4BwlLLMkVxk/2kd1nmrsiZdFfzKr1Q/',
        :supports => {
          :manage_home => true
        }
      }
    }
  }
)
