#
# checks for snmpd installation
#
# Christopher Huhn 2019
#

require 'spec_helper'

case os[:family]
when 'redhat'
  snmpd_package = 'net-snmp'
  snmpwalk_package = 'net-snmp-utils'
  snmp_user    = 'snmp'
when 'debian', 'ubuntu'
  snmpd_package = 'snmpd'
  snmpwalk_package = 'snmp'
  if os[:release].to_i >= 9 ||
     os[:release] == 'testing'
    snmp_user = 'Debian-snmp'
  else
    snmp_user = 'snmp'
  end
end

describe package(snmpd_package) do
  it { should be_installed }
end

describe service('snmpd') do
  it { should be_enabled }
  it { should be_running }
end

describe user(snmp_user) do
  it { should exist }
end

describe process('snmpd') do
  its(:user) { should eq snmp_user }
end

describe package(snmpwalk_package) do
  it { should be_installed }
end

# query snmpd for sysContact.0:
describe command('snmpwalk -Ov -Oq -c oz -v2c localhost .1.3.6.1.2.1.1.4.0') do
  its(:stdout) { should match(/Dorothy Gale/) }
  its(:exit_status) { should eq 0 }
end
