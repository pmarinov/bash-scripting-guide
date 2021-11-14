#lang pollen

◊page-init{}
◊define-meta[page-title]{Complex Functions}
◊define-meta[page-description]{Complex Functions and Function Complexities}

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

