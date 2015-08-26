# 
# Install the packages needed to configure/grab data from the IPMI cards.
#

ipmi = node['sys']['ipmi']['install_packages']

unless ipmi.empty?

   # Install the command line tool to access BMC data:
   package 'ipmitool'

   # Tools used by the supplied IPMI Ohai plugin (bmc-config):
   package 'freeipmi-tools'

end
