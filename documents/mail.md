Configures Postfix to forward outgoing messages to a mail relay.

↪ `attributes/mail.rb`  
↪ `recipes/mail.rb`  
↪ `definitions/sys_mail_alias.rb`  

**Resource**

Add or change (Postfix) account to mail address aliases in
`/etc/aliases` with `sys_mail_alias`.


    sys_mail_alias "jdoe" do
      to "jdoe@devops.test"
    end

Note that you cannot remove aliases with this resource.

**Attributes**

All attributes in `node.sys.mail`:

* `relay` (required) defines the mail relay host FQDN.
* `aliases` (optional) hash of account name, mail address pairs.

For example:

    [...SNIP...]
    "sys" => {
      "mail" => {
        "relay" => "smtp.devops.test",
        "aliases => {
          "root" => jdoe@devops.test",
          "logcheck" => "root"
        }
      }
      [...SNIP...]
