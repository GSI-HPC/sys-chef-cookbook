#
# Author:: Dennis Klein
# Author:: Victor Penso
#
# Copyright:: 2013, GSI HPC department
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

action :add do
  # Deploy the APT key if true
  deploy_flag = true

  newkey = new_resource.key
  # Remove leading white-spaces
  newkey = newkey.gsub(/^ */,'')

  # fingerprint for the key as defined by the client code, remove white spaces
  fingerprint_command = "echo '#{newkey}' | gpg --with-fingerprint --no-options"
  fingerprint_command += " 2>/dev/null | grep fingerprint | cut -d= -f2 | tr -d ' '"
  cmd = Mixlib::ShellOut.new(fingerprint_command)
  cmd.run_command
  # TODO:
  #cmd.error!
  fingerprint = cmd.stdout.chomp || nil

  unless fingerprint.nil?
    # Get a list of all key fingerprints in the system, remove white spaces
    fingerprints_command = "apt-key finger 2>/dev/null | grep fingerprint |"
    fingerprints_command += " tr -s ' ' | cut -d' ' -f2 | cut -d'/' -f2"
    cmd.run_command
    # TODO:
    #cmd.error!
    fingerprints = cmd.stdout.split("\n").map { |f| f.delete(' ') }
    # If the fingerprints exists, assume the key is deployed already
    deploy_flag = false if fingerprints.include? fingerprint
  end

  ruby_block "Add APT key with fingerpint #{fingerprint}" do
    block do
      cmd = Mixlib::ShellOut.new("echo '#{newkey}' | apt-key add - >/dev/null")
      cmd.run_command
      cmd.error!
    end
    only_if do deploy_flag end
  end

  new_resource.updated_by_last_action(deploy_flag)
end

action :remove do
  fingerprint = new_resource.key.gsub(/^ */,'')
  fp_suffix = fingerprint[-8..-1]
  execute "Remove APT key with fingerprint #{fingerprint}" do
    command "apt-key del '#{fp_suffix}' >/dev/null"
    only_if "apt-key list | grep '#{fp_suffix}' >/dev/null"
  end

  new_resource.updated_by_last_action(true)
end
