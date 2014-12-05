default_unless[:ohai][:plugin_path]      = '/var/cache/chef/ohai_plugins'
default_unless[:ohai][:disabled_plugins] = [ 'pci' ]
default_unless[:ohai][:update_pciids]    = false

default['debian'] = { }
