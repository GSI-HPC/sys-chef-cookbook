sys_sdparm '/dev/sd*' do
  flag 'WCE'
  action :restore_default
end
