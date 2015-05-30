Getting started with Kobo reader hacking

# Introduction #

I have a Kobo ereader ( a first generation one, without wifi). It is a relatively open e-reader platform:

  1. Source code for the kernel (and some other things) was made available by Kobo developers at
> > https://github.com/kobolabs/Kobo-Reader
  1. Kobo can boot of an external sd-card, in fact it is one of the methods for upgrading firmware
> > http://bordersau.zendesk.com/entries/234241-how-do-i-update-my-kobo-firmware-if-i-am-using-linux
  1. While source code for the main reader application is not made public there is a public plug-in interface that allows for extension of the main reader application.

# Running Your own #

## Booting sd-card ##

  1. Format sd-card as ext3
  1. Populate with your choice of root
> > A good place to start is the firmware update sd-card linked earlier. Just edit `etc/init.d/rcS` to disable firmware update and add your code.
  1. Power off your reader and insert sd-card into it
  1. While holding down middle button on D-pad press power button
  1. Keep holding down middle button until squares start appearing on the screen

Use commands `show_pic` and `led` to see if it is running your code.

## Patching Kobo startup script ##
Kobo startup is rather simple: it just runs /etc/init.d/rcS . This script does minimal set up (mounts mainly) then it launches main reader application: `nickel`. What we want to do is add the following lines to `rcS` file

```
if [ -f /mnt/onboard/runme.sh ] ; then
 sh /mnt/onboard/runme.sh >/mnt/onboard/out.txt 2>/mnt/onboard/err.txt &
fi
```

This will run `runme.sh` script on startup if it is present on the internal flash drive of the Kobo reader. The outputs of that script will be redirected to files `out.txt` and `err.txt` for standard/error outputs.

You have two options to get that change into the firmware:
  1. Modify firmware files on your PC and then re-flash modified firmware
  1. Boot sd-card image with a script that modifies internal firmware.

Of the two options second one is probably the easiest. Here is a relevant part of the official `sd_upgrade_fs.sh`

```
#upgrade_filesystem
    mkdir -p /mnt/flash
    echo "Upgrade filesystem"
    mount /dev/mtdblock4 /mnt/flash -t yaffs2
    cd /mnt/flash
    /bin/show_pic /pic/02.jpg
    tar zxvf /files/${dev_name}/fs.tgz
    sync
    sleep 1
    sync
    cd /
    umount /mnt/flash
#end upgrade_filesystem
```

see: http://bordersau.zendesk.com/entries/234241-how-do-i-update-my-kobo-firmware-if-i-am-using-linux

Once you have the patch in place you can experiment with your Kobo without booting sd-card.

# References #
While some of the above is a result of original investigations done by me, a lot of it is sourced from various other sources online.

Here is an incomplete list of sources

  * http://www.mobileread.com/forums/forumdisplay.php?f=223
    * http://www.mobileread.com/forums/showthread.php?t=99820

  * http://blog.ringerc.id.au/2011/01/kobo-and-kobo-wifi-hacking.html and other posts about kobo wifi from the same blog
  * https://github.com/kobolabs/Kobo-Reader
  * http://bordersau.zendesk.com/entries/234241-how-do-i-update-my-kobo-firmware-if-i-am-using-linux
