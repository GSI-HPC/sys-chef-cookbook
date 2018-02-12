require 'spec_helper'
require 'chefspec/ohai'

describe_ohai_plugin :LsiController do
  let(:plugin_path) { 'files/default/ohai_plugins' }
  let(:plugin_file) { 'files/default/ohai_plugins/lsi.rb' }

  it 'provides lsi' do
    expect(plugin).to provides_attribute('lsi')
  end

  let(:command) {
    double('Fake Command', stdout: 'OUTPUT')
  }

  it 'correctly captures output' do
    allow(plugin).to receive(:shell_out).with('/usr/sbin/MegaCli64 -AdpAllInfo -aALL').and_return(command)
    expect(plugin_attribute('lsi')).to eq('OUTPUT')
  end
end
