#
# Copy a sensible /etc/updatedb.conf to every host
#

template '/etc/updatedb.conf' do
  source 'etc_updatedb.conf.erb'
  owner "root"
  group "root"
  mode "0600"
end
