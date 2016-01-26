#
# Copy a sensible /etc/updatedb.conf to every host
#

unless node['sys']['updatedb'].empty? # ~FC023
  template '/etc/updatedb.conf' do
    source 'etc_updatedb.conf.erb'
    owner "root"
    group "root"
    mode "0600"
    variables({
      :prunebindmounts => node['sys']['updatedb']['prunebindmounts'],
      :prunepaths      => node['sys']['updatedb']['prunepaths'],
      :prunefs         => node['sys']['updatedb']['prunefs']
    })
  end
end
