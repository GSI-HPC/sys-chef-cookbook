# `sys::time`

Configure the system time and timezone.

↪ `attributes/time.rb`  
↪ `recipes/time.rb`  
↪ `templates/default/etc_ntp.conf.erb`  

## Attributes

All attributes in `node['sys']['time']`:

`zone`
: (optional) sets the system timezone.
`servers`
: (optional) list of NTP servers.
`observers`
: (optional) list of hosts that can query the `ntpd` (ie. `ntpq -c rv …`).

## Example

Set the timezone to "Europe/Berlin" and a couple of NTP server are defined like:

```ruby
sys: {
  # …
  time: {
    zone: 'Indian/Maldives',
    servers: [
      '0.debian.pool.ntp.org',
      '1.debian.pool.ntp.org',
      '31.almalinux.pool.ntp.org'
    ],
    observers: [
      'matahari.example.org',
      'honey.rider.jb'
    ]
  },
  # …
```
