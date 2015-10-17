KVER=4.2.3
KVER_MINOR=-64kvmg01

QEMU=qemu-2.4.0.1.tar.bz2

TOP_DIR=/kvm
SRC_DIR=${TOP_DIR}/SRC/
KERN_DIR=${SRC_DIR}/linux-${KVER}/
QEMU_DIR=${SRC_DIR}/$(QEMU:.tar.bz2=)

default: 
	@echo "Usage: make target "
	@echo " Available Targets "
	@echo "\t all		: Make all files"
	@echo "\t "
	@echo "\t kernel		: Compile kernel"
	@echo "\t initrd		: Create initrd image"

.PHONY: default

all: 
	make initrd
	make kernel

.PHONY: all kernel  


.PHONY: initrd
initrd: initrd_dir
	mkdir -p ${TOP_DIR}/boot/
	(cd $< ;find . | cpio -o -H newc | gzip -9 -n > ${TOP_DIR}/boot/initrd-kvm.img)

kernel: ${KERN_DIR}/.config ~/bin/installkernel
	mkdir -p ${TOP_DIR}/boot/
	ARCH=x86_64 nice -n 10 make -C ${KERN_DIR} -j20
	ARCH=x86_64 make -C ${KERN_DIR} install INSTALL_PATH=${TOP_DIR}/boot/
	(cp ${KERN_DIR}/.config dot.config ; touch ${KERN_DIR}/.config)

${KERN_DIR}/.config: dot.config
	mkdir -p ${SRC_DIR}
	if [ ! -d ${KERN_DIR} ]; then \
	(wget -c http://www.kernel.org/pub/linux/kernel/v4.x/linux-${KVER}.tar.xz; \
	tar xf linux-${KVER}.tar.xz -C ${SRC_DIR}; rm linux-${KVER}.tar.xz) ; fi
	sed -e 's/^CONFIG_LOCALVERSION=.*/CONFIG_LOCALVERSION=\"${KVER_MINOR}\"/g' dot.config > ${KERN_DIR}/.config
	ARCH=x86_64 make -C ${KERN_DIR} menuconfig
	(cd ${KERN_DIR}/; cp -v  .config .config.tmp ;\
	sed -e 's/^CONFIG_LOCALVERSION=.*/CONFIG_LOCALVERSION=\"${KVER_MINOR}\"/g' .config.tmp > .config ;\
	rm .config.tmp )
	(cd ${KERN_DIR}/; cp  .config ../dot.config ; touch .config)

~/bin/installkernel: /sbin/installkernel
	mkdir -p ~/bin/
	egrep -v "run-parts --verbose|/etc/kernel/postinst.d" /sbin/installkernel > ~/bin/installkernel

.PHONY: qemu
qemu: 
	mkdir -p ${SRC_DIR}
	if [ ! -d ${QEMU_DIR} ]; then \
	(wget -c http://wiki.qemu-project.org/download/${QEMU} ; \
	tar xf ${QEMU} -C ${SRC_DIR}; rm ${QEMU}) ; fi
	(cd ${QEMU_DIR}/; \
	./configure --prefix=${TOP_DIR}/qemu/$(QEMU:.tar.bz2=)/ --enable-kvm ; \
	time make -j 8 install ;\
	)

