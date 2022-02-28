# amlogic-u-boot-scripts
U-boot scripts for Amlogic based TV-Boxes

This is my attempt to understand the nasty boot details on these boxes.

It is "Work in process" and by no means a tutorial in how to use U-Boot.

# Caution
It is your own responsibility if you damage something. Before you carry out an action, you should understand the details about what you do.
# Logging
To see what is going on, it is essential that you can see the log output of u-boot.
Many boxes offer solder pads/holes marked with GND, TX, RX, VCC (or 3V). In my case the Tanix TX3 shows these 4 pads, so I soldered a 4 pin header into it and connected a USB-Serial adapter (FTDI): GND-GND, TX-RX, RX-TX. No connection on the VCC or 3V pin!
You can use Putty to see and log the output. Did I mention you need to open the box in first place?

### Shell of U-Boot
You can even stop the boot and talk to the shell of u-boot.
Do it by pressing any key several times while the box boots and eventually you will end up at the prompt of U-Boot. Now you can enter commands.

Make yourself familiar with the commands. There is also the help command.

# Boot steps and background
These cheap TV boxes are not made to run Linux on them. They usually arrive with some kind of Android/Kodi as the OS. Neither Amlogic nor the box manufacturers will offer any support here.

Linux can be used with a trick discovered by a few smart people (I was not involved).

Most (all?) of these boxes offer a way to reflash their NAND memory. This mechanism is used to boot Linux from SD, USB or even direct from EMMC/NAND.

A U-Boot script checks a button after power up and if pressed, runs the script aml_autoscript on SD or USB. This aml_autoscript is now used to boot Linux. The details vary though. The above is often called "toothpick method".

In case there is no button, sarch in the settings of the box (Android). With luck you find a way to "reflash the device". That most likely also runs the aml_autoscript.

# Various operating systems
The different operating systems use flavours of the above method to boot.
Find the sources of the scripts in the sub directories. There are also bash scripts to translate the script sources (with extension.cmd) to the binary scripts (either .scr or no extension).
Files with .ini extension do not need to be translated, they work as text files.
# LibreElec
Uses 5 scripts:
- aml_autoscript
- s905_autoscript
- boot.scr
- uEnv.ini
### for EMMC installation
- emmc_autoscript

Edit the uEnv.ini so it describes which kernel, initrd and dtb to use.
A '#' marks a comment.
# Armbian
Boot up Armbian for TV-Boxes is more complex compare to the other two solutions. Even uses a second stage boot loader. I have read one of the reasons is bugs in some original boot loaders that prevent colors from showing correctly.

Uses 7 scripts:
- aml_autoscript
- s905_autoscript
- boot.scr
- boot.ini
- uEnv.ini
### for EMMC installation
- boot-emmc.scr
- boot-emmc.ini

Edit the uEnv.ini so it describes which kernel, initrd and dtb to use.
A '#' marks a comment.

### Chain load U-Boot
There are various files that contain a new U-Boot which gets loaded and run by s905_autoscript. It is not 100% clear how to use these files. On some places you can read that you must replace u-boot.ext with one of the *.bin files that fits your box. Other places tell you to use either the .sd or the .usb version.

For my Tanix TX3 I did some experiments (failed) before I went back to the original u-boot.ext which is the same contents as in u-boot-x96maxplus.bin. This boots fine from an USB stick or SSD with SATA/USB adapter.

- u-boot*.bin
- u-boot.ext
- u-boot.sd
- u-boot.usb

## Sabotage
The scripts for Armbian contain a test for the variable "BootFromSD". If it exists these scripts will simply exit. That prevents booting Armbian if CoreElec had been installed before.

I do not know why this test even exists. Find a possible solution in the CoreElec section. If you know the background, please report (open an isssue).

My scripts do not carry this sad test, so CoreElect traces will not disturb.

# CoreElec
Uses 3 scripts:
- aml_autoscript
- cfgload
- config.ini (I am not sure how this is loaded. Only contains comments anyway)

You need to copy one of the *.dtb files to dtb.img.
### Caution: Running CoreElec will prevent to install Armbian.
You can read a reflash of the NAND with the original image is required to fix this. Fortunatelly it is easier than that. Just delete the variable "BootFromSD".
Reseting the U-Boot environment with default values should help as well:

	defenv
	saveenv
	reboot

# How to get sources of the scripts
The executable scripts contain a binary header with a checksum followed by the text of the script. That allows to use a hex editor like ghex to extract the script text.

Armbian contains the sources additionally to the binary versions. So there it is easy to get them.