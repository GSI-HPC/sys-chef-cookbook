maintainer       "GSI HPC department"
maintainer_email "hpc@gsi.de"
license          "Apache 2.0"
description      "System Software configuration and maintenance"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.19.0"
# newer versions of the apt cookbook do not run with Chef 10.12 on Wheezy:
depends          "apt","~> 1.7.0"
