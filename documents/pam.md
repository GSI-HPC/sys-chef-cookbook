# `sys::pam`

Configures Linux authentication modules (PAM).

↪ `attributes/pam.rb`  
↪ `recipes/pam.rb`  
↪ `templates/*/etc_security_limits.conf.erb`  
↪ `templates/*/etc_security_access.conf.erb`  
↪ `templates/*/etc_pam.d_generic.erb`  
↪ `tests/roles/sys_pam_test.rb`  
↪ `files/*/etc_pam.d_sshd`  
↪ `files/*/etc_pam.d_login`  
↪ `libraries/pamupdate_*.rb`  


## Attributes

All attributes in `node['sys']['pam']`:

* `limits` holds an array of ulimits written to `/etc/security/limits.conf`.
* `access` holds an array of rules written to `/etc/security/access.conf`.
* `group`  holds an array of rules written to `/etc/security/group.conf`.

It is possible to write any file in the `/etc/pam.d/` directory using attributes
in `node⌷'sys']['pamd']`. The key needs to be used as the file to be altered
(e.g. `xscreensaver` or `ssh`) and the value is a string containing the entire
configuration. However, to change the content of `/etc/pam.d/common-*` files,
you are best adviced to use the attributes in `node['sys']['pamupdate']`.

## Pam-Update

This is a minimal ruby rewrite of [pam-auth-update](https://manpages.debian.org/bullseye/libpam-runtime/pam-auth-update.8.en.html).
The options are a little more complicated than just providing one giant string,
but it offers more flexibilty.
Pamupdate configuration is done with *profiles*.
Each profile configures at least one of the `/etc/pam.d/common-_`-files,
and provides information on how to be merged with other profiles configuring
the same files.
The pam-configuration in the `/etc/pam.d/common-_`-files is always divided
into two block, the primary and the additional block.

### Primary

The Primary block contains information modules that either deny or permit
access.
If none of these modules succeeds, pam_deny is used as fallback which prevents
login.
The priority of the profile determines the position of the module in the pam-stack.
E.g. libpam-heimdal ships a default configuration with priority 704.
Since the default unix-profile has a priority of 256, authentication is first
delegated to the heimdal-module, only afterwards the unix-module is asked.
If two profiles have equal priorities the name of the profile is used
for sorting.

### Additional

In this block modules are configured, which often just modify the user's groups,
limits, session or the like.
Again, modules are inserted here by highest priority or by name if they have
equal priorities.

### Creation

If you specify configuration of a profile, you must at a minimum provide a
number of fields, so that the configuartion can work at all:

*Name*
: This makes the profiles unique, it can be anything you,
  just try to keep it different from the other modules.

*Default*
: Set this to "yes" to enable the profile. Anything else disables it.
  It must be present, i.e. not `nil`
*Priority*
: Must be present to sort the profiles.

To define a profile use the `PamUpdate`-library as in `sys::pam`:

* Create Profiles with `PamUpdate::Profile.new(values)`.
  Values can either be a hash of hashes, or a filename.
  This way you can either configure it from scratch,
  or use configuration which ships with the packages,
  e.g. `/usr/share/pam-configs/krb5`.
* Put all the profiles in an array which is used to initialize a writer object:
  `generate = PamUpdate::Writer.new(profile-array)`. then get the needed strings
  by running `generate.auth`.
  Supported methods are `account`, `auth`, `password`, `session` and
  `session-noninteractive`.


## Example

```
    "sys" => {
      "pam" => {
        "access" => [
          "+:devops:10.1.1.1 LOCAL",
          "+:ALL:.devops.test LOCAL",
          "+:ALL:LOCAL",
          "-:ALL:ALL"
        ],
        "group" => [
          # minimal specification using defaults:
          { 'usr' => 'tschipfel', 'grp' => 'sudo' }
          # complete example (allow dummbabbler to read syslog while
          #                   logging in via console tty1 on workhours)
          {
            'usr'  => 'dummbabbler',
            'grp'  => 'adm',
            'srv'  => 'login',
            'tty'  => 'tty1',
            'time' => 'Wk0900-1800'
          }
        ],
        "limits" => [
          "*    hard memlock unlimited",
          "*    soft memlock unlimited"
        ]
      },
      "pamd" => {
        "xscreensaver" => "
          session [default=1]     pam_permit.so
          session requisite       pam_deny.so
          session required        pam_permit.so
          session required        pam_unix.so
        "
      },
      "pamupdate" => {
        "group" => {
          :Name => "PAM group"
          :Default => "yes"
          :Priority => "256"
          :"Auth-Type" => "Additional"
            :Auth => "optional			pam_group.so"
        }
      }
    }
```

## Access control with `pam_access`

If the attribute `node['sys']['pam']['access']` is set:
* `files/*/etc_pam.d_login` is deployed at `/etc/pam.d/login`.
  It contains the default config as shipped by the `login` package with
  the `pam_access` module enabled.

* `files/*/etc_pam.d_sshd` is deployed to `/etc/pam.d/sshd`
  if `/etc/ssh/sshd_config` exists (ie. SSH server is installed).
  It contains the default config as shipped by the `openssh-server`
  package with the `pam_access` module enabled. See also [`sys::ssh`](ssh.md)
