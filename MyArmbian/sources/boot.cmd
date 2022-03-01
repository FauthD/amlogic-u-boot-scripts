echo "Start AMLOGIC mainline U-boot"
setenv env_addr "0x44000000"
setenv l_mmc "0 1 2 3"
for devtype in "usb mmc" ; do
	if test "${devtype}" = "mmc"; then
		setenv l_mmc "1"
	fi 
	for devnum in ${l_mmc} ; do
		if test -e ${devtype} ${devnum} uEnv.txt; then
			load ${devtype} ${devnum} ${env_addr} uEnv.txt
			env import -t ${env_addr} ${filesize}
			setenv bootargs ${APPEND}
			if printenv mac; then
				setenv bootargs ${bootargs} mac=${mac}
			elif printenv eth_mac; then
				setenv bootargs ${bootargs} mac=${eth_mac}
			elif printenv ethaddr; then
				setenv bootargs ${bootargs} mac=${ethaddr}
			fi
			if load ${devtype} ${devnum} ${kernel_addr_r} ${LINUX}; then
				echo "kernel_addr_r=${kernel_addr_r}, LINUX=${LINUX}"
				if load ${devtype} ${devnum} ${fdt_addr_r} ${FDT}; then
					echo "fdt_addr_r=${fdt_addr_r}, FDT=${FDT}"
					fdt addr ${fdt_addr_r}
					RamDisk=0
					if test '${INITRD}x' != 'x'; then
						if test -e ${devtype} ${devnum} ${INITRD}; then
							if fatload ${devtype} ${devnum} ${ramdisk_addr_r} ${INITRD}; then
								RamDisk=1
								echo "ramdisk_addr_r=${ramdisk_addr_r}, INITRD=${INITRD}"
							fi
						fi
					fi

					echo "bootargs=${bootargs}"
					if itest ${RamDisk} == 1; then
						echo "booti ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}"
						booti ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}
					else
						echo "booti ${kernel_addr_r} - ${fdt_addr_r}"
						booti ${kernel_addr_r} - ${fdt_addr_r}
					fi
				fi
			fi
		fi
	done
done
echo "End of df boot.scr"

# Recompile with:
# mkimage -C none -A arm -T script -d /boot/boot.cmd /boot/boot.scr
# Mod by Dieter Fauth, https://github.com/FauthD/amlogic-u-boot-script