#lang pollen

◊page-init{}
◊define-meta[page-title]{Local Variables}
◊define-meta[page-description]{Local Variables in functions}


◊section{What makes a variable local?}

A variable declared as ◊command{local} is one that is visible only
within the block of code in which it appears. It has local scope. In a
function, a local variable has meaning only within that function
block.

◊anchored-example[#:anchor "var_scope1"]{Local variable visibility}

◊example{
#!/bin/bash
# ex62.sh: Global and local variables inside a function.

func ()
{
  local loc_var=23       # Declared as local variable.
  echo                   # Uses the 'local' builtin.
  echo "\"loc_var\" in function = $loc_var"
  global_var=999         # Not declared as local.
                         # Therefore, defaults to global. 
  echo "\"global_var\" in function = $global_var"
}  

func

# Now, to see if local variable "loc_var" exists outside the function.

echo
echo "\"loc_var\" outside function = $loc_var"
                                      # $loc_var outside function = 
                                      # No, $loc_var not visible globally.
echo "\"global_var\" outside function = $global_var"
                                      # $global_var outside function = 999
                                      # $global_var is visible globally.
echo				      

exit 0
#  In contrast to C, a Bash variable declared inside a function
#+ is local ONLY if declared as such.
}

Caution: Before a function is called, all variables declared within
the function are invisible outside the body of the function, not just
those explicitly declared as local.

◊example{
#!/bin/bash

func ()
{
global_var=37    #  Visible only within the function block
                 #+ before the function has been called. 
}                #  END OF FUNCTION

echo "global_var = $global_var"  # global_var =
                                 #  Function "func" has not yet been called,
                                 #+ so $global_var is not visible here.

func
echo "global_var = $global_var"  # global_var = 37
                                 # Has been set by function call.
}

Note: When declaring and setting a local variable in a single command,
apparently the order of operations is to first set the variable, and
only afterwards restrict it to local scope. This is reflected in the
return value.

◊example{
#!/bin/bash

echo "==OUTSIDE Function (global)=="
t=$(exit 1)
echo $?      # 1
             # As expected.
echo

function0 ()
{

echo "==INSIDE Function=="
echo "Global"
t0=$(exit 1)
echo $?      # 1
             # As expected.

echo
echo "Local declared & assigned in same command."
local t1=$(exit 1)
echo $?      # 0
             # Unexpected!
#  Apparently, the variable assignment takes place before
#+ the local declaration.
#+ The return value is for the latter.

echo
echo "Local declared, then assigned (separate commands)."
local t2
t2=$(exit 1)
echo $?      # 1
             # As expected.

}

function0
}

Note: a local variable declared in a function is also visible to
functions called by the parent function.

◊example{
#!/bin/bash

function1 ()
{
  local func1var=20

  echo "Within function1, \$func1var = $func1var."

  function2
}

function2 ()
{
  echo "Within function2, \$func1var = $func1var."
}

function1

exit 0


# Output of the script:

# Within function1, $func1var = 20.
# Within function2, $func1var = 20.
}

This is documented in the Bash manual: "Local can only be used within
a function; it makes the variable name have a visible scope restricted
to that function and its children."  The ABS Guide author considers
this behavior to be a bug.

◊section{Local variables and recursion}

Recursion is an interesting and sometimes useful form of
self-reference. Herbert Mayer defines it as ". . . expressing an
algorithm by using a simpler version of that same algorithm . . ."

Consider a definition defined in terms of itself, ◊footnote{Otherwise
known as "redundancy".} an expression implicit in its own expression,
◊footnote{Otherwise known as "tautology".} a snake swallowing its own
tail, ◊footnote{Otherwise known as a "metaphor".} or . . . a function
that calls itself. ◊footnote{Otherwise known as a "recursive function".}

◊anchored-example[#:anchor "func_rec1"]{Demonstration of a simple
recursive function}

◊example{
#!/bin/bash
# recursion-demo.sh
# Demonstration of recursion.

RECURSIONS=9   # How many times to recurse.
r_count=0      # Must be global. Why?

recurse ()
{
  var="$1"

  while [ "$var" -ge 0 ]
  do
    echo "Recursion count = "$r_count"  +-+  \$var = "$var""
    (( var-- )); (( r_count++ ))
    recurse "$var"  #  Function calls itself (recurses)
  done              #+ until what condition is met?
}

recurse $RECURSIONS

exit $?
}

◊anchored-example[#:anchor "func_rec2"]{Another simple demonstration}

◊example{
#!/bin/bash
# recursion-def.sh
# A script that defines "recursion" in a rather graphic way.

RECURSIONS=10
r_count=0
sp=" "

define_recursion ()
{
  ((r_count++))
  sp="$sp"" "
  echo -n "$sp"
  echo "\"The act of recurring ... \""   # Per 1913 Webster's dictionary.

  while [ $r_count -le $RECURSIONS ]
  do
    define_recursion
  done
}

echo
echo "Recursion: "
define_recursion
echo

exit $?
}

Local variables are a useful tool for writing recursive code, but this
practice generally involves a great deal of computational overhead and
is definitely not recommended in a shell script.

◊anchored-example[#:anchor "func_rec3"]{Recursion, using a local
variable}

◊example{
#!/bin/bash

#               factorial
#               ---------


# Does bash permit recursion?
# Well, yes, but...
# It's so slow that you gotta have rocks in your head to try it.


MAX_ARG=5
E_WRONG_ARGS=85
E_RANGE_ERR=86


if [ -z "$1" ]
then
  echo "Usage: `basename $0` number"
  exit $E_WRONG_ARGS
fi

if [ "$1" -gt $MAX_ARG ]
then
  echo "Out of range ($MAX_ARG is maximum)."
  #  Let's get real now.
  #  If you want greater range than this,
  #+ rewrite it in a Real Programming Language.
  exit $E_RANGE_ERR
fi  

fact ()
{
  local number=$1
  #  Variable "number" must be declared as local,
  #+ otherwise this doesn't work.
  if [ "$number" -eq 0 ]
  then
    factorial=1    # Factorial of 0 = 1.
  else
    let "decrnum = number - 1"
    fact $decrnum  # Recursive function call (the function calls itself).
    let "factorial = $number * $?"
  fi

  return $factorial
}

fact $1
echo "Factorial of $1 is $?."

exit 0
}

Also see TODO Example A-15 for an example of recursion in a script. Be
aware that recursion is resource-intensive and executes slowly, and is
therefore generally not appropriate in a script.

Note: Too many levels of recursion may crash a script with a segfault.

◊example{
#!/bin/bash

#  Warning: Running this script could possibly lock up your system!
#  If you're lucky, it will segfault before using up all available memory.

recursive_function ()		   
{
echo "$1"     # Makes the function do something, and hastens the segfault.
(( $1 < $2 )) && recursive_function $(( $1 + 1 )) $2;
#  As long as 1st parameter is less than 2nd,
#+ increment 1st and recurse.
}

recursive_function 1 50000  # Recurse 50,000 levels!
#  Most likely segfaults (depending on stack size, set by ulimit -m).

#  Recursion this deep might cause even a C program to segfault,
#+ by using up all the memory allotted to the stack.


echo "This will probably not print."
exit 0  # This script will not exit normally.
}
