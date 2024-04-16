#!/bin/bash

export KERNEL=kernel8
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-

UPDATE_KERNEL=0
UPDATE_DTBS=1

make -j16 Image modules dtbs
INSTALL_MOD_PATH=../modules make modules_install -j16

if [[ "$UPDATE_DTBS" != "" ]]
then
  rm -rf ../out/*
  mkdir -p ../out/overlays

  cp arch/arm64/boot/dts/broadcom/*.dtb ../out
  cp arch/arm64/boot/dts/overlays/*.dtb* ../out/overlays/
  cp arch/arm64/boot/dts/overlays/README ../out/overlays/
  cp arch/arm64/boot/Image ../out/$KERNEL.img
  scp -r ../out uconsole:~/
  ssh uConsole "sudo mv out/* /boot/"
  ssh uConsole "sudo mv out/overlays /boot/overlays/"
fi

cp arch/arm64/boot/Image ../out/$KERNEL.img
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
