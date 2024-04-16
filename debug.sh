#!/bin/bash

export KERNEL=kernel8
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-

make -j16 Image modules dtbs
INSTALL_MOD_PATH=../modules make modules_install -j16
cp arch/arm64/boot/Image ../out/$KERNEL.img

#UPDATE_KERNEL=1

scp ../modules/lib/modules/6.1.21-v8+/kernel/drivers/gpu/drm/vc4/vc4.ko.xz 192.168.50.4:~/
scp ../modules/lib/modules/6.1.21-v8+/kernel/drivers/gpu/drm/panel/panel-cwu50.ko.xz 192.168.50.4:~/
scp ../modules/lib/modules/6.1.21-v8+/kernel/drivers/video/backlight/ocp8178_bl.ko.xz 192.168.50.4:~/

ssh uConsole "sudo mv vc4.ko.xz /lib/modules/6.1.21-v8+/kernel/drivers/gpu/drm/vc4/"
ssh uConsole "sudo mv panel-cwu50.ko.xz /lib/modules/6.1.21-v8+/kernel/drivers/gpu/drm/panel/"
ssh uConsole "sudo mv ocp8178_bl.ko.xz /lib/modules/6.1.21-v8+/kernel/drivers/video/backlight/"

if [[ "$UPDATE_KERNEL" != "" ]]
then
  scp ../out/kernel8.img uconsole:~/
  ssh uConsole "sudo mv kernel8.img /boot/"
fi

ssh uConsole "sudo mkinitcpio -P"
