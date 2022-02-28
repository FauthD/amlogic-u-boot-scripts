#!/bin/bash
#set -x
Scripts=scripts
Sources=sources

mkdir -p $Scripts
mkimage -C none -A arm -T script -d $Sources/aml_autoscript.cmd $Scripts/aml_autoscript
mkimage -C none -A arm -T script -d $Sources/s905_autoscript.cmd $Scripts/s905_autoscript
mkimage -C none -A arm -T script -d $Sources/boot.cmd $Scripts/boot.scr

mkimage -C none -A arm -T script -d $Sources/emmc_autoscript.cmd $Scripts/emmc_autoscript
mkimage -C none -A arm -T script -d $Sources/boot-emmc.cmd $Scripts/boot-emmc.scr
