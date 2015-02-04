#
# recipe for clamav virus scanner
#

package 'clamav'

params = { }

if node['http_proxy']
  params[:proxy_srv]  = node['http_proxy']['name']
  params[:proxy_name] = node['http_proxy']['port']
end

template '/etc/clamav/freshclam.conf' do
  source 'etc_clamav_freshclam.conf.erb'
  variables params
end
