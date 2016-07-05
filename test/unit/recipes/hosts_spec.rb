describe 'sys::hosts' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'without any attributes' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

end
