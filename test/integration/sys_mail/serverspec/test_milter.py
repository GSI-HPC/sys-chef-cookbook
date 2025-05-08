#!/usr/bin/env python3

import Milter

class TestMilter(Milter.Base):
    def eom(self):
        self.addheader("X-Milter-Filter", "intelligent circuitry")
        return Milter.ACCEPT

if __name__ == "__main__":
    Milter.factory = TestMilter
    Milter.set_flags(Milter.ADDHDRS)
    Milter.runmilter("testmilter", "inet:42761@127.0.0.1")
