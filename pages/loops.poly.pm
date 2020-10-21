#lang pollen

◊define-meta[page-title]{Loops}
◊define-meta[page-description]{Loop forms: "for", "while"}

◊section{for arg in [list]}

This is the basic looping construct. It differs significantly from its
C counterpart.

◊example{
for arg in [list]
do
  command(s)...
done
}

Note: During each pass through the loop, ◊code{arg} takes on the value
of each successive variable in the ◊code{list}.

◊example{
for arg in "$var1" "$var2" "$var3" ... "$varN"
# In pass 1 of the loop, arg = $var1
# In pass 2 of the loop, arg = $var2
# In pass 3 of the loop, arg = $var3
# ...
# In pass N of the loop, arg = $varN

# Arguments in [list] quoted to prevent possible word splitting.
}

The argument ◊code{list} may contain wild cards.

If ◊code{do} is on same line as ◊code{for}, there needs to be a
semicolon after ◊code{list}: ◊code{for arg in [list] ; do}

◊section-example[#:anchor "simple_for1"]{Simple for loops}

◊example{
#!/bin/bash
# Listing the planets.

for planet in Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune Pluto
do
  echo $planet  # Each planet on a separate line.
done

echo; echo

for planet in "Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune Pluto"
    # All planets on same line.
    # Entire 'list' enclosed in quotes creates a single variable.
    # Why? Whitespace incorporated into the variable.
do
  echo $planet
done

echo; echo "Whoops! Pluto is no longer a planet!"

exit 0
}

◊section-example[#:anchor "for_twoelem1"]{for loop with two parameters
in each [list] element}

Each ◊code{[list]} element may contain multiple parameters. This is
useful when processing parameters in groups. In such cases, use the
◊code{set} command (TODO see Example 15-16) to force parsing of each
◊code{[list]} element and assignment of each component to the
positional parameters.

◊example{
#!/bin/bash
# Planets revisited.

# Associate the name of each planet with its distance from the sun.

for planet in "Mercury 36" "Venus 67" "Earth 93"  "Mars 142" "Jupiter 483"
do
  set -- $planet  #  Parses variable "planet"
                  #+ and sets positional parameters.
  #  The "--" prevents nasty surprises if $planet is null or
  #+ begins with a dash.

  #  May need to save original positional parameters,
  #+ since they get overwritten.
  #  One way of doing this is to use an array,
  #         original_params=("$@")

  echo "$1		$2,000,000 miles from the sun"
  #-------two  tabs---concatenate zeroes onto parameter $2
done

# (Thanks, S.C., for additional clarification.)

exit 0
}

◊section-example[#:anchor "fileinfo1"]{Fileinfo: operating on a file
list contained in a variable}

A variable may supply the ◊code{[list]} in a ◊code{for} loop.

◊example{
#!/bin/bash
# fileinfo.sh

FILES="/usr/sbin/accept
/usr/sbin/pwck
/usr/sbin/chroot
/usr/bin/fakefile
/sbin/badblocks
/sbin/ypbind"     # List of files you are curious about.
                  # Threw in a dummy file, /usr/bin/fakefile.

echo

for file in $FILES
do

  if [ ! -e "$file" ]       # Check if file exists.
  then
    echo "$file does not exist."; echo
    continue                # On to next.
   fi

  ls -l $file | awk '{ print $8 "         file size: " $5 }'  # Print 2 fields.
  whatis `basename $file`   # File info.
  # Note that the whatis database needs to have been set up for this to work.
  # To do this, as root run /usr/bin/makewhatis.
  echo
done

exit 0
}

◊section-example[#:anchor "for_paramlst1"]{Operating on a
parameterized file list}

The ◊code{[list]} in a ◊code{for} loop may be parameterized.

◊example{
#!/bin/bash

filename="*txt"

for file in $filename
do
  echo "Contents of $file"
  echo "---"
  cat "$file"
  echo
done
}

◊section-example[#:anchor "files_forloo1"]{Operating on files with a
for loop}

If the ◊code{[list]} in a ◊code{for} loop contains wild cards
(◊code{*} and ◊code{?}) used in filename expansion, then globbing
takes place.

◊example{
#!/bin/bash
# list-glob.sh: Generating [list] in a for-loop, using "globbing" ...
# Globbing = filename expansion.

echo

for file in *
#           ^  Bash performs filename expansion
#+             on expressions that globbing recognizes.
do
  ls -l "$file"  # Lists all files in $PWD (current directory).
  #  Recall that the wild card character "*" matches every filename,
  #+ however, in "globbing," it doesn't match dot-files.

  #  If the pattern matches no file, it is expanded to itself.
  #  To prevent this, set the nullglob option
  #+   (shopt -s nullglob).
  #  Thanks, S.C.
done

echo; echo

for file in [jx]*
do
  rm -f $file    # Removes only files beginning with "j" or "x" in $PWD.
  echo "Removed file \"$file\"".
done

echo

exit 0
}

◊section-example[#:anchor "for_missing_lst1"]{Missing in [list] in a
for loop}

Omitting the ◊code{in [list]} part of a ◊code{for} loop causes the
loop to operate on ◊code{$◊escaped{@}} -- the positional parameters. A
particularly clever illustration of this is TODO Example A-15. See
also Example 15-17.

◊example{
#!/bin/bash

#  Invoke this script both with and without arguments,
#+ and see what happens.

for a
do
 echo -n "$a "
done

#  The 'in list' missing, therefore the loop operates on '$@'
#+ (command-line argument list, including whitespace).

echo

exit 0
}

◊section-example[#:anchor "for_listsubst1"]{ Generating the [list] in
a for loop with command substitution}

It is possible to use command substitution to generate the
◊code{[list]} in a ◊code{for} loop. See also TODO Example 16-54,
Example 11-11 and Example 16-48.

◊example{
#!/bin/bash
#  for-loopcmd.sh: for-loop with [list]
#+ generated by command substitution.

NUMBERS="9 7 3 8 37.53"

for number in `echo $NUMBERS`  # for number in 9 7 3 8 37.53
do
  echo -n "$number "
done

echo
exit 0
}

◊section-example[#:anchor "grep_bin1"]{A grep replacement for binary
files}

Here is a somewhat more complex example of using command substitution
to create the ◊code{[list]}.

◊example{
#!/bin/bash
# bin-grep.sh: Locates matching strings in a binary file.

# A "grep" replacement for binary files.
# Similar effect to "grep -a"

E_BADARGS=65
E_NOFILE=66

if [ $# -ne 2 ]
then
  echo "Usage: `basename $0` search_string filename"
  exit $E_BADARGS
fi

if [ ! -f "$2" ]
then
  echo "File \"$2\" does not exist."
  exit $E_NOFILE
fi


IFS=$'\012'       # Per suggestion of Anton Filippov.
                  # was:  IFS="\n"
for word in $( strings "$2" | grep "$1" )
# The "strings" command lists strings in binary files.
# Output then piped to "grep", which tests for desired string.
do
  echo $word
done

# As S.C. points out, lines 23 - 30 could be replaced with the simpler
#    strings "$2" | grep "$1" | tr -s "$IFS" '[\n*]'


#  Try something like  "./bin-grep.sh mem /bin/ls"
#+ to exercise this script.

exit 0
}

◊section-example[#:anchor "list_sysusrs1"]{Listing all users on the
system}

More of the same.

◊example{
#!/bin/bash
# userlist.sh

PASSWORD_FILE=/etc/passwd
n=1           # User number

for name in $(awk 'BEGIN{FS=":"}{print $1}' < "$PASSWORD_FILE" )
# Field separator = :    ^^^^^^
# Print first field              ^^^^^^^^
# Get input from password file  /etc/passwd  ^^^^^^^^^^^^^^^^^
do
  echo "USER #$n = $name"
  let "n += 1"
done


# USER #1 = root
# USER #2 = bin
# USER #3 = daemon
# ...
# USER #33 = bozo

exit $?

#  Discussion:
#  ----------
#  How is it that an ordinary user, or a script run by same,
#+ can read /etc/passwd? (Hint: Check the /etc/passwd file permissions.)
#  Is this a security hole? Why or why not?
}

◊section-example[#:anchor "bin_auth1"]{Checking all the binaries in a
directory for authorship}

Yet another example of the ◊code{[list]} resulting from command
substitution.

◊example{
#!/bin/bash
# findstring.sh:
# Find a particular string in the binaries in a specified directory.

directory=/usr/bin/
fstring="Free Software Foundation"  # See which files come from the FSF.

for file in $( find $directory -type f -name '*' | sort )
do
  strings -f $file | grep "$fstring" | sed -e "s%$directory%%"
  #  In the "sed" expression,
  #+ it is necessary to substitute for the normal "/" delimiter
  #+ because "/" happens to be one of the characters filtered out.
  #  Failure to do so gives an error message. (Try it.)
done

exit $?

#  Exercise (easy):
#  ---------------
#  Convert this script to take command-line parameters
#+ for $directory and $fstring.
}

A final example of ◊code{[list]} / command substitution, but this time
the "command" is a function.

◊example{
generate_list ()
{
  echo "one two three"
}

for word in $(generate_list)  # Let "word" grab output of function.
do
  echo "$word"
done

# one
# two
# three
}

◊section-example[#:anchor "ls_syml1"]{Listing the symbolic links in a
directory}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
