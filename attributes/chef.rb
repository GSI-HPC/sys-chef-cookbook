# invocation interval in seconds
default[:sys][:chef][:interval]       = 1800
# invocation will be postponed by a random value up to this number of seconds:
default[:sys][:chef][:splay]          = 300
default[:sys][:chef][:client_key]     = '/etc/chef/client.pem'
default[:sys][:chef][:validation_key] = '/etc/chef/validation.pem'
# this definition is bogus, not?
default[:sys][:chef][:server_url]     = nil
default[:sys][:chef][:use_syslog]     = false
default[:sys][:chef][:log_level]      = 'info'
