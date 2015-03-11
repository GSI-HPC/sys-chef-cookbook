describe 'sys::file' do

  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'node.sys.file is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do

    test_file = '/tmp/file'
    test_file_content = 'This is some plain text content'
    test_file_mode = '0644'

    before do
      chef_run.node.default['sys']['file'][test_file] = {content: test_file_content, mode: test_file_mode} 
      chef_run.converge(described_recipe)
    end

    it "Create #{test_file} " do
      expect(chef_run).to create_file(test_file).with(content: test_file_content, mode: test_file_mode)
    end


  end

end
