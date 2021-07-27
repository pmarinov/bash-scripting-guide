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

}
