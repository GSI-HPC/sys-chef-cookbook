#
# Cookbook Name:: sys
# Recipe:: accounts
#
# Copyright 2013, Victor Penso
# Copyright 2015, Dennis Klein
# Copyright 2015, Christopher Huhn
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

  # TODO: we might want to create groups only implictly defined
  #       from accounts...gid attributes but described in a databag
  bag = data_bag('localgroups') unless Chef::Config[:solo]
  node['sys']['groups'].each do |name, grp|
    unless Chef::Config[:solo]
      begin
        raise "No data bag item for group '#{name}'" unless bag.include?(name)

        item = data_bag_item('localgroups', name)
        grp = grp.to_hash
        grp['gid']     ||= item['gid']
      rescue StandardError => e
        Chef::Log.debug("Attribute merge with data bag 'localgroups/#{name}' failed: #{e.message}")
      end
    end

    begin
      group name do
        # grp.each{|k,v| send(k,v)} is elegant
        #  but hard to handle for account attributes
        #  that we don't want to send to the group resource
        gid     grp['gid']     if grp['gid']
        members grp['members'] if grp['members']
        append  grp['append']  || false
        system  grp['system']  || false
      end
    rescue StandardError => e
      Chef::Log.error("Creation of group resource '#{name}' failed: #{e.message}")
    end
  end

  bag = data_bag('accounts') unless Chef::Config[:solo]
  node['sys']['accounts'].each do |name, caccount|
    account = caccount.merge({}) # gives us a mutable copy of the ImmutableMash
    unless Chef::Config[:solo]
      begin
        raise "No data bag item for account '#{name}'" unless bag.include?(name)

        item = data_bag_item('accounts', name)
        account['comment'] ||= item['comment']
        item['account'].each do |key, value|
          account[key] = value unless account.has_key?(key)
          if key == 'home'
            account['supports'] = { :manage_home => true }
          end
        end
      rescue StandardError => e
        Chef::Log.debug("Attribute merge with data bag 'accounts/#{name}' failed: #{e.message}")
      end
    end

    begin

      comment = account['comment'] || 'managed by Chef via sys::accounts recipe'

      supports_hash = Hash.new
      if account.has_key? 'supports'
        account['supports'].each do |key, value|
          supports_hash[key.to_s] = value
          supports_hash[key.to_sym] = value
        end
      end

      # If attribute local exists and is set to false,
      #  we skip the creation of the account itself
      if account['local'] != false # nil ~= true

        # In case a group ID is specified
        if account.has_key?('gid')

          # Make sure that it exists already...
          group_exists = (node['etc']['group'].has_key?(account['gid']) or
            node['etc']['group'].values.detect { |g| g['gid'] == account['gid'] })
          # ...or that it has been create during this Chef run
          was_just_created = (node['sys']['groups'].has_key?(account['gid']) or
            node['sys']['groups'].values.detect { |g| g['gid'] == account['gid'] })

          # If this isn't the case something went wrong!
          unless group_exists or was_just_created
            raise "The given group '#{account['gid']}' does not exist or wasn't defined"
          end

        end


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
          supports supports_hash
          ignore_failure true
        end
      elsif account['supports']['manage_home']
        # don't create the account but only its homedir:
        directory account['home'] do
          owner account['uid']
          group account['gid']
          mode 0750
        end
      end

      if account.has_key?('sudo')
        rule = "#{name} #{node['fqdn']} = #{account['sudo']}"
        if node['sys']['sudo'].has_key?('localadmin')
          node.default['sys']['sudo']['localadmin']['rules'].push(rule)
          Chef::Log.debug("Adding #{name} to localadmin sudoers")
        else
          node.default['sys']['sudo']['localadmin'] = { 'rules' => [ rule ] }
          Chef::Log.debug("Creating localadmin sudoers for #{name}")
        end
      end

      if account.has_key?('remote')
        node.default['sys']['pam']['access'].unshift("+:#{name}:#{account['remote']} LOCAL")
      end

    rescue StandardError => e
      Chef::Log.error("Creation of user resource '#{name}' failed: #{e.message}")
    end
  end
end
