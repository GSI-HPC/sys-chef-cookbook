# coding: utf-8

describe 'lwrp: sys_mail_alias' do
  let(:runner) do
    ChefSpec::SoloRunner.new(
      :step_into => ['sys_mail_alias']
    )
  end

  let(:node) { runner.node }

  change_alias_value_block = 'SysMailAlias action :add : change alias value'
  insert_alias_block = 'SysMailAlias action :add : insert alias'
  remove_alias_block = 'SysMailAlias action :remove : remove alias'

  let(:fake_file_edit) { double('chef util file edit') }

  describe 'action :add' do
    let(:chef_run) { runner.converge('fixtures::sys_mail_alias_add') }

    context '/etc/aliases exists' do
      before { etc_aliases_exists }
      # after convergence of the fixture /etc/aliases has been altered?!
      # it 'does not create /etc/aliases' do
      #   expect(chef_run).not_to create_file('/etc/aliases')
      # end

      context 'does not contain alias' do
        before do
          allow(fake_file_edit).to receive(:insert_line_if_no_match)
                                    .and_return(true)
          contains_alias 'not: the@expected.alias'
        end
        xit 'inserts alias' do
          expect(chef_run).to run_ruby_block(insert_alias_block)
          expect(chef_run.find_resource(:sys_mail_alias, 'foo').updated).to be
        end
      end

      context 'contains alias with outdated value' do
        before { contains_alias 'foo: old_value' }
        xit 'changes alias value' do
          expect(chef_run).to run_ruby_block(change_alias_value_block)
          expect(chef_run.find_resource(:sys_mail_alias, 'foo').updated).to be
        end
      end

      context 'contains already up-to-date alias' do
        before { contains_alias 'foo: "foo@bar"'}
        xit 'does nothing' do
          expect(chef_run.find_resource(:sys_mail_alias, 'foo')
                  .updated).not_to be
        end
      end
    end

    context '/etc/aliases does not exist' do
      before { etc_aliases_does_not_exist }
      xit 'creates /etc/aliases' do
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
      xit 'removes the alias' do
        expect(chef_run).to run_ruby_block(remove_alias_block)
        expect(chef_run.find_resource(:sys_mail_alias, 'foo').updated).to be
      end
    end

    context 'alias does not exist' do
      before { contains_alias 'not: the_expected_alias' }
      xit 'does nothing' do
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
  # fake_alias = double('fake alias')
  # fake_alias_stats = double('file stat')
  # allow(::File).to receive(:open).and_call_original
  # allow(::File).to receive(:open).with('/etc/aliases').and_yield(fake_alias)
  # allow(fake_alias).to receive(:exist?).and_return(true)
  # allow(fake_alias).to receive(:readlines).and_return([])
  #allow(::FileUtils).to receive(:cp).with('/etc/aliases','/etc/aliases.old',{preserve: true})
  #allow(fake_alias).to receive(:stat).and_return(fake_alias_stats)
  #allow(fake_alias_stats).to receive(:mode).and_return(0o644)
  #allow(::File).to receive(:readlines).and_call_original

  # stub Chef::Util::FileEdit - this is quite insane
  allow(Chef::Util::FileEdit).to receive(:new).and_call_original
  allow(Chef::Util::FileEdit).to receive(:new).with('/etc/aliases')
                                  .and_return(fake_file_edit)
  allow(fake_file_edit).to receive(:insert_line_if_no_match)
  allow(fake_file_edit).to receive(:search_file_replace_line)
  allow(fake_file_edit).to receive(:search_file_delete_line)
  allow(fake_file_edit).to receive(:write_file)
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
