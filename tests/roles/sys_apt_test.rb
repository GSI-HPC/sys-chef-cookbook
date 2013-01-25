name "sys_apt_test"
description "Use to test the [sys::apt] recipe."
run_list( "recipe[sys]" )
default_attributes(
  "sys" => {
    "apt" => {
      "preferences" => {
        "testing" => {
          "pin" => "release o=Debian,a=testing",
          "priority" => 900
        },
        "unstable" => {
          "pin" => "release o=Debian,a=unstable",
          "priority" => 400
        },
        "experimental" => {
          "pin" => "release o=Debian,a=experimental",
          "priority" => 200
        }
      },
      "repositories" => {
        "unstable" => "
          deb http://ftp.de.debian.org/debian/ unstable main
          deb-src http://ftp.de.debian.org/debian/ unstable main
        ",
        "experimental" => "
          deb http://ftp.de.debian.org/debian/ experimental main
          deb-src http://ftp.de.debian.org/debian/ experimental main
        "
      }
    }
  }
)
