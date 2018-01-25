name             'sys'
maintainer       'GSI HPC department'
maintainer_email 'hpc@gsi.de'
license          'Apache-2.0'
description      'System Software configuration and maintenance'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url       'https://github.com/GSI-HPC/sys-chef-cookbook'
issues_url       'https://github.com/GSI-HPC/sys-chef-cookbook/issues'
chef_version     '>= 12.0' if respond_to?(:chef_version)
supports         'debian'
version          '1.39.1'
