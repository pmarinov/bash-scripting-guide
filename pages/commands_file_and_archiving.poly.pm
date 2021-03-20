#lang pollen

◊; This is free software released into the public domain
◊; See LICENSE.txt

◊page-init{}
◊define-meta[page-title]{Files and Archiving}
◊define-meta[page-description]{Files and Archiving Commands}


◊section{Archiving}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "tar"]{
The standard UNIX archiving utility. ◊footnote{An archive, in the
sense discussed here, is simply a set of related files stored in a
single location.}

Originally a Tape ARchiving program, it has developed into a general
purpose package that can handle all manner of archiving with all types
of destination devices, ranging from tape drives to regular files to
even ◊code{stdout} (see TODO Example 3-4). GNU ◊command{tar} has been
patched to accept various compression filters, for example:
◊command{tar -czvf archive_name.tar.gz *}, which recursively archives
and ◊command{gzip}-s all files in a directory tree in the current
working directory (◊command{$PWD}).

Some useful ◊command{tar} options:

◊list-block[#:type "bullet"]{

◊list-entry{◊code{-c} create (a new archive)}

◊list-entry{◊code{-x} extract (files from existing archive)}

◊list-entry{◊code{--delete} delete (files from existing archive)

Caution: This option will not work on magnetic tape devices.}

◊list-entry{◊code{-r} append (files to existing archive)}

◊list-entry{◊code{-A} append (tar files to existing archive)}

◊list-entry{◊code{-t} list (contents of existing archive)}

◊list-entry{◊code{-u} update archive}

◊list-entry{◊code{-d} compare archive with specified filesystem}

◊list-entry{◊code{--after-date} only process files with a date stamp after specified date}

◊list-entry{◊code{-z} gzip the archive

(compress or uncompress, depending on whether combined with the -c or -x) option}

◊list-entry{◊code{-j bzip2 the archive}

Caution: It may be difficult to recover data from a corrupted gzipped
tar archive. When archiving important files, make multiple backups.
}

}

}

◊definition-entry[#:name "shar"]{
Shell archiving utility. The text and/or binary files in a shell
archive are concatenated without compression, and the resultant
archive is essentially a shell script, complete with ◊code{#!/bin/sh}
header, containing all the necessary unarchiving commands, as well as
the files themselves. Unprintable binary characters in the target
file(s) are converted to printable ASCII characters in the output shar
file. Shar archives still show up in Usenet newsgroups, but otherwise
shar has been replaced by ◊code{tar}/◊code{gzip}. The ◊code{unshar}
command unpacks shar archives.

The ◊command{mailshar} command is a Bash script that uses shar to
concatenate multiple files into a single one for e-mailing. This
script supports compression and uuencoding.

}

◊definition-entry[#:name "ar"]{
Creation and manipulation utility for archives, mainly used for binary
object file libraries.

Staticly linked libraries for C/C++ programs are managed via
◊command{ar}
}

◊definition-entry[#:name "rpm"]{

The Red Hat Package Manager, or ◊command{rpm} utility provides a
wrapper for source or binary archives. It includes commands for
installing and checking the integrity of packages, among other things.

A simple ◊command{rpm -i package_name.rpm} usually suffices to install
a package, though there are many more options available.

Tip: ◊command{rpm -qf} identifies which package a file originates
from.

◊example{
bash$ rpm -qf /bin/ls
coreutils-5.2.1-31
}

Tip: ◊command{rpm -qa} gives a complete list of all installed rpm
packages on a given system. An ◊command{rpm -qa package_name} lists
only the package(s) corresponding to ◊code{package_name}.

◊example{
bash$ rpm -qa
redhat-logos-1.1.3-1
glibc-2.2.4-13
cracklib-2.7-12
dosfstools-2.7-1
gdbm-1.8.0-10
ksymoops-2.4.1-1
mktemp-1.5-11
perl-5.6.0-17
reiserfs-utils-3.x.0j-2
...


bash$ rpm -qa docbook-utils
docbook-utils-0.6.9-2


bash$ rpm -qa docbook | grep docbook
docbook-dtd31-sgml-1.0-10
docbook-style-dsssl-1.64-3
docbook-dtd30-sgml-1.0-10
docbook-dtd40-sgml-1.0-11
docbook-utils-pdf-0.6.9-2
docbook-dtd41-sgml-1.0-10
docbook-utils-0.6.9-2
}

}

}

◊section{Compression}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
