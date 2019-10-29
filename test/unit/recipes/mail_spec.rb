#
# Cookbook Name:: sys
# Unit tests for recipe sys::mail
#
# Copyright 2015-2020 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn  <c.huhn@gsi.de>
#  Dennis Klein      <d.klein@gsi.de>
#  Matthias Pausch   <m.pausch@gsi.de>
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

describe 'sys::mail' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'node.sys.mail.relay is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do

    let(:canonical_update_test) do
      '/usr/bin/test /etc/postfix/canonical.db -nt /etc/postfix/canonical'
    end
    let(:virtual_update_test) do
      '/usr/bin/test /etc/postfix/virtual.db -nt /etc/postfix/virtual'
    end

    before do
      stub_command(canonical_update_test).and_return(true)
      stub_command(virtual_update_test).and_return(true)

      @example_alias_name   = 'foo'
      @example_alias_value  = 'foo@bar.mail'
      @expected_alias_value = 'foo@bar.mail'

      allow(::File).to receive(:exist?).and_call_original
      allow(::File).to receive(:exist?).with('/etc/aliases').and_return(true)
    end

    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default[:sys][:mail][:relay] = 'smtp.example.net'
        node.default[:sys][:mail][:aliases][@example_alias_name.to_sym] =
          @example_alias_value
      end.converge(described_recipe)
    end

    postfix = 'postfix'
    it "installs package '#{postfix}'" do
      expect(chef_run).to install_package(postfix)
    end

    it "manages service '#{postfix}'" do
      expect(chef_run).to enable_service(postfix)
      expect(chef_run).to start_service(postfix)
    end

    etc_mailname = '/etc/mailname'
    it "manages #{etc_mailname}" do
      expect(chef_run).to create_file(etc_mailname)
                           .with_content("#{chef_run.node['fqdn']}\n")
    end

    etc_postfix_canonical = '/etc/postfix/canonical'
    it "manages #{etc_postfix_canonical}" do
      expect(chef_run).to create_template(etc_postfix_canonical)
                           .with_mode('0600')
      expect(chef_run.template(etc_postfix_canonical))
        .to notify("execute[update-canonical]") .to(:run).immediately
    end

    it "updates #{etc_postfix_canonical}.db when needed" do
      stub_command(canonical_update_test).and_return(false)
      chef_run.converge(described_recipe)
      expect(chef_run).to run_execute('update-canonical')
      expect(chef_run.execute('update-canonical'))
        .to notify("service[#{postfix}]").to(:reload).delayed
    end

    it "does nothing when #{etc_postfix_canonical}.db is up to date" do
      #stub_command(canonical_update_test).and_return(true)
      expect(chef_run).to_not run_execute('update-canonical')
    end

    etc_postfix_virtual = '/etc/postfix/virtual'
    it "manages #{etc_postfix_virtual}" do
      expect(chef_run).to create_template(etc_postfix_virtual).with_mode('0600')
      expect(chef_run.template(etc_postfix_virtual))
        .to notify("execute[#{update_virtual}]").to(:run).immediately
      expect(chef_run.execute(update_virtual)).to do_nothing
      expect(chef_run.execute(update_virtual))
        .to notify("service[#{postfix}]").to(:reload).delayed
    end

    etc_postfix_main_cf = '/etc/postfix/main.cf'
    it "manages #{etc_postfix_main_cf}" do
      expect(chef_run).to create_template(etc_postfix_main_cf).with_mode('0644')
      expect(chef_run.template(etc_postfix_main_cf))
        .to notify("service[#{postfix}]").to(:restart).delayed
    end

    etc_aliases = '/etc/aliases'
    update_aliases = 'Update Postfix aliases'

    it "manages #{etc_aliases}" do
      expect(chef_run).to add_sys_mail_alias(@example_alias_name)
                            .with_to([@expected_alias_value])
                            .with_aliases_file(etc_aliases)
      expect(chef_run.find_resource(:sys_mail_alias, @example_alias_name))
        .to notify("execute[#{update_aliases}]").to(:run).delayed
      # expect(chef_run).to run_execute(update_aliases)
      expect(chef_run.execute(update_aliases))
        .to notify("service[#{postfix}]").to(:reload).delayed
    end
  end
end
