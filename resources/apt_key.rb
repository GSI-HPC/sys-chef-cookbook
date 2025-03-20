#
# Cookbook:: sys
# Resource:: sys_apt_key
#
# Copyright:: 2013-2025 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <c.huhn@gsi.de>
#  Dennis Klein       <d.klein@gsi.de>
#  Matthias Pausch    <m.pausch@gsi.de>
#  Victor Penso       <v.penso@gsi.de>
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

# input property of execute resource appeared in Chef 16.2
if Gem::Requirement.new('>= 16.2')
     .satisfied_by?(Gem::Version.new(Chef::VERSION))

  default_action :add
  property :key, String, required: true
  property :keyring, String, name_property: true, desired_state: false
  property :place, String, default: '/etc/apt/trusted.gpg.d'

  # small helper class to extract the uid and fingerprint from a PGP key
  class Sys
    class Apt
      class Key
        attr_reader :key, :fingerprint, :uid

        def initialize(key)
          @key = key

          keyring = Tempfile.new('sys_apt_key')
          gpg_cmd = "gpg --no-default-keyring --keyring #{keyring.path}"

          cmd = Mixlib::ShellOut.new(
            "#{gpg_cmd} --show-keys --with-colons",
            input: key
          )
          cmd.run_command
          keyring.unlink

          @fingerprint = cmd.stdout.match(/^fpr:.*/)[0].split(':')[9]
          @uid = cmd.stdout.match(/^uid:.*/)[0].split(':')[9]
        end

        # clean up the uid to make it suitable for a filename
        def tidy_uid
          # strip the email part, convert it to lowercase,
          # replace all non alphanumerical characters to dashes
          #  including whitespace
          tidy_uid = @uid.match(/(.*?)\s+<(.*)>/)[1].downcase
                       .gsub(/[^[:alnum:]]+/, ' ').strip.gsub(' ', '-')
        end
      end
    end
  end

  load_current_value do |new_resource|

    new_key =  Sys::Apt::Key.new new_resource.key

    keyfile = "#{new_resource.place}/#{new_key.tidy_uid}.asc"
    if ::File.exist?(keyfile)
      key IO.read(keyfile)
    else
      current_value_does_not_exist!
    end
  end

  action :add do
    new_key = Sys::Apt::Key.new new_resource.key

    keyfile = "#{new_resource.place}/#{new_key.tidy_uid}.asc"

    directory new_resource.place do
      mode 0o755
    end

    keyring = Tempfile.new('sys_apt_key')
    gpg_cmd = "gpg --no-default-keyring --keyring #{keyring.path}"

    # man apt-secure:
    # > Alternatively, keys may be placed in /etc/apt/keyrings for local keys,
    # > […] ASCII-armored keys must use an extension of .asc, and unarmored keys
    # > an extension of .gpg.
    # > To generate keys suitable for use in APT using GnuPG, you will need to
    # > use the gpg --export-options export-minimal [--armor] --export command.
    execute "Adding '#{new_key.uid}' (#{new_key.fingerprint}) "\
            "to #{new_resource.place}" do
      command "#{gpg_cmd} --import;" \
              " #{gpg_cmd} --export-options export-minimal --armor --export"\
              " --output #{keyfile}"
      input new_resource.key
    end

    keyring.unlink
  end

  action :remove do
    new_key =  Sys::Apt::Key.new new_resource.key

    file "#{new_resource.place}/#{new_key.tidy_uid}.asc" do
      action :delete
    end
  end

else
  # old school custom resource
  actions :add, :remove
  default_action :add
  attribute :key, :kind_of => String, :name_attribute => true
end
