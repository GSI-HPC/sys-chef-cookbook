# This plugin adds SSH key fingerprints.

Ohai.plugin(:SSHHostKeyFingerprints) do
  provides 'keys/ssh'
  depends 'keys/ssh'

  collect_data(:default) do
    fingerprints = Mash.new

    keys['ssh'].each do |type, key|
      next unless type.end_with? '_public'

      type = type.sub(/^host_/, '').sub(/_public$/, '')

      ssh_type = "ssh-#{type}"
      # ecdsa has a special type attribute
      ssh_type = keys['ssh']["host_#{type}_type"] \
        if keys['ssh'].include? "host_#{type}_type"

      cmd = "echo '#{ssh_type} #{key}' | ssh-keygen -lf -"
      so = shell_out(cmd, timeout: 5)
      so.stdout.each_line do |line|
        fingerprints["host_#{type}_fingerprint"] = line.split[1]
      end
    end

    keys['ssh'].merge! fingerprints
  end
end
