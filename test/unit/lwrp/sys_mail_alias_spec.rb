#
# Cookbook Name:: sys
# Unit tests for sys_mail_alias custom resource
#
# Copyright 2015-2019 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn  <C.Huhn@gsi.de>
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

describe 'lwrp: sys_mail_alias' do
  let(:runner) do
    ChefSpec::SoloRunner.new(
      :step_into => ['sys_mail_alias']
    )
  end

  describe 'action :add' do
    let(:chef_run) { runner.converge('fixtures::sys_mail_alias_add') }

    context '/etc/aliases exists' do
      before { etc_aliases_exists }
      it 'does not create /etc/aliases' do
        expect(chef_run).not_to create_file('/etc/aliases')
      end

      context 'does not contain alias' do
        before { contains_alias 'not: the@expected.alias' }
        it 'inserts alias' do
          expect(chef_run).to add_sys_mail_alias('foo')
        end
      end

      context 'contains alias with outdated value' do
        before { contains_alias 'foo: old_value' }
        it 'changes alias value' do
          expect(chef_run).to add_sys_mail_alias('foo')
        end
      end

      context 'contains already up-to-date alias' do
        before { contains_alias 'foo: "foo@bar"'}
        it 'still runs the resource' do
          expect(chef_run).to add_sys_mail_alias('foo')
        end
      end
    end

    context '/etc/aliases does not exist' do
      before { etc_aliases_does_not_exist }
      it 'creates /etc/aliases' do
        expect(chef_run).to add_sys_mail_alias('foo')
      end
    end
  end

  describe 'action :remove' do
    let(:chef_run) { runner.converge('fixtures::sys_mail_alias_remove') }

    before { etc_aliases_exists }

    context 'alias exists' do
      before { contains_alias 'foo: asdf' }
      it 'removes the alias' do
        expect(chef_run).to remove_sys_mail_alias('foo')
      end
    end

    context 'alias does not exist' do
      before { contains_alias 'not: the_expected_alias' }
      it 'does nothing' do
        expect(chef_run).to remove_sys_mail_alias('foo')
      end
    end
  end
end

def etc_aliases_exists
  allow(::File).to receive(:exist?).and_call_original
  allow(::File).to receive(:exist?).with('/etc/aliases') { true }
  # for travis we have to stub readlines too:
  #  exist? is immediatly followed by readlines
  allow(::File).to receive(:readlines).and_call_original
  allow(::File).to receive(:readlines).with('/etc/aliases') { [] }
end

def etc_aliases_does_not_exist
  allow(::File).to receive(:exist?).and_call_original
  allow(::File).to receive(:exist?).with('/etc/aliases') { false }
end

def contains_alias(alias_line)
  allow(::File).to receive(:readlines).and_call_original
  allow(::File).to receive(:readlines).with('/etc/aliases') {
    [
      'root: "notify@central.net"',
      alias_line,
      'to_cmd: "| save_to_db.sh"'
    ]
  }
end
