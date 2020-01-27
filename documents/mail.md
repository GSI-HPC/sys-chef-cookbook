Configures Postfix to forward outgoing messages to a mail relay.

↪ `attributes/mail.rb`  
↪ `recipes/mail.rb`  
↪ `resources/mail_alias.rb`  
↪ `providers/mail_alias.rb`  

**Resource**

Add or change (Postfix) account to mail address aliases in
`/etc/aliases` with `sys_mail_alias`.


    sys_mail_alias "jdoe" do
      to "jdoe@devops.test"
    end

Use `action :remove` to remove an alias. The aliases file defaults to
`/etc/aliases`, but can be overriden via `aliases_file '/etc/otheraliases'`.

**Attributes**

All attributes in `node['sys']['mail]`:

* `relay` (required) defines the mail relay host FQDN.
* `aliases` (optional) hash of account name, mail address pairs.
* `canonical` (optional) hash of mappings for postfix's canonical map
* `virtual` (optional) hash of mappings for postfix's virtual map
* `mynetworks` (optional) string with additional space separated values for the
postfix `mynetworks` configuration option, cause the postfix `inet_interfaces`
option to be set to `all`, too
* `mydestination` (optional) string with additional comma separated values for
postfix `mydestination` configuration option
* `default_privs` (optional) string with a value for the postfix `default_privs`
configuration option
* `export_environment` (optional) array of environment variables that will be
  passed to binaries or scripts called in `/etc/alias`
  (`alias: '|/path/command')  
  The contents of this array will be merged with the default
  `TZ`, `LANG`, `MAIL_CONFIG`

For example:

    [...SNIP...]
    "sys" => {
      "mail" => {
        "relay" => "smtp.devops.test",
        "aliases => {
          "root" => "jdoe@devops.test",
          "logcheck" => "root"
        }
      }
      [...SNIP...]
