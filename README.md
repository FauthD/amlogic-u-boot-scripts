# amlogic-u-boot-scripts
U-boot scripts for Amlogic based TV-Boxes

This is my attempt to understand the nasty boot details on these boxes.

It is "Work in process" and by no means a tutorial in how to use U-Boot.

# Caution
It is your own responsibility if you damage something. Before you carry out any action, you should understand the details about what you do.
# Logging
To see what is going on, it is essential that you can see the log output of u-boot.
Many boxes offer solder pads/holes marked with GND, TX, RX, VCC (or 3V). In my case the Tanix TX3 shows these 4 pads, so I soldered a 4 pin header into it and connected a USB-Serial adapter (FTDI): GND-GND, TX-RX, RX-TX. No connection on the VCC or 3V pin!
You can use Putty to see and log the output. Did I mention you need to open the box in first place? That is easy with an "Ifixit metal spundger". My favorite tool to open housings. The best 3€ I ever spent.

### Shell of U-Boot
You can even stop the boot and talk to the shell of u-boot.
Do it by pressing any key several times while the box boots and eventually you will end up at the prompt of U-Boot. Now you can enter commands.

Make yourself familiar with the commands. There is also the help command.

# Boot steps and background
These cheap TV boxes are not made to run Linux on them. They usually arrive with some kind of Android/Kodi as the OS. Neither Amlogic nor the box manufacturers will offer any support here.

Linux can be used with a trick discovered by a few smart people (I was not involved).

Most (all?) of these boxes offer a way to reflash their NAND memory. This mechanism is used to boot Linux from SD, USB or even direct from EMMC/NAND.

A U-Boot script checks a button after power up and if pressed, runs the script aml_autoscript on SD or USB. This aml_autoscript is now used to boot Linux. The details vary though. The above is often called "toothpick method".

In case there is no button, search in the settings of the box (Android). With luck you find a way to "reflash the device". That most likely also runs the aml_autoscript.

So far the only way I found to run kernel V4.9 is to encapsule it as an Android image together with the intial ramdisk.
Kernels like V5.10 or above can be booted easily with the booti command.

# Various operating systems
The different operating systems use flavours of the above method to boot.
Find the sources of the scripts in the sub directories. There are also bash scripts to translate the script sources (with extension.cmd) to the binary scripts (either .scr or no extension).
Files with .ini extension do not need to be translated, they work as text files.
## Be aware of small variations
Check carefully for small differences. E.g: Some use uEnv.ini, others uEnv.
txt. 
# LibreElec
Uses 5 scripts:
- aml_autoscript
- s905_autoscript
- boot.scr
- uEnv.ini
### for EMMC installation
- emmc_autoscript

Edit the uEnv.ini so it describes kernel boot parameter and dtb to use.
A '#' marks a comment.
The kernel always has the name KERNEL, no way to change without modifying s905_autoscript.
## Steps to boot LibreElec
### aml_autoscript
The first script aml_autoscript runs when the so called reset button is pressed after power up ("Toothpick method).
It's important actions:
- set variable bootcmd to 'run start_autoscript'
- set a few other variables for different boot details used by start_autoscript
- save
- reboot

(This is very much the same as with Armbian)
### s905_autoscript and emmc_autoscript
At next power up, start_autoscript runs and either calls s905_autoscript (SD, USB), or emmc_autoscript. 
It looks up kernel boot parameter and device tree from uEnv.ini and loads them into memory. Kernel has a fixed name KERNEL. Finally it calls the bootm command to start the kernel.

### boot.scr
There is a boot.scr and boot.ini in the image, but it looks like they are not used for Amlogic.

## Kernel format
LE uses an Android image format that also contains the initrd in the same file. See below for more details.

# CoreElec
Uses 3 scripts:
- aml_autoscript
- cfgload
- config.ini
- resolution.ini (does not exist in image)

## Steps to boot CoreElec
### aml_autoscript
The first script aml_autoscript runs when the so called reset button is pressed after power up ("Toothpick method).
It's important actions:
- set variable bootcmd to commands that will figure out from which drive to boot.
- save
- reboot

### bootcmd
At next power up, bootcmd runs from the environment and figures out from which drive to boot. Also loads cfgload to get more details, finally starts the kernel with bootm.
Kernel always has the name kernel.img, dtb is dtb.img.
You need to copy one of the *.dtb files to dtb.img.

### cfgload
This is called by the bootcmd to provide more boot details (mainly kernel boot args). It also imports the config.ini and resolution.ini.

### config.ini
Imported by cfgload, default file only contains comments. Can be used to change settings used by the kernel.

### resolution.ini
This is an optional file and will only be imported by cfgload if it exists.

## Kernel format
CE uses an Android image format that also contains the initrd in the same file. See below for more details.

## Enable kernel logs
Remove the word "quiet" from the "bootargs=" line in uEnv.ini.

## Caution: Running CoreElec will prevent to install Armbian.
You can read a reflash of the NAND with the original image is required to fix this. Fortunately it is easier than that. Just delete the variable "BootFromSD".
Reseting the U-Boot environment with default values should help as well:

	defenv
	saveenv
	reboot

# Armbian
Boot up Armbian for TV-Boxes is more complex compared to the other two OS. Even uses a second stage boot loader. I have read one of the reasons is bugs in some original boot loaders that prevent colors from showing correctly.

Uses 7 scripts:
- aml_autoscript
- s905_autoscript
- boot.scr
- boot.ini
- uEnv.ini
### for EMMC installation
- boot-emmc.scr
- boot-emmc.ini

Edit the uEnv.ini so it describes which kernel, kernel boot parameter, initrd and dtb to use.
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

## Steps to boot Armbian
### aml_autoscript
The first script aml_autoscript runs when the so called reset button is pressed after power up ("Toothpick method).
It's important actions:
- set variable bootcmd to 'run start_autoscript'
- set a few other variables for different boot details used by start_autoscript
- save
- reboot

### s905_autoscript and emmc_autoscript
At next power up, start_autoscript runs and either calls s905_autoscript (SD, USB), or emmc_autoscript. 
Both do load the u-boot.ext into memory and run it. This starts an instance of a newer version of U-Boot which in turn runs boot.scr.

### boot.scr
This script is executed by the the U-Boot (from u-boot.ext).
It looks up kernel, ramdisk and device tree from uEnv.txt and loads them into memory. Finally it calls the booti command to start the kernel.

# Booting kernels V4.9 as Android image
These older kernels cannot be booted directly with booti or bootm. There are various reasons for this, mainly bugs in the vendor u-boot. Chainloading also fails because the chainloaded modern u-boot cannot start kernels below 4.14.
A solution was found by the CoreElec team (or LibreElec team?). They encapsule their kernel into an Android image together with the initial ramdisk.
Therefore I tried to use the same method, however my kernel image is much bigger that the CE image (init ramdisk is bigger since I wanted to run Ubuntu). The vendor u-boot has an issue with images above 32MB. For luck I found an easy workaround: Using another load address (0x8080000).
My scripts are kind of a mix between the CoreElec and Armbian scripts. There is an uEnv.ini that needs to contain the names of kernel and dtb as well as kernel cmd line. No chainloading is used.
EMMC and SD-Kard installation are untested. I currently use an USB-Stick.
There is a log of a succesfull boot in Logs/CE_Kernel_With_Ubuntu_ROOTFS.

I do not know whether my scripts will work on devices  other than my Tanix TX3. Please report.
### Uses 3 scripts:
- aml_autoscript
- s905_autoscript
- uEnv.ini

### aml_autoscript
The first script aml_autoscript runs when the so called reset button is pressed after power up ("Toothpick method).
It's important actions:
- set variable bootcmd to commands that will figure out from which drive to boot.
- save
- reboot

### s905_autoscript
At next power up, start_autoscript runs and either calls s905_autoscript (SD, USB) (later perhaps emmc_autoscript).
It looks up kernel, boot parameter and device tree from uEnv.txt and loads them into memory. Finally it calls the bootm command to start the kernel as Android image.

# How to get sources of the scripts
The executable scripts contain a binary header with a checksum followed by the text of the script. That allows to use a hex editor like ghex to extract the script text. I did that for you already.

Armbian contains the sources additionally to the binary versions. So there it is easy to get them.

# Where to find the button for the "toothpick" method?
With some devices this button sits just behind the audio outlet and can be accessed by this hole with a plastic or wooden toothpick.

Some other devices have a very small hole for a paper clip.
On the TX3 this small hole sits between USB2 and audio outlet.

Press only gentle, you can feel the button spring.
