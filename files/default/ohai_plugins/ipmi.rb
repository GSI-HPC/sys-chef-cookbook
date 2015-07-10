#
# Ohai plugin to check if IPMI is available
#


Ohai.plugin(:Ipmi) do
  provides 'ipmi'
  depends 'kernel/modules'

  collect_data(:default) do

    unless kernel[:modules][:ipmi_si]
      unless load_modules
        Ohai::Log.debug("IPMI modules could not be loaded")
        return false
      end
    end

    ipmi Mash.new
    ipmi['bmc-config'] = bmc_config

  end

  # try to load the IPMI modules:
  #  TODO: this produces a lot of noise in the kern.log
  #        should not be run every time
  #        Set a normal attribute (node.ipmi.available) instead?
  def load_modules
    if shell_out('modprobe ipmi_devintf').exitstatus == 0
      if shell_out('modprobe ipmi_si').exitstatus == 0
        return File.exists?('/dev/ipmi0')
      end
    end
    false
  end

  # parse the output of bmc-config from freeipmi-tools
  def bmc_config
    output = shell_out('bmc-config --checkout')

    result = {}

    sections = Hash[output.stdout.scan(/^Section\s+(.*?)\s*\n+(.*?)EndSection/m)]

    sections.each do |name,config|
      h = {}
      config.each_line do |line|
        (key,value) = line.match(/^\s*(.*?)\s+(.*)/).captures
        next if key =~ /^#/   #skip comments
        h[key] = value
      end
      # skip disabled users:
      next if h['Enable_User'] == 'No'
      result[name] = h
    end

    result
  end

end
