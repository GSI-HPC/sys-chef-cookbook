#
# Ohai plugin to check if IPMI HW is available.
#

Ohai.plugin(:Ipmi) do
  provides 'ipmi'
  depends 'kernel/modules'

  collect_data(:default) do

   # Check if 'dmidecode' is available on the node:
   unless cmd_avail("dmidecode")
    Ohai::Log.debug("The dmidecode cmd is not available: no check for IPMI HW will be performed")
    false
   end

   # 1. Verify if there's IPMI HW available.
   # 2. Only if it's the case then we'll try to load IPMI modules. 
   if ipmi_hw_avail 
    unless kernel[:modules][:ipmi_si]
      unless load_modules
        Ohai::Log.debug("IPMI modules could not be loaded")
      end
    end
     
     # Fill the IPMI mash with the output of the 'bmc-config' cmd:
     ipmi Mash.new
     ipmi['bmc-config'] = bmc_config
   else
     Ohai::Log.debug("No IPMI HW is available or the dmidecode cmd reported a non zero exit status")
   end

  end

  # Check if a command is available on the PATH:
  def cmd_avail(cmd)
    system("which #{ cmd} > /dev/null 2>&1")
  end

  # Attempt to verify if IPMI HW is available:
  def ipmi_hw_avail
    ipmi_available = ""
    result = shell_out('dmidecode -t 38') # '38' is the DMI type reported for IPMI HW on the dmidecode man page.
    if result.exitstatus == 0
       result.stdout.lines do |line|
          case line
	  when /IPMI Device Information/
              ipmi_available = "yes"
          end
       end

       if ipmi_available.eql?("yes")
         true
       end
    else
       false # No IPMI HW available or the exit status of 'dmidecode' reported something different from zero.
    end
  end

  # Try to load the IPMI modules:
  def load_modules
    if shell_out('modprobe ipmi_devintf').exitstatus == 0
      if shell_out('modprobe ipmi_si').exitstatus == 0
        return File.exist?('/dev/ipmi0')
      end
    end
    false
  end

  # Parse the output of bmc-config from freeipmi-tools:
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
