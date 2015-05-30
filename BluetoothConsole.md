This page describes how to login into Kobo reader via bluetooth console.

# Introduction #

Given that
  1. It is possible to run custom scripts on Kobo
  1. Kobo reader has bluetooth

it should be possible to login into the reader via bluetooth serial console. Things to know: `hcitool hciconfig rfcomm getty minicom busybox`

## Overview of the setup ##
  1. Establish connection between Kobo and PC using `rfcomm`
    * on PC `rfcomm listen 0 1`
    * on Kobo: rfcomm connect 0 MAC\_ADDR 1
  1. Run `getty` on Kobo using `/dev/rfcomm0` as tty
  1. Run `minicom` on PC to connect into Kobo.

# Instructions #

I assume throughout that you are running linux-based distribution of some sort on you computer/laptop. This was all tested on ubuntu laptop.

First you should read [README](README.md) section and make sure you can run custom scripts on your Kobo reader (first gen no wifi).

Second you need to **pair** your computer with Kobo.

## Pairing Kobo with your PC ##
Kobos' documentation and interface keeps talking about blackberry, but really you can pair any device to Kobo. This is how you do it on Ubuntu

  1. Make your BT visible on a PC
> > In Ubuntu: left click on BT applet make sure Visible is checked
> > Or from command line `sudo hciconfig hci0 iscan piscan`(Not sure if this is necessary, but won't hurt)
  1. On Kobo : menu->Bluetooth Sync
  1. This will display some screen with a pin number
  1. On PC BT applet->"set up new device"
    * Pin Options...
    * Custom pin: enter PIN displayed on Kobo
  1. If successful you should have "Generic Kobo device" sub-menu on you BT applet

Pairing only needs to happen once, both kobo and you computer will remember relevant settings and will connect to each other automatically from now on.

Try it BT->Generic Kobo device->Browse files...

You can add content via bluetooth and it will get copied to your reader, but unfortunately it won't appear in your library until you connect and disconnect usb plug.

## Adding custom busybox to your reader ##
Busybox (http://www.busybox.net/) shipped with latest Kobo firmware does not have `getty` plugin, and we need it to login. I have compiled a compatible busybox using the toolchain I got from here: http://code.google.com/p/princess-alist/downloads/detail?name=arm-linux-gcc-3.4.1.tar.bz2&can=2&q=

It might be possible to replace original busybox with the new one, but it is safer to keep original and just copy new one into /bin2/ folder.

You can either compile your own or download pre-compiled version from the download section `KoboRoot_patch.tgz` file. Use `runme.sh` to add new busybox (if you don't know what I am talking about read [README](README.md) **now**).

```
 tar -xvzf /mnt/onboard/KoboRoot_patch.tgz -C /
 echo "Checking busybox installation"
 /bin2/busybox
```

## Starting getty on bluetooth ##

I have written a script that waits for bluetooth to be enabled on Kobo and then attempts to connect to your PC and start getty on that connection:

http://kobo-hacks.googlecode.com/hg/bt_rfcomm.sh

To use it download to your reader internal card into scripts folder,
then create `runme.sh` like that
```
#!/bin/sh
cd /mnt/onboard/
sh scripts/bt_rfcomm.sh XX:XX:XX:XX:XX:XX >/dev/null 2>/dev/null
```

Replace `XX:XX:XX:XX:XX:XX` with actual mac address of your PC bluetooth (`hciconfig -a`). For debugging you might want to skip redirecting to null.

## Setup on your PC ##

Make sure you have `rfcomm hciconfig hcitool minicom` installed.

Configure minicom using `sudo minicom -s` choose following parameters:
```
pu port             /dev/rfcomm0
pu baudrate         38400
pu bits             8
pu parity           N
pu stopbits         1
```

  1. Make sure your computers bluetooth is visible
  1. In the terminal run the following: `sudo rfcomm listen 0 1`
  1. Boot up your reader
  1. On the reader: Menu->Bluetooth Sync (you have about ten minutes to enable bluetooth before the script gives up on waiting)
  1. Back in the terminal you'll see
```
Connection from XX:XX:XX:XX:XX:XX to /dev/rfcomm0
Press CTRL-C for hangup
```
  1. In another terminal do: `sudo minicom`
  1. If all went well you should have shell on your reader.