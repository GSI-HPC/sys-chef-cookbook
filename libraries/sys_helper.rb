module Sys
  module Helper

    # Detect active systemd instance
    def systemd?
      cmd = Mixlib::ShellOut.new('cat /proc/1/comm')
      cmd.run_command
      cmd.stdout.chomp == 'systemd'
    end
  end
end
