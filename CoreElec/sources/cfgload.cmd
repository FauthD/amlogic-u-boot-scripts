echo "Using device ${device}, number ${devnr}, partition ${partnr}, CoreELEC on eMMC: ${ce_on_emmc}"

setenv decode_type "0"
setenv remotewakeupmask "0xffffffff"
setenv coreelec "quiet"
setenv vout "1080p60hz"
setenv frac_rate_policy "0"
setenv native_4k_gui "0"

setenv rootopt "BOOT_IMAGE=kernel.img boot=LABEL=COREELEC disk=LABEL=STORAGE"
if test "${ce_on_emmc}" = "yes"; then setenv rootopt "BOOT_IMAGE=kernel.img boot=LABEL=CE_FLASH disk=FOLDER=/dev/CE_STORAGE"; fi

if fatload ${device} ${devnr}:${partnr} ${loadaddr} resolution.ini; then env import -t ${loadaddr} ${filesize}; fi
if test "${allfmt_names}" != ""; then for name in ${allfmt_names}; do if test "${kernel_hdmimode}" = ${name}; then setenv vout ${name}; fi; done; fi
if fatload ${device} ${devnr}:${partnr} ${loadaddr} config.ini; then env import -t ${loadaddr} ${filesize}; fi

setenv consoleopt "console=ttyS0,115200 console=tty0 no_console_suspend"

if test "${cec_func_config}" != ""; then setenv cec "hdmitx=cec${cec_func_config}"; fi
if test "${gpiopower}" != ""; then setenv gpiopower "gpiopower=${gpiopower}"; fi
if test "${max_freq_a53}" != ""; then setenv max_freq_a53 "max_freq_a53=${max_freq_a53}"; fi
if test "${max_freq_a73}" != ""; then setenv max_freq_a73 "max_freq_a73=${max_freq_a73}"; fi
if test "${modeline}" != ""; then setenv cmode "modeline=${modeline}"; fi
if test "${wol}" != ""; then setenv wol "enable_wol=${wol}"; fi
if test "${keymap}" != ""; then setenv consoleopt "${consoleopt} keymap=${keymap}"; fi
if test "${loadaddr_kernel}" != ""; then setenv loadaddr "${loadaddr_kernel}"; fi
setenv displayopt "vout=${vout},en logo=osd0,loaded,${fb_addr} frac_rate_policy=${frac_rate_policy} native_4k_gui=${native_4k_gui} hdr_policy=1"
setenv initargs "${rootopt} ${consoleopt} ${max_freq_a53} ${max_freq_a73} ${wol} ${cec} ${gpiopower} ${usbopts} ${cmode}"
setenv bootargs "${bootargs} ${initargs} ${displayopt} ${coreelec}"

fatload ${device} ${devnr}:${partnr} ${loadaddr} kernel.img
fatload ${device} ${devnr}:${partnr} ${dtb_mem_addr} dtb.img

bootm ${loadaddr}
bootm start
bootm loados
bootm prep
bootm go
