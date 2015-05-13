sys_sdparm '/dev/sd*' do
  flag 'WCE'
  action :clear
end
