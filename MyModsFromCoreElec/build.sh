#!/bin/bash
#set -x
Scripts=scripts
Sources=sources

# get mkimage:
# sudo apt-get install u-boot-tools

mkdir -p $Scripts
#mkimage -C none -A arm -T script -d $Sources/boot.cmd $Scripts/boot.scr
mkimage -C none -A arm -T script -d $Sources/aml_autoscript.cmd $Scripts/aml_autoscript
mkimage -C none -A arm -T script -d $Sources/s905_autoscript.cmd $Scripts/s905_autoscript
