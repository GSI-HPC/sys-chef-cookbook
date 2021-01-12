#
# Cookbook Name:: sys
# Ohai plugin to collect SSH key fingerprints
#
# Copyright 2021 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Andre Kerkhoff    <a.kerkhoff@gsi.de>
#  Christopher Huhn  <c.huhn@gsi.de>
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

Ohai.plugin(:SSHHostKeyFingerprints) do
  provides 'keys/ssh'
  depends 'keys/ssh'

  collect_data(:default) do
    fingerprints = Mash.new

    keys['ssh'].each do |type, key|
      next unless type =~ /^host_(\w+)_public$/

      # strip prefix and suffix from type:
      type = Regexp.last_match(1)

      # ecdsa has a special type attribute
      ssh_type = if keys['ssh'].include? "host_#{type}_type"
                   keys['ssh']["host_#{type}_type"]
                 else
                   "ssh-#{type}"
                 end

      fingerprints[type] = {}

      %w[md5 sha256].each do |method|
        so = shell_out("ssh-keygen -l -f - -E #{method}",
                       input: "#{ssh_type} #{key}\n",
                       timeout: 5)
        __fp_hash, fp, _fp_type = so.stdout.lines.first
                                    .match(/^\d+ (\w+):(\S+) .*? \((\w+)\)$/)
                                    .captures
        # some checks could be made here, ie.
        # fp_type.downcase == type && fp_hash.downcase == method
        fingerprints[type][method] = fp
      end
    end

    keys['ssh']['fingerprints'] = fingerprints
  end
end
