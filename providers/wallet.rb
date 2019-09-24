require 'etc'
require 'open3'

use_inline_resources

action :deploy do
  if ! ::File.exist?(new_resource.place) || ! check_keytab()
    if check_krb5
      bash "deploy #{new_resource.principal}" do
        cwd "/"
        code <<-EOH
          if [ -e #{new_resource.place}.tmp ]; then
              rm -f #{new_resource.place}.tmp
          fi
          kinit -t /etc/krb5.keytab host/#{node['fqdn']}
          wallet get keytab #{new_resource.principal}@#{node['sys']['krb5']['realm'].upcase} -f #{new_resource.place}.tmp
          ret=$?
          if [ $ret = 0 ]; then
              mv #{new_resource.place}.tmp #{new_resource.place}
          else
              if [ -e #{new_resource.place}.tmp ]; then
                  rm -f #{new_resource.place}.tmp
              fi
              exit $ret
          fi
          kdestroy
        EOH
      end
      new_resource.updated_by_last_action(true)
    else
      Chef::Log.warn("Unable to deploy #{new_recource.principal}: Kerberos not installed or /etc/krb5.keytab missing.")
    end
  end

  unless check_stat()
    file new_resource.place do
      mode new_resource.mode
      owner new_resource.owner
      group new_resource.group
    end
    new_resource.updated_by_last_action(true)
  end
end

def check_keytab()
  check_keytab = "ktutil -k #{new_resource.place} list --keys | grep -q #{new_resource.principal}"
  cmd = Mixlib::ShellOut.new(check_keytab)
  cmd.run_command
  return cmd.exitstatus == 0
end

def check_mode(stat)
  file_mode = sprintf("%o", stat.mode)
  return file_mode.eql?("100#{new_resource.mode[-3..-1]}")
end

def check_owner(stat)
  user = Etc.getpwuid(stat.uid).name
  return user.eql?(new_resource.owner)
end

def check_group(stat)
  group =  Etc.getgrgid(stat.gid).name
  return group.eql?(new_resource.group)
end

def check_stat()
  check = false
  if ::File.exist?(new_resource.place)
    stat = ::File.stat(new_resource.place)
    check = check_mode(stat) && check_owner(stat) && check_group(stat)
  end
  return check
end

def check_krb5()
  return File.exist?('/etc/krb5.keytab') && File.exist?('/usr/bin/kinit')
end
