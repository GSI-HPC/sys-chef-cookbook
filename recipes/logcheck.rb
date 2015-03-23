#
# setup logcheck
#

if node['sys']['logcheck']  

  package 'logcheck'
  package 'logcheck-database'
  
  package 'syslog-summary' if node['sys']['logcheck']['syslog-summary']
  
  template '/etc/logcheck/logcheck.conf' do
    source 'etc_logcheck_logcheck.conf.erb'
    user 'root'
    group 'logcheck'
    mode 0640
  end
  
  cookbook_file '/etc/cron.d/logcheck' do
    source 'etc_cron.d_logcheck'
    action node['sys']['logcheck']['disable']?'delete':'create'
  end
  
end
