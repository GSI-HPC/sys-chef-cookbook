require 'spec_helper'

describe file('/etc/sudoers') do
  it { should exist }
  its(:content) do
    should match(/Defaults\s+mailfrom="prosecutor@example.com"/)
    should match(/Defaults\s+mailto="daemon"/)
    should match(/Defaults\s+mailsub="\[SUDO\] RED ALERT!"/)
  end
end

describe file('/etc/sudoers.d/kitchen') do
  it { should exist }
  its(:content) do
    should match(/User_Alias SMUTJE = .*vagrant/)
    should include('SMUTJE ALL=(ALL) NOPASSWD: ALL')
  end
end

# should have been cleaned up:
describe file('/etc/sudoers.d/vagrant') do
  it { should_not exist }
end

describe user('daemon') do
  it { should exist }
end

# real-life test

mbox = (host_inventory['platform'] == 'redhat') ? '/var/mail/root' : '/var/mail/daemon'
describe file(mbox) do
  # sudo something stupid as nobody:
  before do
    # silence sudo:
    lectured_dir = (host_inventory['platform'] == 'redhat') ? '/var/db/sudo/lectured' : '/var/lib/sudo/lectured'
    FileUtils.touch("#{lectured_dir}/nobody")
    `yes | sudo -u nobody sudo --prompt='' --stdin whoami`

    # wait for creation of mailbox:
    (1..10).each do |i|
      File.exist?(mbox) && break
      puts i
      sleep 1
    end
  end

  it { should exist }
  its(:content) do
    should include 'From: prosecutor@example.com'
    should include '[SUDO] RED ALERT!'
    should match %r{nobody : user NOT in sudoers.*COMMAND=/usr/bin/whoami}
  end
end
