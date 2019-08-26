#!/bin/bash

# Get android arch
arch=$(adb shell getprop ro.product.cpu.abi)
case $arch in
	arm64*|aarch64*)  arch="aarch64"  ;;
	arm*|aarch*)      arch="arm"      ;;
	x86*)             arch="x86"      ;;
esac

# Download pre-built rsync
! [ -f rsync.bin ] && curl --progress-bar -L -o rsync.bin "https://github.com/JBBgameich/rsync-static/releases/download/continuous/rsync-$arch"

# Kill running rsync instances
adb shell killall rsync

# Push rsync
adb push rsync.bin /data/rsync
adb shell chmod +x /data/rsync
adb push rsyncd.conf /data/rsyncd.conf

# Start rsync daemon on the device
adb shell '/data/rsync --daemon --config=/data/rsyncd.conf &'
adb forward tcp:6010 tcp:1873
