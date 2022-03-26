

On FreeBSD 4


mkdir /.null
chmod 0 /.null

mkdir /CFS
chmod 0755 /CFS

# /etc/sysctl.conf
net.inet.udp.recvspace=233016 
net.inet.udp.sendspace=65536

# /etc/rc.conf
portmap=YES
nfs_server=YES
nfsd_flags="-tun 4"

# /etc/exports
/.null 127.0.0.1


# /etc/rc.local
cfsd 3333
mount -o port=3333,nfsv2,intr 127.0.0.1:/.null /CFS


//—//
User actions
//—//
#create
cmkdir  <crypted dir>

#mount
cattach <crypted dir>  <decrypt_share-name> 
cd /CFS/<decrypt_share-name>

#unmount
cdetach <decrypt_share-name>
