#!/bin/bash

# Download prebuilt rsync
! [ -f rsync.bin ] && curl --progress-bar -L -o rsync.bin "https://github.com/JBBgameich/rsync-static/releases/download/continuous/rsync-arm"

# Kill running rsync instances
adb shell killall rsync

# Push rsync
adb push rsync.bin /data/rsync
adb shell chmod +x /data/rsync
adb push rsyncd.conf /data/rsyncd.conf

# Start rsync daemon on the device
adb shell '/data/rsync --daemon --config=/data/rsyncd.conf &'
adb forward tcp:6010 tcp:1873

# Where there is SElinux enabled (enforcing), we need to allow those ports
if [ getenforce ]; then
	sudo semanage port -a -t rsync_port_t -p tcp 6010
	sudo semanage port -a -t rsync_port_t -p tcp 1873
fi
