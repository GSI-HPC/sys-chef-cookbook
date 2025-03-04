require 'serverspec'

set :backend, :exec

# return a meaningful numeric Debian version where
#  the value for Testing or Unstable is 1) numeric and
#  2) larger than any sensible Debian version number
def debian_version
  return -1 unless os[:family] == 'debian'
  if os[:release] =~ /^\d+(\.\d+)?$/
    os[:release].to_f
  elsif os[:release] == 'n/a' &&
        ::File.exist?('/etc/debian_version')
    2**32 - 1.0
  end
end
