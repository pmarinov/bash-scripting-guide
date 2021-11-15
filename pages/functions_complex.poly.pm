#lang pollen

◊page-init{}
◊define-meta[page-title]{Complex Functions}
◊define-meta[page-description]{Complex Functions and Function Complexities}

◊section{Function arguments}

Functions may process arguments passed to them and return an exit
status to the script for further processing.

◊example{
function_name $arg1 $arg2
}

The function refers to the passed arguments by position (as if they
were positional parameters), that is, ◊code{$1}, ◊code{$2}, and so
forth.

◊anchored-example[#:anchor "func_param1"]{Function Taking Parameters}

◊example{
#!/bin/bash
# Functions and parameters

DEFAULT=default                             # Default param value.

func2 () {
   if [ -z "$1" ]                           # Is parameter #1 zero length?
   then
     echo "-Parameter #1 is zero length.-"  # Or no parameter passed.
   else
     echo "-Parameter #1 is \"$1\".-"
   fi

   variable=${1-$DEFAULT}                   #  What does
   echo "variable = $variable"              #+ parameter substitution show?
                                            #  ---------------------------
                                            #  It distinguishes between
                                            #+ no param and a null param.

   if [ "$2" ]
   then
     echo "-Parameter #2 is \"$2\".-"
   fi

   return 0
}

echo
   
echo "Nothing passed."   
func2                          # Called with no params
echo


echo "Zero-length parameter passed."
func2 ""                       # Called with zero-length param
echo

echo "Null parameter passed."
func2 "$uninitialized_param"   # Called with uninitialized param
echo

echo "One parameter passed."   
func2 first           # Called with one param
echo

echo "Two parameters passed."   
func2 first second    # Called with two params
echo

echo "\"\" \"second\" passed."
func2 "" second       # Called with zero-length first parameter
echo                  # and ASCII string as a second one.

exit 0
}

Important: The ◊command{shift} command works on arguments passed to
functions (see TODO Example 36-18).

But, what about command-line arguments passed to the script? Does a
function see them? Well, let's clear up the confusion.

◊anchored-example[#:anchor "func_param2"]{Functions and command-line
args passed to the script}

◊example{
#!/bin/bash
# func-cmdlinearg.sh
#  Call this script with a command-line argument,
#+ something like $0 arg1.


func ()

{
echo "$1"   # Echoes first arg passed to the function.
}           # Does a command-line arg qualify?

echo "First call to function: no arg passed."
echo "See if command-line arg is seen."
func
# No! Command-line arg not seen.

echo "============================================================"
echo
echo "Second call to function: command-line arg passed explicitly."
func $1
# Now it's seen!

exit 0
}

In contrast to certain other programming languages, shell scripts
normally pass only value parameters to functions. Variable names
(which are actually pointers), if passed as parameters to functions,
will be treated as string literals. Functions interpret their
arguments literally.

Indirect variable references (see TODO Example 37-2) provide a clumsy sort
of mechanism for passing variable pointers to functions.

◊anchored-example[#:anchor "func_param3"]{Passing an indirect
reference to a function}

◊example{
#!/bin/bash
# ind-func.sh: Passing an indirect reference to a function.

echo_var ()
{
echo "$1"
}

message=Hello
Hello=Goodbye

echo_var "$message"        # Hello
# Now, let's pass an indirect reference to the function.
echo_var "${!message}"     # Goodbye

echo "-------------"

# What happens if we change the contents of "hello" variable?
Hello="Hello, again!"
echo_var "$message"        # Hello
echo_var "${!message}"     # Hello, again!

exit 0
}

The next logical question is whether parameters can be dereferenced
after being passed to a function.

◊anchored-example[#:anchor "func_deref1"]{Dereferencing a parameter
passed to a function}

◊example{
#!/bin/bash
# dereference.sh
# Dereferencing parameter passed to a function.
# Script by Bruce W. Clare.

dereference ()
{
     y=\$"$1"   # Name of variable (not value!).
     echo $y    # $Junk

     x=`eval "expr \"$y\" "`
     echo $1=$x
     eval "$1=\"Some Different Text \""  # Assign new value.
}

Junk="Some Text"
echo $Junk "before"    # Some Text before

dereference Junk
echo $Junk "after"     # Some Different Text after

exit 0
}

◊anchored-example[#:anchor "func_deref2"]{Again, dereferencing a
parameter passed to a function}

◊example{
#!/bin/bash
# ref-params.sh: Dereferencing a parameter passed to a function.
#                (Complex Example)

ITERATIONS=3  # How many times to get input.
icount=1

my_read () {
  #  Called with my_read varname,
  #+ outputs the previous value between brackets as the default value,
  #+ then asks for a new value.

  local local_var

  echo -n "Enter a value "
  eval 'echo -n "[$'$1'] "'  #  Previous value.
# eval echo -n "[\$$1] "     #  Easier to understand,
                             #+ but loses trailing space in user prompt.
  read local_var
  [ -n "$local_var" ] && eval $1=\$local_var

  # "And-list": if "local_var" then set "$1" to its value.
}

echo

while [ "$icount" -le "$ITERATIONS" ]
do
  my_read var
  echo "Entry #$icount = $var"
  let "icount += 1"
  echo
done  


# Thanks to Stephane Chazelas for providing this instructive example.

exit 0
}

◊section{Exit and Return}

◊definition-block[#:type "variables"]{

◊definition-entry[#:name "exit status"]{
Functions return a value, called an exit status. This is analogous to
the exit status returned by a command. The exit status may be
explicitly specified by a ◊command{return} statement, otherwise it is
the exit status of the last command in the function (0 if successful,
and a non-zero error code if not). This exit status may be used in the
script by referencing it as ◊code{$?}. This mechanism effectively
permits script functions to have a "return value" similar to C
functions.

}

◊definition-entry[#:name "return"]{
Terminates a function. A ◊command{return} command optionally takes an
integer argument, which is returned to the calling script as the "exit
status" of the function, and this exit status is assigned to the
variable ◊code{$?}.

The ◊command{return} command is a Bash builtin.

}

}

◊anchored-example[#:anchor "max_of_2"]{Maximum of two numbers}

◊example{
#!/bin/bash
# max.sh: Maximum of two integers.

E_PARAM_ERR=250    # If less than 2 params passed to function.
EQUAL=251          # Return value if both params equal.
#  Error values out of range of any
#+ params that might be fed to the function.

max2 ()             # Returns larger of two numbers.
{                   # Note: numbers compared must be less than 250.
if [ -z "$2" ]
then
  return $E_PARAM_ERR
fi

if [ "$1" -eq "$2" ]
then
  return $EQUAL
else
  if [ "$1" -gt "$2" ]
  then
    return $1
  else
    return $2
  fi
fi
}

max2 33 34
return_val=$?

if [ "$return_val" -eq $E_PARAM_ERR ]
then
  echo "Need to pass two parameters to the function."
elif [ "$return_val" -eq $EQUAL ]
  then
    echo "The two numbers are equal."
else
    echo "The larger of the two numbers is $return_val."
fi  

  
exit 0

#  Exercise (easy):
#  ---------------
#  Convert this to an interactive script,
#+ that is, have the script ask for input (two numbers).
}

Tip: For a function to return a string or array, use a dedicated
variable.

◊example{
count_lines_in_etc_passwd()
{
  [[ -r /etc/passwd ]] && REPLY=$(echo $(wc -l < /etc/passwd))
  #  If /etc/passwd is readable, set REPLY to line count.
  #  Returns both a parameter value and status information.
  #  The 'echo' seems unnecessary, but . . .
  #+ it removes excess whitespace from the output.
}

if count_lines_in_etc_passwd
then
  echo "There are $REPLY lines in /etc/passwd."
else
  echo "Cannot count lines in /etc/passwd."
fi
}

◊anchored-example[#:anchor "roman_num1"]{Converting numbers to Roman
numerals}

◊example{
#!/bin/bash

# Arabic number to Roman numeral conversion
# Range: 0 - 200
# It's crude, but it works.

# Extending the range and otherwise improving the script is left as an exercise.

# Usage: roman number-to-convert

LIMIT=200
E_ARG_ERR=65
E_OUT_OF_RANGE=66

if [ -z "$1" ]
then
  echo "Usage: `basename $0` number-to-convert"
  exit $E_ARG_ERR
fi  

num=$1
if [ "$num" -gt $LIMIT ]
then
  echo "Out of range!"
  exit $E_OUT_OF_RANGE
fi  

to_roman ()   # Must declare function before first call to it.
{
number=$1
factor=$2
rchar=$3
let "remainder = number - factor"
while [ "$remainder" -ge 0 ]
do
  echo -n $rchar
  let "number -= factor"
  let "remainder = number - factor"
done  

return $number
       # Exercises:
       # ---------
       # 1) Explain how this function works.
       #    Hint: division by successive subtraction.
       # 2) Extend to range of the function.
       #    Hint: use "echo" and command-substitution capture.
}
   

to_roman $num 100 C
num=$?
to_roman $num 90 LXXXX
num=$?
to_roman $num 50 L
num=$?
to_roman $num 40 XL
num=$?
to_roman $num 10 X
num=$?
to_roman $num 9 IX
num=$?
to_roman $num 5 V
num=$?
to_roman $num 4 IV
num=$?
to_roman $num 1 I
# Successive calls to conversion function!
# Is this really necessary??? Can it be simplified?

echo

exit
}

See also TODO Example 11-29.

Important: The largest positive integer a function can return is
255. The return command is closely tied to the concept of exit status,
which accounts for this particular limitation. Fortunately, there are
various workarounds for those situations requiring a large integer
return value from a function.

◊anchored-example[#:anchor "large_return1"]{Testing large return
values in a function}

◊example{
#!/bin/bash
# return-test.sh

# The largest positive value a function can return is 255.

return_test ()         # Returns whatever passed to it.
{
  return $1
}

return_test 27         # o.k.
echo $?                # Returns 27.
  
return_test 255        # Still o.k.
echo $?                # Returns 255.

return_test 257        # Error!
echo $?                # Returns 1 (return code for miscellaneous error).

# =========================================================
return_test -151896    # Do large negative numbers work?
echo $?                # Will this return -151896?
                       # No! It returns 168.
#  Version of Bash before 2.05b permitted
#+ large negative integer return values.
#  It happened to be a useful feature.
#  Newer versions of Bash unfortunately plug this loophole.
#  This may break older scripts.
#  Caution!
# =========================================================

exit 0
}

A workaround for obtaining large integer "return values" is to simply
assign the "return value" to a global variable.

◊example{
Return_Val=   # Global variable to hold oversize return value of function.

alt_return_test ()
{
  fvar=$1
  Return_Val=$fvar
  return   # Returns 0 (success).
}

alt_return_test 1
echo $?                              # 0
echo "return value = $Return_Val"    # 1

alt_return_test 256
echo "return value = $Return_Val"    # 256

alt_return_test 257
echo "return value = $Return_Val"    # 257

alt_return_test 25701
echo "return value = $Return_Val"    #25701
}

A more elegant method is to have the function echo its "return value
to stdout," and then capture it by command substitution. See the
discussion of this in TODO Section 36.7.

◊anchored-example[#:anchor "large_num2"]{Comparing two large integers}

◊example{
#!/bin/bash
# max2.sh: Maximum of two LARGE integers.

#  This is the previous "max.sh" example,
#+ modified to permit comparing large integers.

EQUAL=0             # Return value if both params equal.
E_PARAM_ERR=-99999  # Not enough params passed to function.
#           ^^^^^^    Out of range of any params that might be passed.

max2 ()             # "Returns" larger of two numbers.
{
if [ -z "$2" ]
then
  echo $E_PARAM_ERR
  return
fi

if [ "$1" -eq "$2" ]
then
  echo $EQUAL
  return
else
  if [ "$1" -gt "$2" ]
  then
    retval=$1
  else
    retval=$2
  fi
fi

echo $retval        # Echoes (to stdout), rather than returning value.
                    # Why?
}


return_val=$(max2 33001 33997)
#            ^^^^             Function name
#                 ^^^^^ ^^^^^ Params passed
#  This is actually a form of command substitution:
#+ treating a function as if it were a command,
#+ and assigning the stdout of the function to the variable "return_val."


# ========================= OUTPUT ========================
if [ "$return_val" -eq "$E_PARAM_ERR" ]
  then
  echo "Error in parameters passed to comparison function!"
elif [ "$return_val" -eq "$EQUAL" ]
  then
    echo "The two numbers are equal."
else
    echo "The larger of the two numbers is $return_val."
fi
# =========================================================
  
exit 0

#  Exercises:
#  ---------
#  1) Find a more elegant way of testing
#+    the parameters passed to the function.
#  2) Simplify the if/then structure at "OUTPUT."
#  3) Rewrite the script to take input from command-line parameters.
}

Here is another example of capturing a function "return value."
Understanding it requires some knowledge of ◊command{awk}.

◊example{
month_length ()  # Takes month number as an argument.
{                # Returns number of days in month.
monthD="31 28 31 30 31 30 31 31 30 31 30 31"  # Declare as local?
echo "$monthD" | awk '{ print $'"${1}"' }'    # Tricky.
#                             ^^^^^^^^^
# Parameter passed to function  ($1 -- month number), then to awk.
# Awk sees this as "print $1 . . . print $12" (depending on month number)
# Template for passing a parameter to embedded awk script:
#                                 $'"${script_parameter}"'

#    Here's a slightly simpler awk construct:
#    echo $monthD | awk -v month=$1 '{print $(month)}'
#    Uses the -v awk option, which assigns a variable value
#+   prior to execution of the awk program block.
#    Thank you, Rich.

#  Needs error checking for correct parameter range (1-12)
#+ and for February in leap year.
}

# ----------------------------------------------
# Usage example:
month=4        # April, for example (4th month).
days_in=$(month_length $month)
echo $days_in  # 30
# ----------------------------------------------
}

See also TODO Example A-7 and Example A-37.

Exercise: Using what we have just learned, extend the previous Roman
numerals example to accept arbitrarily large input.

◊section{Redirection}

A function is essentially a code block, which means its stdin can be
redirected (as in TODO Example 3-1).

◊anchored-example[#:anchor "real_user_name1"]{Real name from username}

◊example{
#!/bin/bash
# realname.sh
#
# From username, gets "real name" from /etc/passwd.


ARGCOUNT=1       # Expect one arg.
E_WRONGARGS=85

file=/etc/passwd
pattern=$1

if [ $# -ne "$ARGCOUNT" ]
then
  echo "Usage: `basename $0` USERNAME"
  exit $E_WRONGARGS
fi  

file_excerpt ()    #  Scan file for pattern,
{                  #+ then print relevant portion of line.
  while read line  # "while" does not necessarily need [ condition ]
  do
    echo "$line" | grep $1 | awk -F":" '{ print $5 }'
    # Have awk use ":" delimiter.
  done
} <$file  # Redirect into function's stdin.

file_excerpt $pattern

# Yes, this entire script could be reduced to
#       grep PATTERN /etc/passwd | awk -F":" '{ print $5 }'
# or
#       awk -F: '/PATTERN/ {print $5}'
# or
#       awk -F: '($1 == "username") { print $5 }' # real name from username
# However, it might not be as instructive.

exit 0
}

There is an alternate, and perhaps less confusing method of
redirecting a function's stdin. This involves redirecting the stdin to
an embedded bracketed code block within the function.

◊example{
# Instead of:
Function ()
{
 ...
 } < file

# Try this:
Function ()
{
  {
    ...
   } < file
}

# Similarly,

Function ()  # This works.
{
  {
   echo $*
  } | tr a b
}

Function ()  # This doesn't work.
{
  echo $*
} | tr a b   # A nested code block is mandatory here.
}

Note: See TODO Emmanuel Rouat's sample ◊fname{bashrc} file contains
some instructive examples of functions.
