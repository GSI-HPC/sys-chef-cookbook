default_unless['sys']['sshd']['config'] = Hash.new
default_unless['sys']['ssh']['ssh_config'] = Hash.new
default_unless['sys']['ssh']['authorize'] = Mash.new
default_unless['sys']['ssh']['config'] = Mash.new

default_unless['sys']['sshd']['host_keys_vault'] = 'ssh_host_keys'
default_unless['sys']['sshd']['host_keys_item'] = node['fqdn']
