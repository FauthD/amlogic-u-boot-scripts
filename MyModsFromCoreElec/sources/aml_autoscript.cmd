echo "start aml_autoscript"
defenv
setenv ab 0;
setenv autoscript_addr 0x800000
setenv bootcmd 'run start_autoscript; run storeboot'
setenv start_autoscript 'if mmcinfo; then run start_mmc_autoscript; fi; if usb start; then run start_usb_autoscript; fi; run start_emmc_autoscript'
setenv start_emmc_autoscript 'if fatload mmc 1 ${autoscript_addr} emmc_autoscript; then autoscr ${autoscript_addr}; fi;'
setenv start_mmc_autoscript 'if fatload mmc 0 ${autoscript_addr} s905_autoscript; then autoscr ${autoscript_addr}; fi;'
setenv start_usb_autoscript 'for usbdev in 0 1 2 3; do if fatload usb ${usbdev} ${autoscript_addr} s905_autoscript; then autoscr ${autoscript_addr}; fi; done'
setenv upgrade_step 2
saveenv
sleep 1
reboot
# Mod by Dieter Fauth, https://github.com/FauthD/amlogic-u-boot-scripts