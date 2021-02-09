#lang pollen

◊; This is free software released into the public domain
◊; See LICENSE.txt

◊page-init{}
◊define-meta[page-title]{Text Processing}
◊define-meta[page-description]{Text Processing Commands}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "sort"]{
File sort utility, often used as a filter in a pipe. This command
sorts a text stream or file forwards or backwards, or according to
various keys or character positions. Using the ◊code{-m} option, it
merges presorted input files. The info page lists its many
capabilities and options. See TODO Example 11-10, Example 11-11, and
Example A-8.

}

◊definition-entry[#:name "tsort"]{
Topological sort, reading in pairs of whitespace-separated strings and
sorting according to input patterns. The original purpose of
◊command{tsort} was to sort a list of dependencies for an obsolete
version of the ◊command{ld} linker in an "ancient" version of UNIX.

The results of a ◊command{tsort} will usually differ markedly from
those of the standard ◊command{sort} command, above.

}

◊definition-entry[#:name "uniq"]{
This filter removes duplicate lines from a sorted file. It is often
seen in a pipe coupled with ◊command{sort}.

◊example{
cat list-1 list-2 list-3 | sort | uniq > final.list
# Concatenates the list files,
# sorts them,
# removes duplicate lines,
# and finally writes the result to an output file.
}

The useful ◊code{-c} option prefixes each line of the input file with
its number of occurrences.

◊example{
bash$ cat testfile
This line occurs only once.
 This line occurs twice.
 This line occurs twice.
 This line occurs three times.
 This line occurs three times.
 This line occurs three times.


bash$ uniq -c testfile
      1 This line occurs only once.
      2 This line occurs twice.
      3 This line occurs three times.


bash$ sort testfile | uniq -c | sort -nr
      3 This line occurs three times.
      2 This line occurs twice.
      1 This line occurs only once.
}

◊anchored-example[#:anchor "wrd_cnt1"]{Word Frequency Analysis}

The ◊command{sort INPUTFILE | uniq -c | sort -nr} command string
produces a frequency of occurrence listing on the INPUTFILE file (the
◊code{-nr} options to sort cause a reverse numerical sort). This
template finds use in analysis of log files and dictionary lists, and
wherever the lexical structure of a document needs to be examined.

◊example{
#!/bin/bash
# wf.sh: Crude word frequency analysis on a text file.
# This is a more efficient version of the "wf2.sh" script.


# Check for input file on command-line.
ARGS=1
E_BADARGS=85
E_NOFILE=86

if [ $# -ne "$ARGS" ]  # Correct number of arguments passed to script?
then
  echo "Usage: `basename $0` filename"
  exit $E_BADARGS
fi

if [ ! -f "$1" ]       # Check if file exists.
then
  echo "File \"$1\" does not exist."
  exit $E_NOFILE
fi


########################################################
# main ()
sed -e 's/\.//g'  -e 's/\,//g' -e 's/ /\
/g' "$1" | tr 'A-Z' 'a-z' | sort | uniq -c | sort -nr
#                           =========================
#                            Frequency of occurrence

#  Filter out periods and commas, and
#+ change space between words to linefeed,
#+ then shift characters to lowercase, and
#+ finally prefix occurrence count and sort numerically.

#  Arun Giridhar suggests modifying the above to:
#  . . . | sort | uniq -c | sort +1 [-f] | sort +0 -nr
#  This adds a secondary sort key, so instances of
#+ equal occurrence are sorted alphabetically.
#  As he explains it:
#  "This is effectively a radix sort, first on the
#+ least significant column
#+ (word or string, optionally case-insensitive)
#+ and last on the most significant column (frequency)."
#
#  As Frank Wang explains, the above is equivalent to
#+       . . . | sort | uniq -c | sort +0 -nr
#+ and the following also works:
#+       . . . | sort | uniq -c | sort -k1nr -k
########################################################

exit 0

# Exercises:
# ---------
# 1) Add 'sed' commands to filter out other punctuation,
#+   such as semicolons.
# 2) Modify the script to also filter out multiple spaces and
#+   other whitespace.
}

◊example{
bash$ cat testfile
This line occurs only once.
This line occurs twice.
This line occurs twice.
This line occurs three times.
This line occurs three times.
This line occurs three times.

bash$ ./wf.sh testfile
      6 this
      6 occurs
      6 line
      3 times
      3 three
      2 twice
      1 only
      1 once
}

}

◊definition-entry[#:name "expand, unexpand"]{
The ◊command{expand} filter converts tabs to spaces. It is often used
in a pipe.

The ◊command{unexpand} filter converts spaces to tabs. This reverses
the effect of ◊command{expand}.

}

◊definition-entry[#:name "cut"]{
A tool for extracting fields from files. It is similar to the
◊command{print $N} command set in awk, but more limited. It may be
simpler to use ◊command{cut} in a script than awk. Particularly
important are the ◊code{-d} (delimiter) and ◊code{-f} (field
specifier) options.

Using ◊command{cut} to obtain a listing of the mounted filesystems:

◊example{
cut -d ' ' -f1,2 /etc/mtab
}

Using ◊command{cut} to list the OS and kernel version:

◊example{
uname -a | cut -d" " -f1,3,11,12
}

Using ◊command{cut} to extract message headers from an e-mail folder:

◊example{
bash$ grep '^Subject:' read-messages | cut -c10-80
Re: Linux suitable for mission-critical apps?
MAKE MILLIONS WORKING AT HOME!!!
Spam complaint
Re: Spam complaint
}

Using ◊command{cut} to parse a file:

◊example{
# List all the users in /etc/passwd.

FILENAME=/etc/passwd

for user in $(cut -d: -f1 $FILENAME)
do
  echo $user
done
}

◊command{cut -d ' ' -f2,3 filename} is equivalent to ◊command{awk -F'[
]' '$◊escaped{◊"{"} print $2, $3 $◊escaped{◊"}    "}' filename}

Note: It is even possible to specify a linefeed as a delimiter. The
trick is to actually embed a linefeed (RETURN) in the command
sequence.

◊example{
bash$ cut -d'
 ' -f3,7,19 testfile
This is line 3 of testfile.
This is line 7 of testfile.
This is line 19 of testfile.

}

See also TODO Example 16-48.

}

◊definition-entry[#:name "paste"]{
Tool for merging together different files into a single, multi-column
file. In combination with ◊command{cut}, useful for creating system
log files.

◊example{
bash$ cat items
alphabet blocks
building blocks
cables

bash$ cat prices
$1.00/dozen
$2.50 ea.
$3.75

bash$ paste items prices
alphabet blocks $1.00/dozen
building blocks $2.50 ea.
cables  $3.75
}

}

◊definition-entry[#:name "join"]{
Consider this a special-purpose cousin of ◊command{paste}. This
powerful utility allows merging two files in a meaningful fashion,
which essentially creates a simple version of a relational database.

The ◊command{join} command operates on exactly two files, but pastes
together only those lines with a common tagged field (usually a
numerical label), and writes the result to ◊code{stdout}. The files to
be joined should be sorted according to the tagged field for the
matchups to work properly.

◊example{
File: 1.data

100 Shoes
200 Laces
300 Socks
}

◊example{
File: 2.data

100 $40.00
200 $1.00
300 $2.00
}

◊example{
bash$ join 1.data 2.data
File: 1.data 2.data

100 Shoes $40.00
200 Laces $1.00
300 Socks $2.00
}

Note: The tagged field appears only once in the output.

}

◊definition-entry[#:name "head"]{
lists the beginning of a file to ◊code{stdout}. The default is 10
lines, but a different number can be specified. The command has a
number of interesting options.

◊anchored-example[#:anchor "head_scripts1"]{Which files are scripts?}

◊example{
#!/bin/bash
# script-detector.sh: Detects scripts within a directory.

TESTCHARS=2    # Test first 2 characters.
SHABANG='#!'   # Scripts begin with a "sha-bang."

for file in *  # Traverse all the files in current directory.
do
  if [[ `head -c$TESTCHARS "$file"` = "$SHABANG" ]]
  #      head -c2                      #!
  #  The '-c' option to "head" outputs a specified
  #+ number of characters, rather than lines (the default).
  then
    echo "File \"$file\" is a script."
  else
    echo "File \"$file\" is *not* a script."
  fi
done

exit 0

#  Exercises:
#  ---------
#  1) Modify this script to take as an optional argument
#+    the directory to scan for scripts
#+    (rather than just the current working directory).
#
#  2) As it stands, this script gives "false positives" for
#+    Perl, awk, and other scripting language scripts.
#     Correct this.
}

◊anchored-example[#:anchor "head_rnd1"]{Generating 10-digit random
numbers}

◊example{
#!/bin/bash
# rnd.sh: Outputs a 10-digit random number

# Script by Stephane Chazelas.

head -c4 /dev/urandom | od -N4 -tu4 | sed -ne '1s/.* //p'


# =================================================================== #

# Analysis
# --------

# head:
# -c4 option takes first 4 bytes.

# od:
# -N4 option limits output to 4 bytes.
# -tu4 option selects unsigned decimal format for output.

# sed:
# -n option, in combination with "p" flag to the "s" command,
# outputs only matched lines.



# The author of this script explains the action of 'sed', as follows.

# head -c4 /dev/urandom | od -N4 -tu4 | sed -ne '1s/.* //p'
# ----------------------------------> |

# Assume output up to "sed" --------> |
# is 0000000 1198195154\n

#  sed begins reading characters: 0000000 1198195154\n.
#  Here it finds a newline character,
#+ so it is ready to process the first line (0000000 1198195154).
#  It looks at its <range><action>s. The first and only one is

#   range     action
#   1         s/.* //p

#  The line number is in the range, so it executes the action:
#+ tries to substitute the longest string ending with a space in the line
#  ("0000000 ") with nothing (//), and if it succeeds, prints the result
#  ("p" is a flag to the "s" command here, this is different
#+ from the "p" command).

#  sed is now ready to continue reading its input. (Note that before
#+ continuing, if -n option had not been passed, sed would have printed
#+ the line once again).

#  Now, sed reads the remainder of the characters, and finds the
#+ end of the file.
#  It is now ready to process its 2nd line (which is also numbered '$' as
#+ it's the last one).
#  It sees it is not matched by any <range>, so its job is done.

#  In few word this sed commmand means:
#  "On the first line only, remove any character up to the right-most space,
#+ then print it."

# A better way to do this would have been:
#           sed -e 's/.* //;q'

# Here, two <range><action>s (could have been written
#           sed -e 's/.* //' -e q):

#   range                    action
#   nothing (matches line)   s/.* //
#   nothing (matches line)   q (quit)

#  Here, sed only reads its first line of input.
#  It performs both actions, and prints the line (substituted) before
#+ quitting (because of the "q" action) since the "-n" option is not passed.

# =================================================================== #

# An even simpler altenative to the above one-line script would be:
#           head -c4 /dev/urandom| od -An -tu4

exit
}

See also TODO Example 16-39.

}

◊definition-entry[#:name "tail"]{
lists the (tail) end of a file to ◊code{stdout}. The default is 10
lines, but this can be changed with the ◊code{-n} option. Commonly
used to keep track of changes to a system logfile, using the ◊code{-f}
option, which outputs lines appended to the file.

◊example{
#!/bin/bash

filename=sys.log

cat /dev/null > $filename; echo "Creating / cleaning out file."
#  Creates the file if it does not already exist,
#+ and truncates it to zero length if it does.
#  : > filename   and   > filename also work.

tail /var/log/messages > $filename
# /var/log/messages must have world read permission for this to work.

echo "$filename contains tail end of system log."

exit 0
}

Tip: To list a specific line of a text file, pipe the output of head to
◊command{tail -n 1}. For example ◊command{head -n 8 database.txt |
tail -n 1} lists the 8th line of the file ◊fname{database.txt}.

To set a variable to a given block of a text file:

◊example{
var=$(head -n $m $filename | tail -n $n)

# filename = name of file
# m = from beginning of file, number of lines to end of block
# n = number of lines to set variable to (trim from end of block)
}

Note: Newer implementations of ◊command{tail} deprecate the older
◊command{tail -$LINES filename} usage. The standard ◊command{tail -n
$LINES filename} is correct.

See also TODO Example 16-5, Example 16-39 and Example 32-6.

}

◊definition-entry[#:name "grep"]{

A multi-purpose file search tool that uses Regular Expressions. It was
originally a command/filter in the venerable ed line editor: g/re/p --
global - regular expression - print.

◊code{grep pattern [file...]}

Search the target file(s) for occurrences of ◊code{pattern}, where
◊code{pattern} may be literal text or a Regular Expression.

◊example{
bash$ grep '[rst]ystem.$' osinfo.txt
The GPL governs the distribution of the Linux operating system.

}

If no target file(s) specified, ◊command{grep} works as a filter on
◊code{stdout}, as in a pipe.

◊example{
bash$ ps ax | grep clock
765 tty1     S      0:00 xclock
901 pts/1    S      0:00 grep clock

}

The ◊code{-i} option causes a case-insensitive search.

The ◊code{-w} option matches only whole words.

The ◊code{-l} option lists only the files in which matches were found,
but not the matching lines.

The ◊code{-r} (recursive) option searches files in the current working
directory and all subdirectories below it.

The ◊code{-n} option lists the matching lines, together with line
numbers.

◊example{
bash$ grep -n Linux osinfo.txt
2:This is a file containing information about Linux.
6:The GPL governs the distribution of the Linux operating system.

}

The ◊code{-v} (or ◊code{--invert-match}) option filters out matches.

◊example{
grep pattern1 *.txt | grep -v pattern2

# Matches all lines in "*.txt" files containing "pattern1",
# but ***not*** "pattern2".
}

The ◊code{-c} (◊code{--count}) option gives a numerical count of
matches, rather than actually listing the matches.

◊example{
grep -c txt *.sgml   # (number of occurrences of "txt" in "*.sgml" files)


#   grep -cz .
#            ^ dot
# means count (-c) zero-separated (-z) items matching "."
# that is, non-empty ones (containing at least 1 character).
#
printf 'a b\nc  d\n\n\n\n\n\000\n\000e\000\000\nf' | grep -cz .     # 3
printf 'a b\nc  d\n\n\n\n\n\000\n\000e\000\000\nf' | grep -cz '$'   # 5
printf 'a b\nc  d\n\n\n\n\n\000\n\000e\000\000\nf' | grep -cz '^'   # 5
#
printf 'a b\nc  d\n\n\n\n\n\000\n\000e\000\000\nf' | grep -c '$'    # 9
# By default, newline chars (\n) separate items to match.

# Note that the -z option is GNU "grep" specific.

}

◊anchored-example[#:anchor "grep_color1"]{Printing out the From lines
in stored e-mail messages}

The ◊code{--color} (or ◊code{--colour}) option marks the matching
string in color (on the console or in an ◊code{xterm} window). Since
◊code{grep} prints out each entire line containing the matching
pattern, this lets you see exactly what is being matched. See also the
◊code{-o} option, which shows only the matching portion of the
line(s).

◊example{
#!/bin/bash
# from.sh

#  Emulates the useful 'from' utility in Solaris, BSD, etc.
#  Echoes the "From" header line in all messages
#+ in your e-mail directory.


MAILDIR=~/mail/*               #  No quoting of variable. Why?
# Maybe check if-exists $MAILDIR:   if [ -d $MAILDIR ] . . .
GREP_OPTS="-H -A 5 --color"    #  Show file, plus extra context lines
                               #+ and display "From" in color.
TARGETSTR="^From"              # "From" at beginning of line.

for file in $MAILDIR           #  No quoting of variable.
do
  grep $GREP_OPTS "$TARGETSTR" "$file"
  #    ^^^^^^^^^^              #  Again, do not quote this variable.
  echo
done

exit $?

#  You might wish to pipe the output of this script to 'more'
#+ or redirect it to a file . . .
}

When invoked with more than one target file given, ◊command{grep}
specifies which file contains matches.

◊example{
bash$ grep Linux osinfo.txt misc.txt
osinfo.txt:This is a file containing information about Linux.
osinfo.txt:The GPL governs the distribution of the Linux operating system.
misc.txt:The Linux operating system is steadily gaining in popularity.

}

Tip: To force ◊command{grep} to show the filename when searching only
one target file, simply give ◊fname{/dev/null} as the second file.

◊example{
bash$ grep Linux osinfo.txt /dev/null
osinfo.txt:This is a file containing information about Linux.
osinfo.txt:The GPL governs the distribution of the Linux operating system

}

If there is a successful match, ◊command{grep} returns an exit status
of 0, which makes it useful in a condition test in a script,
especially in combination with the ◊code{-q} option to suppress
output.

◊example{
SUCCESS=0                      # if grep lookup succeeds
word=Linux
filename=data.file

grep -q "$word" "$filename"    #  The "-q" option
                               #+ causes nothing to echo to stdout.
if [ $? -eq $SUCCESS ]
# if grep -q "$word" "$filename"   can replace lines 5 - 7.
then
  echo "$word found in $filename"
else
  echo "$word not found in $filename"
fi
}

TODO Example 32-6 demonstrates how to use ◊code{grep} to search for a
word pattern in a system logfile.

◊anchored-example[#:anchor "grep_emu1"]{Emulating grep in a script}

◊example{
#!/bin/bash
# grp.sh: Rudimentary reimplementation of grep.

E_BADARGS=85

if [ -z "$1" ]    # Check for argument to script.
then
  echo "Usage: `basename $0` pattern"
  exit $E_BADARGS
fi

echo

for file in *     # Traverse all files in $PWD.
do
  output=$(sed -n /"$1"/p $file)  # Command substitution.

  if [ ! -z "$output" ]           # What happens if "$output" is not quoted?
  then
    echo -n "$file: "
    echo "$output"
  fi              #  sed -ne "/$1/s|^|${file}: |p"  is equivalent to above.

  echo
done

echo

exit 0

# Exercises:
# ---------
# 1) Add newlines to output, if more than one match in any given file.
# 2) Add features.

}

How can ◊command{grep} search for two (or more) separate patterns?
What if you want ◊command{grep} to display all lines in a file or
files that contain both "pattern1" and "pattern2"?

One method is to pipe the result of ◊command{grep pattern1} to
◊command{grep pattern2}.

For example, given the following file:

◊example{
# Filename: tstfile

This is a sample file.
This is an ordinary text file.
This file does not contain any unusual text.
This file is not unusual.
Here is some text.
}

Now, let's search this file for lines containing both "file" and
"text" ...

◊example{
bash$ grep file tstfile
# Filename: tstfile
This is a sample file.
This is an ordinary text file.
This file does not contain any unusual text.
This file is not unusual.

bash$ grep file tstfile | grep text
This is an ordinary text file.
This file does not contain any unusual text.

}

◊anchored-example[#:anchor "grep_crswd1"]{Crossword puzzle solver}

Now, for an interesting recreational use of ◊command{grep} ...

◊example{
#!/bin/bash
# cw-solver.sh
# This is actually a wrapper around a one-liner (line 46).

#  Crossword puzzle and anagramming word game solver.
#  You know *some* of the letters in the word you're looking for,
#+ so you need a list of all valid words
#+ with the known letters in given positions.
#  For example: w...i....n
#               1???5????10
# w in position 1, 3 unknowns, i in the 5th, 4 unknowns, n at the end.
# (See comments at end of script.)


E_NOPATT=71
DICT=/usr/share/dict/word.lst
#                    ^^^^^^^^   Looks for word list here.
#  ASCII word list, one word per line.
#  If you happen to need an appropriate list,
#+ download the author's "yawl" word list package.
#  http://ibiblio.org/pub/Linux/libs/yawl-0.3.2.tar.gz
#  or
#  http://bash.deta.in/yawl-0.3.2.tar.gz


if [ -z "$1" ]   #  If no word pattern specified
then             #+ as a command-line argument . . .
  echo           #+ . . . then . . .
  echo "Usage:"  #+ Usage message.
  echo
  echo ""$0" \"pattern,\""
  echo "where \"pattern\" is in the form"
  echo "xxx..x.x..."
  echo
  echo "The x's represent known letters,"
  echo "and the periods are unknown letters (blanks)."
  echo "Letters and periods can be in any position."
  echo "For example, try:   sh cw-solver.sh w...i....n"
  echo
  exit $E_NOPATT
fi

echo
# ===============================================
# This is where all the work gets done.
grep ^"$1"$ "$DICT"   # Yes, only one line!
#    |    |
# ^ is start-of-word regex anchor.
# $ is end-of-word regex anchor.

#  From _Stupid Grep Tricks_, vol. 1,
#+ a book the ABS Guide author may yet get around
#+ to writing . . . one of these days . . .
# ===============================================
echo


exit $?  # Script terminates here.
#  If there are too many words generated,
#+ redirect the output to a file.

$ sh cw-solver.sh w...i....n

wellington
workingman
workingmen
}

◊command{egrep}

}

}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
