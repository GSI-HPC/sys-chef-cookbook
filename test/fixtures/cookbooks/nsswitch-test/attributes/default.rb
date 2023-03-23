if Gem::Requirement.new('< 12.15')
  default['sys']['nsswitch'] = {
    passwd: %w[files ldap],
    group: 'ldap files'
  }
end
