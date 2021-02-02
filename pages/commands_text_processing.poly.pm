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
}

}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
