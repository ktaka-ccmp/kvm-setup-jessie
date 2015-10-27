# kvm-setup-jessie

## What is this?
This is a setup tool for Debian jessie kvm guest VMs on a Debian jessie host.
While there are libvirt compatible tools for debian, I prefere to run kvm a guest VM using qemu comandline for simplicity.
I compile guest kernel, qemu, prepare initrd, debootstrap root file system, and run the qemu program.
That's it. All you need to run a kvm VM is just to run the single qemu program with appropriate command line options. It's that simple.

So here is the setup tool for that purpose.

## Usage

### How to run the setup tool

```
sudo apt-get install make aptitude git -y
git clone git@github.com:ktaka-ccmp/kvm-setup-jessie.git
sudo make all 
```

Above will install needed tools to run kvm VMs in /kvm directory. Here are short description of purposes of /kvm/ subdirectories.

```
/kvm/
|-- SRC          directory for download and compilation.
|-- boot         directory for guest kernels.
|-- console      directory for guest console sockets.
|-- data         directory for VM images.
|-- etc          directory for guest networks setup scripts.
|-- mnt          mount point for VM image manupiration.
|-- monitor      directory for guest monitor sockets.
|-- qemu         qemu install directory.
`-- sbin         kvm script directory.
```

###How to run VMs.

You need to become root user to run/stop/control VMs.

The following command run a VM whose host name is v001. 

```
# /kvm/sbin/kvm  create v001 
booting v001 ....
```

You can access v001 both by connecting to console socket(UNIX domain socket) or by ssh to the host.

Socket connection:
```
# /kvm/sbin/kvm  con v001 

Debian GNU/Linux 8 v001 ttyS0

v001 login: root
Password: 
Last login: Wed Oct 28 02:57:58 UTC 2015 from 172.16.1.254 on pts/0
Linux v001 4.2.4-64kvmg01 #6 SMP Tue Oct 27 02:53:04 JST 2015 x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
root@v001:~# 
root@jessie64:~# 
```
The default ID/pass for vm guest console is root/root. 
The escape sequence for socket connection is "Ctrl+]". See /kvm/sbin/kvm .

SSH:
```
root@jessie64:~# ssh v001

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Wed Oct 28 03:00:32 2015
root@v001:~# 
```

The "/root/.ssh/authorized_keys" on the host will be copied to the VM template image during the setup. 
So you may be able to ssh using public key authentication. 


### How to stop VM. 

You can stop a vm either by the "poweroff" command inside the VM or sending shutdown sequence through the monitor socket. 

poweroff:
```
root@jessie64:~# ssh v001

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Wed Oct 28 03:07:58 2015
root@v001:~# poweroff 
Connection to v001 closed by remote host.
Connection to v001 closed.
```

Through monitor socket:
```
root@jessie64:~# /kvm/sbin/kvm  shutdown  v001 
QEMU 2.4.0.1 monitor - type 'help' for more information
(qemu) system_powerdown
(qemu) 
root@jessie64:~# 
```

