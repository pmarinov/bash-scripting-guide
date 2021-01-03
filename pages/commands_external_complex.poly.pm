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
}

}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
