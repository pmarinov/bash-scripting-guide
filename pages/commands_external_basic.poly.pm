#lang pollen

◊; This is free software released into the public domain
◊; See LICENSE.txt

◊page-init{}
◊define-meta[page-title]{Basic External Commands}
◊define-meta[page-description]{Basic External Commands}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "ls"]{
The basic file "list" command. It is all too easy to underestimate the
power of this humble command. For example, using the ◊code{-R},
recursive option, ◊code{ls} provides a tree-like listing of a
directory structure. Other useful options are ◊code{-S}, sort listing
by file size, ◊code{-t}, sort by file modification time, ◊code{-v},
sort by (numerical) version numbers embedded in the filenames,
◊code{-b}, show escape characters, and ◊code{-i}, show file inodes
(see TODO Example 16-4). ◊footnote{The ◊code{-v} option also orders
the sort by upper- and lowercase prefixed filenames.}

◊example{
bash$ ls -l
-rw-rw-r-- 1 bozo bozo 0 Sep 14 18:44 chapter10.txt
 -rw-rw-r-- 1 bozo bozo 0 Sep 14 18:44 chapter11.txt
 -rw-rw-r-- 1 bozo bozo 0 Sep 14 18:44 chapter12.txt
 -rw-rw-r-- 1 bozo bozo 0 Sep 14 18:44 chapter1.txt
 -rw-rw-r-- 1 bozo bozo 0 Sep 14 18:44 chapter2.txt
 -rw-rw-r-- 1 bozo bozo 0 Sep 14 18:44 chapter3.txt
 -rw-rw-r-- 1 bozo bozo 0 Sep 14 18:49 Chapter_headings.txt
 -rw-rw-r-- 1 bozo bozo 0 Sep 14 18:49 Preface.txt


bash$ ls -lv
 total 0
 -rw-rw-r-- 1 bozo bozo 0 Sep 14 18:49 Chapter_headings.txt
 -rw-rw-r-- 1 bozo bozo 0 Sep 14 18:49 Preface.txt
 -rw-rw-r-- 1 bozo bozo 0 Sep 14 18:44 chapter1.txt
 -rw-rw-r-- 1 bozo bozo 0 Sep 14 18:44 chapter2.txt
 -rw-rw-r-- 1 bozo bozo 0 Sep 14 18:44 chapter3.txt
 -rw-rw-r-- 1 bozo bozo 0 Sep 14 18:44 chapter10.txt
 -rw-rw-r-- 1 bozo bozo 0 Sep 14 18:44 chapter11.txt
 -rw-rw-r-- 1 bozo bozo 0 Sep 14 18:44 chapter12.txt
}

Tip: The ◊code{ls} command returns a non-zero exit status when
attempting to list a non-existent file.

◊example{
bash$ ls abc
ls: abc: No such file or directory


bash$ echo $?
2
}

◊anchored-example[#:anchor "ls_tblc1"]{Using ls to create a table of
contents for burning a CDR disk}

◊example{
#!/bin/bash
# ex40.sh (burn-cd.sh)
# Script to automate burning a CDR.


SPEED=10         # May use higher speed if your hardware supports it.
IMAGEFILE=cdimage.iso
CONTENTSFILE=contents
# DEVICE=/dev/cdrom     For older versions of cdrecord
DEVICE="1,0,0"
DEFAULTDIR=/opt  # This is the directory containing the data to be burned.
                 # Make sure it exists.
                 # Exercise: Add a test for this.

# Uses Joerg Schilling's "cdrecord" package:
# http://www.fokus.fhg.de/usr/schilling/cdrecord.html

#  If this script invoked as an ordinary user, may need to suid cdrecord
#+ chmod u+s /usr/bin/cdrecord, as root.
#  Of course, this creates a security hole, though a relatively minor one.

if [ -z "$1" ]
then
  IMAGE_DIRECTORY=$DEFAULTDIR
  # Default directory, if not specified on command-line.
else
    IMAGE_DIRECTORY=$1
fi

# Create a "table of contents" file.
ls -lRF $IMAGE_DIRECTORY > $IMAGE_DIRECTORY/$CONTENTSFILE
# The "l" option gives a "long" file listing.
# The "R" option makes the listing recursive.
# The "F" option marks the file types (directories get a trailing /).
echo "Creating table of contents."

# Create an image file preparatory to burning it onto the CDR.
mkisofs -r -o $IMAGEFILE $IMAGE_DIRECTORY
echo "Creating ISO9660 file system image ($IMAGEFILE)."

# Burn the CDR.
echo "Burning the disk."
echo "Please be patient, this will take a while."
wodim -v -isosize dev=$DEVICE $IMAGEFILE
#  In newer Linux distros, the "wodim" utility assumes the
#+ functionality of "cdrecord."
exitcode=$?
echo "Exit code = $exitcode"

exit $exitcode
}

}

◊definition-entry[#:name "cat, tac"]{
◊code{cat}, an acronym for concatenate, lists a file to
◊code{stdout}. When combined with redirection (◊code{>} or ◊code{>>}),
it is commonly used to concatenate files.

◊example{
# Uses of 'cat'
cat filename                          # Lists the file.

cat file.1 file.2 file.3 > file.123   # Combines three files into one.
}

The ◊code{-n} option to ◊code{cat} inserts consecutive numbers before
all lines of the target file(s). The ◊code{-b} option numbers only the
non-blank lines. The ◊code{-v} option echoes nonprintable characters,
using ^ notation. The ◊code{-s} option squeezes multiple consecutive
blank lines into a single blank line.

See also TODO Example 16-28 and Example 16-24.

Note: In a pipe, it may be more efficient to redirect the ◊code{stdin} to a
file, rather than to ◊code{cat} the file.

◊example{
cat filename | tr a-z A-Z

tr a-z A-Z < filename   #  Same effect, but starts one less process,
                        #+ and also dispenses with the pipe.
}

◊code{tac}, is the inverse of ◊code{cat}, listing a file backwards
from its end.

}

◊definition-entry[#:name "rev"]{
reverses each line of a file, and outputs to ◊code{stdout}. This does
not have the same effect as ◊code{tac}, as it preserves the order of
the lines, but flips each one around (mirror image).

◊example{
bash$ cat file1.txt
This is line 1.
 This is line 2.


bash$ tac file1.txt
This is line 2.
 This is line 1.


bash$ rev file1.txt
.1 enil si sihT
 .2 enil si sihT
}

}

◊definition-entry[#:name "cp"]{
This is the file ◊code{copy} command. ◊code{cp file1 file2} copies
◊fname{file1} to ◊fname{file2}, overwriting ◊fname{file2} if it
already exists (see TODO Example 16-6).

Tip: Particularly useful are the ◊code{-a} archive flag (for copying
an entire directory tree), the ◊code{-u} update flag (which prevents
overwriting identically-named newer files), and the ◊code{-r} and
◊code{-R} recursive flags.

◊example{
cp -u source_dir/* dest_dir
#  "Synchronize" dest_dir to source_dir
#+  by copying over all newer and not previously existing files.
}

}

◊definition-entry[#:name "mv"]{

This is the file move command. It is equivalent to a combination of
◊command{cp} and ◊command{rm}. It may be used to move multiple files
to a directory, or even to rename a directory. For some examples of
using ◊command{mv} in a script, see TODO Example 10-11 and Example
A-2.

Note: When used in a non-interactive script, ◊command{mv} takes the
◊command{-f} (force) option to bypass user input.

When a directory is moved to a preexisting directory, it becomes a
subdirectory of the destination directory.

◊example{
bash$ mv source_directory target_directory

bash$ ls -lF target_directory
total 1
drwxrwxr-x    2 bozo  bozo      1024 May 28 19:20 source_directory/
}

}

}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
