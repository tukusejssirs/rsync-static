# rsync-static
This repository contains a script to build static rsync binaries for ARM, aarch64 and x86 using a musl gcc toolchain.

# Example
This example is based on [a blog post](https://ptspts.blogspot.de/2015/03/how-to-use-rsync-over-adb-on-android.html) by [Péter Szabó](https://github.com/pts).

To install and start rsync on your Android phone, run

`./adb-start-rsyncd.sh`

You can now transfer files from and to the device. To pull your current rsyncd.conf, use this command:

`rsync -av --progress --stats rsync://localhost:6010/root/data/rsyncd.conf .`

To deploy a new rsyncd.conf file using rsync, you can use

`rsync -av --progress --stats rsyncd.conf rsync://localhost:6010/root/data/rsyncd.conf`
