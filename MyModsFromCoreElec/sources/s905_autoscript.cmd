echo "start s905_aml_autoscript mainly for Android images"
#if fatload mmc 0 ${loadaddr} boot_android; then if test ${ab} = 0; then setenv ab 1; saveenv; exit; else setenv ab 0; saveenv; fi; fi;
#if fatload usb 0 ${loadaddr} boot_android; then if test ${ab} = 0; then setenv ab 1; saveenv; exit; else setenv ab 0; saveenv; fi; fi;

setenv ramdisk_addr_r 0x13000000
# This load addr works even with +100MB images
setenv loadaddr  0x8080000

setenv l_mmc "0"
for devtype in "mmc usb" ; do 
	if test "${devtype}" = "usb"; then
		echo "start test usb"
		setenv l_mmc "0 1 2 3"
	fi
	for devnum in ${l_mmc} ; do
		if test -e ${devtype} ${devnum} uEnv.txt; then
			fatload ${devtype} ${devnum} ${loadaddr} uEnv.txt
			env import -t ${loadaddr} ${filesize}
			setenv bootargs ${APPEND}
			if printenv mac; then
				setenv bootargs ${bootargs} mac=${mac}
			elif printenv eth_mac; then
				setenv bootargs ${bootargs} mac=${eth_mac}
			elif printenv ethaddr; then
				setenv bootargs ${bootargs} mac=${ethaddr}
			fi
			if fatload ${devtype} ${devnum} ${loadaddr} ${LINUX}; then
				echo "loadaddr=${loadaddr}, LINUX=${LINUX}"
				if fatload ${devtype} ${devnum} ${dtb_mem_addr} ${FDT}; then
					echo "dtb_mem_addr=${dtb_mem_addr}, FDT=${FDT}"
					RamDisk=0
					if test '${INITRD}x' != 'x'; then
						if test -e ${devtype} ${devnum} ${INITRD}; then
							if fatload ${devtype} ${devnum} ${ramdisk_addr_r} ${INITRD}; then
								RamDisk=1
								echo "ramdisk_addr_r=${ramdisk_addr_r}, INITRD=${INITRD}"
							fi
						fi
					fi
					if itest ${RamDisk} == 1; then
						#echo "bootm ${loadaddr} ${ramdisk_addr_r} ${dtb_mem_addr}"
						#bootm ${loadaddr} ${ramdisk_addr_r} ${dtb_mem_addr}
						#fdt addr ${dtb_mem_addr}
						echo "booti ${loadaddr} ${ramdisk_addr_r} ${dtb_mem_addr}"
						booti ${loadaddr} ${ramdisk_addr_r} ${dtb_mem_addr}
					else
						echo "bootargs=${bootargs}"
						echo "bootm ${loadaddr}"
						bootm ${loadaddr}
					fi
				fi
			fi
		fi
	done
done

# By Dieter Fauth, https://github.com/FauthD/amlogic-u-boot-scripts

