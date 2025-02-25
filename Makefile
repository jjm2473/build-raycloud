URL_BASE := https://github.com/hanwckf/raycloud-1296/releases/download
RELEASE_TAG = v2019-9-4
DTB := rtd-1296-raycloud-2GB.dtb

DTB_URL := $(URL_BASE)/$(RELEASE_TAG)/$(DTB)
KERNEL_URL := $(URL_BASE)/$(RELEASE_TAG)/Image
KMOD_URL := $(URL_BASE)/$(RELEASE_TAG)/modules.tar.xz

TARGETS := debian archlinux alpine ubuntu

DL := dl
DL_KERNEL := $(DL)/kernel/$(RELEASE_TAG)

WGET_KERNEL := wget -P $(DL_KERNEL)
WGET_PKG := wget -P $(DL)

OUTPUT := output

help:
	@echo "Usage: make build_[system1]=y build_[system2]=y build"
	@echo "available system: $(TARGETS)"

build: $(TARGETS)

clean: $(TARGETS:%=%_clean)

dl_kernel: $(DL_KERNEL)/$(DTB) $(DL_KERNEL)/Image $(DL_KERNEL)/modules.tar.xz

$(DL_KERNEL)/$(DTB):
	$(WGET_KERNEL) $(DTB_URL)

$(DL_KERNEL)/Image:
	$(WGET_KERNEL) $(KERNEL_URL)

$(DL_KERNEL)/modules.tar.xz:
	$(WGET_KERNEL) $(KMOD_URL)

ifeq ($(build_archlinux),y)
ARCHLINUX_PKG := ArchLinuxARM-aarch64-latest.tar.gz

ifneq ($(TRAVIS),)
ARCHLINUX_URL_BASE := http://os.archlinuxarm.org/os
else
ARCHLINUX_URL_BASE := https://mirrors.tuna.tsinghua.edu.cn/archlinuxarm/os
endif

archlinux: archlinux_dl
	sudo ./build-archlinux.sh release $(DL)/$(ARCHLINUX_PKG) $(DL_KERNEL)

archlinux_dl: dl_kernel $(DL)/$(ARCHLINUX_PKG)

$(DL)/$(ARCHLINUX_PKG):
	$(WGET_PKG) $(ARCHLINUX_URL_BASE)/$(ARCHLINUX_PKG)

archlinux_clean:
	rm -f $(DL)/$(ARCHLINUX_PKG)

else
archlinux:
archlinux_clean:
endif

ifeq ($(build_alpine),y)
ALPINE_BRANCH := v3.10
ALPINE_VERSION := 3.10.0
ALPINE_PKG := alpine-minirootfs-$(ALPINE_VERSION)-aarch64.tar.gz

ifneq ($(TRAVIS),)
ALPINE_URL_BASE := http://dl-cdn.alpinelinux.org/alpine/$(ALPINE_BRANCH)/releases/aarch64
else
ALPINE_URL_BASE := https://mirrors.tuna.tsinghua.edu.cn/alpine/$(ALPINE_BRANCH)/releases/aarch64
endif

alpine: alpine_dl
	sudo ./build-alpine.sh release $(DL)/$(ALPINE_PKG) $(DL_KERNEL)

alpine_dl: dl_kernel $(DL)/$(ALPINE_PKG)

$(DL)/$(ALPINE_PKG):
	$(WGET_PKG) $(ALPINE_URL_BASE)/$(ALPINE_PKG)

alpine_clean:
	rm -f $(DL)/$(ALPINE_PKG)

else
alpine:
alpine_clean:
endif

ifeq ($(build_ubuntu),y)
UBUNTU_PKG := ubuntu-base-18.04.2-base-arm64.tar.gz

ifneq ($(TRAVIS),)
UBUNTU_URL_BASE := http://cdimage.ubuntu.com/ubuntu-base/releases/bionic/release
else
UBUNTU_URL_BASE := https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cdimage/ubuntu-base/releases/bionic/release
endif

ubuntu: ubuntu_dl
	sudo ./build-ubuntu.sh release $(DL)/$(UBUNTU_PKG) $(DL_KERNEL)

ubuntu_dl: dl_kernel $(DL)/$(UBUNTU_PKG)

$(DL)/$(UBUNTU_PKG):
	$(WGET_PKG) $(UBUNTU_URL_BASE)/$(UBUNTU_PKG)

ubuntu_clean:
	rm -f $(DL)/$(UBUNTU_PKG)

else
ubuntu:
ubuntu_clean:
endif

ifeq ($(build_debian),y)

debian: dl_kernel
	sudo ./build-debian.sh release - $(DL_KERNEL)

debian_clean:

else
debian:
debian_clean:
endif
