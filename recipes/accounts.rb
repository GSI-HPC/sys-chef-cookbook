#
# Cookbook Name:: sys
# Recipe:: accounts
#
# Copyright 2013, Victor Penso
# Copyright 2015, Dennis Klein
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

unless (node['sys']['accounts'].empty? and node['sys']['groups'].empty?)

  package 'ruby-shadow'

  bag = data_bag('localgroups') unless Chef::Config[:solo]
  node['sys']['groups'].each do |name, grp|
    unless Chef::Config[:solo]
      begin
        raise "No data bag item for group '#{name}'" unless bag.include?(name)

        item = data_bag_item('localgroups', name)
        grp = grp.to_hash
        grp['gid']     ||= item['gid']
      rescue Exception => e
        log("Attribute merge with data bag 'localgroups/#{name}' failed: #{e.message}"){ level :debug }
      end
    end

    begin
      group name do
        # grp.each{|k,v| send(k,v)} is elegant
        #  but hard to handle for account attributes
        #  that we don't want to send to the group ressource
        gid     grp['gid']     if grp['gid']
        members grp['members'] if grp['members']
        append  grp['append']  || false
        system  grp['system']  || false
      end
    rescue Exception => e
      log("Creation of group resource '#{name}' failed: #{e.message}"){
        level :error
      }
    end
  end

  bag = data_bag('accounts') unless Chef::Config[:solo]
  node['sys']['accounts'].each do |name, account|
    unless Chef::Config[:solo]
      begin
        raise "No data bag item for account '#{name}'" unless bag.include?(name)

        item = data_bag_item('accounts', name)
        account = account.to_hash
        account['comment'] ||= item['comment']
        item['account'].each do |key, value|
          account[key] ||= value
          if key == 'home'
            account['supports'] ||= { :manage_home => true }
          end
        end
      rescue Exception => e
        log("Attribute merge with data bag 'accounts/#{name}' failed: #{e.message}"){ level :debug }
      end
    end

    begin
      if account.has_key?('gid')
        group_exists = (node['etc']['group'].has_key?(account['gid']) or
          node['etc']['group'].values.detect { |g| g['gid'] == account['gid'] })
        was_just_created = (node['sys']['groups'].has_key?(account['gid']) or
          node['sys']['groups'].values.detect { |g| g['gid'] == account['gid'] })

        unless group_exists or was_just_created
          raise "The given group '#{account['gid']}' does not exist or wasn't defined"
        end
      end

      comment = account['comment'] || 'managed by Chef via sys::accounts recipe'

      user name do
        # account.each{|k,v| send(k,v)} is elegant
        #  but hard to handle for account attributes
        #  that we don't want to send to the user ressource
        comment  comment.gsub(/:+/, '_')  # gecos does not like colons
        uid      account['uid']
        gid      account['gid']
        password account['password']
        home     account['home']
        shell    account['shell']
        system   account['system'] # ~FC048 No command is issued here
        supports account['supports'] || {}
      end

      if account.has_key?('sudo')
        # FIXME: this will overwrite all previous invocations
        #  rather set node['sys']['sudo'] attributes here
        #  but did not get it to work for now :(
        sys_sudo 'localadmin' do
          rules [ "#{name} #{node['fqdn']} = #{account['sudo']}" ]
        end
        node
      end

      if account.has_key?('remote')
        node.force_override['sys']['pam']['access'] = [ "+:#{name}:#{account['remote']} LOCAL" ] # ~FC019 (Bug in foodcritic)
      end

    rescue Exception => e
      log("Creation of user resource '#{name}' failed: #{e.message}"){
        level :error
      }
    end
  end
end
