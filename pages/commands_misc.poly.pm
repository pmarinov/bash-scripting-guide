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


}
