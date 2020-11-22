#lang pollen

◊; This is free and unencumbered software released into the public domain
◊; See LICENSE.txt

◊page-init{}
◊define-meta[page-title]{Internal Commands}
◊define-meta[page-description]{Internal Commands and Builtins}

A builtin is a command contained within the Bash tool set, literally
built in. This is either for performance reasons -- builtins execute
faster than external commands, which usually require forking off a
separate process -- or because a particular builtin needs direct
access to the shell internals. ◊footnote{While forking a process is a
low-cost operation, executing a new program in the newly-forked child
process adds more overhead.}

A builtin may be a synonym to a system command of the same name, but
Bash reimplements it internally. For example, the Bash echo command is
not the same as ◊code{/bin/echo}, although their behavior is almost
identical.

◊example{
#!/bin/bash

echo "This line uses the \"echo\" builtin."
/bin/echo "This line uses the /bin/echo system command."
}

◊section{I/O}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "echo"]{
prints (to stdout) an expression or variable (TODO see Example 4-1).

◊example{
echo Hello
echo $a
}

An ◊code{echo} requires the ◊code{-e} option to print escaped
characters. See TODO Example 5-2.

Normally, each ◊code{echo} command prints a terminal newline, but the
◊code{-n} option suppresses this.

Note: An ◊code{echo} can be used to feed a sequence of commands down a
pipe.

◊example{
if echo "$VAR" | grep -q txt   # if [[ $VAR = *txt* ]]
then
  echo "$VAR contains the substring sequence \"txt\""
fi
}

Note: An ◊code{echo}, in combination with command substitution can set
a variable.

◊example{
a=$(echo "HELLO" | tr A-Z a-z)
}

See TODO also Example 16-22, Example 16-3, Example 16-47, and Example
16-48.

Be aware that ◊code{echo} `command` deletes any linefeeds that the
output of command generates.

The ◊code{$IFS} (internal field separator) variable normally contains
◊code{\n} (linefeed) as one of its set of whitespace characters. Bash
therefore splits the output of command at linefeeds into arguments to
◊code{echo}. Then ◊code{echo} outputs these arguments, separated by
spaces.

◊example{
bash$ ls -l /usr/share/apps/kjezz/sounds
-rw-r--r--    1 root     root         1407 Nov  7  2000 reflect.au
-rw-r--r--    1 root     root          362 Nov  7  2000 seconds.au

bash$ echo $(ls -l /usr/share/apps/kjezz/sounds)
total 40 -rw-r--r-- 1 root root 716 Nov 7 2000 reflect.au -rw-r--r-- 1 root root ...
}

So, how can we embed a linefeed within an echoed character string?

◊example{
# Embedding a linefeed?
echo "Why doesn't this string \n split on two lines?"
# Doesn't split.

# Let's try something else.

echo

echo $"A line of text containing
a linefeed."
# Prints as two distinct lines (embedded linefeed).
# But, is the "$" variable prefix really necessary?

echo

echo "This string splits
on two lines."
# No, the "$" is not needed.

echo
echo "---------------"
echo

echo -n $"Another line of text containing
a linefeed."
# Prints as two distinct lines (embedded linefeed).
# Even the -n option fails to suppress the linefeed here.

echo
echo
echo "---------------"
echo
echo

# However, the following doesn't work as expected.
# Why not? Hint: Assignment to a variable.
string1=$"Yet another line of text containing
a linefeed (maybe)."

echo $string1
# Yet another line of text containing a linefeed (maybe).
#                                    ^
# Linefeed becomes a space.

# Thanks, Steve Parker, for pointing this out.
}

Note: This command is a shell builtin, and not the same as
◊fname{/bin/echo}, although its behavior is similar.

◊example{
bash$ type -a echo
echo is a shell builtin
echo is /bin/echo
}

}

◊definition-entry[#:name "printf"]{
The ◊code{printf}, formatted print, command is an enhanced
◊code{echo}. It is a limited variant of the C language ◊code{printf()}
library function, and its syntax is somewhat different.

◊example{
printf format-string... parameter...
}

This is the Bash builtin version of the ◊fname{/bin/printf} or
◊fname{/usr/bin/printf} command. See the ◊code{printf} manpage (of the
system command) for in-depth coverage.

Caution: Older versions of Bash may not support ◊code{printf}.

◊code{printf} in action

◊example{
#!/bin/bash
# printf demo

declare -r PI=3.14159265358979     # Read-only variable, i.e., a constant.
declare -r DecimalConstant=31373

Message1="Greetings,"
Message2="Earthling."

echo

printf "Pi to 2 decimal places = %1.2f" $PI
echo
printf "Pi to 9 decimal places = %1.9f" $PI  # It even rounds off correctly.

printf "\n"                                  # Prints a line feed,
                                             # Equivalent to 'echo' . . .

printf "Constant = \t%d\n" $DecimalConstant  # Inserts tab (\t).

printf "%s %s \n" $Message1 $Message2

echo

# ==========================================#
# Simulation of C function, sprintf().
# Loading a variable with a formatted string.

echo

Pi12=$(printf "%1.12f" $PI)
echo "Pi to 12 decimal places = $Pi12"      # Roundoff error!

Msg=`printf "%s %s \n" $Message1 $Message2`
echo $Msg; echo $Msg

#  As it happens, the 'sprintf' function can now be accessed
#+ as a loadable module to Bash,
#+ but this is not portable.

exit 0
}

Formatting error messages is a useful application of ◊code{printf}

◊example{
E_BADDIR=85

var=nonexistent_directory

error()
{
  printf "$@" >&2
  # Formats positional params passed, and sends them to stderr.
  echo
  exit $E_BADDIR
}

cd $var || error $"Can't cd to %s." "$var"

# Thanks, S.C.
}

See also TODO Example 36-17.

}

◊definition-entry[#:name "read"]{
"Reads" the value of a variable from ◊code{stdin}, that is,
interactively fetches input from the keyboard. The ◊code{-a} option
lets read get array variables (see TODO Example 27-6).

◊anchored-example[#:anchor ""]{Variable assignment, using read}

◊example{
#!/bin/bash
# "Reading" variables.

echo -n "Enter the value of variable 'var1': "
# The -n option to echo suppresses newline.

read var1
# Note no '$' in front of var1, since it is being set.

echo "var1 = $var1"


echo

# A single 'read' statement can set multiple variables.
echo -n "Enter the values of variables 'var2' and 'var3' "
echo =n "(separated by a space or tab): "
read var2 var3
echo "var2 = $var2      var3 = $var3"
#  If you input only one value,
#+ the other variable(s) will remain unset (null).

exit 0
}

A ◊code{read} without an associated variable assigns its input to the
dedicated variable ◊code{$REPLY}.

◊example{
#!/bin/bash
# read-novar.sh

echo

# -------------------------- #
echo -n "Enter a value: "
read var
echo "\"var\" = "$var""
# Everything as expected here.
# -------------------------- #

echo

# ------------------------------------------------------------------- #
echo -n "Enter another value: "
read           #  No variable supplied for 'read', therefore...
               #+ Input to 'read' assigned to default variable, $REPLY.
var="$REPLY"
echo "\"var\" = "$var""
# This is equivalent to the first code block.
# ------------------------------------------------------------------- #

echo
echo "========================="
echo


#  This example is similar to the "reply.sh" script.
#  However, this one shows that $REPLY is available
#+ even after a 'read' to a variable in the conventional way.


# ================================================================= #

#  In some instances, you might wish to discard the first value read.
#  In such cases, simply ignore the $REPLY variable.

{ # Code block.
read            # Line 1, to be discarded.
read line2      # Line 2, saved in variable.
  } <$0
echo "Line 2 of this script is:"
echo "$line2"   #   # read-novar.sh
echo            #   #!/bin/bash  line discarded.

# See also the soundcard-on.sh script.

exit 0
}

Normally, inputting a ◊code{\} suppresses a newline during input to a
read. The ◊code{-r} option causes an inputted ◊code{\} to be
interpreted literally.

◊example{
#!/bin/bash

echo

echo "Enter a string terminated by a \\, then press <ENTER>."
echo "Then, enter a second string (no \\ this time), and again press <ENTER>."

read var1     # The "\" suppresses the newline, when reading $var1.
              #     first line \
              #     second line

echo "var1 = $var1"
#     var1 = first line second line

#  For each line terminated by a "\"
#+ you get a prompt on the next line to continue feeding characters into var1.

echo; echo

echo "Enter another string terminated by a \\ , then press <ENTER>."
read -r var2  # The -r option causes the "\" to be read literally.
              #     first line \

echo "var2 = $var2"
#     var2 = first line \

# Data entry terminates with the first <ENTER>.

echo

exit 0
}

The ◊code{read} command has some interesting options that permit
echoing a prompt and even reading keystrokes without hitting
◊code{ENTER}.

◊example{
# Read a keypress without hitting ENTER.

read -s -n1 -p "Hit a key " keypress
echo; echo "Keypress was "\"$keypress\""."

# -s option means do not echo input.
# -n N option means accept only N characters of input.
# -p option means echo the following prompt before reading input.

# Using these options is tricky, since they need to be in the correct order.
}

The ◊code{-n} option to ◊code{read} also allows detection of the arrow
keys and certain of the other unusual keys.

◊example{
#!/bin/bash
# arrow-detect.sh: Detects the arrow keys, and a few more.
# Thank you, Sandro Magi, for showing me how.

# --------------------------------------------
# Character codes generated by the keypresses.
arrowup='\[A'
arrowdown='\[B'
arrowrt='\[C'
arrowleft='\[D'
insert='\[2'
delete='\[3'
# --------------------------------------------

SUCCESS=0
OTHER=65

echo -n "Press a key...  "
# May need to also press ENTER if a key not listed above pressed.
read -n3 key                      # Read 3 characters.

echo -n "$key" | grep "$arrowup"  #Check if character code detected.
if [ "$?" -eq $SUCCESS ]
then
  echo "Up-arrow key pressed."
  exit $SUCCESS
fi

echo -n "$key" | grep "$arrowdown"
if [ "$?" -eq $SUCCESS ]
then
  echo "Down-arrow key pressed."
  exit $SUCCESS
fi

echo -n "$key" | grep "$arrowrt"
if [ "$?" -eq $SUCCESS ]
then
  echo "Right-arrow key pressed."
  exit $SUCCESS
fi

echo -n "$key" | grep "$arrowleft"
if [ "$?" -eq $SUCCESS ]
then
  echo "Left-arrow key pressed."
  exit $SUCCESS
fi

echo -n "$key" | grep "$insert"
if [ "$?" -eq $SUCCESS ]
then
  echo "\"Insert\" key pressed."
  exit $SUCCESS
fi

echo -n "$key" | grep "$delete"
if [ "$?" -eq $SUCCESS ]
then
  echo "\"Delete\" key pressed."
  exit $SUCCESS
fi


echo " Some other key pressed."

exit $OTHER

# ========================================= #

#  Mark Alexander came up with a simplified
#+ version of the above script (Thank you!).
#  It eliminates the need for grep.

#!/bin/bash

  uparrow=$'\x1b[A'
  downarrow=$'\x1b[B'
  leftarrow=$'\x1b[D'
  rightarrow=$'\x1b[C'

  read -s -n3 -p "Hit an arrow key: " x

  case "$x" in
  $uparrow)
     echo "You pressed up-arrow"
     ;;
  $downarrow)
     echo "You pressed down-arrow"
     ;;
  $leftarrow)
     echo "You pressed left-arrow"
     ;;
  $rightarrow)
     echo "You pressed right-arrow"
     ;;
  esac

exit $?

# ========================================= #

# Antonio Macchi has a simpler alternative.

#!/bin/bash

while true
do
  read -sn1 a
  test "$a" == `echo -en "\e"` || continue
  read -sn1 a
  test "$a" == "[" || continue
  read -sn1 a
  case "$a" in
    A)  echo "up";;
    B)  echo "down";;
    C)  echo "right";;
    D)  echo "left";;
  esac
done

# ========================================= #

#  Exercise:
#  --------
#  1) Add detection of the "Home," "End," "PgUp," and "PgDn" keys.
}

Note: The ◊code{-n} option to read will not detect the ◊code{ENTER}
(newline) key.

The ◊code{-t} option to read permits timed input (see TODO Example 9-4
and TODO Example A-41).

The ◊code{-u} option takes the file descriptor of the target file.

The ◊code{read} command may also "read" its variable value from a file
redirected to ◊code{stdin}. If the file contains more than one line,
only the first line is assigned to the variable. If read has more than
one parameter, then each of these variables gets assigned a successive
whitespace-delineated string. Caution!

◊anchored-example[#:anchor ""]{Using read with file
redirection}

◊example{
#!/bin/bash

read var1 <data-file
echo "var1 = $var1"
# var1 set to the entire first line of the input file "data-file"

read var2 var3 <data-files
echo "var2 = $var2   var3 = $var3"
# Note non-intuitive behavior of "read" here.
# 1) Rewinds back to the beginning of input file.
# 2) Each variable is now set to a corresponding string,
#    separated by whitespace, rather than to an entire line of text.
# 3) The final variable gets the remainder of the line.
# 4) If there are more variables to be set than whitespace-terminated strings
#    on the first line of the file, then the excess variables remain empty.

echo "------------------------------------------------"

# How to resolve the above problem with a loop:
while read line
do
  echo "$line"
done <data-file
# Thanks, Heiner Steven for pointing this out.

echo "------------------------------------------------"

# Use $IFS (Internal Field Separator variable) to split a line of input to
# "read", if you do not want the default to be whitespace.

echo "List of all users:"
OIFS=$IFS; IFS=:       # /etc/passwd uses ":" for field separator.
while read name passwd uid gid fullname ignore
do
  echo "$name ($fullname)"
done </etc/passwd   # I/O redirection.
IFS=$OIFS              # Restore original $IFS.
# This code snippet also by Heiner Steven.



#  Setting the $IFS variable within the loop itself
#+ eliminates the need for storing the original $IFS
#+ in a temporary variable.
#  Thanks, Dim Segebart, for pointing this out.
echo "------------------------------------------------"
echo "List of all users:"

while IFS=: read name passwd uid gid fullname ignore
do
  echo "$name ($fullname)"
done </etc/passwd   # I/O redirection.

echo
echo "\$IFS still $IFS"

exit 0
}

Note: Piping output to a ◊code{read}, using ◊code{echo} to set
variables will fail.

Yet, piping the output of ◊code{cat} seems to work.

◊example{
cat file1 file2 |
while read line
do
echo $line
done
}

However, as Bjön Eriksson shows:

◊anchored-example[#:anchor "read_pipe1"]{Problems reading from a pipe}

◊example{
#!/bin/sh
# readpipe.sh
# This example contributed by Bjon Eriksson.

### shopt -s lastpipe

last="(null)"
cat $0 |
while read line
do
    echo "{$line}"
    last=$line
done

echo
echo "++++++++++++++++++++++"
printf "\nAll done, last: $last\n" #  The output of this line
                                   #+ changes if you uncomment line 5.
                                   #  (Bash, version -ge 4.2 required.)

exit 0  # End of code.
        # (Partial) output of script follows.
        # The 'echo' supplies extra brackets.

#############################################

./readpipe.sh

{#!/bin/sh}
{last="(null)"}
{cat $0 |}
{while read line}
{do}
{echo "{$line}"}
{last=$line}
{done}
{printf "nAll done, last: $lastn"}


All done, last: (null)

The variable (last) is set within the loop/subshell
but its value does not persist outside the loop.
}

The ◊code{gendiff} script, usually found in ◊fname{/usr/bin} on many
Linux distros, pipes the output of find to a while ◊code{read}
construct.

◊example{
find $1 \( -name "*$2" -o -name ".*$2" \) -print |
while read f; do
. . .
}

Tip: It is possible to paste text into the input field of a
◊code{read} (but not multiple lines!). See TODO Example A-38.

}

}

◊section{Filesystem}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "cd"]{
The familiar ◊command{cd} change directory command finds use in scripts
where execution of a command requires being in a specified directory.

◊example{
(cd /source/directory && tar cf - . ) | (cd /dest/directory && tar xpvf -)
}

The ◊code{-P} (physical) option to ◊command{cd} causes it to ignore
symbolic links.

◊command{cd -} changes to ◊code{$OLDPWD}, the previous working
directory.

Caution: The ◊command{cd} command does not function as expected when
presented with two forward slashes.

◊example{
bash$ cd //
bash$ pwd
//
}

The output should, of course, be ◊code{/}. This is a problem both from
the command-line and in a script.

}

◊definition-entry[#:name "pwd"]{
Print Working Directory. This gives the user's (or script's) current
directory (see TODO Example 15-9). The effect is identical to reading
the value of the builtin variable ◊code{$PWD}.

}

◊definition-entry[#:name "pushd, popd, dirs"]{
This command set is a mechanism for bookmarking working directories, a
means of moving back and forth through directories in an orderly
manner. A pushdown stack is used to keep track of directory
names. Options allow various manipulations of the directory stack.

◊command{pushd dir-name} pushes the path dir-name onto the directory
stack (to the top of the stack) and simultaneously changes the current
working directory to dir-name

◊command{popd} removes (pops) the top directory path name off the
directory stack and simultaneously changes the current working
directory to the directory now at the top of the stack.

◊command{dirs} lists the contents of the directory stack (compare this
with the ◊code{$DIRSTACK} variable). A successful ◊command{pushd} or
◊command{popd} will automatically invoke ◊command{dirs}.

Scripts that require various changes to the current working directory
without hard-coding the directory name changes can make good use of
these commands. Note that the implicit ◊code{$DIRSTACK} array variable,
accessible from within a script, holds the contents of the directory
stack.

◊example{
#!/bin/bash

dir1=/usr/local
dir2=/var/spool

pushd $dir1
# Will do an automatic 'dirs' (list directory stack to stdout).
echo "Now in directory `pwd`." # Uses back-quoted 'pwd'.

# Now, do some stuff in directory 'dir1'.
pushd $dir2
echo "Now in directory `pwd`."

# Now, do some stuff in directory 'dir2'.
echo "The top entry in the DIRSTACK array is $DIRSTACK."
popd
echo "Now back in directory `pwd`."

# Now, do some more stuff in directory 'dir1'.
popd
echo "Now back in original working directory `pwd`."

exit 0

# What happens if you don't 'popd' -- then exit the script?
# Which directory do you end up in? Why?
}

}

}

◊section{Variables}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
