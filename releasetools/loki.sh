#!/sbin/sh
#
# This leverages the loki_patch utility created by djrbliss which allows us
# to bypass the bootloader checks on jfltevzw and jflteatt
# See here for more information on loki: https://github.com/djrbliss/loki
#
#
# Run loki patch on boot.img for locked bootloaders, found in loki_bootloaders
#


if getprop ro.bootloader | grep -q 'I337UCUAMDB\|I337UCUAMDL'; then
  echo '[*] Locked bootloader version detected.'
  export C=/tmp/loki_tmpdir
  mkdir -p $C
  dd if=/dev/block/platform/msm_sdcc.1/by-name/aboot of=$C/aboot.img
  if getprop ro.twrp.boot | grep -q 1; then
    toybox mount /dev/block/bootdevice/by-name/system -t ext4 /system
    echo '[*] Patching boot.img to with loki.'
    /system/bin/loki_tool patch boot $C/aboot.img /tmp/boot.img $C/boot.lok || exit 1
    echo '[*] Flashing modified boot.img to device.'
    /system/bin/loki_tool flash boot $C/boot.lok || exit 1
    toybox umount /system
  else
    toybox mount /dev/block/bootdevice/by-name/system -t ext4 /mnt/system
    echo '[*] Patching boot.img to with loki.'
    /mnt/system/system/bin/loki_tool patch boot $C/aboot.img /tmp/boot.img $C/boot.lok || exit 1
    echo '[*] Flashing modified boot.img to device.'
    /mnt/system/system/bin/loki_tool flash boot $C/boot.lok || exit 1
    toybox umount /mnt/system
  fi
  rm -rf $C
else
  echo '[*] Unlocked bootloader version detected.'
  echo '[*] Flashing unmodified boot.img to device.'
  dd if=/tmp/boot.img of=/dev/block/platform/msm_sdcc.1/by-name/boot || exit 1
fi

exit 0
