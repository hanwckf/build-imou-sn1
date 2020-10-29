KERNEL_PKG ?= linux-5.4
RELEASE_TAG = v2020-10-29

DTB := hi3798cv200-imou-sn1.dtb
KERNEL_URL = https://github.com/hanwckf/linux-hi3798c/releases/download/$(RELEASE_TAG)
TARGETS := debian ubuntu archlinux

DL = dl
DL_KERNEL = $(DL)/kernel/$(RELEASE_TAG)
KERNEL_PKG_NAME = $(KERNEL_PKG).tar.xz
OUTPUT := output

CURL := curl -O -L -4
download = ( mkdir -p $(1) && cd $(1) ; $(CURL) $(2) )

help:
	@echo "Usage: make build_[system1]=y build_[system2]=y build"
	@echo "available system: $(TARGETS)"

build: $(TARGETS)

clean: $(TARGETS:%=%_clean)
	rm -f $(RESCUE_ROOTFS)

dl_kernel: $(DL_KERNEL)/$(KERNEL_PKG_NAME)
	tar -xf $(DL_KERNEL)/$(KERNEL_PKG_NAME) -C $(DL_KERNEL)

$(DL_KERNEL)/$(KERNEL_PKG_NAME):
	$(call download,$(DL_KERNEL),$(KERNEL_URL)/$(KERNEL_PKG_NAME))

ALPINE_BRANCH := v3.10
ALPINE_VERSION := 3.10.4
ALPINE_PKG := alpine-minirootfs-$(ALPINE_VERSION)-aarch64.tar.gz
RESCUE_ROOTFS := tools/rescue/rescue-alpine-imou-sn1-$(KERNEL_PKG)-$(ALPINE_VERSION)-aarch64.tar.xz

ifneq ($(TRAVIS),)
ALPINE_URL_BASE := http://dl-cdn.alpinelinux.org/alpine/$(ALPINE_BRANCH)/releases/aarch64
else
ALPINE_URL_BASE := https://mirrors.cloud.tencent.com/alpine/$(ALPINE_BRANCH)/releases/aarch64
endif

alpine_dl: dl_kernel $(DL)/$(ALPINE_PKG)

$(DL)/$(ALPINE_PKG):
	$(call download,$(DL),$(ALPINE_URL_BASE)/$(ALPINE_PKG))

alpine_clean:

$(RESCUE_ROOTFS):
	@[ ! -f $(RESCUE_ROOTFS) ] && make rescue

rescue: alpine_dl
	sudo kernel_ver=$(KERNEL_PKG) BUILD_RESCUE=y ./build-alpine.sh release $(DL)/$(ALPINE_PKG) $(DL_KERNEL) -

ARCHLINUX_PKG := ArchLinuxARM-aarch64-latest.tar.gz
ifneq ($(TRAVIS),)
ARCHLINUX_URL_BASE := http://os.archlinuxarm.org/os
else
ARCHLINUX_URL_BASE := https://mirrors.163.com/archlinuxarm/os
endif

archlinux_dl: dl_kernel $(DL)/$(ARCHLINUX_PKG)

$(DL)/$(ARCHLINUX_PKG):
	$(call download,$(DL),$(ARCHLINUX_URL_BASE)/$(ARCHLINUX_PKG))

archlinux_clean:

ifeq ($(build_archlinux),y)
archlinux: archlinux_dl $(RESCUE_ROOTFS)
	sudo kernel_ver=$(KERNEL_PKG) ./build-archlinux.sh release $(DL)/$(ARCHLINUX_PKG) $(DL_KERNEL) $(RESCUE_ROOTFS)
else
archlinux:
endif

UBUNTU_VER ?= 18.04.5
UBUNTU_PKG ?= ubuntu-base-$(UBUNTU_VER)-base-arm64.tar.gz
ifneq ($(TRAVIS),)
UBUNTU_URL_BASE = http://cdimage.ubuntu.com/ubuntu-base/releases/$(UBUNTU_VER)/release
else
UBUNTU_URL_BASE = https://mirrors.cloud.tencent.com/ubuntu-cdimage/ubuntu-base/releases/$(UBUNTU_VER)/release
endif

ubuntu_dl: dl_kernel $(DL)/$(UBUNTU_PKG)

$(DL)/$(UBUNTU_PKG):
	$(call download,$(DL),$(UBUNTU_URL_BASE)/$(UBUNTU_PKG))

ubuntu_clean:

ifeq ($(build_ubuntu),y)
ubuntu: ubuntu_dl $(RESCUE_ROOTFS)
	sudo kernel_ver=$(KERNEL_PKG) ./build-ubuntu.sh release $(DL)/$(UBUNTU_PKG) $(DL_KERNEL) $(RESCUE_ROOTFS)
else
ubuntu:
endif

ifeq ($(build_debian),y)
DEBIAN_VER ?= buster
debian: dl_kernel $(RESCUE_ROOTFS)
	sudo debian_ver=$(DEBIAN_VER) kernel_ver=$(KERNEL_PKG) ./build-debian.sh release - $(DL_KERNEL) $(RESCUE_ROOTFS)

else
debian:
endif
debian_clean:

