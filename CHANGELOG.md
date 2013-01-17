# 0.8.0

* Configuration of Sudo with `node.sys.sudo`.
* Configuration of the SSH daemon with `node.sshd.config` and management
  of authorized keys with `node.sys.ssh.authorize`.
* Support the configuration of network interfaces, VLANs and bridges with
  `node.sys.network.interfaces`.  
* Configure mail relay and aliases with attributes in `node.sys.mail`.
* Configure DNS names service with attributes in `node.sys.resolv`.
* Set the timezone and configure NTP servers in `node.sys.time`.
* Configure sysctl with `node.sys.ctl`.
* Configure a serial console with attribute `node.serial`.
* Deploy cgroups with attributes in `node.sys.cgroups`.
* Alter Grub boot configuration attributes in `node.sys.boot`. 
* System login banner with attributes in `node.sys.banner`,
* Load Linux kernel modules with `sys_module`.
* Reboot/Shutdown node with `sys_shutdown`. 
