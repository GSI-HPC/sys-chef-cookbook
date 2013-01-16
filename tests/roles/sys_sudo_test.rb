name "sys_sudo_test"
description "Use to test the [sys::sudo] recipe."
run_list( "recipe[sys]" )
default_attributes(
  "sys" => {
    "sudo" => {
      "admins" => {
        "users" => { 
          "ADMIN" => ["joe","bob","ted"] 
        },
        "rules" => [ 
          "%admin LOCAL = NOPASSWD: ALL",
          "ADMIN ALL = ALL",
          "devops ALL=NOPASSWD: ALL"
        ]
      },
      "monitor" => {
        "users" => { 
          "MON" => [ "monalisa", "mon", "nagios", "snmp" ] 
        },
        "commands" => {
          "IB" => [ "/usr/sbin/perfquery" ],
          "NET" => [ "/bin/netstat", "/usr/sbin/iftop", "/sbin/ifconfig" ]
        },
        "rules" => [
          "MON LOCAL = NOPASSWD: IB, NET"
        ]
      },
      "users" => {
        "users" => {
          "KILLERS" => ["maria","anna"]
        },
        "hosts" => {
          "LAN" => ["10.1.1.0/255.255.255.0"]
        },
        "commands" => {
          "KILL" => [ "/usr/bin/kill", "/usr/bin/killall" ],
          "SHUTDOWN" => [ "/usr/sbin/shutdown", "/usr/sbin/reboot" ],
          "CDROM" => ["/sbin/umount /media/cdrom",'/sbin/mount -o nosuid\,nodev /dev/cd0a /media/cdrom']
        },
        "rules" => [
          "KILLERS LOCAL = KILL",
          "%users LAN = SHUTDOWN",
          "pete LOCAL = /usr/bin/passwd [A-z]*, !/usr/bin/passwd root",
          "john LOCAL = /usr/bin/su [!-]*, !/usr/bin/su *root*",
          "ALL LOCAL = CDROM"
        ]
      }
    }
  }
)
