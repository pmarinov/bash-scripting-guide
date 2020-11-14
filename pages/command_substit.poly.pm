#lang pollen

◊; This is free and unencumbered software released into the public domain
◊; See LICENSE.txt

◊page-init{}
◊define-meta[page-title]{Command Substitution}
◊define-meta[page-description]{Command Substitution and Arithmetic Expansion}

Command substitution reassigns the output of a command or even
multiple commands; it literally plugs the command output into another
context.

For purposes of command substitution, a command may be an external
system command, an internal scripting builtin, or even a script
function.

In a more technically correct sense, command substitution extracts the
stdout of a command, then assigns it to a variable using the ◊code{=}
operator.

The classic form of command substitution uses backquotes
(◊code{`...`}). Commands within backquotes (backticks) generate
command-line text.

◊example{
script_name=`basename $0`
echo "The name of this script is $script_name."
}

The output of commands can be used as arguments to another command, to
set a variable, and even for generating the argument list in a for
loop.

Note: Command substitution invokes a subshell.

◊section{Usage examples}

◊example{
rm `cat filename`   # "filename" contains a list of files to delete.
#
# S. C. points out that "arg list too long" error might result.
# Better is              xargs rm -- < filename
# ( -- covers those cases where "filename" begins with a "-" )

textfile_listing=`ls *.txt`
# Variable contains names of all *.txt files in current working directory.
echo $textfile_listing

textfile_listing2=$(ls *.txt)   # The alternative form of command substitution.
echo $textfile_listing2
# Same result.

# A possible problem with putting a list of files into a single string
# is that a newline may creep in.
#
# A safer way to assign a list of files to a parameter is with an array.
#      shopt -s nullglob    # If no match, filename expands to nothing.
#      textfile_listing=( *.txt )
#
# Thanks, S.C.
}

Command substitution permits setting a variable to the contents of a
file, or using redirection.

◊example{
variable1=`<file1`      #  Set "variable1" to contents of "file1".
variable2=`cat file2`   #  Set "variable2" to contents of "file2".
                        #  This, however, forks a new process,
                        #+ so the line of code executes slower than the above version.

#  Note that the variables may contain embedded whitespace,
#+ or even (horrors), control characters.

#  It is not necessary to explicitly assign a variable.
echo "` <$0`"           # Echoes the script itself to stdout.
}

Command substitution permits setting a variable to the output of the
◊command{cat} command.

◊example{
#  Excerpts from system file, /etc/rc.d/rc.sysinit
#+ (on a Red Hat Linux installation)


if [ -f /fsckoptions ]; then
        fsckoptions=`cat /fsckoptions`
...
fi
#
#
if [ -e "/proc/ide/${disk[$device]}/media" ] ; then
             hdmedia=`cat /proc/ide/${disk[$device]}/media`
...
fi
#
#
if [ ! -n "`uname -r | grep -- "-"`" ]; then
       ktag="`cat /proc/version`"
...
fi
#
#
if [ $usb = "1" ]; then
    sleep 5
    mouseoutput=`cat /proc/bus/usb/devices 2>/dev/null|grep -E "^I.*Cls=03.*Prot=02"`
    kbdoutput=`cat /proc/bus/usb/devices 2>/dev/null|grep -E "^I.*Cls=03.*Prot=01"`
...
fi
}

Command substitution permits setting a variable to the output of a
loop. The key to this is grabbing the output of an ◊code{echo} command
within the loop.

◊example{
#!/bin/bash
# csubloop.sh: Setting a variable to the output of a loop.

variable1=`for i in 1 2 3 4 5
do
  echo -n "$i"                 #  The 'echo' command is critical
done`                          #+ to command substitution here.

echo "variable1 = $variable1"  # variable1 = 12345


i=0
variable2=`while [ "$i" -lt 10 ]
do
  echo -n "$i"                 # Again, the necessary 'echo'.
  let "i += 1"                 # Increment.
done`

echo "variable2 = $variable2"  # variable2 = 0123456789

#  Demonstrates that it's possible to embed a loop
#+ inside a variable declaration.

exit 0
}

◊section{Modern form}

The ◊code{$(...)} form has superseded backticks for command
substitution.

◊example{
output=$(sed -n /"$1"/p $file)   # From "grp.sh"	example.

# Setting a variable to the contents of a text file.
File_contents1=$(cat $file1)
File_contents2=$(<$file2)        # Bash permits this also.
}

The ◊code{$(...)} form of command substitution treats a double backslash in a
different way than ◊code{`...`}.

◊example{
bash$ echo `echo \\`


bash$ echo $(echo \\)
\
}

The ◊code{$(...)} form of command substitution permits
nesting. ◊footnote{In fact, nesting with backticks is also possible,
but only by escaping the inner backticks, as John Default points
out. ◊code{word_count=` wc -w \`echo * | awk '◊escaped{"{"}print
$8◊escaped{"}"}'\` `}}
◊; TODO: The escaped doesn't work in case of HTML & INFO here

◊example{
word_count=$( wc -w $(echo * | awk '{print $8}') )
}

◊section-example[#:anchor "finding_anagrams1"]{Finding anagrams}

◊example{
#!/bin/bash
# agram2.sh
# Example of nested command substitution.

#  Uses "anagram" utility
#+ that is part of the author's "yawl" word list package.
#  http://ibiblio.org/pub/Linux/libs/yawl-0.3.2.tar.gz
#  http://bash.deta.in/yawl-0.3.2.tar.gz

E_NOARGS=86
E_BADARG=87
MINLEN=7

if [ -z "$1" ]
then
  echo "Usage $0 LETTERSET"
  exit $E_NOARGS         # Script needs a command-line argument.
elif [ ${#1} -lt $MINLEN ]
then
  echo "Argument must have at least $MINLEN letters."
  exit $E_BADARG
fi



FILTER='.......'         # Must have at least 7 letters.
#       1234567
Anagrams=( $(echo $(anagram $1 | grep $FILTER) ) )
#          $(     $(  nested command sub.    ) )
#        (              array assignment         )

echo
echo "${#Anagrams[*]}  7+ letter anagrams found"
echo
echo ${Anagrams[0]}      # First anagram.
echo ${Anagrams[1]}      # Second anagram.
                         # Etc.

# echo "${Anagrams[*]}"  # To list all the anagrams in a single line . . .

#  Look ahead to the Arrays chapter for enlightenment on
#+ what's going on here.

# See also the agram.sh script for an exercise in anagram finding.

exit $?
}

◊section{What to avoid}

Caution: Command substitution may result in word splitting.

◊example{
COMMAND `echo a b`     # 2 args: a and b

COMMAND "`echo a b`"   # 1 arg: "a b"

COMMAND `echo`         # no arg

COMMAND "`echo`"       # one empty arg

# Thanks, S.C.
}

Caution: Even when there is no word splitting, command substitution can remove
trailing newlines.

◊example{
# cd "`pwd`"  # This should always work.
# However...

mkdir 'dir with trailing newline
'

cd 'dir with trailing newline
'

cd "`pwd`"  # Error message:
# bash: cd: /tmp/file with trailing newline: No such file or directory

cd "$PWD"   # Works fine.



old_tty_setting=$(stty -g)   # Save old terminal setting.
echo "Hit a key "
stty -icanon -echo           # Disable "canonical" mode for terminal.
                             # Also, disable *local* echo.
key=$(dd bs=1 count=1 2> /dev/null)   # Using 'dd' to get a keypress.
stty "$old_tty_setting"      # Restore old setting.
echo "You hit ${#key} key."  # ${#variable} = number of characters in $variable
#
# Hit any key except RETURN, and the output is "You hit 1 key."
# Hit RETURN, and it's "You hit 0 key."
# The newline gets eaten in the command substitution.

#Code snippet by Stéphane Chazelas.
}

Caution: Using ◊code{echo} to output an unquoted variable set with
command substitution removes trailing newlines characters from the
output of the reassigned command(s). This can cause unpleasant
surprises.

◊example{
dir_listing=`ls -l`
echo $dir_listing     # unquoted

# Expecting a nicely ordered directory listing.

# However, what you get is:
# total 3 -rw-rw-r-- 1 bozo bozo 30 May 13 17:15 1.txt -rw-rw-r-- 1 bozo
# bozo 51 May 15 20:57 t2.sh -rwxr-xr-x 1 bozo bozo 217 Mar 5 21:13 wi.sh

# The newlines disappeared.


echo "$dir_listing"   # quoted
# -rw-rw-r--    1 bozo       30 May 13 17:15 1.txt
# -rw-rw-r--    1 bozo       51 May 15 20:57 t2.sh
# -rwxr-xr-x    1 bozo      217 Mar  5 21:13 wi.sh
}

Caution: Do not set a variable to the contents of a long text file
unless you have a very good reason for doing so. Do not set a variable
to the contents of a binary file, even as a joke.

◊example{
#!/bin/bash
# stupid-script-tricks.sh: Don't try this at home, folks.
# From "Stupid Script Tricks," Volume I.

exit 99  ### Comment out this line if you dare.

dangerous_variable=`cat /boot/vmlinuz`   # The compressed Linux kernel itself.

echo "string-length of \$dangerous_variable = ${#dangerous_variable}"
# string-length of $dangerous_variable = 794151
# (Newer kernels are bigger.)
# Does not give same count as 'wc -c /boot/vmlinuz'.

# echo "$dangerous_variable"
# Don't try this! It would hang the script.


#  The document author is aware of no useful applications for
#+ setting a variable to the contents of a binary file.

exit 0
}

TODO put long list of examples here

◊section{Arithmetic Expansion}

Arithmetic expansion provides a powerful tool for performing (integer)
arithmetic operations in scripts. Translating a string into a
numerical expression is relatively straightforward using backticks,
double parentheses, or ◊code{let}.

◊definition-block[#:type "variables"]{
◊definition-entry[#:name "backticks"]{
Arithmetic expansion with backticks (often used in conjunction with
◊code{expr})

◊example{
z=`expr $z + 3`          # The 'expr' command performs the expansion.
}

}

◊definition-entry[#:name "double parentheses"]{
Arithmetic expansion with double parentheses, and using ◊code{let}

The use of backticks (backquotes) in arithmetic expansion has been
superseded by double parentheses -- ◊code{((...))} and ◊code{$((...))}
-- and also by the very convenient let construction.

◊example{
z=$(($z+3))
z=$((z+3))                                  #  Also correct.
                                            #  Within double parentheses,
                                            #+ parameter dereferencing
                                            #+ is optional.

# $((EXPRESSION)) is arithmetic expansion.  #  Not to be confused with
                                            #+ command substitution.



# You may also use operations within double parentheses without assignment.

  n=0
  echo "n = $n"                             # n = 0

  (( n += 1 ))                              # Increment.
# (( $n += 1 )) is incorrect!
  echo "n = $n"                             # n = 1


let z=z+3
let "z += 3"  #  Quotes permit the use of spaces in variable assignment.
              #  The 'let' operator actually performs arithmetic evaluation,
              #+ rather than expansion.
}
}

}

TODO put long list of examples here

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
