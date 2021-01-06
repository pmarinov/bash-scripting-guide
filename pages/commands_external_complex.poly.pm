#lang pollen

◊; This is free software released into the public domain
◊; See LICENSE.txt

◊page-init{}
◊define-meta[page-title]{Complex External Commands}
◊define-meta[page-description]{Complex External Commands}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "find"]{
◊command{-exec COMMAND \;}

Carries out ◊code{COMMAND} on each file that find matches. The command
sequence terminates with ◊code{;} (the ";" is escaped to make certain
the shell passes it to find literally, without interpreting it as a
special character).

◊example{
bash$ find ~/ -name '*.txt'
/home/bozo/.kde/share/apps/karm/karmdata.txt
/home/bozo/misc/irmeyc.txt
/home/bozo/test-scripts/1.txt
}

If ◊code{COMMAND} contains ◊code{◊escaped{◊"{"}◊escaped{◊"}"}}, then
◊command{find} substitutes the full path name of the selected file for
"◊escaped{◊"{"}◊escaped{◊"}"}".

◊example{
find ~/ -name 'core*' -exec rm {} \;
# Removes all core dump files from user's home directory.
}

◊example{
ind /home/bozo/projects -mtime -1
#                               ^   Note minus sign!
#  Lists all files in /home/bozo/projects directory tree
#+ that were modified within the last day (current_day - 1).
#
find /home/bozo/projects -mtime 1
#  Same as above, but modified *exactly* one day ago.
#
#  mtime = last modification time of the target file
#  ctime = last status change time (via 'chmod' or otherwise)
#  atime = last access time

DIR=/home/bozo/junk_files
find "$DIR" -type f -atime +5 -exec rm {} \;
#                          ^           ^^
#  Curly brackets are placeholder for the path name output by "find."
#
#  Deletes all files in "/home/bozo/junk_files"
#+ that have not been accessed in *at least* 5 days (plus sign ... +5).
#
#  "-type filetype", where
#  f = regular file
#  d = directory
#  l = symbolic link, etc.
#
#  (The 'find' manpage and info page have complete option listings.)
}

◊example{
find /etc -exec grep '[0-9][0-9]*[.][0-9][0-9]*[.][0-9][0-9]*[.][0-9][0-9]*' {} \;

# Finds all IP addresses (xxx.xxx.xxx.xxx) in /etc directory files.
# There a few extraneous hits. Can they be filtered out?

# Possibly by:

find /etc -type f -exec cat '{}' \; | tr -c '.[:digit:]' '\n' \
| grep '^[^.][^.]*\.[^.][^.]*\.[^.][^.]*\.[^.][^.]*$'
#
#  [:digit:] is one of the character classes
#+ introduced with the POSIX 1003.2 standard.
}

Note: The ◊code{-exec} option to ◊command{find} should not be confused
with the ◊command{exec} shell builtin.

◊anchored-example[#:anchor "find_badname1"]{Badname, eliminate file names in current directory containing bad characters and whitespace.}

◊example{
!/bin/bash
# badname.sh
# Delete filenames in current directory containing bad characters.

for filename in *
do
  badname=`echo "$filename" | sed -n /[\+\◊"{"\;\"\\\=\?~\(\)\<\>\&\*\|\$]/p`
# badname=`echo "$filename" | sed -n '/[+◊"{";"\=?~()<>&*|$]/p'`  also works.
# Deletes files containing these nasties:     + ◊"{" ; " \ = ? ~ ( ) < > & * | $
#
  rm $badname 2>/dev/null
#             ^^^^^^^^^^^ Error messages deep-sixed.
done

# Now, take care of files containing all manner of whitespace.
find . -name "* *" -exec rm -f {} \;
# The path name of the file that _find_ finds replaces the "{}".
# The '\' ensures that the ';' is interpreted literally, as end of command.

exit 0

#---------------------------------------------------------------------
# Commands below this line will not execute because of _exit_ command.

# An alternative to the above script:
find . -name '*[+◊"{";"\\=?~()<>&*|$ ]*' -maxdepth 0 \
-exec rm -f '{}' \;
#  The "-maxdepth 0" option ensures that _find_ will not search
#+ subdirectories below $PWD.
}

◊anchored-example[#:anchor "find_inode1"]{Deleting a file by its inode
number}

◊example{
#!/bin/bash
# idelete.sh: Deleting a file by its inode number.

#  This is useful when a filename starts with an illegal character,
#+ such as ? or -.

ARGCOUNT=1                      # Filename arg must be passed to script.
E_WRONGARGS=70
E_FILE_NOT_EXIST=71
E_CHANGED_MIND=72

if [ $# -ne "$ARGCOUNT" ]
then
  echo "Usage: `basename $0` filename"
  exit $E_WRONGARGS
fi

if [ ! -e "$1" ]
then
  echo "File \""$1"\" does not exist."
  exit $E_FILE_NOT_EXIST
fi

inum=`ls -i | grep "$1" | awk '{print $1}'`
# inum = inode (index node) number of file
# -----------------------------------------------------------------------
# Every file has an inode, a record that holds its physical address info.
# -----------------------------------------------------------------------

echo; echo -n "Are you absolutely sure you want to delete \"$1\" (y/n)? "
# The '-v' option to 'rm' also asks this.
read answer
case "$answer" in
[nN]) echo "Changed your mind, huh?"
      exit $E_CHANGED_MIND
      ;;
*)    echo "Deleting file \"$1\".";;
esac

find . -inum $inum -exec rm {} \;
#                           ^^
#        Curly brackets are placeholder
#+       for text output by "find."
echo "File "\"$1"\" deleted!"

exit 0
}

The ◊command{find} command also works without the ◊command{-exec}
option.

◊example{
#!/bin/bash
#  Find suid root files.
#  A strange suid file might indicate a security hole,
#+ or even a system intrusion.

directory="/usr/sbin"
# Might also try /sbin, /bin, /usr/bin, /usr/local/bin, etc.
permissions="+4000"  # suid root (dangerous!)


for file in $( find "$directory" -perm "$permissions" )
do
  ls -ltF --author "$file"
done
}

See TODO Example 16-30, Example 3-4, and Example 11-10 for scripts
using find. Its manpage provides more detail on this complex and
powerful command.

}

◊definition-entry[#:name "xargs"]{
A filter for feeding arguments to a command, and also a tool for
assembling the commands themselves. It breaks a data stream into small
enough chunks for filters and commands to process. Consider it as a
powerful replacement for backquotes. In situations where command
substitution fails with a too many arguments error, substituting
◊command{xargs} often works. Normally, ◊command{xargs} reads from
◊code{stdin} or from a pipe, but it can also be given the output of a
file. ◊footnote{And even when ◊command{xargs} is not strictly
necessary, it can speed up execution of a command involving
batch-processing of multiple files.}

The default command for ◊command{xargs} is ◊command{echo}. This means
that input piped to ◊command{xargs} may have linefeeds and other
whitespace characters stripped out.

◊example{
bash$ ls -l
total 0
-rw-rw-r--    1 bozo  bozo         0 Jan 29 23:58 file1
-rw-rw-r--    1 bozo  bozo         0 Jan 29 23:58 file2


bash$ ls -l | xargs
total 0 -rw-rw-r-- 1 bozo bozo 0 Jan 29 23:58 file1 -rw-rw-r-- 1 bozo bozo 0 Jan...


bash$ find ~/mail -type f | xargs grep "Linux"
./misc:User-Agent: slrn/0.9.8.1 (Linux)
./sent-mail-jul-2005: hosted by the Linux Documentation Project.
./sent-mail-jul-2005: (Linux Documentation Project Site, rtf version)
./sent-mail-jul-2005: Subject: Criticism of Bozo's Windows/Linux article
./sent-mail-jul-2005: while mentioning that the Linux ext2/ext3 filesystem
. . .
}

◊command{ls | xargs -p -l gzip} gzips every file in current directory,
one at a time, prompting before each operation.

Note: Note that ◊command{xargs} processes the arguments passed to it
sequentially, one at a time.

◊example{
bash$ find /usr/bin | xargs file
/usr/bin:          directory
/usr/bin/foomatic-ppd-options:          perl script text executable
. . .
}

Tip: An interesting ◊command{xargs} option is ◊code{-n NN}, which
limits to ◊code{NN} the number of arguments passed.

◊command{ls | xargs -n 8 echo} lists the files in the current directory
in 8 columns.

Tip: Another useful option is ◊code{-0}, in combination with
◊command{find -print0} or ◊command{grep -lZ}. This allows handling
arguments containing whitespace or quotes.

◊example{
find / -type f -print0 | xargs -0 grep -liwZ GUI | xargs -0 rm -f
}

◊example{
grep -rliwZ GUI / | xargs -0 rm -f
}

Either of the above will remove any file containing "GUI".

Or:

◊example{
cat /proc/"$pid"/"$OPTION" | xargs -0 echo
#  Formats output:         ^^^^^^^^^^^^^^^
#  From Han Holl's fixup of "get-commandline.sh"
#+ script in "/dev and /proc" chapter.
}

Tip: The ◊code{-P} option to ◊command{xargs} permits running processes
in parallel. This speeds up execution in a machine with a multicore
CPU.

◊example{
#!/bin/bash

ls *gif | xargs -t -n1 -P2 gif2png
# Converts all the gif images in current directory to png.

# Options:
# =======
# -t    Print command to stderr.
# -n1   At most 1 argument per command line.
# -P2   Run up to 2 processes simultaneously.

# Thank you, Roberto Polli, for the inspiration.
}

◊anchored-example[#:anchor "xargs_log1"]{Using xargs to monitor system
log}

◊example{
#!/bin/bash

# Generates a log file in current directory
# from the tail end of /var/log/messages.

# Note: /var/log/messages must be world readable
# if this script invoked by an ordinary user.
#         #root chmod 644 /var/log/messages

LINES=5

( date; uname -a ) >>logfile
# Time and machine name
echo ---------------------------------------------------------- >>logfile
tail -n $LINES /var/log/messages | xargs | fmt -s >>logfile
echo >>logfile
echo >>logfile

exit 0

#  Note:
#  ----
#  As Frank Wang points out,
#+ unmatched quotes (either single or double quotes) in the source file
#+ may give xargs indigestion.
#
#  He suggests the following substitution for line 15:
#  tail -n $LINES /var/log/messages | tr -d "\"'" | xargs | fmt -s >>logfile



#  Exercise:
#  --------
#  Modify this script to track changes in /var/log/messages at intervals
#+ of 20 minutes.
#  Hint: Use the "watch" command.
}

◊anchored-example[#:anchor "xargs_arg1"]{Copying files in current
directory to another}

As in ◊command{find}, a curly bracket pair serves as a placeholder for
replacement text.

◊example{
#!/bin/bash
# copydir.sh

#  Copy (verbose) all files in current directory ($PWD)
#+ to directory specified on command-line.

E_NOARGS=85

if [ -z "$1" ]   # Exit if no argument given.
then
  echo "Usage: `basename $0` directory-to-copy-to"
  exit $E_NOARGS
fi

ls . | xargs -i -t cp ./{} $1
#            ^^ ^^      ^^
#  -t is "verbose" (output command-line to stderr) option.
#  -i is "replace strings" option.
#  {} is a placeholder for output text.
#  This is similar to the use of a curly-bracket pair in "find."
#
#  List the files in current directory (ls .),
#+ pass the output of "ls" as arguments to "xargs" (-i -t options),
#+ then copy (cp) these arguments ({}) to new directory ($1).
#
#  The net result is the exact equivalent of
#+   cp * $1
#+ unless any of the filenames has embedded "whitespace" characters.

exit 0
}

◊anchored-example[#:anchor "xargs_killp1"]{Killing processes by name}

◊example{
#!/bin/bash
# kill-byname.sh: Killing processes by name.
# Compare this script with kill-process.sh.

#  For instance,
#+ try "./kill-byname.sh xterm" --
#+ and watch all the xterms on your desktop disappear.

#  Warning:
#  -------
#  This is a fairly dangerous script.
#  Running it carelessly (especially as root)
#+ can cause data loss and other undesirable effects.

E_BADARGS=66

if test -z "$1"  # No command-line arg supplied?
then
  echo "Usage: `basename $0` Process(es)_to_kill"
  exit $E_BADARGS
fi


PROCESS_NAME="$1"
ps ax | grep "$PROCESS_NAME" | awk '{print $1}' | xargs -i kill {} 2&>/dev/null
#                                                       ^^      ^^

# ---------------------------------------------------------------
# Notes:
# -i is the "replace strings" option to xargs.
# The curly brackets are the placeholder for the replacement.
# 2&>/dev/null suppresses unwanted error messages.
#
# Can  grep "$PROCESS_NAME" be replaced by pidof "$PROCESS_NAME"?
# ---------------------------------------------------------------

exit $?

#  The "killall" command has the same effect as this script,
#+ but using it is not quite as educational.
}

◊anchored-example[#:anchor "xargs_cntw1"]{Word frequency analysis
using xargs}

◊example{
#!/bin/bash
# wf2.sh: Crude word frequency analysis on a text file.

# Uses 'xargs' to decompose lines of text into single words.
# Compare this example to the "wf.sh" script later on.


# Check for input file on command-line.
ARGS=1
E_BADARGS=85
E_NOFILE=86

if [ $# -ne "$ARGS" ]
# Correct number of arguments passed to script?
then
  echo "Usage: `basename $0` filename"
  exit $E_BADARGS
fi

if [ ! -f "$1" ]       # Does file exist?
then
  echo "File \"$1\" does not exist."
  exit $E_NOFILE
fi


#####################################################
cat "$1" | xargs -n1 | \
#  List the file, one word per line.
tr A-Z a-z | \
#  Shift characters to lowercase.
sed -e 's/\.//g'  -e 's/\,//g' -e 's/ /\
/g' | \
#  Filter out periods and commas, and
#+ change space between words to linefeed,
sort | uniq -c | sort -nr
#  Finally remove duplicates, prefix occurrence count
#+ and sort numerically.
#####################################################

#  This does the same job as the "wf.sh" example,
#+ but a bit more ponderously, and it runs more slowly (why?).

exit $?
}

}

◊definition-entry[#:name "expr"]{
}

}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
