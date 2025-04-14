require 'serverspec'

set :backend, :exec

# return a meaningful numeric Debian version
#  casting to a float is very simplistic and misses corner cases
#  like 8.11 should be greater than 8.7
#  but for our use cases it will just do
def debian_version
  return -1 unless os[:family] == 'debian'
  os[:release].to_f
end
