echo "start s905_aml_autoscript with amlogic u-boot.ext"
#echo "start s905_aml_autoscript"
#if fatload mmc 0 ${loadaddr} boot_android; then if test ${ab} = 0; then setenv ab 1; saveenv; exit; else setenv ab 0; saveenv; fi; fi;
#if fatload usb 0 ${loadaddr} boot_android; then if test ${ab} = 0; then setenv ab 1; saveenv; exit; else setenv ab 0; saveenv; fi; fi;
echo "Try chainload a newer u-boot"
if fatload mmc 0 0x1000000 u-boot.ext; then go 0x1000000; fi;
if fatload usb 0 0x1000000 u-boot.ext; then go 0x1000000; fi;
echo "Proceed with old u-boot"
# I could not boot with old u-boot. It does not like the dtb.
setenv fdt_addr_r 0x1000000
#setenv env_addr 0x10400000
setenv env_addr 0x44000000
#setenv kernel_addr_r 0x11000000
setenv kernel_addr_r 0x08080000
setenv ramdisk_addr_r 0x13000000
setenv l_mmc "0"
for devtype in "mmc usb" ; do 
	if test "${devtype}" = "usb"; then
		echo "start test usb"
		setenv l_mmc "0 1 2 3"
	fi
	for devnum in ${l_mmc} ; do
		if test -e ${devtype} ${devnum} uEnv.txt; then
			fatload ${devtype} ${devnum} ${env_addr} uEnv.txt
			env import -t ${env_addr} ${filesize}
			setenv bootargs ${APPEND}
			if printenv mac; then
				setenv bootargs ${bootargs} mac=${mac}
			elif printenv eth_mac; then
				setenv bootargs ${bootargs} mac=${eth_mac}
			elif printenv ethaddr; then
				setenv bootargs ${bootargs} mac=${ethaddr}
			fi
			if fatload ${devtype} ${devnum} ${kernel_addr_r} ${LINUX}; then
				echo "kernel_addr_r=${kernel_addr_r}, LINUX=${LINUX}"
				if fatload ${devtype} ${devnum} ${ramdisk_addr_r} ${INITRD}; then
					echo "ramdisk_addr_r=${ramdisk_addr_r}, INITRD=${INITRD}"
					if fatload ${devtype} ${devnum} ${fdt_addr_r} ${FDT}; then
						echo "fdt_addr_r=${fdt_addr_r}, FDT=${FDT}"
						echo "bootargs=${bootargs}"
						echo "booti ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}"
						fdt addr ${fdt_addr_r}
						booti ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}
					fi
				fi
			fi
		fi
	done
done

# Mod by Dieter Fauth, https://github.com/FauthD/amlogic-u-boot-scripts