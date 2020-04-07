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


} ◊; definition-block

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
