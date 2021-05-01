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

◊definition-entry[#:name "cpio"]{
This specialized archiving copy command (copy input and output) is
rarely seen any more, having been supplanted by
◊code{tar}/◊code{gzip}. It still has its uses, such as moving a
directory tree. With an appropriate block size (for copying)
specified, it can be appreciably faster than ◊command{tar}.

◊example{
#!/bin/bash

# Copying a directory tree using cpio.

# Advantages of using 'cpio':
#   Speed of copying. It's faster than 'tar' with pipes.
#   Well suited for copying special files (named pipes, etc.)
#+  that 'cp' may choke on.

ARGS=2
E_BADARGS=65

if [ $# -ne "$ARGS" ]
then
  echo "Usage: `basename $0` source destination"
  exit $E_BADARGS
fi

source="$1"
destination="$2"

###################################################################
find "$source" -depth | cpio -admvp "$destination"
#               ^^^^^         ^^^^^
#  Read the 'find' and 'cpio' info pages to decipher these options.
#  The above works only relative to $PWD (current directory) . . .
#+ full pathnames are specified.
###################################################################


# Exercise:
# --------

#  Add code to check the exit status ($?) of the 'find | cpio' pipe
#+ and output appropriate error messages if anything went wrong.

exit $?
}

}

◊definition-entry[#:name "rpm2cpio"]{
This command extracts a ◊code{cpio} archive from an ◊code{rpm} one.

◊example{
#!/bin/bash
# de-rpm.sh: Unpack an 'rpm' archive

: ${1?"Usage: `basename $0` target-file"}
# Must specify 'rpm' archive name as an argument.


TEMPFILE=$$.cpio                         #  Tempfile with "unique" name.
                                         #  $$ is process ID of script.

rpm2cpio < $1 > $TEMPFILE                #  Converts rpm archive into
                                         #+ cpio archive.
cpio --make-directories -F $TEMPFILE -i  #  Unpacks cpio archive.
rm -f $TEMPFILE                          #  Deletes cpio archive.

exit 0

#  Exercise:
#  Add check for whether 1. "target-file" exists and
#+                       2. it is an rpm archive.
#  Hint:                    Parse output of 'file' command.
}

A single-line alternative (which also avoids the creation of a temp
file):

◊example{
bash$ rpm2cpio file.rpm | cpio -idmv
}

}

◊definition-entry[#:name "pax"]{
The pax portable archive exchange toolkit facilitates periodic file
backups and is designed to be cross-compatible between various flavors
of UNIX. It was designed to replace ◊command{tar} and ◊command{cpio}.

◊example{
pax -wf daily_backup.pax ~/linux-server/files
#  Creates a tar archive of all files in the target directory.
#  Note that the options to pax must be in the correct order --
#+ pax -fw     has an entirely different effect.

pax -f daily_backup.pax
#  Lists the files in the archive.

pax -rf daily_backup.pax ~/bsd-server/files
#  Restores the backed-up files from the Linux machine
#+ onto a BSD one.
}

Note that ◊command{pax} handles many of the standard archiving and
compression commands.

}

}

◊section{Compression}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "gzip"]{
The standard GNU/UNIX compression utility, replacing the inferior and
proprietary ◊command{compress}. The corresponding decompression
command is ◊command{gunzip}, which is the equivalent of ◊command{gzip
-d}.

Note: The ◊code{-c} option sends the output of ◊command{gzip} to
◊code{stdout}. This is useful when piping to other commands.

The ◊command{zcat} filter decompresses a gzipped file to
◊code{stdout}, as possible input to a pipe or redirection. This is, in
effect, a cat command that works on compressed files (including files
processed with the older ◊command{compress} utility). The
◊command{zcat} command is equivalent to ◊command{gzip -dc}.

Caution: On some commercial UNIX systems, ◊command{zcat} is a synonym
for ◊command{uncompress -c}, and will not work on gzipped files.

See also TODO Example 7-7.

}

◊definition-entry[#:name "bzip2"]{
An alternate compression utility, usually more efficient (but slower)
than ◊command{gzip}, especially on large files. The corresponding
decompression command is ◊command{bunzip2}.

Similar to the ◊command{zcat} command, ◊command{bzcat} decompresses a
◊code{bzipped2}-ed file to ◊code{stdout}.

Note: Newer versions of tar have been patched with ◊code{bzip2}
support.

}

◊definition-entry[#:name "compress, uncompress"]{
This is an older, proprietary compression utility found in commercial
UNIX distributions. The more efficient ◊code{gzip} has largely
replaced it. Linux distributions generally include a compress
workalike for compatibility, although ◊code{gunzip} can unarchive
files treated with ◊command{compress}.

Tip: The ◊command{znew} command transforms compressed files into
gzipped ones.

}

◊definition-entry[#:name "sq"]{
Yet another compression (squeeze) utility, a filter that works only on
sorted ASCII word lists. It uses the standard invocation syntax for a
filter, ◊command{sq < input-file > output-file}. Fast, but not nearly
as efficient as ◊command{gzip}. The corresponding uncompression filter
is ◊command{unsq}, invoked like ◊command{sq}.

Tip: The output of ◊command{sq} may be piped to ◊command{gzip} for
further compression.

}

◊definition-entry[#:name "zip, unzip"]{
Cross-platform file archiving and compression utility compatible with
DOS ◊command{pkzip.exe}. "Zipped" archives seem to be a more common
medium of file exchange on the Internet than "tarballs."

Zip files have the advantage of embedding a checksum to verify archive
correctness.

}

◊definition-entry[#:name "unarc, unarj, unrar"]{
These Linux utilities permit unpacking archives compressed with the
DOS ◊command{arc.exe}, ◊command{arj.exe}, and ◊command{rar.exe}
programs.

}

◊definition-entry[#:name "lzma, unlzma, lzcat"]{
Highly efficient Lempel-Ziv-Markov compression. The syntax of ◊command{lzma} is
similar to that of ◊command{gzip}.

See: ◊url[#:link "https://www.7-zip.org/sdk.html"]{}

}

◊definition-entry[#:name "xz, unxz, xzcat"]{
A new high-efficiency compression tool, backward compatible with ◊command{lzma},
and with an invocation syntax similar to ◊command{gzip}.

See: ◊url[#:link "https://en.wikipedia.org/wiki/XZ_Utils"]{}

}

}

◊section{File Information}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "file"]{
A utility for identifying file types. The command ◊command{file
file-name} will return a file specification for ◊code{file-name}, such
as ascii text or data. It references the magic numbers found in
◊fname{/usr/share/magic}, ◊fname{/etc/magic}, or
◊fname{/usr/lib/magic}, depending on the Linux/UNIX distribution
(consult ◊command{man file} for the exact location).

The ◊code{-f} option causes file to run in batch mode, to read from a
designated file a list of filenames to analyze. The ◊code{-z} option,
when used on a compressed target file, forces an attempt to analyze
the uncompressed file type.

◊example{
bash$ file test.tar.gz
test.tar.gz: gzip compressed data, deflated,
last modified: Sun Sep 16 13:34:51 2001, os: Unix

bash file -z test.tar.gz
test.tar.gz: GNU tar archive (gzip compressed data, deflated,
last modified: Sun Sep 16 13:34:51 2001, os: Unix)
}

◊example{
# Find sh and Bash scripts in a given directory:

DIRECTORY=/usr/local/bin
KEYWORD=Bourne
# Bourne and Bourne-Again shell scripts

file $DIRECTORY/* | fgrep $KEYWORD

# Output:

# /usr/local/bin/burn-cd:          Bourne-Again shell script text executable
# /usr/local/bin/burnit:           Bourne-Again shell script text executable
# /usr/local/bin/cassette.sh:      Bourne shell script text executable
# /usr/local/bin/copy-cd:          Bourne-Again shell script text executable
# . . .
}

◊anchored-example[#:anchor "file_strip_c1"]{Stripping comments from C
program files}

◊example{
#!/bin/bash
# strip-comment.sh: Strips out the comments (/* COMMENT */) in a C program.

E_NOARGS=0
E_ARGERROR=66
E_WRONG_FILE_TYPE=67

if [ $# -eq "$E_NOARGS" ]
then
  echo "Usage: `basename $0` C-program-file" >&2 # Error message to stderr.
  exit $E_ARGERROR
fi

# Test for correct file type.
type=`file $1 | awk '{ print $2, $3, $4, $5 }'`
# "file $1" echoes file type . . .
# Then awk removes the first field, the filename . . .
# Then the result is fed into the variable "type."
correct_type="ASCII C program text"

if [ "$type" != "$correct_type" ]
then
  echo
  echo "This script works on C program files only."
  echo
  exit $E_WRONG_FILE_TYPE
fi


# Rather cryptic sed script:
#--------
sed '
/^\/\*/d
/.*\*\//d
' $1
#--------
# Easy to understand if you take several hours to learn sed fundamentals.


#  Need to add one more line to the sed script to deal with
#+ case where line of code has a comment following it on same line.
#  This is left as a non-trivial exercise.

#  Also, the above code deletes non-comment lines with a "*/" . . .
#+ not a desirable result.

exit 0


# ----------------------------------------------------------------
# Code below this line will not execute because of 'exit 0' above.

# Stephane Chazelas suggests the following alternative:

usage() {
  echo "Usage: `basename $0` C-program-file" >&2
  exit 1
}

WEIRD=`echo -n -e '\377'`   # or WEIRD=$'\377'
[[ $# -eq 1 ]] || usage
case `file "$1"` in
  *"C program text"*) sed -e "s%/\*%${WEIRD}%g;s%\*/%${WEIRD}%g" "$1" \
     | tr '\377\n' '\n\377' \
     | sed -ne 'p;n' \
     | tr -d '\n' | tr '\377' '\n';;
  *) usage;;
esac

#  This is still fooled by things like:
#  printf("/*");
#  or
#  /*  /* buggy embedded comment */
#
#  To handle all special cases (comments in strings, comments in string
#+ where there is a \", \\" ...),
#+ the only way is to write a C parser (using lex or yacc perhaps?).

exit 0
}

}

◊definition-entry[#:name "wchich"]{
◊command{which} command gives the full path to "command." This is
useful for finding out whether a particular command or utility is
installed on the system.

◊example{
bash$ which rm
/usr/bin/rm
}

For an interesting use of this command, see TODO Example 36-16.

}

◊definition-entry[#:name "whereis"]{
Similar to ◊command{which}, above, ◊command{whereis} command gives the
full path to "command," but also to its manpage.

◊example{
bash$ whereis rm
rm: /bin/rm /usr/share/man/man1/rm.1.bz2
}

}

◊definition-entry[#:name "whatis"]{
◊command{whatis} command looks up "command" in the ◊code{whatis}
database. This is useful for identifying system commands and important
configuration files. Consider it a simplified ◊command{man} command.

◊example{
bash$ whatis whatis
whatis               (1)  - search the whatis database for complete words
}

◊anchored-example[#:anchor "whatis_x11"]{Exploring /usr/X11R6/bin}

◊example{
#!/bin/bash

# What are all those mysterious binaries in /usr/X11R6/bin?

DIRECTORY="/usr/X11R6/bin"
# Try also "/bin", "/usr/bin", "/usr/local/bin", etc.

for file in $DIRECTORY/*
do
  whatis `basename $file`   # Echoes info about the binary.
done

exit 0

#  Note: For this to work, you must create a "whatis" database
#+ with /usr/sbin/makewhatis.
#  You may wish to redirect output of this script, like so:
#    ./what.sh >>whatis.db
#  or view it a page at a time on stdout,
#    ./what.sh | less
}

See also TODO Example 11-3.

}

◊definition-entry[#:name "vdir"]{
Show a detailed directory listing. The effect is similar to
◊command{ls -lb}.

This is one of the GNU fileutils.

◊example{
bash$ vdir
total 10
-rw-r--r--    1 bozo  bozo      4034 Jul 18 22:04 data1.xrolo
-rw-r--r--    1 bozo  bozo      4602 May 25 13:58 data1.xrolo.bak
-rw-r--r--    1 bozo  bozo       877 Dec 17  2000 employment.xrolo

bash ls -l
total 10
-rw-r--r--    1 bozo  bozo      4034 Jul 18 22:04 data1.xrolo
-rw-r--r--    1 bozo  bozo      4602 May 25 13:58 data1.xrolo.bak
-rw-r--r--    1 bozo  bozo       877 Dec 17  2000 employment.xrolo
}

}

◊definition-entry[#:name "locate, slocate"]{
The ◊command{locate} command searches for files using a database
stored for just that purpose. The ◊command{slocate} command is the
secure version of ◊command{locate} (which may be aliased to
◊command{slocate}).

◊example{
bash$ locate hickson
/usr/lib/xephem/catalogs/hickson.edb
}

}

◊definition-entry[#:name "getfacl, setfacl"]{
These commands retrieve or set the file access control list -- the
owner, group, and file permissions.

◊example{
bash$ getfacl *
# file: test1.txt
 # owner: bozo
 # group: bozgrp
 user::rw-
 group::rw-
 other::r--

 # file: test2.txt
 # owner: bozo
 # group: bozgrp
 user::rw-
 group::rw-
 other::r--


bash$ setfacl -m u:bozo:rw yearly_budget.csv
bash$ getfacl yearly_budget.csv
# file: yearly_budget.csv
 # owner: accountant
 # group: budgetgrp
 user::rw-
 user:bozo:rw-
 user:accountant:rw-
 group::rw-
 mask::rw-
 other::r--
}

}

◊definition-entry[#:name "readlink"]{
Disclose the file that a symbolic link points to.

◊example{
bash$ readlink /usr/bin/awk
../../bin/gawk
}

}

◊definition-entry[#:name "strings"]{
Use the ◊command{strings} command to find printable strings in a
binary or data file. It will list sequences of printable characters
found in the target file. This might be handy for a quick 'n dirty
examination of a core dump or for looking at an unknown graphic image
file (◊command{strings image-file | more} might show something like
JFIF, which would identify the file as a jpeg graphic). In a script,
you would probably parse the output of strings with grep or sed. See
TODO Example 11-8 and Example 11-10.

◊anchored-example[#:anchor "string_improved1"]{An "improved" strings
command}

◊example{
#!/bin/bash
# wstrings.sh: "word-strings" (enhanced "strings" command)
#
#  This script filters the output of "strings" by checking it
#+ against a standard word list file.
#  This effectively eliminates gibberish and noise,
#+ and outputs only recognized words.

# ===========================================================
#                 Standard Check for Script Argument(s)
ARGS=1
E_BADARGS=85
E_NOFILE=86

if [ $# -ne $ARGS ]
then
  echo "Usage: `basename $0` filename"
  exit $E_BADARGS
fi

if [ ! -f "$1" ]                      # Check if file exists.
then
    echo "File \"$1\" does not exist."
    exit $E_NOFILE
fi
# ===========================================================


MINSTRLEN=3                           #  Minimum string length.
WORDFILE=/usr/share/dict/linux.words  #  Dictionary file.
#  May specify a different word list file
#+ of one-word-per-line format.
#  For example, the "yawl" word-list package,
#  http://bash.deta.in/yawl-0.3.2.tar.gz


wlist=`strings "$1" | tr A-Z a-z | tr '[:space:]' Z | \
       tr -cs '[:alpha:]' Z | tr -s '\173-\377' Z | tr Z ' '`

# Translate output of 'strings' command with multiple passes of 'tr'.
#  "tr A-Z a-z"  converts to lowercase.
#  "tr '[:space:]'"  converts whitespace characters to Z's.
#  "tr -cs '[:alpha:]' Z"  converts non-alphabetic characters to Z's,
#+ and squeezes multiple consecutive Z's.
#  "tr -s '\173-\377' Z"  converts all characters past 'z' to Z's
#+ and squeezes multiple consecutive Z's,
#+ which gets rid of all the weird characters that the previous
#+ translation failed to deal with.
#  Finally, "tr Z ' '" converts all those Z's to whitespace,
#+ which will be seen as word separators in the loop below.

#  ***********************************************************************
#  Note the technique of feeding/piping the output of 'tr' back to itself,
#+ but with different arguments and/or options on each successive pass.
#  ***********************************************************************


for word in $wlist                    #  Important:
                                      #  $wlist must not be quoted here.
                                      # "$wlist" does not work.
                                      #  Why not?
do
  strlen=${#word}                     #  String length.
  if [ "$strlen" -lt "$MINSTRLEN" ]   #  Skip over short strings.
  then
    continue
  fi

  grep -Fw $word "$WORDFILE"          #   Match whole words only.
#      ^^^                            #  "Fixed strings" and
                                      #+ "whole words" options. 
done  

exit $?
}

}

}

◊section{Comparison}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "diff, patch"]{

◊command{diff}: flexible file comparison utility. It compares the
target files line-by-line sequentially. In some applications, such as
comparing word dictionaries, it may be helpful to filter the files
through ◊command{sort} and ◊command{uniq} before piping them to
◊command{diff}. ◊command{diff file-1 file-2} outputs the lines in the
files that differ, with carets showing which file each particular line
belongs to.

The ◊code{--side-by-side} option to ◊command{diff} outputs each
compared file, line by line, in separate columns, with non-matching
lines marked. The ◊code{-c} and ◊code{-u} options likewise make the
output of the command easier to interpret.

There are available various fancy frontends for ◊command{diff}, such
as ◊command{sdiff}, ◊command{wdiff}, ◊command{xdiff}, and
◊command{mgdiff}.

Tip: The ◊command{diff} command returns an exit status of 0 if the
compared files are identical, and 1 if they differ (or 2 when binary
files are being compared). This permits use of ◊command{diff} in a
test construct within a shell script (see below).

A common use for ◊command{diff} is generating difference files to be
used with ◊command{patch}. The ◊code{-e} option outputs files suitable
for ◊command{ed} or ◊command{ex} scripts.

◊command{patch}: flexible versioning utility. Given a difference file
generated by ◊command{diff}, ◊command{patch} can upgrade a previous
version of a package to a newer version. It is much more convenient to
distribute a relatively small "diff" file than the entire body of a
newly revised package. Kernel "patches" have become the preferred
method of distributing the frequent releases of the Linux kernel.

◊example{
patch -p1 <patch-file
# Takes all the changes listed in 'patch-file'
# and applies them to the files referenced therein.
# This upgrades to a newer version of the package.
}

Patching the kernel:

◊example{
cd /usr/src
gzip -cd patchXX.gz | patch -p0
# Upgrading kernel source using 'patch'.
# From the Linux kernel docs "README",
# by anonymous author (Alan Cox?).
}

Note: The ◊command{diff} command can also recursively compare
directories (for the filenames present).

◊example{
bash$ diff -r ~/notes1 ~/notes2
Only in /home/bozo/notes1: file02
Only in /home/bozo/notes1: file03
Only in /home/bozo/notes2: file04
}

Tip: Use ◊command{zdiff} to compare gzipped files.

Tip: Use ◊command{diffstat} to create a histogram (point-distribution
graph) of output from ◊command{diff}.

}

}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
