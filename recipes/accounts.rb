#
# Cookbook Name:: sys
# Recipe:: accounts
#
# Copyright 2013-2020 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <c.huhn@gsi.de>
#  Dennis Klein       <d.klein@gsi.de>
#  Matthias Pausch    <m.pausch@gsi.de>
#  Victor Penso       <v.penso@gsi.de>
#  Thomas Roth        <t.roth@gsi.de>
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

  # required to handle passwords with the 'user' resource
  #  cf. https://docs.chef.io/resource_user.html
  package 'ruby-shadow'

  # TODO: we might want to create groups only implictly defined
  #       from accounts...gid attributes but described in a databag
  bag = data_bag('localgroups') unless Chef::Config[:solo]
  node['sys']['groups'].each do |name, grp|
    unless Chef::Config[:solo]

      if bag.include?(name)
        item = data_bag_item('localgroups', name)
        grp = grp.to_h
        grp['gid']     ||= item['gid']
      else
        log "No data bag item for group '#{name}'" do
          level :debug
        end
      end
    end

    #begin
      group name do
        # grp.each{|k,v| send(k,v)} is elegant
        #  but hard to handle for account attributes
        #  that we don't want to send to the group resource
        gid     grp['gid']     if grp['gid']
        members grp['members'] if grp['members']
        append  grp['append']  || false
        system  grp['system']  || false
      end
    #rescue StandardError => e
    #  Chef::Log.error("Creation of group resource '#{name}' failed: " +
    #                  e.message)
    #end
  end

  bag = data_bag('accounts') unless Chef::Config[:solo]
  node['sys']['accounts'].each do |name, caccount|
    # gives us a mutable copy of the ImmutableMash:
    account = (caccount) ? caccount.merge({}) : {}
    unless Chef::Config[:solo]
      if bag.include?(name)
        item = data_bag_item('accounts', name)
        account['comment'] ||= item['comment']
        item['account'].each do |key, value|
          account[key.to_s] = value unless account.key?(key.to_s)
        end
      else
        log "No data bag item for account '#{name}'" do
          level :warn
        end
      end
    end

    begin

      comment = account['comment'] || 'managed by Chef via sys::accounts recipe'

      # 'supports(manage_home: ... )' has become 'manage_home ...'
      if account.key?('supports')
        account['supports'].each do |key, value|
          account[key.to_s] = value
        end
      end

      # If attribute local exists and is set to false,
      #  we skip the creation of the account itself
      # FIXME: use pam_mkhomedir instead
      if account['local'] != false # nil ~= true

        # In case a group ID is specified
        if account.key?('gid')

          # Make sure that it exists already...
          group_exists = (node['etc']['group'].has_key?(account['gid']) or
                          node['etc']['group'].values.detect do |g|
                            g['gid'] == account['gid']
                          end)
          # ...or that it has been create during this Chef run
          was_just_created = (node['sys']['groups'].has_key?(account['gid']) or
                              node['sys']['groups'].values.detect do |g|
                                g['gid'] == account['gid']
                              end)

          # If this isn't the case something went wrong!
          unless group_exists or was_just_created
            raise "The given group '#{account['gid']}' "\
                  "does not exist or wasn't defined"
          end

        end

        # if a home directory is explicitly specified and
        #  it does not exist, we default to 'manage_home true'
        if account['manage_home'] != false && account.key?('home')
          File.exist?(account['home']) || account['manage_home'] = true
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
          manage_home account['manage_home']
          ignore_failure true
        end
      elsif account['manage_home']
        # don't create the account but only its homedir:
        directory account['home'] do
          owner account['uid'].to_i
          group account['gid']
          mode 0750
          # creating a local home dir for a central account will fail
          #  until the central account information is properly set up
          ignore_failure true
        end
      end

      # add sudo rules from the sudo attribute:
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

      # add pam_access rules from the remote attribute:
      if account.key?('remote')
        if node['sys']['pam'].key?('access')
          node.default['sys']['pam']['access'] <<
            "+ : #{name} : #{account['remote']} LOCAL"
        else
          node.default['sys']['pam']['access'] = [
            "+ : #{name} : #{account['remote']} LOCAL"
          ]
        end
        log "Configuring remote access rules for #{name}" do
          level :debug
        end
      end

    rescue StandardError => e
      Chef::Log.error("Creation of user resource '#{name}' failed: " +
                      e.message)
    end
  end
end
