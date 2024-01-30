require 'serverspec'

set :backend, :exec

# return a meaningful numeric Debian version where
#  the value for Testing or Unstable is 1) numeric and
#  2) larger than any sensible Debian version number
def debian_version
  if os[:platform] == 'debian' && os[:release] =~ /^\d+(\.\d+)?$/
    os[:release].to_f
  elsif os[:platform].nil? && os[:release] == 'n/a' &&
        ::File.exist?('/etc/debian_version')
    2**32 - 1.0
  else
    -1.0
  end
end
