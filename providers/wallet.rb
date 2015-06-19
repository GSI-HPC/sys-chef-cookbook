require 'etc'
require 'open3'

use_inline_resources

action :deploy do
  if ! ::File.exists?(new_resource.place) || ! check_keytab()
    bash "deploy #{new_resource.principal}" do
      cwd "/"
      code <<-EOH
        rm -f #{new_resource.place}.tmp
        kinit -t /etc/krb5.keytab host/#{node['fqdn']}
        wallet get keytab #{new_resource.principal}@#{node['sys']['krb5']['realm'].upcase} -f #{new_resource.place}.tmp
        mv #{new_resource.place}.tmp #{new_resource.place}
        kdestroy
      EOH
    end
    new_resource.updated_by_last_action(true)
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
  cmd = "ktutil -k #{new_resource.place} list --keys | grep -q #{new_resource.principal}"
  exit_status = 1
  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
    exit_status = wait_thr.value
  end

  return exit_status == 0
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
  if ::File.exists?(new_resource.place)
    stat = ::File.stat(new_resource.place)
    check = check_mode(stat) && check_owner(stat) && check_group(stat)
  end
  return check
end
