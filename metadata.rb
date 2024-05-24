name             'sys'
maintainer       'GSI IT department'
maintainer_email 'linuxgroup@gsi.de'
license          'Apache-2.0'
description      'System Software configuration and maintenance'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
if respond_to?(:source_url)
  source_url       'https://github.com/GSI-HPC/sys-chef-cookbook'
end
if respond_to?(:issues_url)
  issues_url       'https://github.com/GSI-HPC/sys-chef-cookbook/issues'
end
chef_version     '>= 12.0' if respond_to?(:chef_version)
supports         'debian'

depends          'chef-vault', '< 4.0'

version          '2.4.1'
