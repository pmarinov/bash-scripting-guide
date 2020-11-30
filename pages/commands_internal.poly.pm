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

◊definition-block[#:type "code"]{

◊definition-entry[#:name "let"]{
The ◊code{let} command carries out arithmetic operations on
variables. In many cases, it functions as a less complex version
of ◊code{expr}.

Note: ◊code{let} cannot be used for setting string variables.

◊example{
#!/bin/bash

echo

let a=11            # Same as 'a=11'
let a=a+5           # Equivalent to  let "a = a + 5"
                    # (Double quotes and spaces make it more readable.)
echo "11 + 5 = $a"  # 16

let "a <<= 3"       # Equivalent to  let "a = a << 3"
echo "\"\$a\" (=16) left-shifted 3 places = $a"
                    # 128

let "a /= 4"        # Equivalent to  let "a = a / 4"
echo "128 / 4 = $a" # 32

let "a -= 5"        # Equivalent to  let "a = a - 5"
echo "32 - 5 = $a"  # 27

let "a *=  10"      # Equivalent to  let "a = a * 10"
echo "27 * 10 = $a" # 270

let "a %= 8"        # Equivalent to  let "a = a % 8"
echo "270 modulo 8 = $a  (270 / 8 = 33, remainder $a)"
                    # 6


# Does "let" permit C-style operators?
# Yes, just as the (( ... )) double-parentheses construct does.

let a++             # C-style (post) increment.
echo "6++ = $a"     # 6++ = 7
let a--             # C-style decrement.
echo "7-- = $a"     # 7-- = 6
# Of course, ++a, etc., also allowed . . .
echo


# Trinary operator.

# Note that $a is 6, see above.
let "t = a<7?7:11"   # True
echo $t  # 7

let a++
let "t = a<7?7:11"   # False
echo $t  #     11

exit
}

Caution: The let command can, in certain contexts, return a surprising exit status.

◊example{
# Evgeniy Ivanov points out:

var=0
echo $?     # 0
            # As expected.

let var++
echo $?     # 1
            # The command was successful, so why isn't $?=0 ???
            # Anomaly!

let var++
echo $?     # 0
            # As expected.


# Likewise . . .

let var=0
echo $?     # 1
            # The command was successful, so why isn't $?=0 ???

#  However, as Jeff Gorak points out,
#+ this is part of the design spec for 'let' . . .
# "If the last ARG evaluates to 0, let returns 1;
#  let returns 0 otherwise." ['help let']
}

}

◊definition-entry[#:name "eval"]{
Combines the arguments in an expression or list of expressions and
evaluates them. Any variables within the expression are expanded. The
net result is to convert a string into a command.

◊example{
eval arg1 [arg2] ... [argN]
}

Tip: The ◊code{eval} command can be used for code generation from the
command-line or within a script.

◊example{
bash$ command_string="ps ax"
bash$ process="ps ax"
bash$ eval "$command_string" | grep "$process"
26973 pts/3    R+     0:00 grep --color ps ax
26974 pts/3    R+     0:00 ps ax
}

Each invocation of ◊code{eval} forces a re-evaluation of its
arguments.

◊example{
a='$b'
b='$c'
c=d

echo $a             # $b
                    # First level.
eval echo $a        # $c
                    # Second level.
eval eval echo $a   # d
                    # Third level.

# Thank you, E. Choroba.
}

◊anchored-example[#:anchor "eval_effect1"]{Showing the effect of eval}

◊example{
#!/bin/bash
# Exercising "eval" ...

y=`eval ls -l`  #  Similar to y=`ls -l`
echo $y         #+ but linefeeds removed because "echoed" variable is unquoted.
echo
echo "$y"       #  Linefeeds preserved when variable is quoted.

echo; echo

y=`eval df`     #  Similar to y=`df`
echo $y         #+ but linefeeds removed.

#  When LF's not preserved, it may make it easier to parse output,
#+ using utilities such as "awk".

echo
echo "==========================================================="
echo

eval "`seq 3 | sed -e 's/.*/echo var&=ABCDEFGHIJ/'`"
# var1=ABCDEFGHIJ
# var2=ABCDEFGHIJ
# var3=ABCDEFGHIJ

echo
echo "==========================================================="
echo


# Now, showing how to do something useful with "eval" . . .
# (Thank you, E. Choroba!)

version=3.4     #  Can we split the version into major and minor
                #+ part in one command?
echo "version = $version"
eval major=${version/./;minor=}     #  Replaces '.' in version by ';minor='
                                    #  The substitution yields '3; minor=4'
                                    #+ so eval does minor=4, major=3
echo Major: $major, minor: $minor   #  Major: 3, minor: 4
}

◊anchored-example[#:anchor "eval_selvar1"]{Using eval to select among
variables}

◊example{
#!/bin/bash
# arr-choice.sh

#  Passing arguments to a function to select
#+ one particular variable out of a group.

arr0=( 10 11 12 13 14 15 )
arr1=( 20 21 22 23 24 25 )
arr2=( 30 31 32 33 34 35 )
#       0  1  2  3  4  5      Element number (zero-indexed)


choose_array ()
{
  eval array_member=\${arr${array_number}[element_number]}
  #                 ^       ^^^^^^^^^^^^
  #  Using eval to construct the name of a variable,
  #+ in this particular case, an array name.

  echo "Element $element_number of array $array_number is $array_member"
} #  Function can be rewritten to take parameters.

array_number=0    # First array.
element_number=3
choose_array      # 13

array_number=2    # Third array.
element_number=4
choose_array      # 34

array_number=3    # Null array (arr3 not allocated).
element_number=4
choose_array      # (null)

# Thank you, Antonio Macchi, for pointing this out.
}

◊anchored-example[#:anchor "eval_echo1"]{Echoing the command-line
parameters}

◊example{
#!/bin/bash
# echo-params.sh

# Call this script with a few command-line parameters.
# For example:
#     sh echo-params.sh first second third fourth fifth

params=$#              # Number of command-line parameters.
param=1                # Start at first command-line param.

while [ "$param" -le "$params" ]
do
  echo -n "Command-line parameter "
  echo -n \$$param     #  Gives only the *name* of variable.
#         ^^^          #  $1, $2, $3, etc.
                       #  Why?
                       #  \$ escapes the first "$"
                       #+ so it echoes literally,
                       #+ and $param dereferences "$param" . . .
                       #+ . . . as expected.
  echo -n " = "
  eval echo \$$param   #  Gives the *value* of variable.
# ^^^^      ^^^        #  The "eval" forces the *evaluation*
                       #+ of \$$
                       #+ as an indirect variable reference.

(( param ++ ))         # On to the next.
done

exit $?

# =================================================

$ sh echo-params.sh first second third fourth fifth
Command-line parameter $1 = first
Command-line parameter $2 = second
Command-line parameter $3 = third
Command-line parameter $4 = fourth
Command-line parameter $5 = fifth
}

◊anchored-example[#:anchor "eval_logoff1"]{Forcing a log-off}

◊example{
#!/bin/bash
# Killing ppp to force a log-off.
# For dialup connection, of course.

# Script should be run as root user.

SERPORT=ttyS3
#  Depending on the hardware and even the kernel version,
#+ the modem port on your machine may be different --
#+ /dev/ttyS1 or /dev/ttyS2.


killppp="eval kill -9 `ps ax | awk '/ppp/ { print $1 }'`"
#                     -------- process ID of ppp -------

$killppp                     # This variable is now a command.


# The following operations must be done as root user.

chmod 666 /dev/$SERPORT      # Restore r+w permissions, or else what?
#  Since doing a SIGKILL on ppp changed the permissions on the serial port,
#+ we restore permissions to previous state.

rm /var/lock/LCK..$SERPORT   # Remove the serial port lock file. Why?

exit $?

# Exercises:
# ---------
# 1) Have script check whether root user is invoking it.
# 2) Do a check on whether the process to be killed
#+   is actually running before attempting to kill it.
# 3) Write an alternate version of this script based on 'fuser':
#+      if [ fuser -s /dev/modem ]; then . . .
}

◊anchored-example[#:anchor "eval_rot1"]{A version of rot13}

◊example{
#!/bin/bash
# A version of "rot13" using 'eval'.
# Compare to "rot13.sh" example.

setvar_rot_13()              # "rot13" scrambling
{
  local varname=$1 varvalue=$2
  eval $varname='$(echo "$varvalue" | tr a-z n-za-m)'
}


setvar_rot_13 var "foobar"   # Run "foobar" through rot13.
echo $var                    # sbbone

setvar_rot_13 var "$var"     # Run "sbbone" through rot13.
                             # Back to original variable.
echo $var                    # foobar

# This example by Stephane Chazelas.
# Modified by document author.

exit 0
}

Here is another example of using ◊code{eval} to evaluate a complex
expression, this one from an earlier version of YongYe's Tetris game
script.

◊example{
eval ${1}+=\"${x} ${y} \"
}

TODO Example A-53 uses ◊code{eval} to convert array elements into a
command list.

The ◊code{eval} command occurs in the older version of indirect
referencing.

◊example{
eval var=\$$var
}

Tip: The ◊code{eval} command can be used to parameterize brace
expansion.

Caution: The ◊code{eval} command can be risky, and normally should be
avoided when there exists a reasonable alternative. An ◊code{eval
$COMMANDS} executes the contents of ◊code{COMMANDS}, which may contain
such unpleasant surprises as ◊code{rm -rf *}. Running an ◊code{eval}
on unfamiliar code written by persons unknown is living dangerously.

}

◊definition-entry[#:name "set"]{

The ◊code{set} command changes the value of internal script
variables/options. One use for this is to toggle option flags which
help determine the behavior of the script. Another application for it
is to reset the positional parameters that a script sees as the result
of a command (◊code{set `command`}). The script can then parse the
fields of the command output.

◊example{
#!/bin/bash
# ex34.sh
# Script "set-test"

# Invoke this script with three command-line parameters,
# for example, "sh ex34.sh one two three".

echo
echo "Positional parameters before  set \`uname -a\` :"
echo "Command-line argument #1 = $1"
echo "Command-line argument #2 = $2"
echo "Command-line argument #3 = $3"


set `uname -a` # Sets the positional parameters to the output
               # of the command `uname -a`

echo
echo +++++
echo $_        # +++++
# Flags set in script.
echo $-        # hB
#                Anomalous behavior?
echo

echo "Positional parameters after  set \`uname -a\` :"
# $1, $2, $3, etc. reinitialized to result of `uname -a`
echo "Field #1 of 'uname -a' = $1"
echo "Field #2 of 'uname -a' = $2"
echo "Field #3 of 'uname -a' = $3"
echo \#\#\#
echo $_        # ###
echo

exit 0
}

◊anchored-example[#:anchor "set_pos2"]{Reversing the positional parameters}

More fun with positional parameters.

◊example{
#!/bin/bash
# revposparams.sh: Reverse positional parameters.
# Script by Dan Jacobson, with stylistic revisions by document author.


set a\ b c d\ e;
#     ^      ^     Spaces escaped
#       ^ ^        Spaces not escaped
OIFS=$IFS; IFS=:;
#              ^   Saving old IFS and setting new one.

echo

until [ $# -eq 0 ]
do          #      Step through positional parameters.
  echo "### k0 = "$k""     # Before
  k=$1:$k;  #      Append each pos param to loop variable.
#     ^
  echo "### k = "$k""      # After
  echo
  shift;
done

set $k  #  Set new positional parameters.
echo -
echo $# #  Count of positional parameters.
echo -
echo

for i   #  Omitting the "in list" sets the variable -- i --
        #+ to the positional parameters.
do
  echo $i  # Display new positional parameters.
done

IFS=$OIFS  # Restore IFS.

#  Question:
#  Is it necessary to set an new IFS, internal field separator,
#+ in order for this script to work properly?
#  What happens if you don't? Try it.
#  And, why use the new IFS -- a colon -- in line 17,
#+ to append to the loop variable?
#  What is the purpose of this?

exit 0

$ ./revposparams.sh

### k0 =
### k = a b

### k0 = a b
### k = c a b

### k0 = c a b
### k = d e c a b

-
3
-

d e
c
a b
}

Invoking ◊command{set} without any options or arguments simply lists
all the environmental and other variables that have been initialized.

◊example{
bash$ set
AUTHORCOPY=/home/bozo/posts
 BASH=/bin/bash
 BASH_VERSION=$'2.05.8(1)-release'
 ...
 XAUTHORITY=/home/bozo/.Xauthority
 _=/etc/bashrc
 variable22=abc
 variable23=xzy
}


◊anchored-example[#:anchor "set_rev1"]{Reassigning the positional parameters}

Using ◊code{set} with the ◊code{--} option explicitly assigns the contents of
a variable to the positional parameters. If no variable follows the --
it unsets the positional parameters.

◊example{
#!/bin/bash

variable="one two three four five"

set -- $variable
# Sets positional parameters to the contents of "$variable".

first_param=$1
second_param=$2
shift; shift        # Shift past first two positional params.
# shift 2             also works.
remaining_params="$*"

echo
echo "first parameter = $first_param"             # one
echo "second parameter = $second_param"           # two
echo "remaining parameters = $remaining_params"   # three four five

echo; echo

# Again.
set -- $variable
first_param=$1
second_param=$2
echo "first parameter = $first_param"             # one
echo "second parameter = $second_param"           # two

# ======================================================

set --
# Unsets positional parameters if no variable specified.

first_param=$1
second_param=$2
echo "first parameter = $first_param"             # (null value)
echo "second parameter = $second_param"           # (null value)

exit 0
}

See also TODO Example 11-2 and Example 16-56.

}

◊definition-entry[#:name "unset"]{
The unset command deletes a shell variable, effectively setting it to
null. Note that this command does not affect positional parameters.

◊example{
bash$ unset PATH

bash$ echo $PATH


bash$
}

"Unsetting" a variable in a script:

◊example{
#!/bin/bash
# unset.sh: Unsetting a variable.

variable=hello                       #  Initialized.
echo "variable = $variable"

unset variable                       #  Unset.
                                     #  In this particular context,
                                     #+ same effect as:   variable=
echo "(unset) variable = $variable"  #  $variable is null.

if [ -z "$variable" ]                #  Try a string-length test.
then
  echo "\$variable has zero length."
fi

exit 0
}


Note: In most contexts, an undeclared variable and one that has been
unset are equivalent. However, the ◊code{$◊escaped{◊"{"}parameter:-default◊escaped{◊"}"}} parameter
substitution construct can distinguish between the two.

}

◊definition-entry[#:name "export"]{

The ◊code{export} command makes available variables to all child
processes of the running script or shell. One important use of the
◊code{export} command is in startup files, to initialize and make accessible
environmental variables to subsequent user processes.

Caution: Unfortunately, there is no way to export variables back to
the parent process, to the process that called or invoked the script
or shell.

◊anchored-example[#:anchor "export_awk1"]{Using export to pass a
variable to an embedded awk script}

◊example{
#!/bin/bash

#  Yet another version of the "column totaler" script (col-totaler.sh)
#+ that adds up a specified column (of numbers) in the target file.
#  This uses the environment to pass a script variable to 'awk' . . .
#+ and places the awk script in a variable.


ARGS=2
E_WRONGARGS=85

if [ $# -ne "$ARGS" ] # Check for proper number of command-line args.
then
   echo "Usage: `basename $0` filename column-number"
   exit $E_WRONGARGS
fi

filename=$1
column_number=$2

#===== Same as original script, up to this point =====#

export column_number
# Export column number to environment, so it's available for retrieval.


# -----------------------------------------------
awkscript='{ total += $ENVIRON["column_number"] }
END { print total }'
# Yes, a variable can hold an awk script.
# -----------------------------------------------

# Now, run the awk script.
awk "$awkscript" "$filename"

# Thanks, Stephane Chazelas.

exit 0
}

Tip: It is possible to initialize and export variables in the same
operation, as in ◊code{export var1=xxx}.

However, in certain situations this may have a different effect than
setting a variable, then exporting it.

◊example{
bash$ export var=(a b); echo ${var[0]}
(a b)

bash$ var=(a b); export var; echo ${var[0]}
a
}

Note: A variable to be exported may require special treatment. See
TODO Example M-2.
}

◊definition-entry[#:name "declare, typeset"]{

The ◊code{declare} and ◊code{typeset} commands specify and/or restrict
properties of variables.

TODO See chapter "Typing variables: declare or typeset"
}

◊definition-entry[#:name "readonly"]{

Same as ◊code{declare -r}, sets a variable as read-only, or, in effect, as a
constant. Attempts to change the variable fail with an error
message. This is the shell analog of the C language ◊code{const} type
qualifier.

TODO See chapter "Typing variables: declare or typeset"
}

◊definition-entry[#:name "getopts"]{

This powerful tool parses command-line arguments passed to the
script. This is the Bash analog of the ◊command{getopt} external
command and the ◊code{getopt} library function familiar to C
programmers. It permits passing and concatenating multiple options [5]
and associated arguments to a script (for example ◊command{scriptname
-abc -e /usr/local}).

The ◊code{getopts} construct uses two implicit
variables. ◊code{$OPTIND} is the argument pointer (OPTion INDex) and
◊code{$OPTARG} (OPTion ARGument) the (optional) argument attached to
an option. A colon following the option name in the declaration tags
that option as having an associated argument.

A getopts construct usually comes packaged in a ◊code{while} loop,
which processes the options and arguments one at a time, then
increments the implicit ◊code{$OPTIND} variable to point to the next.

Note: The arguments passed from the command-line to the script must be
preceded by a dash (◊code{-}). It is the prefixed - that lets getopts
recognize command-line arguments as options. In fact, getopts will not
process arguments without the prefixed ◊code{-}, and will terminate
option processing at the first argument encountered lacking them.

Note: The ◊code{getopts} template differs slightly from the standard
while loop, in that it lacks condition brackets.

Note: The ◊code{getopts} construct is a highly functional replacement
for the traditional ◊code{getopt} external command.

◊example{
while getopts ":abcde:fg" Option
# Initial declaration.
# a, b, c, d, e, f, and g are the options (flags) expected.
# The : after option 'e' shows it will have an argument passed with it.
do
  case $Option in
    a ) # Do something with variable 'a'.
    b ) # Do something with variable 'b'.
    ...
    e)  # Do something with 'e', and also with $OPTARG,
        # which is the associated argument passed with option 'e'.
    ...
    g ) # Do something with variable 'g'.
  esac
done
shift $(($OPTIND - 1))
# Move argument pointer to next.

# All this is not nearly as complicated as it looks <grin>.
}

◊anchored-example[#:anchor "getopt1"]{Using getopts to read the
options/arguments passed to a script}

◊example{
#!/bin/bash
# ex33.sh: Exercising getopts and OPTIND
#          Script modified 10/09/03 at the suggestion of Bill Gradwohl.


# Here we observe how 'getopts' processes command-line arguments to script.
# The arguments are parsed as "options" (flags) and associated arguments.

# Try invoking this script with:
#   'scriptname -mn'
#   'scriptname -oq qOption' (qOption can be some arbitrary string.)
#   'scriptname -qXXX -r'
#
#   'scriptname -qr'
#+      - Unexpected result, takes "r" as the argument to option "q"
#   'scriptname -q -r'
#+      - Unexpected result, same as above
#   'scriptname -mnop -mnop'  - Unexpected result
#   (OPTIND is unreliable at stating where an option came from.)
#
#  If an option expects an argument ("flag:"), then it will grab
#+ whatever is next on the command-line.

NO_ARGS=0
E_OPTERROR=85

if [ $# -eq "$NO_ARGS" ]    # Script invoked with no command-line args?
then
  echo "Usage: `basename $0` options (-mnopqrs)"
  exit $E_OPTERROR          # Exit and explain usage.
                            # Usage: scriptname -options
                            # Note: dash (-) necessary
fi


while getopts ":mnopq:rs" Option
do
  case $Option in
    m     ) echo "Scenario #1: option -m-   [OPTIND=${OPTIND}]";;
    n | o ) echo "Scenario #2: option -$Option-   [OPTIND=${OPTIND}]";;
    p     ) echo "Scenario #3: option -p-   [OPTIND=${OPTIND}]";;
    q     ) echo "Scenario #4: option -q-\
                  with argument \"$OPTARG\"   [OPTIND=${OPTIND}]";;
    #  Note that option 'q' must have an associated argument,
    #+ otherwise it falls through to the default.
    r | s ) echo "Scenario #5: option -$Option-";;
    *     ) echo "Unimplemented option chosen.";;   # Default.
  esac
done

shift $(($OPTIND - 1))
#  Decrements the argument pointer so it points to next argument.
#  $1 now references the first non-option item supplied on the command-line
#+ if one exists.

exit $?

#   As Bill Gradwohl states,
#  "The getopts mechanism allows one to specify:  scriptname -mnop -mnop
#+  but there is no reliable way to differentiate what came
#+ from where by using OPTIND."
#  There are, however, workarounds.
}

}

}

◊section{Script Behavior}

◊definition-block[#:type "code"]{
◊definition-entry[#:name "surce, . (dot command)"]{
This command, when invoked from the command-line, executes a
script. Within a script, a ◊code{source file-name} loads the file
◊fname{file-name}. Sourcing a file (dot-command) imports code into the
script, appending to the script (same effect as the ◊code{#include}
directive in a C program). The net result is the same as if the
"sourced" lines of code were physically present in the body of the
script. This is useful in situations when multiple scripts use a
common data file or function library.

◊example{
#!/bin/bash
#  Note that this example must be invoked with bash, i.e., bash ex38.sh
#+ not  sh ex38.sh !

. data-file    # Load a data file.
# Same effect as "source data-file", but more portable.

#  The file "data-file" must be present in current working directory,
#+ since it is referred to by its basename.

# Now, let's reference some data from that file.

echo "variable1 (from data-file) = $variable1"
echo "variable3 (from data-file) = $variable3"

let "sum = $variable2 + $variable4"
echo "Sum of variable2 + variable4 (from data-file) = $sum"
echo "message1 (from data-file) is \"$message1\""
#                                  Escaped quotes
echo "message2 (from data-file) is \"$message2\""

print_message This is the message-print function in the data-file.

exit $?
}

File data-file for example above. Must be present in same directory.

◊example{
# This is a data file loaded by a script.
# Files of this type may contain variables, functions, etc.
# It loads with a 'source' or '.' command from a shell script.

# Let's initialize some variables.

variable1=23
variable2=474
variable3=5
variable4=97

message1="Greetings from *** line $LINENO *** of the data file!"
message2="Enough for now. Goodbye."

print_message ()
{   # Echoes any message passed to it.

  if [ -z "$1" ]
  then
    return 1 # Error, if argument missing.
  fi

  echo

  until [ -z "$1" ]
  do             # Step through arguments passed to function.
    echo -n "$1" # Echo args one at a time, suppressing line feeds.
    echo -n " "  # Insert spaces between words.
    shift        # Next one.
  done

  echo

  return 0
}
}

If the sourced file is itself an executable script, then it will run,
then return control to the script that called it. A sourced executable
script may use a ◊code{return} for this purpose.

Arguments may be (optionally) passed to the sourced file as positional
parameters: ◊code{source $filename $arg1 arg2}

}

◊definition-entry[#:name "exit"]{
Unconditionally terminates a script. The ◊code{exit} command may
optionally take an integer argument, which is returned to the shell as
the exit status of the script. It is good practice to end all but the
simplest scripts with an ◊code{exit 0}, indicating a successful
run. ◊footnote{Technically, an exit only terminates the process (or
shell) in which it is running, not the parent process.}

Note: If a script terminates with an exit lacking an argument, the
exit status of the script is the exit status of the last command
executed in the script, not counting the ◊code{exit}. This is
equivalent to an ◊code{exit $?}.

Note: An ◊code{exit} command may also be used to terminate a subshell.

}

◊definition-entry[#:name "exec"]{ This shell builtin replaces the
current process with a specified command. Normally, when the shell
encounters a command, it forks off a child process to actually execute
the command. Using the ◊code{exec} builtin, the shell does not fork,
and the command exec'ed replaces the shell. When used in a script,
therefore, it forces an exit from the script when the exec'ed command
terminates ◊footnote{Unless the exec is used to reassign file
descriptors. TODO See I/O redirect}

◊example{
#!/bin/bash

exec echo "Exiting \"$0\" at line $LINENO."   # Exit from script here.
# $LINENO is an internal Bash variable set to the line number it's on.

# ----------------------------------
# The following lines never execute.

echo "This echo fails to echo."

exit 99                       #  This script will not exit here.
                              #  Check exit value after script terminates
                              #+ with an 'echo $?'.
                              #  It will *not* be 99.
}

An exec also serves to reassign file descriptors. For example,
◊code{exec <zzz-file} replaces ◊fname{stdin} with the file
◊fname{zzz-file}.

Note: The ◊code{-exec} option to find is not the same as the
◊code{exec} shell builtin.

}

◊definition-entry[#:name "shopt"]{
This command permits changing shell options on the fly (see TODO
Example 25-1 and Example 25-2). It often appears in the Bash startup
files, but also has its uses in scripts. Needs version 2 or later of
Bash.

◊example{
shopt -s cdspell
# Allows minor misspelling of directory names with 'cd'
# Option -s sets, -u unsets.

cd /hpme  # Oops! Mistyped '/home'.
pwd       # /home
          # The shell corrected the misspelling.
}

}

◊definition-entry[#:name "caller"]{
Putting a ◊code{caller} command inside a function echoes to
◊fname{stdout} information about the caller of that function.

◊example{
#!/bin/bash

function1 ()
{
  # Inside function1 ().
  caller 0   # Tell me about it.
}

function1    # Line 9 of script.

# 9 main test.sh
# ^                 Line number that the function was called from.
#   ^^^^            Invoked from "main" part of script.
#        ^^^^^^^    Name of calling script.

caller 0     # Has no effect because it's not inside a function.
}

A ◊code{caller} command can also return caller information from a script
sourced within another script. Analogous to a function, this is a
"subroutine call."

You may find this command useful in debugging.

}

}

◊section{Commands}

◊definition-block[#:type "code"]{
◊definition-entry[#:name "true"]{
A command that returns a successful (zero) exit status, but does
nothing else.

◊example{
bash$ true
bash$ echo $?
0
}

◊anchored-example[#:anchor "endless1"]{Endless loop}

◊example{
while true   # alias for ":"
do
   operation-1
   operation-2
   ...
   operation-n
   # Need a way to break out of loop or script will hang.
done
}

}

◊definition-entry[#:name "false"]{
A command that returns an unsuccessful exit status, but does nothing
else.

◊example{
bash$ false
bash$ echo $?
1
}

◊anchored-example[#:anchor "null_loop1"]{Null loop}

◊example{
# Testing "false"
if false
then
  echo "false evaluates \"true\""
else
  echo "false evaluates \"false\""
fi
# false evaluates "false"


# Looping while "false" (null loop)
while false
do
   # The following code will not execute.
   operation-1
   operation-2
   ...
   operation-n
   # Nothing happens!
done
}

}

◊definition-entry[#:name "type [cmd]"]{
Similar to the ◊code{which} external command, ◊code{type} cmd
identifies "cmd."  Unlike ◊code{which}, ◊code{type} is a Bash
builtin. The useful ◊code{-a} option to type identifies keywords and
builtins, and also locates system commands with identical names.

◊example{
bash$ type '['
[ is a shell builtin
bash$ type -a '['
[ is a shell builtin
 [ is /usr/bin/[


bash$ type type
type is a shell builtin

bash$ type find
find is /usr/bin/find
}

}

◊definition-entry[#:name "hash [cmd]"]{
Records the path name of specified commands -- in the shell hash table
-- so the shell or script will not need to search the ◊code{$PATH} on
subsequent calls to those commands. When ◊code{hash} is called with no
arguments, it simply lists the commands that have been hashed. The
◊code{-r} option resets the hash table.

Example output with some recently invoked commands:
◊example{
$ hash
hits	command
   1	/usr/bin/which
   1	/bin/stty
   2	/usr/bin/pulseaudio
   7	/usr/bin/git
   6	/usr/bin/info
}

}

◊definition-entry[#:name "bind"]{
The bind builtin displays or modifies ◊emphasize{readline} key
bindings. ◊footnote{The ◊emphasize{readline} library is what Bash uses
for reading input in an interactive shell.}

}

◊definition-entry[#:name "help"]{
Gets a short usage summary of a shell builtin. This is the counterpart
to ◊code{whatis}, but for builtins. The display of help information
got a much-needed update in the version 4 release of Bash.

◊example{
bash$ help exit
exit: exit [n]
    Exit the shell with a status of N.  If N is omitted, the exit status
    is that of the last command executed.
}

}

}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
