#!/bin/bash
# Install additional build dependencies for packages
# mysql: makefs
sudo apt-get update
sudo apt-get install makefs genisoimage
sudo apt-get install openjdk-7-jdk

# Build and install rumprun toolchain from source
RUMPKERNEL=${RUMPKERNEL:-netbsd}
RUMPRUN_PLATFORM=${RUMPRUN_PLATFORM:-hw}
RUMPRUN_TOOLCHAIN_TUPLE=${RUMPRUN_TOOLCHAIN_TUPLE:-x86_64-rumprun-${RUMPKERNEL}}

#git clone -q https://github.com/libos-nuse/rumprun /tmp/rumprun
#(
#	cd /tmp/rumprun
#	git submodule update --init
#	./build-rr.sh -d /usr/local -r ${RUMPKERNEL} -o ./obj -qq ${RUMPRUN_PLATFORM} build
#	sudo ./build-rr.sh -d /usr/local -o ./obj ${RUMPRUN_PLATFORM} install
#)

echo RUMPRUN_TOOLCHAIN_TUPLE=${RUMPRUN_TOOLCHAIN_TUPLE} >config.mk
