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

unless node.sys.accounts.empty?

  package 'ruby-shadow'

  node.sys.accounts.each do |name,account|

    # check if the given group exists, gid could be numeric or string:
    if account.has_key?(:gid) and not
        (node.etc.group.has_key?(account[:gid]) or node[:etc][:group].values.detect { |e| e[:gid] == account[:gid] })

      log("The given group '#{account[:gid]}' does not exist - creation of user '#{name}' skipped"){ level :error }

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
        system     true                if account.has_key?(:system) and account[:system]
        action     account[:action]    if account.has_key?(:action)
      end

    end
  end

end
