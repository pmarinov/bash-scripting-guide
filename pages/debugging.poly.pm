#lang pollen

◊page-init{}
◊define-meta[page-title]{Debugging}
◊define-meta[page-description]{Debugging}

◊quotation[#:author "Brian Kernighan"]{Debugging is twice as hard as
writing the code in the first place. Therefore, if you write the code
as cleverly as possible, you are, by definition, not smart enough to
debug it.}

◊section{Overview}

The Bash shell contains no built-in debugger, and only bare-bones
debugging-specific commands and constructs. Syntax errors or outright
typos in the script generate cryptic error messages that are often of
no help in debugging a non-functional script.

◊anchored-example[#:anchor "buggy1"]{A buggy script}

◊example{
#!/bin/bash
# ex74.sh

# This is a buggy script.
# Where, oh where is the error?

a=37

if [$a -gt 27 ]
then
  echo $a
fi  

exit $?   # 0! Why?
}

Output from script:

◊example{
./ex74.sh: [37: command not found
}

What's wrong with the above script? Hint: after the ◊command{if}.

◊anchored-example[#:anchor "missing_kword1"]{Missing keyword}

◊example{
#!/bin/bash
# missing-keyword.sh
# What error message will this script generate? And why?

for a in 1 2 3
do
  echo "$a"
# done     # Required keyword 'done' commented out in line 8.

exit 0     # Will not exit here!

# === #

# From command line, after script terminates:
  echo $?    # 2
}

Output from script:

◊example{
missing-keyword.sh: line 10: syntax error: unexpected end of file
}

Note that the error message does not necessarily reference the line in
which the error occurs, but the line where the Bash interpreter
finally becomes aware of the error.

Error messages may disregard comment lines in a script when reporting
the line number of a syntax error.

What if the script executes, but does not work as expected? This is
the all too familiar logic error.

◊anchored-example[#:anchor "buggy2"]{test24: another buggy script}

◊example{
#!/bin/bash

#  This script is supposed to delete all filenames in current directory
#+ containing embedded spaces.
#  It doesn't work.
#  Why not?


badname=`ls | grep ' '`

# Try this:
# echo "$badname"

rm "$badname"

exit 0
}

Try to find out what's wrong with TODO Example 32-3 by uncommenting
the ◊command{echo "$badname"} line. Echo statements are useful for
seeing whether what you expect is actually what you get.

In this particular case, ◊command{rm "$badname"} will not give the
desired results because ◊code{$badname} should not be quoted. Placing
it in quotes ensures that ◊command{rm} has only one argument (it will
match only one filename). A partial fix is to remove to quotes from
◊code{$badname} and to reset ◊code{$IFS} to contain only a newline,
◊command{IFS=$'\n'}. However, there are simpler ways of going about
it.

◊example{
# Correct methods of deleting filenames containing spaces.
rm *\ *
rm *" "*
rm *' '*
}

Summarizing the symptoms of a buggy script,

◊list-block[#:type "bullet"]{

◊list-entry{It bombs with a "syntax error" message, or}

◊list-entry{It runs, but does not work as expected (logic error).}

◊list-entry{It runs, works as expected, but has nasty side effects
(logic bomb).}

}

Tools for debugging non-working scripts include

◊list-block[#:type "bullet"]{

◊list-entry{Inserting echo statements at critical points in the script
to trace the variables, and otherwise give a snapshot of what is going
on.

Tip: Even better is an echo that echoes only when debug is on.

◊example{
### debecho (debug-echo), by Stefano Falsetto ###
### Will echo passed parameters only if DEBUG is set to a value. ###
debecho () {
  if [ ! -z "$DEBUG" ]; then
     echo "$1" >&2
     #         ^^^ to stderr
  fi
}

DEBUG=on
Whatever=whatnot
debecho $Whatever   # whatnot

DEBUG=
Whatever=notwhat
debecho $Whatever   # (Will not echo.)
}

}

◊list-entry{Using the tee filter to check processes or data flows at
critical points.}

◊list-entry{Setting option flags ◊code{-n -v -x}

◊command{sh -n scriptname} checks for syntax errors without actually
running the script. This is the equivalent of inserting ◊command{set
-n} or ◊command{set -o noexec} into the script. Note that certain
types of syntax errors can slip past this check.

◊command{sh -v scriptname} echoes each command before executing
it. This is the equivalent of inserting ◊command{set -v} or
◊command{set -o verbose} in the script.

The ◊code{-n} and ◊code{-v} flags work well together. ◊command{sh -nv
scriptname} gives a verbose syntax check.

◊command{sh -x scriptname} echoes the result each command, but in an
abbreviated manner. This is the equivalent of inserting ◊code{set -x}
or ◊code{set -o xtrace} in the script.

Inserting ◊command{set -u} or ◊command{set -o nounset} in the script
runs it, but gives an unbound variable error message and aborts the
script.

◊example{
set -u   # Or   set -o nounset

# Setting a variable to null will not trigger the error/abort.
# unset_var=

echo $unset_var   # Unset (and undeclared) variable.

echo "Should not echo!"

# sh t2.sh
# t2.sh: line 6: unset_var: unbound variable
}

}

◊list-entry{Using an "assert" function to test a variable or condition
at critical points in a script. (This is an idea borrowed from C.)

◊anchored-example[#:anchor "assert1"]{Testing a condition with an
assert}

◊example{
#!/bin/bash
# assert.sh

#######################################################################
assert ()                 #  If condition false,
{                         #+ exit from script
                          #+ with appropriate error message.
  E_PARAM_ERR=98
  E_ASSERT_FAILED=99


  if [ -z "$2" ]          #  Not enough parameters passed
  then                    #+ to assert() function.
    return $E_PARAM_ERR   #  No damage done.
  fi

  lineno=$2

  if [ ! $1 ] 
  then
    echo "Assertion failed:  \"$1\""
    echo "File \"$0\", line $lineno"    # Give name of file and line number.
    exit $E_ASSERT_FAILED
  # else
  #   return
  #   and continue executing the script.
  fi  
} # Insert a similar assert() function into a script you need to debug.    
#######################################################################


a=5
b=4
condition="$a -lt $b"     #  Error message and exit from script.
                          #  Try setting "condition" to something else
                          #+ and see what happens.

assert "$condition" $LINENO
# The remainder of the script executes only if the "assert" does not fail.


# Some commands.
# Some more commands . . .
echo "This statement echoes only if the \"assert\" does not fail."
# . . .
# More commands . . .

exit $?
}

}

◊list-entry{Using the ◊code{$LINENO} variable and the ◊command{caller}
builtin.

}

◊list-entry{Trapping at exit.

The ◊command{exit} command in a script triggers a signal 0, terminating the
process, that is, the script itself. It is often useful to trap
the exit, forcing a "printout" of variables, for example. The trap
must be the first command in the script.

Note: By convention, ◊command{signal 0} is assigned to exit.

}

}

◊section{Trapping signals}

The command ◊command{trap} specifies an action on receipt of a signal;
also useful for debugging.

A signal is a message sent to a process, either by the kernel or
another process, telling it to take some specified action (usually to
terminate). For example, hitting a Control-C sends a user interrupt,
an INT signal, to a running program.

A simple instance:

◊example{
trap '' 2
# Ignore interrupt 2 (Control-C), with no action specified. 

trap 'echo "Control-C disabled."' 2
# Message when Control-C pressed.
}

◊anchored-example[#:anchor "trap_exit1"]{Trapping at exit}

◊example{
#!/bin/bash
# Hunting variables with a trap.

trap 'echo Variable Listing --- a = $a  b = $b' EXIT
#  EXIT is the name of the signal generated upon exit from a script.
#
#  The command specified by the "trap" doesn't execute until
#+ the appropriate signal is sent.

echo "This prints before the \"trap\" --"
echo "even though the script sees the \"trap\" first."
echo

a=39

b=36

exit 0
#  Note that commenting out the 'exit' command makes no difference,
#+ since the script exits in any case after running out of commands.
}

◊anchored-example[#:anchor "cleanup_ctrlc1"]{Cleaning up after
Control-C}

◊example{
#!/bin/bash
# logon.sh: A quick 'n dirty script to check whether you are on-line yet.

umask 177  # Make sure temp files are not world readable.


TRUE=1
LOGFILE=/var/log/messages
#  Note that $LOGFILE must be readable
#+ (as root, chmod 644 /var/log/messages).
TEMPFILE=temp.$$
#  Create a "unique" temp file name, using process id of the script.
#     Using 'mktemp' is an alternative.
#     For example:
#     TEMPFILE=`mktemp temp.XXXXXX`
KEYWORD=address
#  At logon, the line "remote IP address xxx.xxx.xxx.xxx"
#                      appended to /var/log/messages.
ONLINE=22
USER_INTERRUPT=13
CHECK_LINES=100
#  How many lines in log file to check.

trap 'rm -f $TEMPFILE; exit $USER_INTERRUPT' TERM INT
#  Cleans up the temp file if script interrupted by control-c.

echo

while [ $TRUE ]  #Endless loop.
do
  tail -n $CHECK_LINES $LOGFILE> $TEMPFILE
  #  Saves last 100 lines of system log file as temp file.
  #  Necessary, since newer kernels generate many log messages at log on.
  search=`grep $KEYWORD $TEMPFILE`
  #  Checks for presence of the "IP address" phrase,
  #+ indicating a successful logon.

  if [ ! -z "$search" ] #  Quotes necessary because of possible spaces.
  then
     echo "On-line"
     rm -f $TEMPFILE    #  Clean up temp file.
     exit $ONLINE
  else
     echo -n "."        #  The -n option to echo suppresses newline,
                        #+ so you get continuous rows of dots.
  fi

  sleep 1  
done  


#  Note: if you change the KEYWORD variable to "Exit",
#+ this script can be used while on-line
#+ to check for an unexpected logoff.

# Exercise: Change the script, per the above note,
#           and prettify it.

exit 0


# Nick Drage suggests an alternate method:

while true
  do ifconfig ppp0 | grep UP 1> /dev/null && echo "connected" && exit 0
  echo -n "."   # Prints dots (.....) until connected.
  sleep 2
done

# Problem: Hitting Control-C to terminate this process may be insufficient.
#+         (Dots may keep on echoing.)
# Exercise: Fix this.



# Stephane Chazelas has yet another alternative:

CHECK_INTERVAL=1

while ! tail -n 1 "$LOGFILE" | grep -q "$KEYWORD"
do echo -n .
   sleep $CHECK_INTERVAL
done
echo "On-line"

# Exercise: Discuss the relative strengths and weaknesses
#           of each of these various approaches.
}

◊anchored-example[#:anchor "prog_bar1"]{A Simple Implementation of a
Progress Bar}

◊example{
#! /bin/bash
# progress-bar2.sh
# Author: Graham Ewart (with reformatting by ABS Guide author).
# Used in ABS Guide with permission (thanks!).

# Invoke this script with bash. It doesn't work with sh.

interval=1
long_interval=10

{
     trap "exit" SIGUSR1
     sleep $interval; sleep $interval
     while true
     do
       echo -n '.'     # Use dots.
       sleep $interval
     done; } &         # Start a progress bar as a background process.

pid=$!
trap "echo !; kill -USR1 $pid; wait $pid"  EXIT        # To handle ^C.

echo -n 'Long-running process '
sleep $long_interval
echo ' Finished!'

kill -USR1 $pid
wait $pid              # Stop the progress bar.
trap EXIT

exit $?
}

Note: The DEBUG argument to ◊command{trap} causes a specified action
to execute after every command in a script. This permits tracing
variables, for example.

◊anchored-example[#:anchor "tracing_var1"]{Tracing a variable}

◊example{
#!/bin/bash

trap 'echo "VARIABLE-TRACE> \$variable = \"$variable\""' DEBUG
# Echoes the value of $variable after every command.

variable=29; line=$LINENO

echo "  Just initialized \$variable to $variable in line number $line."

let "variable *= 3"; line=$LINENO
echo "  Just multiplied \$variable by 3 in line number $line."

exit 0

#  The "trap 'command1 . . . command2 . . .' DEBUG" construct is
#+ more appropriate in the context of a complex script,
#+ where inserting multiple "echo $variable" statements might be
#+ awkward and time-consuming.

# Thanks, Stephane Chazelas for the pointer.


Output of script:

VARIABLE-TRACE> $variable = ""
VARIABLE-TRACE> $variable = "29"
  Just initialized $variable to 29.
VARIABLE-TRACE> $variable = "29"
VARIABLE-TRACE> $variable = "87"
  Just multiplied $variable by 3.
VARIABLE-TRACE> $variable = "87"
}

Of course, the ◊command{trap} command has other uses aside from
debugging, such as disabling certain keystrokes within a script (see
TODO Example A-43).

◊anchored-example[#:anchor "tracing_var2"]{Running multiple processes
(on an SMP box)}

◊example{
#!/bin/bash
# parent.sh
# Running multiple processes on an SMP box.
# Author: Tedman Eng

#  This is the first of two scripts,
#+ both of which must be present in the current working directory.




LIMIT=$1         # Total number of process to start
NUMPROC=4        # Number of concurrent threads (forks?)
PROCID=1         # Starting Process ID
echo "My PID is $$"

function start_thread() {
        if [ $PROCID -le $LIMIT ] ; then
                ./child.sh $PROCID&
                let "PROCID++"
        else
           echo "Limit reached."
           wait
           exit
        fi
}

while [ "$NUMPROC" -gt 0 ]; do
        start_thread;
        let "NUMPROC--"
done


while true
do

trap "start_thread" SIGRTMIN

done

exit 0



# ======== Second script follows ========


#!/bin/bash
# child.sh
# Running multiple processes on an SMP box.
# This script is called by parent.sh.
# Author: Tedman Eng

temp=$RANDOM
index=$1
shift
let "temp %= 5"
let "temp += 4"
echo "Starting $index  Time:$temp" "$@"
sleep ${temp}
echo "Ending $index"
kill -s SIGRTMIN $PPID

exit 0


# ======================= SCRIPT AUTHOR'S NOTES ======================= #
#  It's not completely bug free.
#  I ran it with limit = 500 and after the first few hundred iterations,
#+ one of the concurrent threads disappeared!
#  Not sure if this is collisions from trap signals or something else.
#  Once the trap is received, there's a brief moment while executing the
#+ trap handler but before the next trap is set.  During this time, it may
#+ be possible to miss a trap signal, thus miss spawning a child process.

#  No doubt someone may spot the bug and will be writing 
#+ . . . in the future.



# ===================================================================== #



# ----------------------------------------------------------------------#



#################################################################
# The following is the original script written by Vernia Damiano.
# Unfortunately, it doesn't work properly.
#################################################################

#!/bin/bash

#  Must call script with at least one integer parameter
#+ (number of concurrent processes).
#  All other parameters are passed through to the processes started.


INDICE=8        # Total number of process to start
TEMPO=5         # Maximum sleep time per process
E_BADARGS=65    # No arg(s) passed to script.

if [ $# -eq 0 ] # Check for at least one argument passed to script.
then
  echo "Usage: `basename $0` number_of_processes [passed params]"
  exit $E_BADARGS
fi

NUMPROC=$1              # Number of concurrent process
shift
PARAMETRI=( "$@" )      # Parameters of each process

function avvia() {
         local temp
         local index
         temp=$RANDOM
         index=$1
         shift
         let "temp %= $TEMPO"
         let "temp += 1"
         echo "Starting $index Time:$temp" "$@"
         sleep ${temp}
         echo "Ending $index"
         kill -s SIGRTMIN $$
}

function parti() {
         if [ $INDICE -gt 0 ] ; then
              avvia $INDICE "${PARAMETRI[@]}" &
                let "INDICE--"
         else
                trap : SIGRTMIN
         fi
}

trap parti SIGRTMIN

while [ "$NUMPROC" -gt 0 ]; do
         parti;
         let "NUMPROC--"
done

wait
trap - SIGRTMIN

exit $?

: <<SCRIPT_AUTHOR_COMMENTS
I had the need to run a program, with specified options, on a number of
different files, using a SMP machine. So I thought [I'd] keep running
a specified number of processes and start a new one each time . . . one
of these terminates.

The "wait" instruction does not help, since it waits for a given process
or *all* process started in background. So I wrote [this] bash script
that can do the job, using the "trap" instruction.
  --Vernia Damiano
SCRIPT_AUTHOR_COMMENTS
}

Note: ◊command{trap '' SIGNAL} (two adjacent apostrophes) disables
SIGNAL for the remainder of the script. ◊command{trap SIGNAL} restores
the functioning of SIGNAL once more. This is useful to protect a
critical portion of a script from an undesirable interrupt.

◊example{
trap '' 2  # Signal 2 is Control-C, now disabled.
command
command
command
trap 2	   # Reenables Control-C
}

◊section{New in Bash version 3}

Version 3 of Bash adds the following internal variables for use by the
debugger.

◊list-block[#:type "bullet"]{

◊list-entry{◊code{$BASH_ARGC}: Number of command-line arguments passed
to script, similar to ◊code{$#}.}

◊list-entry{◊code{$BASH_ARGV}: Final command-line parameter passed to
script, equivalent ◊code{$◊escaped{◊"{"}!#◊escaped{◊"}"}}.}

◊list-entry{◊code{$BASH_COMMAND}: Command currently executing.}

◊list-entry{◊code{$BASH_EXECUTION_STRING}: The option string following
the ◊code{-c} option to Bash.}

◊list-entry{◊code{$BASH_LINENO}: In a function, indicates the line
number of the function call.}

◊list-entry{◊code{$BASH_REMATCH}: Array variable associated with
◊code{=~} conditional regex matching.}

◊list-entry{◊code{$BASH_SOURCE}: This is the name of the script,
usually the same as ◊code{$0}.}

◊list-entry{◊code{$BASH_SUBSHELL}: A variable indicating the subshell
level.}

}
