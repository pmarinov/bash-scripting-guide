#lang pollen

◊define-meta[page-title]{File tests}
◊define-meta[page-description]{File test operators}

◊section{Returns true if...}

◊definition-block[#:type "code"]{
◊definition-entry[#:name "-e"]{
File ◊strong{exists}
}

◊definition-entry[#:name "-a"]{
File ◊strong{exists}

This is identical in effect to ◊code{-e}. It has been "deprecated,"
◊footnote{Per the 1913 edition of Webster's Dictionary:

◊emphasize{Deprecate} => To pray against, as an evil; to seek to avert
by prayer; to desire the removal of; to seek deliverance from; to
express deep regret for; to disapprove of strongly.} and its use is
discouraged.
}

◊definition-entry[#:name "-f"]{
File is a ◊strong{regular} file (not a directory or device file)
}

◊definition-entry[#:name "-s"]{
file is ◊strong{not zero size}
}

◊definition-entry[#:name "-d"]{
file is ◊strong{directory}
}

◊definition-entry[#:name "-b"]{
file is ◊strong{block device}
}

◊definition-entry[#:name "-c"]{
file is ◊strong{character device}

◊example{
device0="/dev/sda2"    # /   (root directory)
if [ -b "$device0" ]
then
  echo "$device0 is a block device."
fi

# /dev/sda2 is a block device.



device1="/dev/ttyS1"   # PCMCIA modem card.
if [ -c "$device1" ]
then
  echo "$device1 is a character device."
fi

# /dev/ttyS1 is a character device.
}

}

◊definition-entry[#:name "-p"]{
file is a ◊strong{pipe}

◊example{
function show_input_type()
{
   [ -p /dev/fd/0 ] && echo PIPE || echo STDIN
}

show_input_type "Input"                           # STDIN
echo "Input" | show_input_type                    # PIPE

# This example courtesy of Carl Anderson.
}

}

◊definition-entry[#:name "-h"]{
file is a ◊strong{symbolic link}
}

◊definition-entry[#:name "-L"]{
file is a ◊strong{symbolic link}
}

◊definition-entry[#:name "-S"]{
file is a ◊strong{socket}
}

◊definition-entry[#:name "-t"]{
file is (descriptor) associated with a ◊strong{terminal device}
}

◊definition-entry[#:name "-r"]{
file has ◊strong{read permission} (for the user running the test)
}

◊definition-entry[#:name "-w"]{
file has ◊strong{write permission} (for the user running the test)
}

◊definition-entry[#:name "-x"]{
file has ◊strong{execute permission} (for the user running the test)
}

◊definition-entry[#:name "-g"]{
file has ◊strong{set-group-id (sgid) flag} set

If a directory has the ◊code{sgid} flag set, then a file created
within that directory belongs to the group that owns the directory,
not necessarily to the group of the user who created the file. This
may be useful for a directory shared by a workgroup.
}

◊definition-entry[#:name "-u"]{
◊strong{set-user-id (suid) } flag set on file

A binary owned by root with ◊code{set-user-id} flag set runs with root
privileges, even when an ordinary user invokes it. ◊footnote{Be aware
that suid binaries may open security holes. The suid flag has no
effect on shell scripts.} This is useful for executables (such as
◊code{pppd} and ◊code{cdrecord}) that need to access system
hardware. Lacking the ◊code{suid} flag, these binaries could not be
invoked by a non-root user.

◊example{
-rwsr-xr-t    1 root       178236 Oct  2  2000 /usr/sbin/pppd
}

A file with the ◊code{suid} flag set shows an ◊code{s} in its
permissions.

}

◊definition-entry[#:name "-k"]{
file has ◊strong{sticky bit set} set

Commonly known as the sticky bit, the save-text-mode flag is a special
type of file permission. If a file has this flag set, that file will
be kept in cache memory, for quicker access. ◊footnote{On Linux
systems, the sticky bit is no longer used for files, only on
directories.} If set on a directory, it restricts write
permission. Setting the sticky bit adds a ◊code{t} to the permissions
on the file or directory listing. This restricts altering or deleting
specific files in that directory to the owner of those files.

◊example{
drwxrwxrwt    7 root         1024 May 19 21:26 tmp/
}

If a user does not own a directory that has the sticky bit set, but
has write permission in that directory, she can only delete those
files that she owns in it. This keeps users from inadvertently
overwriting or deleting each other's files in a publicly accessible
directory, such as ◊fname{/tmp}. (The owner of the directory or root
can, of course, delete or rename files there.)

}

◊definition-entry[#:name "-O"]{
you are ◊strong{owner} of file
}

◊definition-entry[#:name "-G"]{
group-id of file same as yours
}

◊definition-entry[#:name "-N"]{
file modified since it was last read
}

} ◊; definition-block

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
