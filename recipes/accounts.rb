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

  node[:sys][:groups].each do |name,grp|
    log("Creating the group '#{name}': #{grp}"){ level :debug }
    group name do
      gid    grp[:gid]    if grp.has_key?(:gid)
      system grp[:system] or false
    end
  end
  
  node.sys.accounts.each do |name,account|       

    # Currently data bags aren't supported when running chef-solo,
    # but this will be implemented in a coming version!
    unless Chef::Config[:solo]
      # merge with user specific data bag if existing
      if data_bag('accounts').include?(name)
        bag = data_bag_item('accounts', name)
        if bag.has_key?('account')
          Chef::Log.debug "data bag found for account #{name}."

          # we have to turn the node object into a plain hash,
          #  otherwise we cannot add data from a bag:
          account = account ? account.to_hash : Hash.new

          account[:comment] = bag['comment'] unless account.has_key?('comment')

          # Merge the existing account information with the data-bag
          bag['account'].each do |k,v|
            unless account[k]
              account[k] = v
              if k == 'home' and not account[:supports]
                account[:supports] =  { :manage_home => true }
              end
              Chef::Log.debug "Adding info from data-bag: #{k}: #{v}"
            end
          end
        end
      else
        Chef::Log.debug "No data bag for user ID #{name} found"
      end
    end
    
    # we don't add users without any attributes:
    if defined?(account) and not account.empty?
      
      begin   
        # check if the given group exists, gid could be numeric or string:
        #  additionally the group might not exist but was maybe just created:
        if account.has_key?(:gid) and not
            (node.etc.group.has_key?(account[:gid]) or 
             node[:etc][:group].values.detect { |e| e[:gid] == account[:gid] }) and not
            (node[:sys][:groups].has_key?(account[:gid]) or 
             node[:sys][:groups].values.detect { |e| e[:gid] == account[:gid] })
          
          raise "The given group '#{account[:gid]}' does not exist"
        else
          
          # This is a wrapper to call the `user` resource by attributes
          #  I got the impression this is rather boiler-plate?!
          user name do
            uid        account[:uid]       if account.has_key?(:uid)
            gid        account[:gid]       if account.has_key?(:gid)
            home       account[:home]      if account.has_key?(:home)
            shell      account[:shell]     if account.has_key?(:shell)
            password   account[:password]  if account.has_key?(:password)
            comment    account[:comment]   if account.has_key?(:comment)
            supports(  account[:supports]) if account.has_key?(:supports)
            system     account[:system]    or false
            action     account[:action]    if account.has_key?(:action)
          end
        end
        
      rescue Exception => e
        log("Creation of user '#{name}' aborted: #{e.message}"){ level :error }
      end
      
    else
      log("Skipping user '#{name}' with no attributes defined"){ level :warn }
    end
  end
end
