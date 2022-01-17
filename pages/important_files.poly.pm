#lang pollen

◊page-init{}
◊define-meta[page-title]{Important Files}
◊define-meta[page-description]{Important Files and Folders}

◊section{Important Files}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "/etc/profile"]{
Systemwide defaults, mostly setting the environment (all Bourne-type
shells, not just Bash ◊footnote{This does not apply to ◊command{csh},
◊command{tcsh}, and other shells not related to or descended from the
classic Bourne shell (◊command{sh}).})

}

◊definition-entry[#:name "/etc/bashrc"]{
Systemwide functions and aliases for Bash

}

◊definition-entry[#:name "$HOME/.bash_profile"]{
User-specific Bash environmental default settings, found in each
user's home directory (the local counterpart to ◊fname{/etc/profile})

}

◊definition-entry[#:name "$HOME/.bashrc"]{
User-specific Bash init file, found in each user's home directory (the
local counterpart to ◊fname{/etc/bashrc}). Only interactive shells and
user scripts read this file. See TODO Appendix M for a sample
◊fname{.bashrc} file.

}

◊definition-entry[#:name "$HOME/.bash_logout"]{
User-specific instruction file, found in each user's home
directory. Upon exit from a login (Bash) shell, the commands in this
file execute.

}

◊definition-entry[#:name "/etc/passwd"]{
A listing of all the user accounts on the system, their identities,
their home directories, the groups they belong to, and their default
shell. Note that the user passwords are not stored in this file, but
in ◊fname{/etc/shadow} in encrypted form. ◊footnote{In older versions
of UNIX, passwords were stored in ◊fname{/etc/passwd}, and that
explains the name of the file.}

}

◊definition-entry[#:name "/etc/sysconfig/hwconf"]{
Listing and description of attached hardware devices. This information
is in text form and can be extracted and parsed.

◊example{
bash$ grep -A 5 AUDIO /etc/sysconfig/hwconf	      
class: AUDIO
bus: PCI
detached: 0
driver: snd-intel8x0
desc: "Intel Corporation 82801CA/CAM AC'97 Audio Controller"
vendorId: 8086
}

Note: This file is present on Red Hat and Fedora Core installations,
but may be missing from other distros.

}

}

◊section{Important System Directories}

Sysadmins and anyone else writing administrative scripts should be
intimately familiar with the following system directories.

◊definition-block[#:type "code"]{

◊definition-entry[#:name "/bin"]{
Binaries (executables). Basic system programs and utilities (such as
◊command{bash}).

}

◊definition-entry[#:name "/usr/bin"]{
More system binaries. ◊footnote{Some early UNIX systems had a fast,
small-capacity fixed disk (containing ◊fname{/}, the root partition), and a
second drive which was larger, but slower (containing ◊fname{/usr} and other
partitions). The most frequently used programs and utilities therefore
resided on the small-but-fast drive, in ◊fname{/bin}, and the others on the
slower drive, in ◊fname{/usr/bin}.

This likewise accounts for the split between ◊fname{/sbin} and
◊fname{/usr/sbin}, ◊fname{/lib} and ◊fname{/usr/lib}, etc.}

}

◊definition-entry[#:name "/usr/local/bin"]{
Miscellaneous binaries local to the particular machine.

}

◊definition-entry[#:name "/sbin"]{
System binaries. Basic system administrative programs and utilities
(such as ◊command{fsck}).

}

◊definition-entry[#:name "/etc"]{
Et cetera. Systemwide configuration scripts.

Of particular interest are the ◊fname{/etc/fstab} (filesystem table),
◊fname{/etc/mtab} (mounted filesystem table), and the
◊fname{/etc/inittab} files.

}

◊definition-entry[#:name "/etc/rc.d"]{
Boot scripts, on Red Hat and derivative distributions of Linux.

}

◊definition-entry[#:name "/usr/share/doc"]{
Documentation for installed packages.

}

◊definition-entry[#:name "/usr/man"]{
The systemwide manpages.

}

◊definition-entry[#:name "/dev"]{
Device directory. Entries (but not mount points) for physical and
virtual devices. See TODO Chapter 29.

}

◊definition-entry[#:name "/proc"]{
Process directory. Contains information and statistics about running
processes and kernel parameters. See TODO Chapter 29.

}

◊definition-entry[#:name "/sys"]{
Systemwide device directory. Contains information and statistics about
device and device names. This is newly added to Linux with the 2.6.X
kernels.

}

◊definition-entry[#:name "/mnt"]{
Mount.

Directory for mounting hard drive partitions, such as
◊fname{/mnt/dos}, and physical devices. In newer Linux distros, the
◊fname{/media} directory has taken over as the preferred mount point
for I/O devices.

}

◊definition-entry[#:name "/media"]{
In newer Linux distros, the preferred mount point for I/O devices,
such as CD/DVD drives or USB flash drives.

}

◊definition-entry[#:name "/var"]{
Variable (changeable) system files.

This is a catchall "scratchpad" directory for data generated while a
Linux/UNIX machine is running.

}

◊definition-entry[#:name "/var/log"]{
Systemwide log files.

}

◊definition-entry[#:name "/var/spool/mail"]{
User mail spool.

}

◊definition-entry[#:name "/lib"]{
Systemwide library files.

}

◊definition-entry[#:name "/usr/lib"]{
More systemwide library files.

}

◊definition-entry[#:name "/tmp"]{
System temporary files. All files here are deleted at boot time.

}

◊definition-entry[#:name "/boot"]{
System boot directory.

The kernel, module links, system map, and boot manager reside here.

Warning: Altering files in this directory may result in an unbootable
system.

}

}
