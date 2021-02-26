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

◊definition-entry[#:name "egrep"]{
extended grep -- is the same as ◊command{grep -E}. This uses a
somewhat different, extended set of Regular Expressions, which can
make the search a bit more flexible. It also allows the boolean
◊code{|} (or) operator.

◊example{
bash $ egrep 'matches|Matches' file.txt
Line 1 matches.
Line 3 Matches.
Line 4 contains matches, but also Matches

}

}

◊definition-entry[#:name "fgrep"]{
fast grep -- is the same as ◊command{grep -F}. It does a literal
string search (no Regular Expressions), which generally speeds things
up a bit.

Note: On some Linux distros, ◊command{egrep} and ◊command{fgrep} are
symbolic links to, or aliases for ◊command{grep}, but invoked with the
◊code{-E} and ◊code{-F} options, respectively.

◊anchored-example[#:anchor "grep_dict1"]{Looking up definitions in
Webster's 1913 Dictionary}

◊example{
#!/bin/bash
# dict-lookup.sh

#  This script looks up definitions in the 1913 Webster's Dictionary.
#  This Public Domain dictionary is available for download
#+ from various sites, including
#+ Project Gutenberg (http://www.gutenberg.org/etext/247).
#
#  Convert it from DOS to UNIX format (with only LF at end of line)
#+ before using it with this script.
#  Store the file in plain, uncompressed ASCII text.
#  Set DEFAULT_DICTFILE variable below to path/filename.


E_BADARGS=85
MAXCONTEXTLINES=50                        # Maximum number of lines to show.
DEFAULT_DICTFILE="/usr/share/dict/webster1913-dict.txt"
                                          # Default dictionary file pathname.
                                          # Change this as necessary.
#  Note:
#  ----
#  This particular edition of the 1913 Webster's
#+ begins each entry with an uppercase letter
#+ (lowercase for the remaining characters).
#  Only the *very first line* of an entry begins this way,
#+ and that's why the search algorithm below works.



if [[ -z $(echo "$1" | sed -n '/^[A-Z]/p') ]]
#  Must at least specify word to look up, and
#+ it must start with an uppercase letter.
then
  echo "Usage: `basename $0` Word-to-define [dictionary-file]"
  echo
  echo "Note: Word to look up must start with capital letter,"
  echo "with the rest of the word in lowercase."
  echo "--------------------------------------------"
  echo "Examples: Abandon, Dictionary, Marking, etc."
  exit $E_BADARGS
fi


if [ -z "$2" ]                            #  May specify different dictionary
                                          #+ as an argument to this script.
then
  dictfile=$DEFAULT_DICTFILE
else
  dictfile="$2"
fi

# ---------------------------------------------------------
Definition=$(fgrep -A $MAXCONTEXTLINES "$1 \\" "$dictfile")
#                  Definitions in form "Word \..."
#
#  And, yes, "fgrep" is fast enough
#+ to search even a very large text file.


# Now, snip out just the definition block.

echo "$Definition" |
sed -n '1,/^[A-Z]/p' |
#  Print from first line of output
#+ to the first line of the next entry.
sed '$d' | sed '$d'
#  Delete last two lines of output
#+ (blank line and first line of next entry).
# ---------------------------------------------------------

exit $?

# Exercises:
# ---------
# 1)  Modify the script to accept any type of alphabetic input
#   + (uppercase, lowercase, mixed case), and convert it
#   + to an acceptable format for processing.
#
# 2)  Convert the script to a GUI application,
#   + using something like 'gdialog' or 'zenity' . . .
#     The script will then no longer take its argument(s)
#   + from the command-line.
#
# 3)  Modify the script to parse one of the other available
#   + Public Domain Dictionaries, such as the U.S. Census Bureau Gazetteer.
}

Note: See also TODO Example A-41 for an example of speedy fgrep lookup
on a large text file.

}

}

◊definition-entry[#:name "agrep"]{
Approximate grep -- extends the capabilities of ◊command{grep} to approximate
matching. The search string may differ by a specified number of
characters from the resulting matches. This utility is not part of the
core Linux distribution.

Tip: To search compressed files, use ◊command{zgrep},
◊command{zegrep}, or ◊command{zfgrep}. These also work on
non-compressed files, though slower than plain ◊command{grep},
◊command{egrep}, ◊command{fgrep}. They are handy for searching through
a mixed set of files, some compressed, some not.

To search bzipped files, use ◊command{bzgrep}.

}

◊definition-entry[#:name "look"]{
The command ◊command{look} works like ◊command{grep}, but does a
lookup on a "dictionary," a sorted word list. By default,
◊command{look} searches for a match in ◊fname{/usr/dict/words}, but a
different dictionary file may be specified.

◊anchored-example[#:anchor "chk_wrd_valid1"]{Checking words in a list
for validity}

◊example{
#!/bin/bash
# lookup: Does a dictionary lookup on each word in a data file.

file=words.data  # Data file from which to read words to test.

echo
echo "Testing file $file"
echo

while [ "$word" != end ]  # Last word in data file.
do               # ^^^
  read word      # From data file, because of redirection at end of loop.
  look $word > /dev/null  # Don't want to display lines in dictionary file.
  #  Searches for words in the file /usr/share/dict/words
  #+ (usually a link to linux.words).
  lookup=$?      # Exit status of 'look' command.

  if [ "$lookup" -eq 0 ]
  then
    echo "\"$word\" is valid."
  else
    echo "\"$word\" is invalid."
  fi

done <"$file"    # Redirects stdin to $file, so "reads" come from there.

echo

exit 0

# ----------------------------------------------------------------
# Code below line will not execute because of "exit" command above.


# Stephane Chazelas proposes the following, more concise alternative:

while read word && [[ $word != end ]]
do if look "$word" > /dev/null
   then echo "\"$word\" is valid."
   else echo "\"$word\" is invalid."
   fi
done <"$file"

exit 0
}

}

◊definition-entry[#:name "sed"]{
Non-interactive "stream editor", permits using many ◊command{ex}
commands in batch mode. It finds many uses in shell scripts.

TODO: See reference to a more detailed page

}

◊definition-entry[#:name "awk"]{
Programmable file extractor and formatter, good for manipulating
and/or extracting fields (columns) in structured text files. Its
syntax is similar to C.

TODO: See reference to a more detailed page

}

◊definition-entry[#:name "wc"]{
◊command{wc} gives a "word count" on a file or I/O stream:

◊example{
bash $ wc /usr/share/doc/sed-4.1.2/README
13  70  447 README
[13 lines  70 words  447 characters]
}

◊command{wc -w} gives only the word count.

◊command{wc -l} gives only the line count.

◊command{wc -c} gives only the byte count.

◊command{wc -m} gives only the character count.

◊command{wc -L} gives only the length of the longest line.

Using ◊command{wc} to count how many ◊fname{.txt} files are in current
working directory:

◊example{
$ ls *.txt | wc -l
#  Will work as long as none of the "*.txt" files
#+ have a linefeed embedded in their name.

#  Alternative ways of doing this are:
#      find . -maxdepth 1 -name \*.txt -print0 | grep -cz .
#      (shopt -s nullglob; set -- *.txt; echo $#)
}

Using ◊command{wc} to total up the size of all the files whose names
begin with letters in the range d - h:

◊example{
bash$ wc [d-h]* | grep total | awk '{print $3}'
71832
}

Using ◊command{wc} to count the instances of the word "Linux" in the
main source file for this book.

◊example{
bash$ grep Linux abs-book.sgml | wc -l
138
}

See TODO also Example 16-39 and Example 20-8.

Certain commands include some of the functionality of ◊command{wc} as
options.

◊example{
... | grep foo | wc -l
# This frequently used construct can be more concisely rendered.

... | grep -c foo
# Just use the "-c" (or "--count") option of grep.
}

}

◊definition-entry[#:name "tr"]{
character translation filter.

Caution: Must use quoting and/or brackets, as appropriate. Quotes
prevent the shell from reinterpreting the special characters in
◊command{tr} command sequences. Brackets should be quoted to prevent
expansion by the shell.

Either ◊command{tr "A-Z" "*" <filename or tr A-Z \* <filename} changes
all the uppercase letters in ◊code{filename} to asterisks (writes to
◊code{stdout}). On some systems this may not work, but ◊command{tr A-Z
'[**]'} will.

The ◊code{-d} option deletes a range of characters.

◊example{
echo "abcdef"                 # abcdef
echo "abcdef" | tr -d b-d     # aef


tr -d 0-9 <filename
# Deletes all digits from the file "filename".
}

The ◊code{--squeeze-repeats} (or ◊code{-s}) option deletes all but the
first instance of a string of consecutive characters. This option is
useful for removing excess whitespace.

◊example{
bash$ echo "XXXXX" | tr --squeeze-repeats 'X'
X
}

The ◊code{-c} "complement" option inverts the character set to
match. With this option, ◊command{tr} acts only upon those characters
not matching the specified set.

◊example{
bash$ echo "acfdeb123" | tr -c b-d +
+c+d+b++++
}

Note that ◊command{tr} recognizes POSIX character classes. [1]

◊example{
bash$ echo "abcd2ef1" | tr '[:alpha:]' -
----2--1
}

◊anchored-example[#:anchor "toupper_tr1"]{toupper: Transforms a file
to all uppercase}

◊example{
#!/bin/bash
# Changes a file to all uppercase.

E_BADARGS=85

if [ -z "$1" ]  # Standard check for command-line arg.
then
  echo "Usage: `basename $0` filename"
  exit $E_BADARGS
fi

tr a-z A-Z <"$1"

# Same effect as above, but using POSIX character set notation:
#        tr '[:lower:]' '[:upper:]' <"$1"
# Thanks, S.C.

#     Or even . . .
#     cat "$1" | tr a-z A-Z
#     Or dozens of other ways . . .

exit 0

#  Exercise:
#  Rewrite this script to give the option of changing a file
#+ to *either* upper or lowercase.
#  Hint: Use either the "case" or "select" command.
}

◊anchored-example[#:anchor "tolower_tr1"]{lowercase: Changes all
filenames in working directory to lowercase}

◊example{
#!/bin/bash
#
#  Changes every filename in working directory to all lowercase.
#
#  Inspired by a script of John Dubois,
#+ which was translated into Bash by Chet Ramey,
#+ and considerably simplified by the author of the ABS Guide.


for filename in *                # Traverse all files in directory.
do
   fname=`basename $filename`
   n=`echo $fname | tr A-Z a-z`  # Change name to lowercase.
   if [ "$fname" != "$n" ]       # Rename only files not already lowercase.
   then
     mv $fname $n
   fi
done

exit $?


# Code below this line will not execute because of "exit".
#--------------------------------------------------------#
# To run it, delete script above line.

# The above script will not work on filenames containing blanks or newlines.
# Stephane Chazelas therefore suggests the following alternative:


for filename in *    # Not necessary to use basename,
                     # since "*" won't return any file containing "/".
do n=`echo "$filename/" | tr '[:upper:]' '[:lower:]'`
#                             POSIX char set notation.
#                    Slash added so that trailing newlines are not
#                    removed by command substitution.
   # Variable substitution:
   n=${n%/}          # Removes trailing slash, added above, from filename.
   [[ $filename == $n ]] || mv "$filename" "$n"
                     # Checks if filename already lowercase.
done

exit $?
}

◊anchored-example[#:anchor "du_tr1"]{du: DOS to UNIX text file
conversion}

◊example{
#!/bin/bash
# Du.sh: DOS to UNIX text file converter.

E_WRONGARGS=85

if [ -z "$1" ]
then
  echo "Usage: `basename $0` filename-to-convert"
  exit $E_WRONGARGS
fi

NEWFILENAME=$1.unx

CR='\015'  # Carriage return.
           # 015 is octal ASCII code for CR.
           # Lines in a DOS text file end in CR-LF.
           # Lines in a UNIX text file end in LF only.

tr -d $CR < $1 > $NEWFILENAME
# Delete CR's and write to new file.

echo "Original DOS text file is \"$1\"."
echo "Converted UNIX text file is \"$NEWFILENAME\"."

exit 0

# Exercise:
# --------
# Change the above script to convert from UNIX to DOS.
}

◊anchored-example[#:anchor "rot13_tr1"]{rot13: ultra-weak encryption}

◊example{
#!/bin/bash
# rot13.sh: Classic rot13 algorithm,
#           encryption that might fool a 3-year old
#           for about 10 minutes.

# Usage: ./rot13.sh filename
# or     ./rot13.sh <filename
# or     ./rot13.sh and supply keyboard input (stdin)

cat "$@" | tr 'a-zA-Z' 'n-za-mN-ZA-M'   # "a" goes to "n", "b" to "o" ...
#  The   cat "$@"   construct
#+ permits input either from stdin or from files.

exit 0
}

◊anchored-example[#:anchor "crypto_tr1"]{Generating "Crypto-Quote"
Puzzles}

◊example{
#!/bin/bash
# crypto-quote.sh: Encrypt quotes

#  Will encrypt famous quotes in a simple monoalphabetic substitution.
#  The result is similar to the "Crypto Quote" puzzles
#+ seen in the Op Ed pages of the Sunday paper.


key=ETAOINSHRDLUBCFGJMQPVWZYXK
# The "key" is nothing more than a scrambled alphabet.
# Changing the "key" changes the encryption.

# The 'cat "$@"' construction gets input either from stdin or from files.
# If using stdin, terminate input with a Control-D.
# Otherwise, specify filename as command-line parameter.

cat "$@" | tr "a-z" "A-Z" | tr "A-Z" "$key"
#        |  to uppercase  |     encrypt
# Will work on lowercase, uppercase, or mixed-case quotes.
# Passes non-alphabetic characters through unchanged.


# Try this script with something like:
# "Nothing so needs reforming as other people's habits."
# --Mark Twain
#
# Output is:
# "CFPHRCS QF CIIOQ MINFMBRCS EQ FPHIM GIFGUI'Q HETRPQ."
# --BEML PZERC

# To reverse the encryption:
# cat "$@" | tr "$key" "A-Z"


#  This simple-minded cipher can be broken by an average 12-year old
#+ using only pencil and paper.

exit 0

#  Exercise:
#  --------
#  Modify the script so that it will either encrypt or decrypt,
#+ depending on command-line argument(s).
}

Of course, ◊command{tr} lends itself to code obfuscation.

◊example{
#!/bin/bash
# jabh.sh

x="wftedskaebjgdBstbdbsmnjgz"
echo $x | tr "a-z" 'oh, turtleneck Phrase Jar!'

# Based on the Wikipedia "Just another Perl hacker" article.
}

Variants: The ◊command{tr} utility has two historic
variants. The BSD version does not use brackets (◊command{tr a-z
A-Z}), but the SysV one does (◊command{tr '[a-z]' '[A-Z]'}). The GNU
version of tr resembles the BSD one.

}

◊definition-entry[#:name "fold"]{
A filter that wraps lines of input to a specified width. This is
especially useful with the ◊code{-s} option, which breaks lines at
word spaces (see TODO Example 16-26 and Example A-1).

}

◊definition-entry[#:name "fmt"]{
Simple-minded file formatter, used as a filter in a pipe to "wrap"
long lines of text output.

◊example{
#!/bin/bash

WIDTH=40                    # 40 columns wide.

b=`ls /usr/local/bin`       # Get a file listing...

echo $b | fmt -w $WIDTH

# Could also have been done by
#    echo $b | fold - -s -w $WIDTH

exit 0
}

See also TODO Example 16-5.

Tip: A powerful alternative to ◊code{fmt} is Kamil Toman's ◊code{par}
utility, available from http://www.cs.berkeley.edu/~amc/Par/.

}

◊definition-entry[#:name "col"]{
This deceptively named filter removes reverse line feeds from an input
stream. It also attempts to replace whitespace with equivalent
tabs. The chief use of ◊command{col} is in filtering the output from
certain text processing utilities, such as ◊command{groff} and
◊command{tbl}.

}

◊definition-entry[#:name "column"]{
Column formatter. This filter transforms list-type text output into a
"pretty-printed" table by inserting tabs at appropriate places.

◊anchored-example[#:anchor "col_fmt_dir1"]{Using column to format a
directory listing}

◊example{
#!/bin/bash
# colms.sh
# A minor modification of the example file in the "column" man page.


(printf "PERMISSIONS LINKS OWNER GROUP SIZE MONTH DAY HH:MM PROG-NAME\n" \
; ls -l | sed 1d) | column -t
#         ^^^^^^           ^^

#  The "sed 1d" in the pipe deletes the first line of output,
#+ which would be "total        N",
#+ where "N" is the total number of files found by "ls -l".

# The -t option to "column" pretty-prints a table.

exit 0
}

◊definition-entry[#:name "colrm"]{
}

}

}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
