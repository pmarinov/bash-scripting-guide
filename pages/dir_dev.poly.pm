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

Checking whether a disk is in the CD-burner (soft-linked to /dev/hdc):

◊example{
head -1 /dev/hdc


#  head: cannot open '/dev/hdc' for reading: No medium found
#  (No disc in the drive.)

#  head: error reading '/dev/hdc': Input/output error
#  (There is a disk in the drive, but it can't be read;
#+  possibly it's an unrecorded CDR blank.)   

#  Stream of characters and assorted gibberish
#  (There is a pre-recorded disk in the drive,
#+ and this is raw output -- a stream of ASCII and binary data.)
#  Here we see the wisdom of using 'head' to limit the output
#+ to manageable proportions, rather than 'cat' or something similar.


#  Now, it's just a matter of checking/parsing the output and taking
#+ appropriate action.
}

When executing a command on a ◊fname{/dev/tcp/$host/$port}
pseudo-device file, Bash opens a TCP connection to the associated
socket.

A socket is a communications node associated with a specific I/O
port. (This is analogous to a hardware socket, or receptacle, for a
connecting cable.) It permits data transfer between hardware devices
on the same machine, between machines on the same network, between
machines across different networks, and, of course, between machines
at different locations on the Internet.

The following examples assume an active Internet connection.

Getting the time from nist.gov:

◊example{
bash$ cat </dev/tcp/time.nist.gov/13
53082 04-03-18 04:26:54 68 0 0 502.3 UTC(NIST) *

}

Generalizing the above into a script:

◊example{
#!/bin/bash
# This script must run with root permissions.

URL="time.nist.gov/13"

Time=$(cat </dev/tcp/"$URL")
UTC=$(echo "$Time" | awk '{print$3}')   # Third field is UTC (GMT) time.
# Exercise: modify this for different time zones.

echo "UTC Time = "$UTC""
}

Downloading a URL:

◊example{
bash$ exec 5<>/dev/tcp/www.net.cn/80
bash$ echo -e "GET / HTTP/1.0\n" >&5
bash$ cat <&5

}

◊anchored-example[#:anchor "tcp_tshoot1"]{Using /dev/tcp for
troubleshooting}

◊example{
#!/bin/bash
# dev-tcp.sh: /dev/tcp redirection to check Internet connection.

# Script by Troy Engel.
# Used with permission.
 
TCP_HOST=news-15.net       # A known spam-friendly ISP.
TCP_PORT=80                # Port 80 is http.
  
# Try to connect. (Somewhat similar to a 'ping' . . .) 
echo "HEAD / HTTP/1.0" >/dev/tcp/${TCP_HOST}/${TCP_PORT}
MYEXIT=$?

: <<EXPLANATION
If bash was compiled with --enable-net-redirections, it has the capability of
using a special character device for both TCP and UDP redirections. These
redirections are used identically as STDIN/STDOUT/STDERR. The device entries
are 30,36 for /dev/tcp:

  mknod /dev/tcp c 30 36

>From the bash reference:
/dev/tcp/host/port
    If host is a valid hostname or Internet address, and port is an integer
port number or service name, Bash attempts to open a TCP connection to the
corresponding socket.
EXPLANATION

   
if [ "X$MYEXIT" = "X0" ]; then
  echo "Connection successful. Exit code: $MYEXIT"
else
  echo "Connection unsuccessful. Exit code: $MYEXIT"
fi

exit $MYEXIT
}

◊anchored-example[#:anchor "pmusic1"]{Playing music}

◊example{
#!/bin/bash
# music.sh

# Music without external files

# Author: Antonio Macchi
# Used in ABS Guide with permission.


#  /dev/dsp default = 8000 frames per second, 8 bits per frame (1 byte),
#+ 1 channel (mono)

duration=2000       # If 8000 bytes = 1 second, then 2000 = 1/4 second.
volume=$'\xc0'      # Max volume = \xff (or \x00).
mute=$'\x80'        # No volume = \x80 (the middle).

function mknote ()  # $1=Note Hz in bytes (e.g. A = 440Hz ::
{                   #+ 8000 fps / 440 = 16 :: A = 16 bytes per second)
  for t in `seq 0 $duration`
  do
    test $(( $t % $1 )) = 0 && echo -n $volume || echo -n $mute
  done
}

e=`mknote 49`
g=`mknote 41`
a=`mknote 36`
b=`mknote 32`
c=`mknote 30`
cis=`mknote 29`
d=`mknote 27`
e2=`mknote 24`
n=`mknote 32767`
# European notation.

echo -n "$g$e2$d$c$d$c$a$g$n$g$e$n$g$e2$d$c$c$b$c$cis$n$cis$d \
$n$g$e2$d$c$d$c$a$g$n$g$e$n$g$a$d$c$b$a$b$c" > /dev/dsp
# dsp = Digital Signal Processor

exit      # A "bonny" example of an elegant shell script!
}

