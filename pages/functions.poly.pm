#lang pollen

◊page-init{}
◊define-meta[page-title]{Functions}
◊define-meta[page-description]{Functions}

Like "real" programming languages, Bash has functions, though in a
somewhat limited implementation. A function is a subroutine, a code
block that implements a set of operations, a "black box" that performs
a specified task. Wherever there is repetitive code, when a task
repeats with only slight variations in procedure, then consider using
a function.

◊example{
function function_name {
command...
}
}

or

◊example{
function_name () {
command...
}
}

This second form will cheer the hearts of C programmers (and is more portable).

Note: A function may be "compacted" into a single line.

◊example{
fun () { echo "This is a function"; echo; }
#                                 ^     ^
}

In this case, however, a semicolon must follow the final command in
the function.

◊example{
fun () { echo "This is a function"; echo } # Error!
#                                       ^

fun2 () { echo "Even a single-command function? Yes!"; }
#
}

◊anchored-example[#:anchor "func_simple1"]{Simple functions}

Functions are called, triggered, simply by invoking their names. A
function call is equivalent to a command.

◊example{
#!/bin/bash
# ex59.sh: Exercising functions (simple).

JUST_A_SECOND=1

funky ()
{ # This is about as simple as functions get.
  echo "This is a funky function."
  echo "Now exiting funky function."
} # Function declaration must precede call.


fun ()
{ # A somewhat more complex function.
  i=0
  REPEATS=30

  echo
  echo "And now the fun really begins."
  echo

  sleep $JUST_A_SECOND    # Hey, wait a second!
  while [ $i -lt $REPEATS ]
  do
    echo "----------FUNCTIONS---------->"
    echo "<------------ARE-------------"
    echo "<------------FUN------------>"
    echo
    let "i+=1"
  done
}

  # Now, call the functions.

funky
fun

exit $?
}

The function definition must precede the first call to it. There is no
method of "declaring" the function, as, for example, in C.

◊example{
f1
# Will give an error message, since function "f1" not yet defined.

declare -f f1      # This doesn't help either.
f1                 # Still an error message.

# However...


f1 ()
{
  echo "Calling function \"f2\" from within function \"f1\"."
  f2
}

f2 ()
{
  echo "Function \"f2\"."
}

f1  #  Function "f2" is not actually called until this point,
    #+ although it is referenced before its definition.
    #  This is permissible.
}

Note: Functions may not be empty!

◊example{
#!/bin/bash
# empty-function.sh

empty ()
{
}

exit 0  # Will not exit here!

# $ sh empty-function.sh
# empty-function.sh: line 6: syntax error near unexpected token ◊escaped{◊"}"}
# empty-function.sh: line 6: ◊escaped{◊"}"}

# $ echo $?
# 2


# Note that a function containing only comments is empty.

func ()
{
  # Comment 1.
  # Comment 2.
  # This is still an empty function.
  # Thank you, Mark Bova, for pointing this out.
}
# Results in same error message as above.


# However ...

not_quite_empty ()
{
  illegal_command
} #  A script containing this function will *not* bomb
  #+ as long as the function is not called.

not_empty ()
{
  :
} # Contains a : (null command), and this is okay.
}

It is even possible to nest a function within another function,
although this is not very useful.

◊example{
f1 ()
{

  f2 () # nested
  {
    echo "Function \"f2\", inside \"f1\"."
  }

}

f2  #  Gives an error message.
    #  Even a preceding "declare -f f2" wouldn't help.

echo

f1  #  Does nothing, since calling "f1" does not automatically call "f2".
f2  #  Now, it's all right to call "f2",
    #+ since its definition has been made visible by calling "f1".
}

Function declarations can appear in unlikely places, even where a
command would otherwise go.

◊example{
ls -l | foo() { echo "foo"; }  # Permissible, but useless.



if [ "$USER" = bozo ]
then
  bozo_greet ()   # Function definition embedded in an if/then construct.
  {
    echo "Hello, Bozo."
  }
fi

bozo_greet        # Works only for Bozo, and other users get an error.



# Something like this might be useful in some contexts.
NO_EXIT=1   # Will enable function definition below.

[[ $NO_EXIT -eq 1 ]] && exit() { true; }     # Function definition in an "and-list".
# If $NO_EXIT is 1, declares "exit ()".
# This disables the "exit" builtin by aliasing it to "true".

exit  # Invokes "exit ()" function, not "exit" builtin.



# Or, similarly:
filename=file1

[ -f "$filename" ] &&
foo () { rm -f "$filename"; echo "File "$filename" deleted."; } ||
foo () { echo "File "$filename" not found."; touch bar; }

foo
}

Function names can take strange forms.

◊example{
  _(){ for i in {1..10}; do echo -n "$FUNCNAME"; done; echo; }
# ^^^         No space between function name and parentheses.
#             This doesn't always work. Why not?

# Now, let's invoke the function.
  _         # __________
#             ^^^^^^^^^^   10 underscores (10 x function name)!
# A "naked" underscore is an acceptable function name.


# In fact, a colon is likewise an acceptable function name.

:(){ echo ":"; }; :

# Of what use is this?
# It's a devious way to obfuscate the code in a script.
}

See also TODO Example A-56

Note: What happens when different versions of the same function appear
in a script?

◊example{
#  As Yan Chen points out,
#  when a function is defined multiple times,
#  the final version is what is invoked.
#  This is not, however, particularly useful.

func ()
{
  echo "First version of func ()."
}

func ()
{
  echo "Second version of func ()."
}

func   # Second version of func ().

exit $?

#  It is even possible to use functions to override
#+ or preempt system commands.
#  Of course, this is *not* advisable.
}
