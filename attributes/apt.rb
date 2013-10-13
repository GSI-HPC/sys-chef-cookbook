default[:sys][:apt][:default_server] = 'ftp.debian.org'
default[:sys][:apt][:default_path]   = '/debian'

default[:sys][:apt][:srcs]   = {
  # the main repository is happy with the defaults
  'main'              => { },
  # security updates
  'security'          => { 
    :server => 'security.debian.org', 
    :path => '/', 
    :distrib => "#{node[:lsb][:codename]}/updates" 
  },
  'backports'         => { :distrib => "#{node[:lsb][:codename]}-backports" },
  # aka. volatile
  'updates'           => { :distrib => "#{node[:lsb][:codename]}-updates" },
  # may (or may not) become part of the next point release
  'proposed-updates'  => {
    :distrib => "#{node[:lsb][:codename]}-proposed-updates",
    # nowhere used yet
    :pin_priority => 300
  },
  # Newer LTS iceweasel and icedove
  'mozilla-esr'       => {
    :server     => 'mozilla.debian.net',
    :path       => '/',
    :distrib    => "#{node[:lsb][:codename]}-backports",
    :components => [ 'iceweasel-esr', 'icedove-esr' ],
    #:key        => ''
  }
}

default[:sys][:apt][:active_sources] = [ ] #[ 'main', 'security', 'updates' ]

default[:sys][:apt][:config] = { }
