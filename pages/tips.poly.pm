#lang pollen

◊page-init{}
◊define-meta[page-title]{Tips}
◊define-meta[page-description]{Assorted Tips}

◊section{Ideas for more powerful scripts}

◊list-block[#:type "bullet"]{

◊list-entry{You have a problem that you want to solve by writing a
Bash script. Unfortunately, you don't know quite where to start. One
method is to plunge right in and code those parts of the script that
come easily, and write the hard parts as pseudo-code.

◊example{
#!/bin/bash

ARGCOUNT=1                     # Need name as argument.
E_WRONGARGS=65

if [ number-of-arguments is-not-equal-to "$ARGCOUNT" ]
#    ^^^^^^^^^^^^^^^^^^^ ^^^^^^^^^^^^^^^
#  Can't figure out how to code this . . .
#+ . . . so write it in pseudo-code.

then
  echo "Usage: name-of-script name"
  #            ^^^^^^^^^^^^^^     More pseudo-code.
  exit $E_WRONGARGS
fi 

. . .

exit 0


# Later on, substitute working code for the pseudo-code.

# Line 6 becomes:
if [ $# -ne "$ARGCOUNT" ]

# Line 12 becomes:
  echo "Usage: `basename $0` name"
}

For an example of using pseudo-code, see TODO the Square Root exercise.

}

◊list-entry{To keep a record of which user scripts have run during a
particular session or over a number of sessions, add the following
lines to each script you want to keep track of. This will keep a
continuing file record of the script names and invocation times.

◊example{
# Append (>>) following to end of each script tracked.

whoami>> $SAVE_FILE    # User invoking the script.
echo $0>> $SAVE_FILE   # Script name.
date>> $SAVE_FILE      # Date and time.
echo>> $SAVE_FILE      # Blank line as separator.

#  Of course, SAVE_FILE defined and exported as environmental variable in ~/.bashrc
#+ (something like ~/.scripts-run)
}

}

◊list-entry{The ◊code{>>} operator appends lines to a file. What if
you wish to prepend a line to an existing file, that is, to paste it
in at the beginning?

◊example{
file=data.txt
title="***This is the title line of data text file***"

echo $title | cat - $file >$file.new
# "cat -" concatenates stdout to $file.
#  End result is
#+ to write a new file with $title appended at *beginning*.
}

This is a simplified variant of the TODO Example 19-13 script given
earlier. And, of course, ◊command{sed} can also do this.

}

◊list-entry{A shell script may act as an embedded command inside
another shell script, a Tcl or wish script, or even a Makefile. It can
be invoked as an external shell command in a C program using the
◊code{system()} call, i.e., ◊code{system("script_name");}.

}

◊list-entry{Setting a variable to the contents of an embedded
◊command{sed} or ◊command{awk} script increases the readability of the
surrounding shell wrapper. See TODO Example A-1 and Example 15-20.

}

◊list-entry{Put together files containing your favorite and most
useful definitions and functions. As necessary, "include" one or more
of these "library files" in scripts with either the dot (◊command{.})
or ◊command{source} command.

◊example{
# SCRIPT LIBRARY
# ------ -------

# Note:
# No "#!" here.
# No "live code" either.


# Useful variable definitions

ROOT_UID=0             # Root has $UID 0.
E_NOTROOT=101          # Not root user error. 
MAXRETVAL=255          # Maximum (positive) return value of a function.
SUCCESS=0
FAILURE=-1



# Functions

Usage ()               # "Usage:" message.
{
  if [ -z "$1" ]       # No arg passed.
  then
    msg=filename
  else
    msg=$@
  fi

  echo "Usage: `basename $0` "$msg""
}  


Check_if_root ()       # Check if root running script.
{                      # From "ex39.sh" example.
  if [ "$UID" -ne "$ROOT_UID" ]
  then
    echo "Must be root to run this script."
    exit $E_NOTROOT
  fi
}  


CreateTempfileName ()  # Creates a "unique" temp filename.
{                      # From "ex51.sh" example.
  prefix=temp
  suffix=`eval date +%s`
  Tempfilename=$prefix.$suffix
}


isalpha2 ()            # Tests whether *entire string* is alphabetic.
{                      # From "isalpha.sh" example.
  [ $# -eq 1 ] || return $FAILURE

  case $1 in
  *[!a-zA-Z]*|"") return $FAILURE;;
  *) return $SUCCESS;;
  esac                 # Thanks, S.C.
}


abs ()                           # Absolute value.
{                                # Caution: Max return value = 255.
  E_ARGERR=-999999

  if [ -z "$1" ]                 # Need arg passed.
  then
    return $E_ARGERR             # Obvious error value returned.
  fi

  if [ "$1" -ge 0 ]              # If non-negative,
  then                           #
    absval=$1                    # stays as-is.
  else                           # Otherwise,
    let "absval = (( 0 - $1 ))"  # change sign.
  fi  

  return $absval
}


tolower ()             #  Converts string(s) passed as argument(s)
{                      #+ to lowercase.

  if [ -z "$1" ]       #  If no argument(s) passed,
  then                 #+ send error message
    echo "(null)"      #+ (C-style void-pointer error message)
    return             #+ and return from function.
  fi  

  echo "$@" | tr A-Z a-z
  # Translate all passed arguments ($@).

  return

# Use command substitution to set a variable to function output.
# For example:
#    oldvar="A seT of miXed-caSe LEtTerS"
#    newvar=`tolower "$oldvar"`
#    echo "$newvar"    # a set of mixed-case letters
#
# Exercise: Rewrite this function to change lowercase passed argument(s)
#           to uppercase ... toupper()  [easy].
}
}

}

◊list-entry{Use special-purpose comment headers to increase clarity
and legibility in scripts.

◊example{
## Caution.
rm -rf *.zzy   ##  The "-rf" options to "rm" are very dangerous,
               ##+ especially with wild cards.

#+ Line continuation.
#  This is line 1
#+ of a multi-line comment,
#+ and this is the final line.

#* Note.

#o List item.

#> Another point of view.
while [ "$var1" != "end" ]    #> while test "$var1" != "end"
}

}

◊list-entry{Template code for a progress bar in a script.

◊anchored-example[#:anchor "prog_bar1"]{A Progress Bar}

◊example{
#!/bin/bash
# progress-bar.sh

# Author: Dotan Barak (very minor revisions by ABS Guide author).
# Used in ABS Guide with permission (thanks!).


BAR_WIDTH=50
BAR_CHAR_START="["
BAR_CHAR_END="]"
BAR_CHAR_EMPTY="."
BAR_CHAR_FULL="="
BRACKET_CHARS=2
LIMIT=100

print_progress_bar()
{
        # Calculate how many characters will be full.
        let "full_limit = ((($1 - $BRACKET_CHARS) * $2) / $LIMIT)"

        # Calculate how many characters will be empty.
        let "empty_limit = ($1 - $BRACKET_CHARS) - ${full_limit}"

        # Prepare the bar.
        bar_line="${BAR_CHAR_START}"
        for ((j=0; j<full_limit; j++)); do
                bar_line="${bar_line}${BAR_CHAR_FULL}"
        done

        for ((j=0; j<empty_limit; j++)); do
                bar_line="${bar_line}${BAR_CHAR_EMPTY}"
        done

        bar_line="${bar_line}${BAR_CHAR_END}"

        printf "%3d%% %s" $2 ${bar_line}
}

# Here is a sample of code that uses it.
MAX_PERCENT=100
for ((i=0; i<=MAX_PERCENT; i++)); do
        #
        usleep 10000
        # ... Or run some other commands ...
        #
        print_progress_bar ${BAR_WIDTH} ${i}
        echo -en "\r"
done

echo ""

exit
}

}

◊list-entry{A particularly clever use of ◊command{if-test} constructs
is for comment blocks.

◊example{
#!/bin/bash

COMMENT_BLOCK=
#  Try setting the above variable to some value
#+ for an unpleasant surprise.

if [ $COMMENT_BLOCK ]; then

Comment block --
=================================
This is a comment line.
This is another comment line.
This is yet another comment line.
=================================

echo "This will not echo."

Comment blocks are error-free! Whee!

fi

echo "No more comments, please."

exit 0
}

Compare this with using here documents to comment out code blocks.

}

◊list-entry{Using the ◊code{$?} exit status variable, a script may
test if a parameter contains only digits, so it can be treated as an
integer.

◊example{
#!/bin/bash

SUCCESS=0
E_BADINPUT=85

test "$1" -ne 0 -o "$1" -eq 0 2>/dev/null
# An integer is either equal to 0 or not equal to 0.
# 2>/dev/null suppresses error message.

if [ $? -ne "$SUCCESS" ]
then
  echo "Usage: `basename $0` integer-input"
  exit $E_BADINPUT
fi

let "sum = $1 + 25"             # Would give error if $1 not integer.
echo "Sum = $sum"

# Any variable, not just a command-line parameter, can be tested this way.

exit 0
}

}

◊list-entry{The 0 - 255 range for function return values is a severe
limitation. Global variables and other workarounds are often
problematic. An alternative method for a function to communicate a
value back to the main body of the script is to have the function
write to stdout (usually with ◊command{echo}) the "return value," and
assign this to a variable. This is actually a variant of command
substitution.

◊anchored-example[#:anchor "ret_val1"]{Return value trickery}

◊example{
#!/bin/bash
# multiplication.sh

multiply ()                     # Multiplies params passed.
{                               # Will accept a variable number of args.

  local product=1

  until [ -z "$1" ]             # Until uses up arguments passed...
  do
    let "product *= $1"
    shift
  done

  echo $product                 #  Will not echo to stdout,
}                               #+ since this will be assigned to a variable.

mult1=15383; mult2=25211
val1=`multiply $mult1 $mult2`
# Assigns stdout (echo) of function to the variable val1.
echo "$mult1 X $mult2 = $val1"                   # 387820813

mult1=25; mult2=5; mult3=20
val2=`multiply $mult1 $mult2 $mult3`
echo "$mult1 X $mult2 X $mult3 = $val2"          # 2500

mult1=188; mult2=37; mult3=25; mult4=47
val3=`multiply $mult1 $mult2 $mult3 $mult4`
echo "$mult1 X $mult2 X $mult3 X $mult4 = $val3" # 8173300

exit 0
}

The same technique also works for alphanumeric strings. This means
that a function can "return" a non-numeric value.

◊example{
capitalize_ichar ()          #  Capitalizes initial character
{                            #+ of argument string(s) passed.

  string0="$@"               # Accepts multiple arguments.

  firstchar=${string0:0:1}   # First character.
  string1=${string0:1}       # Rest of string(s).

  FirstChar=`echo "$firstchar" | tr a-z A-Z`
                             # Capitalize first character.

  echo "$FirstChar$string1"  # Output to stdout.

}  

newstring=`capitalize_ichar "every sentence should start with a capital letter."`
echo "$newstring"          # Every sentence should start with a capital letter.
}

It is even possible for a function to "return" multiple values with
this method.

◊anchored-example[#:anchor "ret_multi"]{Even more return value
trickery}

◊example{
#!/bin/bash
# sum-product.sh
# A function may "return" more than one value.

sum_and_product ()   # Calculates both sum and product of passed args.
{
  echo $(( $1 + $2 )) $(( $1 * $2 ))
# Echoes to stdout each calculated value, separated by space.
}

echo
echo "Enter first number "
read first

echo
echo "Enter second number "
read second
echo

retval=`sum_and_product $first $second`      # Assigns output of function.
sum=`echo "$retval" | awk '{print $1}'`      # Assigns first field.
product=`echo "$retval" | awk '{print $2}'`  # Assigns second field.

echo "$first + $second = $sum"
echo "$first * $second = $product"
echo

exit 0
}

Caution: There can be only one echo statement in the function for this
to work. If you alter the previous example:

◊example{
sum_and_product ()
{
  echo "This is the sum_and_product function." # This messes things up!
  echo $(( $1 + $2 )) $(( $1 * $2 ))
}
...
retval=`sum_and_product $first $second`      # Assigns output of function.
# Now, this will not work correctly.
}

}

◊list-entry{Next in our bag of tricks are techniques for passing an
array to a function, then "returning" an array back to the main body
of the script.

Passing an array involves loading the space-separated elements of the
array into a variable with command substitution. Getting an array back
as the "return value" from a function uses the previously mentioned
strategem of echoing the array in the function, then invoking command
substitution and the ◊code{( ... )} operator to assign it to an array.

◊anchored-example[#:anchor ""]{Passing and returning arrays}

◊example{
#!/bin/bash
# array-function.sh: Passing an array to a function and ...
#                   "returning" an array from a function


Pass_Array ()
{
  local passed_array   # Local variable!
  passed_array=( `echo "$1"` )
  echo "${passed_array[@]}"
  #  List all the elements of the new array
  #+ declared and set within the function.
}


original_array=( element1 element2 element3 element4 element5 )

echo
echo "original_array = ${original_array[@]}"
#                      List all elements of original array.


# This is the trick that permits passing an array to a function.
# **********************************
argument=`echo ${original_array[@]}`
# **********************************
#  Pack a variable
#+ with all the space-separated elements of the original array.
#
# Attempting to just pass the array itself will not work.

# This is the trick that allows grabbing an array as a "return value".
# *****************************************
returned_array=( `Pass_Array "$argument"` )
# *****************************************
# Assign 'echoed' output of function to array variable.

echo "returned_array = ${returned_array[@]}"

echo "============================================================="

#  Now, try it again,
#+ attempting to access (list) the array from outside the function.
Pass_Array "$argument"

# The function itself lists the array, but ...
#+ accessing the array from outside the function is forbidden.
echo "Passed array (within function) = ${passed_array[@]}"
# NULL VALUE since the array is a variable local to the function.

echo

############################################

# And here is an even more explicit example:

ret_array ()
{
  for element in {11..20}
  do
    echo "$element "   #  Echo individual elements
  done                 #+ of what will be assembled into an array.
}

arr=( $(ret_array) )   #  Assemble into array.

echo "Capturing array \"arr\" from function ret_array () ..."
echo "Third element of array \"arr\" is ${arr[2]}."   # 13  (zero-indexed)
echo -n "Entire array is: "
echo ${arr[@]}                # 11 12 13 14 15 16 17 18 19 20

echo

exit 0

#  Nathan Coulter points out that passing arrays with elements containing
#+ whitespace breaks this example.
}

For a more elaborate example of passing arrays to functions, see
TODO Example A-10.

}

◊list-entry{Using the double-parentheses construct, it is possible to
use C-style syntax for setting and incrementing/decrementing variables
and in ◊command{for} and ◊command{while} loops. See TODO Example 11-13
and Example 11-18.

}

◊list-entry{Setting the ◊code{$PATH} and ◊code{umask} at the beginning
of a script makes it more portable -- more likely to run on a
"foreign" machine whose user may have bollixed up the ◊code{$PATH} and
◊code{umask}.

◊example{
#!/bin/bash
PATH=/bin:/usr/bin:/usr/local/bin ; export PATH
umask 022   # Files that the script creates will have 755 permission.
}

}

◊list-entry{A useful scripting technique is to repeatedly feed the
output of a filter (by piping) back to the same filter, but with a
different set of arguments and/or options. Especially suitable for
this are ◊command{tr} and ◊command{grep}.

◊example{
# From "wstrings.sh" example.

wlist=`strings "$1" | tr A-Z a-z | tr '[:space:]' Z | \
tr -cs '[:alpha:]' Z | tr -s '\173-\377' Z | tr Z ' '`
}

◊anchored-example[#:anchor "anag1"]{Fun with anagrams}

◊example{
#!/bin/bash
# agram.sh: Playing games with anagrams.

# Find anagrams of...
LETTERSET=etaoinshrdlu
FILTER='.......'       # How many letters minimum?
#       1234567

anagram "$LETTERSET" | # Find all anagrams of the letterset...
grep "$FILTER" |       # With at least 7 letters,
grep '^is' |           # starting with 'is'
grep -v 's$' |         # no plurals
grep -v 'ed$'          # no past tense verbs
# Possible to add many combinations of conditions and filters.

#  Uses "anagram" utility
#+ that is part of the author's "yawl" word list package.
#  http://ibiblio.org/pub/Linux/libs/yawl-0.3.2.tar.gz
#  http://bash.deta.in/yawl-0.3.2.tar.gz

exit 0                 # End of code.


bash$ sh agram.sh
islander
isolate
isolead
isotheral



#  Exercises:
#  ---------
#  Modify this script to take the LETTERSET as a command-line parameter.
#  Parameterize the filters in lines 11 - 13 (as with $FILTER),
#+ so that they can be specified by passing arguments to a function.

#  For a slightly different approach to anagramming,
#+ see the agram2.sh script.
}

See also TODO Example 29-4, Example 16-25, and Example A-9.

}

◊list-entry{Use "anonymous here documents" to comment out blocks of
code, to save having to individually comment out each line with a
#. See TODO Example 19-11.

}

◊list-entry{Running a script on a machine that relies on a command
that might not be installed is dangerous. Use ◊command{whatis} to
avoid potential problems with this.

◊example{
CMD=command1                 # First choice.
PlanB=command2               # Fallback option.

command_test=$(whatis "$CMD" | grep 'nothing appropriate')
#  If 'command1' not found on system , 'whatis' will return
#+ "command1: nothing appropriate."
#
#  A safer alternative is:
#     command_test=$(whereis "$CMD" | grep \/)
#  But then the sense of the following test would have to be reversed,
#+ since the $command_test variable holds content only if
#+ the $CMD exists on the system.
#     (Thanks, bojster.)


if [[ -z "$command_test" ]]  # Check whether command present.
then
  $CMD option1 option2       #  Run command1 with options.
else                         #  Otherwise,
  $PlanB                     #+ run command2. 
fi
}

}

◊list-entry{An ◊command{if-grep} test may not return expected results
in an error case, when text is output to stderr, rather that stdout.

◊example{
if ls -l nonexistent_filename | grep -q 'No such file or directory'
  then echo "File \"nonexistent_filename\" does not exist."
fi
}

Redirecting stderr to stdout fixes this.

◊example{
if ls -l nonexistent_filename 2>&1 | grep -q 'No such file or directory'
#                             ^^^^
  then echo "File \"nonexistent_filename\" does not exist."
fi

# Thanks, Chris Martin, for pointing this out.
}

}

◊list-entry{If you absolutely must access a subshell variable outside
the subshell, here's a way to do it.

◊example{
TMPFILE=tmpfile                  # Create a temp file to store the variable.

(   # Inside the subshell ...
inner_variable=Inner
echo $inner_variable
echo $inner_variable >>$TMPFILE  # Append to temp file.
)

    # Outside the subshell ...

echo; echo "-----"; echo
echo $inner_variable             # Null, as expected.
echo "-----"; echo

# Now ...
read inner_variable <$TMPFILE    # Read back shell variable.
rm -f "$TMPFILE"                 # Get rid of temp file.
echo "$inner_variable"           # It's an ugly kludge, but it works.
}

}

◊list-entry{The run-parts command is handy for running a set of
command scripts in a particular sequence, especially in combination
with cron or at.

}

◊list-entry{For doing multiple revisions on a complex script, use the
◊emphasize{rcs} Revision Control System package.

Among other benefits of this is automatically updated ID header
tags. The co command in rcs does a parameter replacement of certain
reserved key words, for example, replacing ◊command{# $Id$} in a
script with something like:

◊example{
# $Id: hello-world.sh,v 1.1 2004/10/16 02:43:05 bozo Exp $
}

}

}  ◊; list-block[#:type "bullet"]

◊section{Widgets}

It would be nice to be able to invoke X-Windows widgets from a shell
script. There happen to exist several packages that purport to do so,
namely Xscript, Xmenu, and widtools. The first two of these no longer
seem to be maintained. Fortunately, it is still possible to obtain
widtools here:

◊url[#:link "http://www.batse.msfc.nasa.gov/~mallozzi/home/software/xforms/src/widtools-2.0.tgz"]{}

Caution: The widtools (widget tools) package requires the XForms
library to be installed. Additionally, the Makefile needs some
judicious editing before the package will build on a typical Linux
system. Finally, three of the six widgets offered do not work (and, in
fact, segfault).

The dialog family of tools offers a method of calling "dialog" widgets
from a shell script. The original dialog utility works in a text
console, but its successors, gdialog, Xdialog, and kdialog use
X-Windows-based widget sets.

◊anchored-example[#:anchor "sh_wdg1"]{Widgets invoked from a shell
script}

◊example{
#!/bin/bash
# dialog.sh: Using 'gdialog' widgets.

# Must have 'gdialog' installed on your system to run this script.
# Or, you can replace all instance of 'gdialog' below with 'kdialog' ...
# Version 1.1 (corrected 04/05/05)

# This script was inspired by the following article.
#     "Scripting for X Productivity," by Marco Fioretti,
#      LINUX JOURNAL, Issue 113, September 2003, pp. 86-9.
# Thank you, all you good people at LJ.


# Input error in dialog box.
E_INPUT=85
# Dimensions of display, input widgets.
HEIGHT=50
WIDTH=60

# Output file name (constructed out of script name).
OUTFILE=$0.output

# Display this script in a text widget.
gdialog --title "Displaying: $0" --textbox $0 $HEIGHT $WIDTH



# Now, we'll try saving input in a file.
echo -n "VARIABLE=" > $OUTFILE
gdialog --title "User Input" --inputbox "Enter variable, please:" \
$HEIGHT $WIDTH 2>> $OUTFILE


if [ "$?" -eq 0 ]
# It's good practice to check exit status.
then
  echo "Executed \"dialog box\" without errors."
else
  echo "Error(s) in \"dialog box\" execution."
        # Or, clicked on "Cancel", instead of "OK" button.
  rm $OUTFILE
  exit $E_INPUT
fi



# Now, we'll retrieve and display the saved variable.
. $OUTFILE   # 'Source' the saved file.
echo "The variable input in the \"input box\" was: "$VARIABLE""


rm $OUTFILE  # Clean up by removing the temp file.
             # Some applications may need to retain this file.

exit $?

# Exercise: Rewrite this script using the 'zenity' widget set.
}

The ◊command{xmessage} command is a simple method of popping up a
message/query window. For example:

◊example{
xmessage Fatal error in script! -button exit
}

The latest entry in the widget sweepstakes is ◊command{zenity}. This
utility pops up GTK+ dialog widgets-and-windows, and it works very
nicely within a script.

◊example{
get_info ()
{
  zenity --entry       #  Pops up query window . . .
                       #+ and prints user entry to stdout.

                       #  Also try the --calendar and --scale options.
}

answer=$( get_info )   #  Capture stdout in $answer variable.

echo "User entered: "$answer""
}

For other methods of scripting with widgets, try Tk or wish (Tcl
derivatives), PerlTk (Perl with Tk extensions), tksh (ksh with Tk
extensions), XForms4Perl (Perl with XForms extensions), Gtk-Perl (Perl
with Gtk extensions), or PyQt (Python with Qt extensions).

