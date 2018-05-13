#!/bin/bash
#
# build_android.sh - build rsync binaries for different mobile architectures using a cross compiler
#
# Florian Dejonckheere <florian@floriandejonckheere.be>
#

# Whether or not to strip binaries (smaller filesize)
STRIP=1

ARCH=(arm aarch64 x86)
CCPREFIX=(arm-linux-musleabihf aarch64-linux-musl i486-linux-musl)

function create_toolchain() {
	if [ $BUILD_TOOLCHAIN ]; then
		echo "I: Building toolchain"
		for target in $CCPREFIX; do
			# Configure
			echo "TARGET = $target" > musl-cross-make/config.mak
			echo "GCC_VER = 7.2.0" >> musl-cross-make/config.mak
			echo "LINUX_VER = 4.4.10" >> musl-cross-make/config.mak

			# Build
			make -C musl-cross-make

			# Install
			make -C musl-cross-make OUTPUT="/" DESTDIR="$PWD/toolchain" install
		done
	else
		if ! [ -d toolchain ]; then
			mkdir toolchain

			echo "I: Downloading prebuilt toolchain"
			wget --continue https://skarnet.org/toolchains/cross/arm-linux-musleabihf-armv7-vfpv3-7.1.0.tar.xz -O /tmp/arm-linux-musleabihf-armv7-vfpv3.tar.xz
			wget --continue https://skarnet.org/toolchains/cross/aarch64-linux-musl-8.1.0.tar.xz -O /tmp/aarch64-linux-musl.tar.xz
			wget --continue https://skarnet.org/toolchains/cross/i486-linux-musl-8.1.0.tar.xz -O /tmp/i486-linux-musl.tar.xz

			for xz in /tmp/*linux-musl*.xz; do
				tar -xf $xz -C toolchain
			done
		fi
	fi
}

function find_toolchain() {
	for I in $(seq 0 $((${#ARCH[@]} - 1))); do
		# Use toolchain in following builds
		TOOLCHAIN_PATH="$(readlink -f $(dirname $(find . -name "${CCPREFIX[$I]}-gcc"))/..)"
		export PATH=$PATH:$TOOLCHAIN_PATH/bin
	done
}

function build_rsync() {
	echo "I: Building rsync"
	cd rsync/
	for I in $(seq 0 $((${#ARCH[@]} - 1))); do
		echo "****************************************"
		echo Building for ${ARCH[$I]}
		echo "****************************************"

		make clean
		export CC="${CCPREFIX[$I]}-gcc"
		./configure CFLAGS="-static" --host="${ARCH[$I]}"
		make
		[ $STRIP ] && "${CCPREFIX[$I]}-strip" rsync
		mv rsync "../rsync-${ARCH[$I]}"
	done
	cd ..
}

create_toolchain
find_toolchain
[ $BUILD_RSYNC ] && build_rsync
