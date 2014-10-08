#
# Cookbook Name:: sys
# Recipe:: accounts
#
# Copyright 2013, Victor Penso
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

unless (node.sys.accounts.empty? and node.sys.groups.empty?)

  package 'ruby-shadow'

  node.sys.groups.each do |name, grp|
    begin
      group name do
        # grp.each{|k,v| send(k,v)} is elegant but hard to handle for account attributes
        #  that we don't want to send to the group ressource
        gid     grp['gid']     if grp['gid']
        members grp['members'] if grp['members']
        append  grp['append']  || false
        system  grp['system']  || false
      end
    rescue Exception => e
      log("Creation of group resource '#{name}' failed: #{e.message}"){ level :error }
    end
  end

  node.sys.accounts.each do |name, account|
    begin

      if account.has_key?(:gid)
        group_exists = (node.etc.group.has_key?(account[:gid]) or
          node.etc.group.values.detect { |e| e[:gid] == account[:gid] })
        was_just_created = (node.sys.groups.has_key?(account[:gid]) or
          node.sys.groups.values.detect { |e| e[:gid] == account[:gid] })
        unless group_exists or was_just_created
          raise "The given group '#{account[:gid]}' does not exist or wasn't defined"
        end
      end

      comment = account['comment'] || 'managed by Chef via sys::accounts recipe'

      user name do
        # account.each{|k,v| send(k,v)} is elegant but hard to handle for account attributes
        #  that we don't want to send to the user ressource
        comment  comment.gsub(/:+/, '_')  # gecos does not like colons
        uid      account['uid']
        gid      account['gid']
        password account['password']
        home     account['home']
        shell    account['shell']
        system   account['system']
        supports account['supports']
      end
    rescue Exception => e
      log("Creation of user resource '#{name}' failed: #{e.message}"){ level :error }
    end
  end
end
