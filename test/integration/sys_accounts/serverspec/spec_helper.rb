require 'serverspec'
require 'pp'

set :backend, :exec

puts "OS info: " + Specinfra::Backend::Exec.new.os_info.pretty_inspect
