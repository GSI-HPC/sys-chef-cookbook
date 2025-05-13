#!/usr/bin/env python3
#
# Copyright:: 2025 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <C.Huhn@gsi.de>
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

"""minimal Milter that adds a X-Milter-Filter header to every mail"""

import Milter

class TestMilter(Milter.Base):
    """Minimal Milter"""

    def eom(self):
        self.addheader("X-Milter-Filter", "intelligent circuitry")
        return Milter.ACCEPT

if __name__ == "__main__":
    Milter.factory = TestMilter
    Milter.set_flags(Milter.ADDHDRS)
    Milter.runmilter("testmilter", "inet:42761@127.0.0.1")
