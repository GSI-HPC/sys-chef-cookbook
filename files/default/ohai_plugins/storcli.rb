#
# Copyright 2019 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Author: Christopher Huhn <c.huhn@gsi.de>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# Ohai plugin for storcli (LSI MegaRAID CLI)
#
Ohai.plugin(:Storcli) do
  provides 'storcli'

  collect_data(:default) do
    # put potential storcli dir on the path:
    old_path = ENV['PATH']
    # this is the default install dir:
    ENV['PATH'] += ":/opt/MegaRAID/storcli"

    # collect all available info in JSON format:
    so = shell_out('storcli64 /call show all J')

    # restore PATH
    ENV['PATH'] = old_path

    info = JSON.parse(so.stdout)

    if info['Controllers'].first['Command Status']['Description'] ==
       'No Controller found'
      false
    else
      storcli Mash.new
      info['Controllers'].each do |c_info|
        next unless c_info['Command Status']['Status'] == 'Success'

        storcli["controller_#{c_info['Command Status']['Controller']}"] =
          c_info['Response Data']
      end
    end
  end
end
