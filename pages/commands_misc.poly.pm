#lang pollen

◊; This is free software released into the public domain
◊; See LICENSE.txt

◊page-init{}
◊define-meta[page-title]{Miscellaneous Commands}
◊define-meta[page-description]{Miscellaneous Commands}

◊section{"Command that fit in no special category"}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "jot, seq"]{
These utilities emit a sequence of integers, with a user-selectable
increment.

The default separator character between each integer is a newline, but
this can be changed with the -s option.

◊example{
bash$ seq 5
1
2
3
4
5


bash$ seq -s : 5
1:2:3:4:5
}

Both ◊code{jot} and ◊code{seq} come in handy in a ◊code{for} loop.

◊example{
#!/bin/bash
# Using "seq"

echo

for a in `seq 80`  # or   for a in $( seq 80 )
# Same as   for a in 1 2 3 4 5 ... 80   (saves much typing!).
# May also use 'jot' (if present on system).
do
  echo -n "$a "
done      # 1 2 3 4 5 ... 80
# Example of using the output of a command to generate
# the [list] in a "for" loop.

echo; echo


COUNT=80  # Yes, 'seq' also accepts a replaceable parameter.

for a in `seq $COUNT`  # or   for a in $( seq $COUNT )
do
  echo -n "$a "
done      # 1 2 3 4 5 ... 80

echo; echo

BEGIN=75
END=80

for a in `seq $BEGIN $END`
#  Giving "seq" two arguments starts the count at the first one,
#+ and continues until it reaches the second.
do
  echo -n "$a "
done      # 75 76 77 78 79 80

echo; echo

BEGIN=45
INTERVAL=5
END=80

for a in `seq $BEGIN $INTERVAL $END`
#  Giving "seq" three arguments starts the count at the first one,
#+ uses the second for a step interval,
#+ and continues until it reaches the third.
do
  echo -n "$a "
done      # 45 50 55 60 65 70 75 80

echo; echo

exit 0
}

A simpler example:

◊example{
#  Create a set of 10 files,
#+ named file.1, file.2 . . . file.10.
COUNT=10
PREFIX=file

for filename in `seq $COUNT`
do
  touch $PREFIX.$filename
  #  Or, can do other operations,
  #+ such as rm, grep, etc.
done
}

◊anchored-example[#:anchor "seq_lettercnt1"]{Letter Count}

◊example{
#!/bin/bash
# letter-count.sh: Counting letter occurrences in a text file.
# Written by Stefano Palmeri.
# Used in ABS Guide with permission.
# Slightly modified by document author.

MINARGS=2          # Script requires at least two arguments.
E_BADARGS=65
FILE=$1

let LETTERS=$#-1   # How many letters specified (as command-line args).
                   # (Subtract 1 from number of command-line args.)


show_help(){
	   echo
           echo Usage: `basename $0` file letters
           echo Note: `basename $0` arguments are case sensitive.
           echo Example: `basename $0` foobar.txt G n U L i N U x.
	   echo
}

# Checks number of arguments.
if [ $# -lt $MINARGS ]; then
   echo
   echo "Not enough arguments."
   echo
   show_help
   exit $E_BADARGS
fi


# Checks if file exists.
if [ ! -f $FILE ]; then
    echo "File \"$FILE\" does not exist."
    exit $E_BADARGS
fi



# Counts letter occurrences .
for n in `seq $LETTERS`; do
      shift
      if [[ `echo -n "$1" | wc -c` -eq 1 ]]; then             #  Checks arg.
             echo "$1" -\> `cat $FILE | tr -cd  "$1" | wc -c` #  Counting.
      else
             echo "$1 is not a  single char."
      fi
done

exit $?

#  This script has exactly the same functionality as letter-count2.sh,
#+ but executes faster.
#  Why?
}

Note: Somewhat more capable than ◊code{seq}, ◊code{jot} is a classic
UNIX utility that is not normally included in a standard Linux
distro. However, the source rpm is available for download from the MIT
repository.

http://www.mit.edu/afs/athena/system/rhlinux/athena-9.0/free/SRPMS/athena-jot-9.0-3.src.rpm

Unlike ◊code{seq}, ◊code{jot} can generate a sequence of random
numbers, using the ◊code{-r} option.

◊example{
bash$ jot -r 3 999
1069
1272
1428
}

}

◊definition-entry[#:name "getopt"]{
The ◊command{getopt} command parses command-line options preceded by a
dash. This external command corresponds to the ◊command{getopts} Bash
builtin. Using ◊command{getopt} permits handling long options by means
of the ◊code{-l} flag, and this also allows parameter reshuffling.

◊example{
#!/bin/bash
# Using getopt

# Try the following when invoking this script:
#   sh ex33a.sh -a
#   sh ex33a.sh -abc
#   sh ex33a.sh -a -b -c
#   sh ex33a.sh -d
#   sh ex33a.sh -dXYZ
#   sh ex33a.sh -d XYZ
#   sh ex33a.sh -abcd
#   sh ex33a.sh -abcdZ
#   sh ex33a.sh -z
#   sh ex33a.sh a
# Explain the results of each of the above.

E_OPTERR=65

if [ "$#" -eq 0 ]
then   # Script needs at least one command-line argument.
  echo "Usage $0 -[options a,b,c]"
  exit $E_OPTERR
fi

set -- `getopt "abcd:" "$@"`
# Sets positional parameters to command-line arguments.
# What happens if you use "$*" instead of "$@"?

while [ ! -z "$1" ]
do
  case "$1" in
    -a) echo "Option \"a\"";;
    -b) echo "Option \"b\"";;
    -c) echo "Option \"c\"";;
    -d) echo "Option \"d\" $2";;
     *) break;;
  esac

  shift
done

#  It is usually better to use the 'getopts' builtin in a script.
#  See "ex33.sh."

exit 0
}

It is often necessary to include an ◊command{eval} to correctly
process whitespace and quotes.

◊example{
args=$(getopt -o a:bc:d -- "$@")
eval set -- "$args"
}

}

◊definition-entry[#:name "run-parts"]{
The ◊command{run-parts} command [1] executes all the scripts in a target
directory, sequentially in ASCII-sorted filename order. Of course, the
scripts need to have execute permission.

The cron daemon invokes run-parts to run the scripts in the
◊fname{/etc/cron.*} directories.

}

◊definition-entry[#:name "yes"]{
In its default behavior the ◊command{yes} command feeds a continuous
string of the character "y" followed by a line feed to stdout. A
◊kbd{control-C} terminates the run. A different output string may be
specified, as in ◊command{yes different string}, which would
continually output different string to stdout.

One might well ask the purpose of this. From the command-line or in a
script, the output of ◊command{yes} can be redirected or piped into a
program expecting user input. In effect, this becomes a sort of poor
man's version of ◊command{expect}.

◊example{
yes | fsck /dev/hda1 runs fsck non-interactively (careful!).
}

◊example{
yes | rm -r dirname has same effect as rm -rf dirname (careful!).
}

Warning: Caution advised when piping ◊command{yes} to a potentially
dangerous system command, such as ◊command{fsck} or
◊command{fdisk}. It might have unintended consequences.

Note: The ◊command{yes} command parses variables, or more accurately,
it echoes parsed variables. For example:

◊example{
yes $BASH_VERSION
3.1.17(1)-release
3.1.17(1)-release
3.1.17(1)-release
3.1.17(1)-release
3.1.17(1)-release
. . .
}

This particular "feature" may be used to create a very large ASCII
file on the fly:

◊example{
bash$ yes $PATH > huge_file.txt
Ctl-C
}

Hit ◊kbd{Ctl-C} very quickly, or you just might get more than you
bargained for....

The ◊command{yes} command may be emulated in a very simple script
function.

◊example{
yes ()
{
  # Trivial emulation of "yes" ...
  local DEFAULT_TEXT="y"
  while [ true ]   # Endless loop.
  do
    if [ -z "$1" ]
    then
      echo "$DEFAULT_TEXT"
    else           # If argument ...
      echo "$1"    # ... expand and echo it.
    fi
  done             #  The only things missing are the
}                  #+ --help and --version options.
}

}

◊definition-entry[#:name "banner"]{
Prints arguments as a large vertical banner to stdout, using an ASCII
character (default '#'). This may be redirected to a printer for
hardcopy.

Note that banner has been dropped from many Linux distros, presumably
because it is no longer considered useful.

}

◊definition-entry[#:name "printenv"]{
Show all the environmental variables set for a particular user.

◊example{
bash$ printenv | grep HOME
HOME=/home/bozo
}

}

◊definition-entry[#:name "lp"]{
The ◊command{lp} and ◊command{lpr} commands send file(s) to the print
queue, to be printed as hard copy. [2] These commands trace the origin
of their names to the line printers of another era. [3]

◊example{
bash$ lp file1.txt or bash lp <file1.txt
}

It is often useful to pipe the formatted output from ◊command{pr} to
◊command{lp}.

◊example{
bash$ pr -options file1.txt | lp
}

Formatting packages, such as ◊command{groff} and Ghostscript may send
their output directly to ◊command{lp}.

◊example{
bash$ groff -Tascii file.tr | lp
}

◊example{
bash$ gs -options | lp file.ps
}

Related commands are ◊command{lpq}, for viewing the print queue, and
◊command{lprm}, for removing jobs from the print queue.

}

◊definition-entry[#:name "tee"]{
[UNIX borrows an idea from the plumbing trade.]

This is a redirection operator, but with a difference. Like the
plumber's tee, it permits "siphoning off" to a file the output of a
command or commands within a pipe, but without affecting the
result. This is useful for printing an ongoing process to a file or
paper, perhaps to keep track of it for debugging purposes.

◊example{
                             (redirection)
                            |----> to file
                            |
  ==========================|====================
  command ---> command ---> |tee ---> command ---> ---> output of pipe
  ===============================================
}

◊example{
cat listfile* | sort | tee check.file | uniq > result.file
#                      ^^^^^^^^^^^^^^   ^^^^

#  The file "check.file" contains the concatenated sorted "listfiles,"
#+ before the duplicate lines are removed by 'uniq.'
}

}

◊definition-entry[#:name "mkfifo"]{
This obscure command creates a named pipe, a temporary
first-in-first-out buffer for transferring data between processes. [4]
Typically, one process writes to the FIFO, and the other reads from
it. See TODO Example A-14.

◊example{
#!/bin/bash
# This short script by Omair Eshkenazi.
# Used in ABS Guide with permission (thanks!).

mkfifo pipe1   # Yes, pipes can be given names.
mkfifo pipe2   # Hence the designation "named pipe."

(cut -d' ' -f1 | tr "a-z" "A-Z") >pipe2 <pipe1 &
ls -l | tr -s ' ' | cut -d' ' -f3,9- | tee pipe1 |
cut -d' ' -f2 | paste - pipe2

rm -f pipe1
rm -f pipe2

# No need to kill background processes when script terminates (why not?).

exit $?

Now, invoke the script and explain the output:
sh mkfifo-example.sh

4830.tar.gz          BOZO
pipe1   BOZO
pipe2   BOZO
mkfifo-example.sh    BOZO
Mixed.msg BOZO
}

}

◊definition-entry[#:name "pathchk"]{
This command checks the validity of a filename. If the filename
exceeds the maximum allowable length (255 characters) or one or more
of the directories in its path is not searchable, then an error
message results.

Unfortunately, ◊command{pathchk} does not return a recognizable error
code, and it is therefore pretty much useless in a script. Consider
instead the file test operators.

}

◊definition-entry[#:name "dd"]{
Though this somewhat obscure and much feared data duplicator command
originated as a utility for exchanging data on magnetic tapes between
UNIX minicomputers and IBM mainframes, it still has its uses. The
◊command{dd} command simply copies a file (or stdin/stdout), but with
conversions. Possible conversions include ASCII/EBCDIC, [5]
upper/lower case, swapping of byte pairs between input and output, and
skipping and/or truncating the head or tail of the input file.

◊example{
# Converting a file to all uppercase:

dd if=$filename conv=ucase > $filename.uppercase
#                    lcase   # For lower case conversion
}


Some basic options to ◊command{dd} are:

◊code{if=INFILE} -- INFILE is the source file.

◊code{of=OUTFILE} -- OUTFILE is the target file, the file that will have
the data written to it.

◊code{bs=BLOCKSIZE} --  This is the size of each block of data being read
and written, usually a power of 2.

◊code{skip=BLOCKS} -- How many blocks of data to skip in INFILE before
starting to copy. This is useful when the INFILE has "garbage" or
garbled data in its header or when it is desirable to copy only a
portion of the INFILE.

◊code{seek=BLOCKS} -- How many blocks of data to skip in OUTFILE before
starting to copy, leaving blank data at beginning of OUTFILE.

◊code{count=BLOCKS} -- Copy only this many blocks of data, rather than
the entire INFILE.

◊code{conv=CONVERSION} -- Type of conversion to be applied to INFILE data
before copying operation.

A ◊command{dd --help} lists all the options this powerful utility
takes.

◊anchored-example[#:anchor "dd_kbd1"]{Capturing Keystrokes}

◊example{
#!/bin/bash
# dd-keypress.sh: Capture keystrokes without needing to press ENTER.


keypresses=4                      # Number of keypresses to capture.


old_tty_setting=$(stty -g)        # Save old terminal settings.

echo "Press $keypresses keys."
stty -icanon -echo                # Disable canonical mode.
                                  # Disable local echo.
keys=$(dd bs=1 count=$keypresses 2> /dev/null)
# 'dd' uses stdin, if "if" (input file) not specified.

stty "$old_tty_setting"           # Restore old terminal settings.

echo "You pressed the \"$keys\" keys."

# Thanks, Stephane Chazelas, for showing the way.
exit 0
}

The ◊command{dd} command can do random access on a data stream.

◊example{
echo -n . | dd bs=1 seek=4 of=file conv=notrunc
#  The "conv=notrunc" option means that the output file
#+ will not be truncated.
}

The ◊command{dd} command can copy raw data and disk images to and from
devices, such as floppies and tape drives (TODO Example A-5). A common
use is creating boot floppies.

◊example{
dd if=kernel-image of=/dev/fd0H1440
}

Similarly, ◊command{dd} can copy the entire contents of a floppy, even
one formatted with a "foreign" OS, to the hard drive as an image file.

◊example{
dd if=/dev/fd0 of=/home/bozo/projects/floppy.img
}

Likewise, ◊command{dd} can create bootable flash drives and SD cards.

◊example{
dd if=image.iso of=/dev/sdb
}

◊anchored-example[#:anchor "dd_bootsd1"]{Preparing a bootable SD card
for the Raspberry Pi}

◊example{
!/bin/bash
# rp.sdcard.sh
# Preparing an SD card with a bootable image for the Raspberry Pi.

# $1 = imagefile name
# $2 = sdcard (device file)
# Otherwise defaults to the defaults, see below.

DEFAULTbs=4M                                 # Block size, 4 mb default.
DEFAULTif="2013-07-26-wheezy-raspbian.img"   # Commonly used distro.
DEFAULTsdcard="/dev/mmcblk0"                 # May be different. Check!
ROOTUSER_NAME=root                           # Must run as root!
E_NOTROOT=81
E_NOIMAGE=82

username=$(id -nu)                           # Who is running this script?
if [ "$username" != "$ROOTUSER_NAME" ]
then
  echo "This script must run as root or with root privileges."
  exit $E_NOTROOT
fi

if [ -n "$1" ]
then
  imagefile="$1"
else
  imagefile="$DEFAULTif"
fi

if [ -n "$2" ]
then
  sdcard="$2"
else
  sdcard="$DEFAULTsdcard"
fi

if [ ! -e $imagefile ]
then
  echo "Image file \"$imagefile\" not found!"
  exit $E_NOIMAGE
fi

echo "Last chance to change your mind!"; echo
read -s -n1 -p "Hit a key to write $imagefile to $sdcard [Ctl-c to exit]."
echo; echo

echo "Writing $imagefile to $sdcard ..."
dd bs=$DEFAULTbs if=$imagefile of=$sdcard

exit $?

# Exercises:
# ---------
# 1) Provide additional error checking.
# 2) Have script autodetect device file for SD card (difficult!).
# 3) Have script sutodetect image file (*img) in $PWD.
}

Oher applications of ◊command{dd} include initializing temporary swap
files (TODO Example 31-2) and ramdisks (TODO Example 31-3). It can
even do a low-level copy of an entire hard drive partition, although
this is not necessarily recommended.

People (with presumably nothing better to do with their time) are
constantly thinking of interesting applications of ◊command{dd}.

◊anchored-example[#:anchor "dd_securedel1"]{Securely deleting a file}

◊example{
#!/bin/bash
# blot-out.sh: Erase "all" traces of a file.

#  This script overwrites a target file alternately
#+ with random bytes, then zeros before finally deleting it.
#  After that, even examining the raw disk sectors by conventional methods
#+ will not reveal the original file data.

PASSES=7         #  Number of file-shredding passes.
                 #  Increasing this slows script execution,
                 #+ especially on large target files.
BLOCKSIZE=1      #  I/O with /dev/urandom requires unit block size,
                 #+ otherwise you get weird results.
E_BADARGS=70     #  Various error exit codes.
E_NOT_FOUND=71
E_CHANGED_MIND=72

if [ -z "$1" ]   # No filename specified.
then
  echo "Usage: `basename $0` filename"
  exit $E_BADARGS
fi

file=$1

if [ ! -e "$file" ]
then
  echo "File \"$file\" not found."
  exit $E_NOT_FOUND
fi  

echo; echo -n "Are you absolutely sure you want to blot out \"$file\" (y/n)? "
read answer
case "$answer" in
[nN]) echo "Changed your mind, huh?"
      exit $E_CHANGED_MIND
      ;;
*)    echo "Blotting out file \"$file\".";;
esac


flength=$(ls -l "$file" | awk '{print $5}')  # Field 5 is file length.
pass_count=1

chmod u+w "$file"   # Allow overwriting/deleting the file.

echo

while [ "$pass_count" -le "$PASSES" ]
do
  echo "Pass #$pass_count"
  sync         # Flush buffers.
  dd if=/dev/urandom of=$file bs=$BLOCKSIZE count=$flength
               # Fill with random bytes.
  sync         # Flush buffers again.
  dd if=/dev/zero of=$file bs=$BLOCKSIZE count=$flength
               # Fill with zeros.
  sync         # Flush buffers yet again.
  let "pass_count += 1"
  echo
done  


rm -f $file    # Finally, delete scrambled and shredded file.
sync           # Flush buffers a final time.

echo "File \"$file\" blotted out and deleted."; echo


exit 0

#  This is a fairly secure, if inefficient and slow method
#+ of thoroughly "shredding" a file.
#  The "shred" command, part of the GNU "fileutils" package,
#+ does the same thing, although more efficiently.

#  The file cannot not be "undeleted" or retrieved by normal methods.
#  However . . .
#+ this simple method would *not* likely withstand
#+ sophisticated forensic analysis.

#  This script may not play well with a journaled file system.
#  Exercise (difficult): Fix it so it does.



#  Tom Vier's "wipe" file-deletion package does a much more thorough job
#+ of file shredding than this simple script.
#     http://www.ibiblio.org/pub/Linux/utils/file/wipe-2.0.0.tar.bz2

#  For an in-depth analysis on the topic of file deletion and security,
#+ see Peter Gutmann's paper,
#+     "Secure Deletion of Data From Magnetic and Solid-State Memory".
#       http://www.cs.auckland.ac.nz/~pgut001/pubs/secure_del.html
}

See also the dd thread entry in the bibliography. (TODO)

}


}
