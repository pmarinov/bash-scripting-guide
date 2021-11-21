#lang pollen

◊page-init{}
◊define-meta[page-title]{/dev}
◊define-meta[page-description]{Special-purpose directory /dev}

The entries in ◊fname{/dev} provide mount points for physical and
virtual devices.

The ◊fname{/dev} directory contains entries for the physical devices
that may or may not be present in the hardware. Appropriately enough,
these are called device files. As an example, the hard drive
partitions containing the mounted filesystem(s) have entries in
◊fname{/dev}, as ◊command{df} shows.

◊example{
bash$ df
Filesystem           1k-blocks      Used Available Use%
Mounted on
/dev/hda6               495876    222748    247527  48% /
/dev/hda1                50755      3887     44248   9% /boot
/dev/hda8               367013     13262    334803   4% /home
/dev/hda5              1714416   1123624    503704  70% /usr

}

Some devices, such as ◊fname{/dev/null}, ◊fname{/dev/zero}, and
◊fname{/dev/urandom} are virtual. They are not actual physical devices
and exist only in software.

Among other things, the ◊fname{/dev} directory contains loopback
devices, such as ◊fame{/dev/loop0}. A loopback device is a gimmick
that allows an ordinary file to be accessed as if it were a block
device. This permits mounting an entire filesystem within a single
large file. See TODO Example 17-8 and Example 17-7. ◊footnote{A block
device reads and/or writes data in chunks, or blocks, in contrast to a
character device, which acesses data in character units. Examples of
block devices are hard drives, CDROM drives, and flash
drives. Examples of character devices are keyboards, modems, sound
cards.}

For instance:

To manually mount a USB flash drive, append the following line to /etc/fstab.

◊example{
/dev/sda1    /mnt/flashdrive    auto    noauto,user,noatime    0 0
}

(See also TODO Example A-23.)

Of course, the mount point ◊fname{/mnt/flashdrive} must exist. If not,
then, as root, ◊command{mkdir /mnt/flashdrive.}

To actually mount the drive, use the following command: ◊command{mount
/mnt/flashdrive}

Newer Linux distros automount flash drives in the ◊fname{/media}
directory without user intervention.




