name "sys_apt_test"
description "Use to test the [sys::apt] recipe."
run_list( "recipe[sys]" )
default_attributes(
  "sys" => {
    "apt" => {
      "config" => {
        "50pdiffs" => {
          "Acquire::PDiffs" => false
        },
        "90recommends" => {
          "APT::Install-Recommends" => 0
        }
      },
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
      },
      "packages" => [
        "dnsutils",
        "less"
      ],
      "keys" => {
        "remove" => [ "A0206ACC" ],
        "add" => [ '
           -----BEGIN PGP PUBLIC KEY BLOCK-----
           Version: GnuPG v1.4.10 (GNU/Linux)

           mQGiBEtwDoURBACtcaK80IOtBaLtvJvwUYDy2gVD5W05vfx9fSSil8hZDpDL4ZMn
           qBghE1TqfHWJSwIz9wvkmUbqEykz16DepjkRqDTTmKbsjwoPsPU/Sp6Mt8X7KtDd
           Tt29z9RAN9cXGVStjlCpnGb0eLl/mt12KUJKQxzc8lDRHA9xMzOomjfkHwCgsUT8
           +LwpbqCxZUJS/KD973arRzUEAKKvFvvzHXNYMOBEdSVYjUKtW2RsOyxLmhNJTxnz
           GaKi/PB/cNVx1PbqDg61f82K1YG8DIWJGEAlNoNanaTt3Ml71jZ6JQuh9E9P99RK
           TsfhYO9Gr3tiGUEYIr174eha+Eu0u3oCVhJVo6ML39XAjKyZCDVxo8e0rPtd/PYq
           x5VpBACM6eXQeYr/Cp/TL42PsWyTa+dgX942FcZzrrEFQLJins8VRvuZ1joB0vdw
           PSVw8LrD8NZ0+JVBj89yHTjaCbhoE7SACEHJejQHMrckLD5FsAXmrWxH3PbRFd8j
           H+K1IQAbdvBdpYHQArm0GYJ+Mhum+7sU67ZvCMWljlnzBRhxUbQzR1NJIHJlcG9z
           aXRvcnkgc2lnbmluZyBrZXkgMjAxMCA8bGludXhncm91cEBnc2kuZGU+iGAEExEC
           ACAFAktwDoUCGwMGCwkIBwMCBBUCCAMEFgIDAQIeAQIXgAAKCRAkSsogoCBqzBht
           AJwLfEpsyussPMcHy/lsYw7Up7NAvACgjfRMKLZXfn5ZkgHs3Y31sR6J2MC5Ag0E
           S3AOhRAIANC3CiHFTEIpe1N3CRBpWKbxUPKKQAU6gDGikp/EXRn2n3PpqH/zJ0Bj
           1//OzVYmgPl/y7KwLEAiEqrABwdliXvykD/w6Cu8dE9Tre1xSHnZ2u7IbnfIvu0x
           I4jViBC1SXvwQNyKIy/rNtny+rBZf2TuCrEJFIzXfD6Cdfu6oOgMG4xI+ehzsNjb
           qSQ7GuIEgTi4itYC0l+zXmCN3/hFmfj2EBVOKmKZfm6w9PHYUAOXrGGeV5a8kFbG
           GQ5rUin8DGpCc/PsM2QtuJCxeWiUFGBAqEmHYPkClwMjONMR9w+YmM7we5fquubr
           0f6EsMlpQOpGaHqrBuGgoPxy/3jSpZsAAwYH/j0qB6fSs0i5Q6eC+8kSZKY7ljaF
           XsyqHmNeJG8opUVVgGMaKx4jHvzxeDfpQp1ekbRv1Eo4ZOgP4b1m2IWh48IxolsV
           lJav6qab8rZ7DoUa7gWxOtqD08x/VImYOOPmkeRk7Mz7a61RPmVqWYkV0WXZg7R+
           59VAHT41cQRd3cT8wk6FYev4gwKEy5QAPCpbuo2pRC6Lcs5xCruE70PFxes1DS8R
           ylcF66M4QZ8AmWJNESAqjLUuAQ0iwKIK32Jr646OnceACMm3g+JY9MzSoY4DypV5
           yvSYC5WfVU6bdSjPNiOidG9GSj44R3dJcaU4latdGaA3ajVI/VGmyHnpm9+ISQQY
           EQIACQUCS3AOhQIbDAAKCRAkSsogoCBqzNN3AJ9Hvc+p2JXd6RhdqK61UZO4A37c
           DACcCQ6b+3LKKrdlfy5xAQ/BYVdAxeA=
           =GI6g
           -----END PGP PUBLIC KEY BLOCK-----
        ']
      }
    }
  }
)
