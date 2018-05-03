describe 'lwrp: sys_mail_alias' do

  let(:cookbook_paths) do
    [
      File.expand_path("#{File.dirname(__FILE__)}/../../../../"),
      File.expand_path("#{File.dirname(__FILE__)}/../")
    ]
  end

  let(:runner) do
    ChefSpec::SoloRunner.new(
      :cookbook_path => cookbook_paths,
      :step_into => ['sys_mail_alias']
    )
  end

  let(:node) { runner.node }

  change_alias_value_block = 'SysMailAlias action :add : change alias value'
  insert_alias_block = 'SysMailAlias action :add : insert alias'
  remove_alias_block = 'SysMailAlias action :remove : remove alias'

  describe 'action :add' do
    let(:chef_run) { runner.converge('fixtures::sys_mail_alias_add') }

    context '/etc/aliases exists' do
      before { etc_aliases_exists }
      # after convergence of the fixture /etc/aliases has been altered?!
      # it 'does not create /etc/aliases' do
      #   expect(chef_run).not_to create_file('/etc/aliases')
      # end

      context 'does not contain alias' do
        before { contains_alias 'not: the@expected.alias' }
        it 'inserts alias' do
          expect(chef_run).to run_ruby_block(insert_alias_block)
          expect(chef_run.find_resource(:sys_mail_alias, 'foo').updated).to be
        end
      end

      context 'contains alias with outdated value' do
        before { contains_alias 'foo: old_value' }
        it 'changes alias value' do
          expect(chef_run).to run_ruby_block(change_alias_value_block)
          expect(chef_run.find_resource(:sys_mail_alias, 'foo').updated).to be
        end
      end

      context 'contains already up-to-date alias' do
        before { contains_alias 'foo: "foo@bar"'}
        it 'does nothing' do
          expect(chef_run.find_resource(:sys_mail_alias, 'foo').updated).not_to be
        end
      end
    end

    context '/etc/aliases does not exist' do
      before { etc_aliases_does_not_exist }
      it 'creates /etc/aliases' do
        expect(chef_run).to create_file('/etc/aliases')
        expect(chef_run.find_resource(:sys_mail_alias, 'foo').updated).to be
      end
    end
  end

  describe 'action :remove' do
    let(:chef_run) { runner.converge('fixtures::sys_mail_alias_remove') }

    before { etc_aliases_exists }

    context 'alias exists' do
      before { contains_alias 'foo: asdf' }
      it 'removes the alias' do
        expect(chef_run).to run_ruby_block(remove_alias_block)
        expect(chef_run.find_resource(:sys_mail_alias, 'foo').updated).to be
      end
    end

    context 'alias does not exist' do
      before { contains_alias 'not: the_expected_alias' }
      it 'does nothing' do
        expect(chef_run).not_to run_ruby_block(remove_alias_block)
        expect(chef_run.find_resource(:sys_mail_alias, 'foo').updated).not_to be
      end
    end
  end
end

def etc_aliases_exists
  allow(::File).to receive(:exist?).and_call_original
  allow(::File).to receive(:exist?).with('/etc/aliases') { true }

  # for travis we have to stub open and readlines too:
  let(fake_alias) { double('fake alias') }
  allow(::File).to receive(:open).and_call_original
  allow(::File).to receive(:open).with('/etc/aliases').and_yield(fake_alias)
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
