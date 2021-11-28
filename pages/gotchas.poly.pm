#lang pollen

◊page-init{}
◊define-meta[page-title]{Gotchas}
◊define-meta[page-description]{Gotchas}

◊quotation[#:author "Puccini"]{Turandot: Gli enigmi sono tre, la morte una!

Caleph: No, no! Gli enigmi sono tre, una la vita!}

Here are some (non-recommended!) scripting practices that will bring
excitement into an otherwise dull life.

◊list-block[#:type "bullet"]{

◊list-entry{Assigning reserved words or characters to variable names.

◊example{
case=value0       # Causes problems.
23skidoo=value1   # Also problems.
# Variable names starting with a digit are reserved by the shell.
# Try _23skidoo=value1. Starting variables with an underscore is okay.

# However . . .   using just an underscore will not work.
_=25
echo $_           # $_ is a special variable set to last arg of last command.
# But . . .       _ is a valid function name!

xyz((!*=value2    # Causes severe problems.
# As of version 3 of Bash, periods are not allowed within variable names.
}

}

◊list-entry{Using a hyphen or other reserved characters in a variable
name (or function name).

◊example{
var-1=23
# Use 'var_1' instead.

function-whatever ()   # Error
# Use 'function_whatever ()' instead.

 
# As of version 3 of Bash, periods are not allowed within function names.
function.whatever ()   # Error
# Use 'functionWhatever ()' instead.
}

}

◊list-entry{Using the same name for a variable and a function. This
can make a script difficult to understand.

◊example{
do_something ()
{
  echo "This function does something with \"$1\"."
}

do_something=do_something

do_something do_something

# All this is legal, but highly confusing.
}

}

◊list-entry{Using whitespace inappropriately. In contrast to other
programming languages, Bash can be quite finicky about whitespace.

◊example{
var1 = 23   # 'var1=23' is correct.
# On line above, Bash attempts to execute command "var1"
# with the arguments "=" and "23".
	
let c = $a - $b   # Instead:   let c=$a-$b   or   let "c = $a - $b"

if [ $a -le 5]    # if [ $a -le 5 ]   is correct.
#           ^^      if [ "$a" -le 5 ]   is even better.
                  # [[ $a -le 5 ]] also works.
}

}

◊list-entry{Not terminating with a semicolon the final command in a
code block within curly brackets.

◊example{
{ ls -l; df; echo "Done." }
# bash: syntax error: unexpected end of file

{ ls -l; df; echo "Done."; }
#                        ^     ### Final command needs semicolon.
}

}

◊list-entry{Assuming uninitialized variables (variables before a value
is assigned to them) are "zeroed out". An uninitialized variable has a
value of null, not zero.

◊example{
#!/bin/bash

echo "uninitialized_var = $uninitialized_var"
# uninitialized_var =

# However . . .
# if $BASH_VERSION ≥ 4.2; then

if [[ ! -v uninitialized_var ]]
then
  uninitialized_var=0   # Initialize it to zero!
fi
}

}

◊list-entry{Mixing up ◊code{=} and ◊code{-eq} in a test. Remember,
◊code{=} is for comparing literal variables and ◊code{-eq} for
integers.

◊example{
if [ "$a" = 273 ]      # Is $a an integer or string?
if [ "$a" -eq 273 ]    # If $a is an integer.

# Sometimes you can interchange -eq and = without adverse consequences.
# However . . .


a=273.0   # Not an integer.
	   
if [ "$a" = 273 ]
then
  echo "Comparison works."
else  
  echo "Comparison does not work."
fi    # Comparison does not work.

# Same with   a=" 273"  and a="0273".


# Likewise, problems trying to use "-eq" with non-integer values.
	   
if [ "$a" -eq 273.0 ]
then
  echo "a = $a"
fi  # Aborts with an error message.  
# test.sh: [: 273.0: integer expression expected
}

}

◊list-entry{Misusing string comparison operators.

◊example{
#!/bin/bash
# bad-op.sh: Trying to use a string comparison on integers.

echo
number=1

#  The following while-loop has two errors:
#+ one blatant, and the other subtle.

while [ "$number" < 5 ]    # Wrong! Should be:  while [ "$number" -lt 5 ]
do
  echo -n "$number "
  let "number += 1"
done  
#  Attempt to run this bombs with the error message:
#+ bad-op.sh: line 10: 5: No such file or directory
#  Within single brackets, "<" must be escaped,
#+ and even then, it's still wrong for comparing integers.

echo "---------------------"

while [ "$number" \< 5 ]    #  1 2 3 4
do                          #
  echo -n "$number "        #  It *seems* to work, but . . .
  let "number += 1"         #+ it actually does an ASCII comparison,
done                        #+ rather than a numerical one.

echo; echo "---------------------"

# This can cause problems. For example:

lesser=5
greater=105

if [ "$greater" \< "$lesser" ]
then
  echo "$greater is less than $lesser"
fi                          # 105 is less than 5
#  In fact, "105" actually is less than "5"
#+ in a string comparison (ASCII sort order).

echo

exit 0
}

}

◊list-entry{Attempting to use let to set string variables.

◊example{
let "a = hello, you"
echo "$a"   # 0
}

}

◊list-entry{Sometimes variables within "test" brackets (◊code{[ ]}) need to
be quoted (double quotes). Failure to do so may cause unexpected
behavior. See TODO Example 7-6, Example 20-5, and Example 9-6.

}

◊list-entry{Quoting a variable containing whitespace prevents
splitting. Sometimes this produces unintended consequences.

}

◊list-entry{Commands issued from a script may fail to execute because
the script owner lacks execute permission for them. If a user cannot
invoke a command from the command-line, then putting it into a script
will likewise fail. Try changing the attributes of the command in
question, perhaps even setting the suid bit (as root, of course).

}

◊list-entry{Attempting to use - as a redirection operator (which it is
not) will usually result in an unpleasant surprise.

◊example{
command1 2> - | command2
# Trying to redirect error output of command1 into a pipe . . .
# . . . will not work.	

command1 2>& - | command2  # Also futile.

}

}

◊list-entry{Using Bash version 2+ functionality may cause a bailout
with error messages. Older Linux machines may have version 1.XX of
Bash as the default installation.

◊example{
#!/bin/bash

minimum_version=2
# Since Chet Ramey is constantly adding features to Bash,
# you may set $minimum_version to 2.XX, 3.XX, or whatever is appropriate.
E_BAD_VERSION=80

if [ "$BASH_VERSION" \< "$minimum_version" ]
then
  echo "This script works only with Bash, version $minimum or greater."
  echo "Upgrade strongly recommended."
  exit $E_BAD_VERSION
fi

...
}

}

◊list-entry{Using Bash-specific functionality in a Bourne shell script
(◊fname{#!/bin/sh}) on a non-Linux machine may cause unexpected
behavior. A Linux system usually aliases ◊command{sh} to
◊command{bash}, but this does not necessarily hold true for a generic
UNIX machine.

}

◊list-entry{Using undocumented features in Bash turns out to be a
dangerous practice. In previous releases of this book there were
several scripts that depended on the "feature" that, although the
maximum value of an exit or return value was 255, that limit did not
apply to negative integers. Unfortunately, in version 2.05b and later,
that loophole disappeared. See TODO Example 24-9.

}

◊list-entry{In certain contexts, a misleading exit status may be
returned. This may occur when setting a local variable within a
function or when assigning an arithmetic value to a variable.

}

◊list-entry{The exit status of an arithmetic expression is not
equivalent to an error code.

◊example{
var=1 && ((--var)) && echo $var
#        ^^^^^^^^^ Here the and-list terminates with exit status 1.
#                     $var doesn't echo!
echo $?   # 1
}

}

◊list-entry{A script with DOS-type newlines (◊code{\r\n}) will fail to
execute, since ◊code{#!/bin/bash\r\n} is not recognized, not the same
as the expected ◊code{#!/bin/bash\n}. The fix is to convert the script
to UNIX-style newlines.

◊example{
#!/bin/bash

echo "Here"

unix2dos $0    # Script changes itself to DOS format.
chmod 755 $0   # Change back to execute permission.
               # The 'unix2dos' command removes execute permission.

./$0           # Script tries to run itself again.
               # But it won't work as a DOS file.

echo "There"

exit 0
}

}

◊list-entry{A shell script headed by ◊code{#!/bin/sh} will not run in
full Bash-compatibility mode. Some Bash-specific functions might be
disabled. Scripts that need complete access to all the Bash-specific
extensions should start with ◊code{#!/bin/bash}.

}

◊list-entry{Putting whitespace in front of the terminating limit
string of a here document will cause unexpected behavior in a script.

}

◊list-entry{Putting more than one ◊command{echo} statement in a function whose
output is captured.

◊example{
add2 ()
{
  echo "Whatever ... "   # Delete this line!
  let "retval = $1 + $2"
    echo $retval
    }

    num1=12
    num2=43
    echo "Sum of $num1 and $num2 = $(add2 $num1 $num2)"

#   Sum of 12 and 43 = Whatever ... 
#   55

#        The "echoes" concatenate.
}

See TODO this will not work

}

◊list-entry{A script may not export variables back to its parent
process, the shell, or to the environment. Just as we learned in
biology, a child process can inherit from a parent, but not vice
versa.

◊example{
WHATEVER=/home/bozo
export WHATEVER
exit 0

bash$ echo $WHATEVER

bash$
}

Sure enough, back at the command prompt, ◊code{$WHATEVER} remains
unset.

}

◊list-entry{Setting and manipulating variables in a subshell, then
attempting to use those same variables outside the scope of the
subshell will result an unpleasant surprise.

◊anchored-example[#:anchor "sh_pfalls1"]{Subshell Pitfalls}

◊example{
#!/bin/bash
# Pitfalls of variables in a subshell.

outer_variable=outer
echo
echo "outer_variable = $outer_variable"
echo

(
# Begin subshell

echo "outer_variable inside subshell = $outer_variable"
inner_variable=inner  # Set
echo "inner_variable inside subshell = $inner_variable"
outer_variable=inner  # Will value change globally?
echo "outer_variable inside subshell = $outer_variable"

# Will 'exporting' make a difference?
#    export inner_variable
#    export outer_variable
# Try it and see.

# End subshell
)

echo
echo "inner_variable outside subshell = $inner_variable"  # Unset.
echo "outer_variable outside subshell = $outer_variable"  # Unchanged.
echo

exit 0

# What happens if you uncomment lines 19 and 20?
# Does it make a difference?
}

}

◊list-entry{Piping echo output to a read may produce unexpected
results. In this scenario, the read acts as if it were running in a
subshell. Instead, use the set command (as in TODO Example 15-18).

◊anchored-example[#:anchor "echo_to_read1"]{Piping the output of echo
to a read}

◊example{
#!/bin/bash
#  badread.sh:
#  Attempting to use 'echo and 'read'
#+ to assign variables non-interactively.

#   shopt -s lastpipe

a=aaa
b=bbb
c=ccc

echo "one two three" | read a b c
# Try to reassign a, b, and c.

echo
echo "a = $a"  # a = aaa
echo "b = $b"  # b = bbb
echo "c = $c"  # c = ccc
# Reassignment failed.

### However . . .
##  Uncommenting line 6:
#   shopt -s lastpipe
##+ fixes the problem!
### This is a new feature in Bash, version 4.2.

# ------------------------------

# Try the following alternative.

var=`echo "one two three"`
set -- $var
a=$1; b=$2; c=$3

echo "-------"
echo "a = $a"  # a = one
echo "b = $b"  # b = two
echo "c = $c"  # c = three 
# Reassignment succeeded.

# ------------------------------

#  Note also that an echo to a 'read' works within a subshell.
#  However, the value of the variable changes *only* within the subshell.

a=aaa          # Starting all over again.
b=bbb
c=ccc

echo; echo
echo "one two three" | ( read a b c;
echo "Inside subshell: "; echo "a = $a"; echo "b = $b"; echo "c = $c" )
# a = one
# b = two
# c = three
echo "-----------------"
echo "Outside subshell: "
echo "a = $a"  # a = aaa
echo "b = $b"  # b = bbb
echo "c = $c"  # c = ccc
echo

exit 0
}

In fact, piping to any loop can cause a similar problem.

◊example{
# Loop piping troubles.
#  This example by Anthony Richardson,
#+ with addendum by Wilbert Berendsen.


foundone=false
find $HOME -type f -atime +30 -size 100k |
while true
do
   read f
   echo "$f is over 100KB and has not been accessed in over 30 days"
   echo "Consider moving the file to archives."
   foundone=true
   # ------------------------------------
     echo "Subshell level = $BASH_SUBSHELL"
   # Subshell level = 1
   # Yes, we're inside a subshell.
   # ------------------------------------
done
   
#  foundone will always be false here since it is
#+ set to true inside a subshell
if [ $foundone = false ]
then
   echo "No files need archiving."
fi

# =====================Now, here is the correct way:=================

foundone=false
for f in $(find $HOME -type f -atime +30 -size 100k)  # No pipe here.
do
   echo "$f is over 100KB and has not been accessed in over 30 days"
   echo "Consider moving the file to archives."
   foundone=true
done
   
if [ $foundone = false ]
then
   echo "No files need archiving."
fi

# ==================And here is another alternative==================

#  Places the part of the script that reads the variables
#+ within a code block, so they share the same subshell.
#  Thank you, W.B.

find $HOME -type f -atime +30 -size 100k | {
     foundone=false
     while read f
     do
       echo "$f is over 100KB and has not been accessed in over 30 days"
       echo "Consider moving the file to archives."
       foundone=true
     done

     if ! $foundone
     then
       echo "No files need archiving."
     fi
}

}

A lookalike problem occurs when trying to write the stdout of a
◊command{tail -f} piped to ◊command{grep}.

◊example{
tail -f /var/log/messages | grep "$ERROR_MSG" >> error.log
#  The "error.log" file will not have anything written to it.
#  This results from grep buffering its output.
#  The fix is to add the "--line-buffered" parameter to grep.
}

}

◊list-entry{Using "suid" commands within scripts is risky, as it may
compromise system security.

(Setting the suid permission on the script itself has no effect in
Linux and most other UNIX flavors.)

}

◊list-entry{Using shell scripts for CGI programming may be
problematic. Shell script variables are not "typesafe," and this can
cause undesirable behavior as far as CGI is concerned. Moreover, it is
difficult to "cracker-proof" shell scripts.

}

◊list-entry{Bash does not handle the double slash (◊code{//}) string
correctly.

}

◊list-entry{Bash scripts written for Linux or BSD systems may need
fixups to run on a commercial UNIX machine. Such scripts often employ
the GNU set of commands and filters, which have greater functionality
than their generic UNIX counterparts. This is particularly true of
such text processing utilites as ◊command{tr}.

}

◊list-entry{Sadly, updates to Bash itself have broken older scripts
that used to work perfectly fine. Let us recall how risky it is to use
undocumented Bash features.

}

◊quotation[#:author "A.J. Lamb and H.W. Petrie"]{
Danger is near thee --

Beware, beware, beware, beware.

Many brave hearts are asleep in the deep.

So beware --

Beware.
}


}
