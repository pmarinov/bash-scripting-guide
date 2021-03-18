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

}

}

◊section{Compression}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
