#
# Copyright 2012, Victor Penso
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

define :sys_mail_alias, :to => String.new do
  if ::File.exists? '/etc/aliases'
    # read the alias file
    aliases = Hash.new
    (::File.readlines('/etc/aliases')).each do |line|
      next if line =~ /^#/
      account, mail_address = line.split(':')
      aliases[account] = mail_address.lstrip.chop
    end
    # add/change alias
    unless aliases.has_key? params[:name] and aliases[params[:name]] == params[:to]
      aliases[params[:name]] = params[:to]
      ::File.open('/etc/aliases','w') do |file|
        aliases.each do |account,mail_address|
          file.puts "#{account}: #{mail_address}"
        end
      end
      Chef::Log.info("Postfix aliases #{params[:name]} to #{params[:to]} set.")
      system('newaliases')
    end
  else
    log("File [/etc/aliases] missing, is the mail system installed?") { level :warn  }
  end
end
