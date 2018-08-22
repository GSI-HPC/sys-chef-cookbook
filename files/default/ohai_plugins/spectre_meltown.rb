require 'json'
require 'mixlib/shellout'

Ohai.plugin(:SpectreMeltdown) do
  provides 'security/spectre_meldown'

  collect_data(:default) do
    cmd = 'spectre-meltdown-checker --batch json'
    status = shell_out(cmd).stdout
    info = JSON.parse(status)

    security Mash.new
    security['spectre_meltdown'] = Mash.new

    info.each do |h|
      # beautify the hash a little bit:
      name =  h.delete('NAME').capitalize
      security['spectre_meltdown'][name] = h.each_with_object({}) do |(k, v), h2|
        h2[k.downcase] = v
      end
    end
  end
end
