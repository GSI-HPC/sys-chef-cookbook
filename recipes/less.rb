#
# setup for less 
#

# this will give you syntax highlighting in less:
package 'less'

#node[:sys][:env]['LESS']      = ' -R '
node[:sys][:env]['LESSOPEN']  = '| /usr/bin/lesspipe %s'
node[:sys][:env]['LESSCLOSE'] = '/usr/bin/lesspipe %s %s'

# syntax highlighting - conflicts with lesspipe for now
#if node[:sys][:less][:highlight] 
#  package 'source-highlight'
#  #export LESSOPEN="| /usr/bin/lesspipe %s"
#end

include_recipe 'sys::env'
