#!/bin/bash
if [ -e /boot/armbianEnv.txt ]; then
  FDT_FILE=`grep -e '^fdt_file=' /boot/armbianEnv.txt | cut -d= -f2`
fi

if [ ! -z "$FDT_FILE" ]; then
  if [ `grep -c -e 'asus,rk3288-tinker' /proc/device-tree/compatible` -eq 1 ]; then
    INCLUDE_FILE='/var/lib/piVCCU/dts/tinkerboard.dts.include'
  fi

  if [ -z "$INCLUDE_FILE" ]; then
    echo "piVCCU: Hardware platform is not supported"
    exit 1
  fi

  TMP_DIR=`mktemp -d`
  cp /boot/dtb/$FDT_FILE $TMP_DIR

  dtc -I dtb -O dts -q -o $TMP_DIR/devicetree.dts /boot/dtb/$FDT_FILE

  if [ `grep -c -e 'compatible = "pivccu,' $TMP_DIR/devicetree.dts` -eq 0 ]; then
    echo "piVCCU: Patching DTB $FDT_FILE"
    cp /boot/dtb/$FDT_FILE /boot/dtb/$FDT_FILE.bak
    cat $INCLUDE_FILE >> $TMP_DIR/devicetree.dts
    dtc -I dts -O dtb -q -o $TMP_DIR/$FDT_FILE $TMP_DIR/devicetree.dts
    cp $TMP_DIR/$FDT_FILE /boot/dtb
  else
    echo "piVCCU: DTB $FDT_FILE was already patched"
  fi

  rm -rf $TMP_DIR
else
  echo "piVCCU: FDT could not be determined"
  exit 1
fi
