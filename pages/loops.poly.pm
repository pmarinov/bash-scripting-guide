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

The output of a ◊code{for} loop may be piped to a command or commands.

◊example{
#!/bin/bash
# symlinks.sh: Lists symbolic links in a directory.


directory=${1-`pwd`}
#  Defaults to current working directory,
#+ if not otherwise specified.
#  Equivalent to code block below.
# ----------------------------------------------------------
# ARGS=1                 # Expect one command-line argument.
#
# if [ $# -ne "$ARGS" ]  # If not 1 arg...
# then
#   directory=`pwd`      # current working directory
# else
#   directory=$1
# fi
# ----------------------------------------------------------

echo "symbolic links in directory \"$directory\""

for file in "$( find $directory -type l )"   # -type l = symbolic links
do
  echo "$file"
done | sort                                  # Otherwise file list is unsorted.
#  Strictly speaking, a loop isn't really necessary here,
#+ since the output of the "find" command is expanded into a single word.
#  However, it's easy to understand and illustrative this way.

#  As Dominik 'Aeneas' Schnitzer points out,
#+ failing to quote  $( find $directory -type l )
#+ will choke on filenames with embedded whitespace.
#  containing whitespace. 

exit 0


# --------------------------------------------------------
# Jean Helou proposes the following alternative:

echo "symbolic links in directory \"$directory\""
# Backup of the current IFS. One can never be too cautious.
OLDIFS=$IFS
IFS=:

for file in $(find $directory -type l -printf "%p$IFS")
do     #                              ^^^^^^^^^^^^^^^^
       echo "$file"
       done|sort

# And, James "Mike" Conley suggests modifying Helou's code thusly:

OLDIFS=$IFS
IFS='' # Null IFS means no word breaks
for file in $( find $directory -type l )
do
  echo $file
  done | sort

#  This works in the "pathological" case of a directory name having
#+ an embedded colon.
#  "This also fixes the pathological case of the directory name having
#+  a colon (or space in earlier example) as well."
}

◊section-example[#:anchor "for_lnk_f1"]{Symbolic links in a directory,
saved to a file}

The ◊code{stdout} of a loop may be redirected to a file, as this
slight modification to the previous example shows.

◊example{
#!/bin/bash
# symlinks.sh: Lists symbolic links in a directory.

OUTFILE=symlinks.list                         # save-file

directory=${1-`pwd`}
#  Defaults to current working directory,
#+ if not otherwise specified.


echo "symbolic links in directory \"$directory\"" > "$OUTFILE"
echo "---------------------------" >> "$OUTFILE"

for file in "$( find $directory -type l )"    # -type l = symbolic links
do
  echo "$file"
done | sort >> "$OUTFILE"                     # stdout of loop
#           ^^^^^^^^^^^^^                       redirected to save file.

# echo "Output file = $OUTFILE"

exit $?
}

◊section-example[#:anchor "for_cstyle1"]{A C-style for loop}

There is an alternative syntax to a ◊code{for} loop that will look
very familiar to C programmers. This requires double parentheses.

◊example{
#!/bin/bash
# Multiple ways to count up to 10.

echo

# Standard syntax.
for a in 1 2 3 4 5 6 7 8 9 10
do
  echo -n "$a "
done  

echo; echo

# +==========================================+

# Using "seq" ...
for a in `seq 10`
do
  echo -n "$a "
done  

echo; echo

# +==========================================+

# Using brace expansion ...
# Bash, version 3+.
for a in {1..10}
do
  echo -n "$a "
done  

echo; echo

# +==========================================+

# Now, let's do the same, using C-like syntax.

LIMIT=10

for ((a=1; a <= LIMIT ; a++))  # Double parentheses, and naked "LIMIT"
do
  echo -n "$a "
done                           # A construct borrowed from ksh93.

echo; echo

# +=========================================================================+

# Let's use the C "comma operator" to increment two variables simultaneously.

for ((a=1, b=1; a <= LIMIT ; a++, b++))
do  # The comma concatenates operations.
  echo -n "$a-$b "
done

echo; echo

exit 0
}

See also TODO Example 27-16, Example 27-17, and Example A-6.

◊section-example[#:anchor "for_efax1"]{Using efax in batch mode}

Now, a for loop used in a "real-life" context.

◊example{
#!/bin/bash
# Faxing (must have 'efax' package installed).

EXPECTED_ARGS=2
E_BADARGS=85
MODEM_PORT="/dev/ttyS2"   # May be different on your machine.
#                ^^^^^      PCMCIA modem card default port.

if [ $# -ne $EXPECTED_ARGS ]
# Check for proper number of command-line args.
then
   echo "Usage: `basename $0` phone# text-file"
   exit $E_BADARGS
fi


if [ ! -f "$2" ]
then
  echo "File $2 is not a text file."
  #     File is not a regular file, or does not exist.
  exit $E_BADARGS
fi
  

fax make $2              #  Create fax-formatted files from text files.

for file in $(ls $2.0*)  #  Concatenate the converted files.
                         #  Uses wild card (filename "globbing")
			 #+ in variable list.
do
  fil="$fil $file"
done  

efax -d "$MODEM_PORT"  -t "T$1" $fil   # Finally, do the work.
# Trying adding  -o1  if above line fails.


#  As S.C. points out, the for-loop can be eliminated with
#     efax -d /dev/ttyS2 -o1 -t "T$1" $2.0*
#+ but it's not quite as instructive [grin].

exit $?   # Also, efax sends diagnostic messages to stdout.
}

Note: The keywords ◊code{do} and ◊code{done} delineate the ◊code{for}
loop command block. However, these may, in certain contexts, be
omitted by framing the command block within curly brackets

◊example{
for((n=1; n<=10; n++)) 
# No do!
{
  echo -n "* $n *"
}
# No done!


# Outputs:
# * 1 ** 2 ** 3 ** 4 ** 5 ** 6 ** 7 ** 8 ** 9 ** 10 *
# And, echo $? returns 0, so Bash does not register an error.


echo


#  But, note that in a classic for-loop:    for n in [list] ...
#+ a terminal semicolon is required.

for n in 1 2 3
{  echo -n "$n "; }
#               ^


# Thank you, YongYe, for pointing this out.
}

◊section{while}

This construct tests for a condition at the top of a loop, and keeps
looping as long as that condition is true (returns a 0 exit
status). In contrast to a ◊code{for} loop, a ◊code{while} loop finds
use in situations where the number of loop repetitions is not known
beforehand.

◊example{
while [ condition ]
do
 command(s)...
done
}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
