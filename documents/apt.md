
Configures the APT package management on Debian.

↪ `attributes/apt.rb`  
↪ `recipes/apt.rb`  
↪ `resources/apt_preferences.rb`  
↪ `resources/apt_conf.rb`  
↪ `resources/apt_repository.rb`  
↪ `providers/apt_preferences.rb`  
↪ `providers/apt_conf.rb`  
↪ `providers/apt_repository.rb`  
↪ `templates/*/etc_apt_preferences.d_generic.erb`  
↪ `templates/*/etc_apt_sources.list.d_generic.erb`  
↪ `tests/roles/sys_apt_test.rb`  

# Configuration

Set APT configurations with individual file in the `/etc/apt/apt.conf.d/` directory using the **`sys_apt_conf`** resource.

**Actions**

* `set` (default) creates a new APT configuration file.
* `remove` deletes an APT configuration file.

**Attributes**

* `name` (name attribute) is the filename used for the configuration.
* `config` (required) to be written into the configuration file.

**Examples**

Configure a couple APT specifics:

    sys_apt_conf "10periodic" do
      config(
        "APT::Periodic::Enable" => 1,
        "APT::Periodic::Update-Package-Lists" => 1,
        "APT::Periodic::Unattended-Upgrade" => 1,
        "APT::Periodic::Download-Upgradeable-Packages" => 1,
        "APT::Periodic::AutocleanInterval" => 7
      )
    end
    
    sys_apt_conf "50pdiffs" do
      config( "Acquire::PDiffs" => false )
    end

Alternatively use attributes in the `node.sys.apt.config`, e.g.:

    "sys" => {
      [...SNIP...]
      "apt" => {
        "config" => {
          "51retries" => {
            "Acquire::Retries" => 0
          },
          "60unattended-upgrade" => {
            "Unattended-Upgrade::Automatic-Reboot" => false,
            "Unattended-Upgrade::Remove-Unused-Dependencies" => true;
            "Unattended-Upgrade::Mail" => "root",
            "Unattended-Upgrade::MailOnlyOnError" => true
          }
        }
        [...SNIP...]
      }
    } 


# Preferences

Set APT preferences with individual files in the `/etc/apt/preferences.d/` directory using the **`sys_apt_preference`** resource (refer to the `apt_preferences` manual).

**Actions**

* `set` (default) creates a new APT preferences configuration file.
* `remove` deletes an APT preferences configuration file.

**Attributes**

* `name` (name attribute) is the filename used for the configuration.
* `package` (defaults to any, as specified by asterisk) list.
* `pin` (required) specifies the release.
* `priority` (required) specifies the priority level.

**Examples**

Defines precedents for the testing packages over unstable.

    sys_apt_preference "testing" do
      pin "release o=Debian,a=testing"
      priority 900
    end
 
    sys_apt_preference "unstable" do
      pin "release o=Debian,a=unstable"
      priority 800
    end

    sys_apt_preference "site-testing" do
      action :remove
    end

Alternatively use attributes in the `node.sys.apt.preferences` to configure, e.g.:

    [...SNIP...]
    "sys" => {
      "apt" => {
        "preferences" => {
          "testing" => {
            "pin" => "release o=Debian,a=testing",
            "priority" => 400
          },
          "unstable" => {
            "pin" => "release o=Debian,a=unstable",
            "priority" => 200
          },
          "site-testing" => {
            "package" => "foo",
            "pin" => "o=site,a=testing",
            "priority" => 900
          }
        }
      }
      [...SNIP...]
    }

Leaving a key with an empty hash a value in the `node.sys.apt.preferences` will remove the corresponding configuration file if present.

# Repositories

Configure the main source repository in `/etc/apt/sources.list` using the attribute `node.sys.apt.sources`, for example:

    "sys" => {
      "apt" => {
        "sources" => "
          deb     http://debian.site.domain/debian wheezy main contrib
          deb-src http://debian.site.domain/debian wheezy main contrib
        ",
        [...SNIP...]
      }
    }

Add APT repositories with individual files in the `/etc/apt/sources.list.d/` directory using the **`sys_apt_repository`** resource.

**Actions**

* `add` (default) writes a new APT repository configuration file.
* `remove` deletes an APT repository configuration file.

**Attributes:**

* `name` (name attribute) is the filename used for the configuration.
* `config` (required) to be written to the configuration file.

**Example**

Add unstable and remove experimental repositories:

    sys_apt_repository "unstable" do
      config "
        deb http://ftp.de.debian.org/debian/ unstable main
        deb-src http://ftp.de.debian.org/debian/ unstable main
      "
    end
    
    sys_apt_repository "experimental" do
      action :remove
    end

Alternatively use attributes in `node.sys.apt.repositories` to configure, e.g.:

    "sys" => {
      "apt" => {
        [...SNIP...]
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

# Keys

Manage APT keys.

**Actions**

* `add` (default) adds a new key to the keyring.
* `remove` deletes a key from the keyring.

**Attributes**

* `key` (name attribute) is the filename used for the configuration.

**Example**

Remove a key by key id and add another key:

    sys_apt_key "65FFB764" do
      action :remove
    end
    
    sys_apt_key <<EOF
    -----BEGIN PGP PUBLIC KEY BLOCK-----
    Version: GnuPG v1.4.9 (GNU/Linux)
    
    mQGiBEtwDoURBACtcaK80IOtBaLtvJvwUYDy2gVD5W05vfx9fSSil8hZDpDL4ZMn
    [...SNIP...]
    EQIACQUCS3AOhQIbDAAKCRAkSsogoCBqzNN3AJ9Hvc+p2JXd6RhdqK61UZO4A37c
    DACcCQ6b+3LKKrdlfy5xAQ/BYVdAxeA=
    =GI6g
    -----END PGP PUBLIC KEY BLOCK-----
    EOF

Alternatively use attributes in `node.sys.apt.keys`, e.g.:

    "sys" => {
      "apt" => {
        [...SNIP...]
        "keys" => {
          "add" => [ <<EOF
    -----BEGIN PGP PUBLIC KEY BLOCK-----
    Version: GnuPG v1.4.9 (GNU/Linux)
    
    mQGiBEtwDoURBACtcaK80IOtBaLtvJvwUYDy2gVD5W05vfx9fSSil8hZDpDL4ZMn
    [...SNIP...]
    EQIACQUCS3AOhQIbDAAKCRAkSsogoCBqzNN3AJ9Hvc+p2JXd6RhdqK61UZO4A37c
    DACcCQ6b+3LKKrdlfy5xAQ/BYVdAxeA=
    =GI6g
    -----END PGP PUBLIC KEY BLOCK-----
    EOF   ],
          "remove" => [ "65FFB764" ]
        }
      }
    }

Keys are removed first and added afterwards.
