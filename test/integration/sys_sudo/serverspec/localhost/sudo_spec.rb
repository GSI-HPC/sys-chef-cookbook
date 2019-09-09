require 'spec_helper'

describe file('/etc/sudoers') do
  it { should exist }
  its(:content) do
    should match(/Defaults\s+mailfrom="prosecutor@example.com"/)
    should match(/Defaults\s+mailto="vagrant"/)
    should match(/Defaults\s+mailsub="\[SUDO\] RED ALERT!"/)
  end
end

describe file('/etc/sudoers.d/kitchen') do
  it { should exist }
  its(:content) do
    should include 'User_Alias SMUTJE = vagrant'
    should include 'SMUTJE ALL=(ALL) NOPASSWD: ALL'
  end
end

# should have been cleaned up:
describe file('/etc/sudoers.d/vagrant') do
  it { should_not exist }
end

# real-life test
describe file('/var/mail/vagrant') do
  # sudo something stupid as nobody:
  before do
    # silence sudo:
    FileUtils.touch('/var/lib/sudo/lectured/nobody')
    `yes | sudo -u nobody sudo --prompt='' --stdin whoami`
    sleep 5 # wait for update of mailbox
  end

  it { should exist }
  its(:content) do
    should include 'From: prosecutor@example.com'
    should include '[SUDO] RED ALERT!'
    should match %r{nobody : user NOT in sudoers.*COMMAND=/usr/bin/whoami}
  end
end
