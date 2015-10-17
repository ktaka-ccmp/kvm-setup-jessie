KVER=4.2.3
KVER_MINOR=-64kvmg01

QEMU=qemu-2.4.0.1.tar.bz2

BUSYBOX_URI=http://busybox.net/downloads/busybox-1.23.2.tar.bz2
BUSYBOX_FILE=$(notdir ${BUSYBOX_URI})
BUSYBOX=$(BUSYBOX_FILE:.tar.bz2=)

TOP_DIR=/kvm
SRC_DIR=${TOP_DIR}/SRC/
KERN_DIR=${SRC_DIR}/linux-${KVER}/
QEMU_DIR=${SRC_DIR}/$(QEMU:.tar.bz2=)

TEMPLATE=template.jessie64


default: 
	@echo "Usage: make target "
	@echo " Available Targets "
	@echo "\t all		: Make all files"
	@echo "\t "
	@echo "\t kernel		: Compile kernel"
	@echo "\t initrd		: Create initrd image"
	@echo "\t qemu		: compile qemu"
	@echo "\t kvm		: copy kvm"

.PHONY: default

all: 
	make prep
	make initrd
	make kernel
	make qemu
	make kvm

.PHONY: all kernel  

prep:
	mkdir -p ${TOP_DIR}/boot/	
	mkdir -p ${TOP_DIR}/sbin/
	mkdir -p ${TOP_DIR}/data
	mkdir -p ${SRC_DIR}
	aptitude install -y debootstrap \
	ca-certificates \
	gcc \
	libncurses5-dev \
	screen \
	xz-utils \
	bc \
	ansible \
	git \
	bzip2 \
	g++ \
	libtool \
	pkg-config \
	zlib1g-dev \
	libglib2.0-dev \
	autoconf \
	build-essential \
	

#.PHONY: initrd
initrd: ${SRC_DIR}/initrd_dir
	(cd $< ;find . | cpio -o -H newc | gzip -9 -n > ${TOP_DIR}/boot/initrd-kvm.img)

.PHONY: ${SRC_DIR}/initrd_dir
${SRC_DIR}/initrd_dir: 
	mkdir -p ${SRC_DIR}/initrd_dir
	rsync -a --delete ${SRC_DIR}/${BUSYBOX}/_install/ ${SRC_DIR}/initrd_dir/
	mkdir -p ${SRC_DIR}/initrd_dir/sysroot
	cp files/init ${SRC_DIR}/initrd_dir/

kernel: ${KERN_DIR}/.config ~/bin/installkernel
	ARCH=x86_64 nice -n 10 make -C ${KERN_DIR} -j20
	ARCH=x86_64 make -C ${KERN_DIR} install INSTALL_PATH=${TOP_DIR}/boot/
	(cp ${KERN_DIR}/.config files/dot.config ; touch ${KERN_DIR}/.config)

${KERN_DIR}/.config: files/dot.config
	if [ ! -d ${KERN_DIR} ]; then \
	(wget -c http://www.kernel.org/pub/linux/kernel/v4.x/linux-${KVER}.tar.xz; \
	tar xf linux-${KVER}.tar.xz -C ${SRC_DIR}; rm linux-${KVER}.tar.xz) ; fi
	sed -e 's/^CONFIG_LOCALVERSION=.*/CONFIG_LOCALVERSION=\"${KVER_MINOR}\"/g' files/dot.config > ${KERN_DIR}/.config
	ARCH=x86_64 make -C ${KERN_DIR} menuconfig
	(cd ${KERN_DIR}/; cp -v  .config .config.tmp ;\
	sed -e 's/^CONFIG_LOCALVERSION=.*/CONFIG_LOCALVERSION=\"${KVER_MINOR}\"/g' .config.tmp > .config ;\
	rm .config.tmp )
	(cp ${KERN_DIR}/.config files/dot.config ; touch ${KERN_DIR}/.config)

~/bin/installkernel: /sbin/installkernel
	mkdir -p ~/bin/
	egrep -v "run-parts --verbose|/etc/kernel/postinst.d" /sbin/installkernel > ~/bin/installkernel

.PHONY: qemu
qemu: 
	if [ ! -d ${QEMU_DIR} ]; then \
	(wget -c http://wiki.qemu-project.org/download/${QEMU} ; \
	tar xf ${QEMU} -C ${SRC_DIR}; rm ${QEMU}) ; fi
	(cd ${QEMU_DIR}/; \
	./configure --prefix=${TOP_DIR}/qemu/$(QEMU:.tar.bz2=)/ --enable-kvm ; \
	time make -j 20 install ;\
	)

busybox:
	if [ ! -d ${SRC_DIR}/${BUSYBOX} ]; then \
	wget -c ${BUSYBOX_URI} ; \
	tar xf ${BUSYBOX_FILE} -C ${SRC_DIR}; rm ${BUSYBOX_FILE} ; fi
	cp files/dot.config.busybox ${SRC_DIR}/${BUSYBOX}/.config
	(cd ${SRC_DIR}/${BUSYBOX} ; \
	make menuconfig ; \
	time make -j 20 install )
	cp ${SRC_DIR}/${BUSYBOX}/.config files/dot.config.busybox 

kvm: files/kvm
	cp files/kvm ${TOP_DIR}/sbin/

template: 
	if [ ! -f ${TOP_DIR}/data/${TEMPLATE} ]; then \
	dd if=/dev/zero of=${TOP_DIR}/data/${TEMPLATE} bs=1024 seek=9999999 count=1 ; \
	mkfs.ext4 ${TOP_DIR}/data/${TEMPLATE} ; \
	mkdir -p ${TOP_DIR}/mnt/tmp ; \
	mount -o loop ${TOP_DIR}/data/${TEMPLATE} ${TOP_DIR}/mnt/tmp/ ; \
	debootstrap --include=openssh-server,openssh-client,rsync,pciutils,tcpdump,strace jessie ${TOP_DIR}/mnt/tmp/ http://apt.h.ccmp.jp:3142/ftp.jp.debian.org/debian ; \
	echo "root:root" | chpasswd --root ${TOP_DIR}/mnt/tmp/ ; \
	apt-get -o RootDir=${TOP_DIR}/mnt/tmp/ clean ;\
	umount ${TOP_DIR}/mnt/tmp ;\
	fi

