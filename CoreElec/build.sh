#!/bin/bash
#set -x
Scripts=scripts
Sources=sources

mkdir -p $Scripts
mkimage -C none -A arm -T script -d $Sources/cfgload.cmd $Scripts/cfgload
mkimage -C none -A arm -T script -d $Sources/aml_autoscript.cmd $Scripts/aml_autoscript
