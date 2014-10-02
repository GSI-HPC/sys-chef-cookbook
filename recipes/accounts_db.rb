#
# Cookbook Name:: sys
# Recipe:: accounts_db
#
# Copyright 2014, GSI HPC department <hpc@gsi.de>
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

# no databags with chef-solo ...
unless Chef::Config[:solo] or (node.sys.accounts.empty? and node.sys.groups.empty?)

  bag = data_bag('accounts')

  node.sys.accounts.each do |name, account|

    begin
      unless bag.include?(name)
        log("No data bag item found for account '#{name}'"){ level :debug }
        next
      end
      item = data_bag_item('accounts', name)

      node.default_unless['sys']['accounts'][name]['comment'] = item['comment']

      item['account'].each do |key, value|
        node.default_unless['sys']['accounts'][name][key] = value
        if key == 'home'
          node.default_unless['sys']['accounts'][name]['supports']['manage_home'] = true
        end
      end
    rescue Exception => e
      log("Attribute merge with data bag 'accounts/#{name}' failed: #{e.message}"){ level :debug }
    end
  end

  # TODO: add stuff for creating groups from data bags
  bag = data_bag('localgroups')

  # this is a list of groups defined in account attributes:
  groups = node[:sys][:accounts].values.map{|x| x[:gid]}.compact

  # Add groups from node attributes
  groups |= node[:sys][:groups].keys

  groups.each do |grp|

    unless bag.include?(grp)
      log("No data bag item found for group '#{grp}'") { level :debug }
      next
    end

    data_bag_item('localgroups', grp).each do |key, value|
      node.default_unless['sys']['groups'][grp][key] = value
    end

  end

  # now we call the stuff that does the work:
  include_recipe "sys::accounts"

end




 
  
   
    
     
      
       
        
      
    
  

