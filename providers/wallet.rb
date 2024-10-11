#
# Cookbook Name:: sys
# File:: providers/wallet.rb
#
# Copyright 2015-2024 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <C.Huhn@gsi.de>
#  Dennis Klein       <d.klein@gsi.de>
#  Matthias Pausch    <m.pausch@gsi.de>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'etc'
require 'open3'

use_inline_resources

action :deploy do
  if ! ::File.exist?(new_resource.place) || ! check_keytab()
    unless check_krb5
      Chef::Log.warn "Unable to deploy #{new_resource.principal}: "\
                     'Kerberos not installed or /etc/krb5.keytab missing.'
        return
    end

    bash "deploy #{new_resource.principal}" do
      cwd "/"
      code <<-CODE
        # TMPFILE must not exist yet, therefore --dry-run
        TMPFILE=$(mktemp --dry-run)
        retval=1
        kinit -t /etc/krb5.keytab host/#{node['fqdn']} || exit 1
        if wallet get keytab '#{new_resource.principal}' -f "$TMPFILE"; then
          retval=0
          # in contrast to mv cat follows symlinks
          cat "$TMPFILE" > '#{new_resource.place}'
        fi
        rm "$TMPFILE"
        kdestroy
        exit $retval
      CODE
    end
    new_resource.updated_by_last_action(true)
  end

  unless check_stat()
    file new_resource.place do
      mode new_resource.mode
      owner new_resource.owner
      group new_resource.group
      # do not create keytabs, only update ownership and permissions
      only_if { ::File.exist?(new_resource.place) }
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
  ::File.exist?('/etc/krb5.keytab') && ::File.exist?('/usr/bin/kinit')
end
