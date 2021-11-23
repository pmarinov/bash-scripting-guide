#lang pollen

◊page-init{}
◊define-meta[page-title]{/proc}
◊define-meta[page-description]{Special-purpose directory /proc}

The ◊fname{/proc} directory is actually a pseudo-filesystem. The files
in ◊fname{/proc} mirror currently running system and kernel processes
and contain information and statistics about them.

◊example{
bash$ cat /proc/devices
Character devices:
  1 mem
  2 pty
  3 ttyp
  4 ttyS
  5 cua
  7 vcs
 10 misc
 14 sound
 29 fb
 36 netlink
128 ptm
136 pts
162 raw
254 pcmcia

Block devices:
  1 ramdisk
  2 fd
  3 ide0
  9 md



bash$ cat /proc/interrupts
           CPU0       
  0:      84505          XT-PIC  timer
  1:       3375          XT-PIC  keyboard
  2:          0          XT-PIC  cascade
  5:          1          XT-PIC  soundblaster
  8:          1          XT-PIC  rtc
 12:       4231          XT-PIC  PS/2 Mouse
 14:     109373          XT-PIC  ide0
NMI:          0 
ERR:          0


bash$ cat /proc/partitions
major minor  #blocks  name     rio rmerge rsect ruse wio wmerge wsect wuse running use aveq

   3     0    3007872 hda 4472 22260 114520 94240 3551 18703 50384 549710 0 111550 644030
   3     1      52416 hda1 27 395 844 960 4 2 14 180 0 800 1140
   3     2          1 hda2 0 0 0 0 0 0 0 0 0 0 0
   3     4     165280 hda4 10 0 20 210 0 0 0 0 0 210 210
   ...



bash$ cat /proc/loadavg
0.13 0.42 0.27 2/44 1119



bash$ cat /proc/apm
1.16 1.2 0x03 0x01 0xff 0x80 -1% -1 ?



bash$ cat /proc/acpi/battery/BAT0/info
present:                 yes
design capacity:         43200 mWh
last full capacity:      36640 mWh
battery technology:      rechargeable
design voltage:          10800 mV
design capacity warning: 1832 mWh
design capacity low:     200 mWh
capacity granularity 1:  1 mWh
capacity granularity 2:  1 mWh
model number:            IBM-02K6897
serial number:            1133
battery type:            LION
OEM info:                Panasonic

 
 
bash$ fgrep Mem /proc/meminfo
MemTotal:       515216 kB
MemFree:        266248 kB
}

Shell scripts may extract data from certain of the files in
◊fname{/proc}. Certain system commands, such as ◊command{procinfo},
◊command{free}, ◊command{vmstat}, ◊command{lsdev}, and
◊command{uptime} do this as well.
