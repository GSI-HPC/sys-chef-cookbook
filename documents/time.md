Configure the system time and timezone.

↪ `attributes/time.rb`  
↪ `recipes/time.rb`  

**Attributes**

All attributes in `node.sys.time`:

* `zone` (optional) sets the system timezone.
* `servers` (optional) list of NTP servers (↪ `templates/*/etc_ntp.conf.erb`).

**Example**

Set the timezone to "Europe/Berlin" and a couple of NTP server are defined like:

    "sys" => {
      [...SNIP...]
      "time" {
        "zone" => "Europe/Berlin",
        "servers" => [
          "0.debian.pool.ntp.org",
          "1.debian.pool.ntp.org"
        ]
      },
      [...SNIP...]
