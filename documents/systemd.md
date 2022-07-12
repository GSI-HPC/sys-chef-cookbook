# `sys::systemd`

## journald setup

Attributes beneath `node['sys']['systemd']['journald']` are written to
`/etc/systemd/journald.conf`.

## network(d) setup

Set `node['sys']['systemd']['networkd']['enable']` to enable and start
`systemd-networkd.

### Automatic migration from `ifupdown`

**This is a dangerous operation that may break your network setup,
use with care!**

`node['sys']['systemd']['networkd']['make_primary_interface_persistent']` will
create a `.network` file containing the current network configuration
as detected by Ohai.

`node['sys']['systemd']['networkd']['clean_legacy']` will remove any existing
network configuration for `ifupdown` in `/etc/network/interfaces` and
`/etc/network/interfaces.d/*`
