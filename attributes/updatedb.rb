default[:sys][:updatedb][:prunebindmounts] = "yes"
default[:sys][:updatedb][:prunepaths] = "/tmp /var/spool /media"
default[:sys][:updatedb][:prunefs] = "NFS nfs nfs4 rpc_pipefs afs binfmt_misc proc smbfs autofs iso9660 ncpfs coda devpts ftpfs devfs mfs shfs sysfs cifs lustre ldiskfs tmpfs usbfs udf fuse.glusterfs fuse.sshfs curlftpfs"
