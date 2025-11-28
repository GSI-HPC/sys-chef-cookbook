#
# Cookbook:: sys
# Recipe:: cups
#
# Copyright:: 2014-2025 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <c.huhn@gsi.de>
#  Dennis Klein       <d.klein@gsi.de>
#  Matthias Pausch    <m.pausch@gsi.de>
#  Thomas Roth        <t.roth@gsi.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

if node['sys']['cups']

  package 'cups-client'

  directory '/etc/cups' do
    mode 0755
  end

  template '/etc/cups/client.conf' do
    source    'etc_generic.erb'
    cookbook  'sys'
    mode      0644
    variables({
      :content => "ServerName #{node['sys']['cups']['server']}"
    })
    only_if { node['sys']['cups']['server'] }
  end

  #TODO: setup a /etc/cups/lpoptions ?!

end
