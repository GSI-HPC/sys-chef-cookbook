sys_systemd_unit 'test.network' do
  directory '/etc/systemd/network'
  config({
    'Match' => {
      'Name' => 'eth0'
    },
    'Network' => {
      'Address' => '192.168.0.2'
    }
  })
  action :delete
end
