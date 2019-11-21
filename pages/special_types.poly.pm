#lang pollen

◊define-meta[page-title]{Variable Types}
◊define-meta[page-description]{Special Variable Types}

◊definition-block[#:type "variables"]{

◊definition-entry[#:name "Local variables"]{
Variables visible only within a code block or function (see also local
variables in functions)

}

◊definition-entry[#:name "Environmental variables"]{
Variables that affect the behavior of the shell and user interface

Note: In a more general context, each ◊emphasize{process} has an
"environment", that is, a group of variables that the process may
reference. In this sense, the shell behaves like any other process.

Every time a shell starts, it creates shell variables that correspond
to its own environmental variables. Updating or adding new
environmental variables causes the shell to update its environment,
and all the shell's ◊emphasize{child processes} (the commands it
executes) inherit this environment.

Caution: The space allotted to the environment is limited. Creating
too many environmental variables or ones that use up excessive space
may cause problems.

◊example{
bash$ eval "`seq 10000 | sed -e 's/.*/export var&=ZZZZZZZZZZZZZZ/'`"

bash$ du
bash: /usr/bin/du: Argument list too long
}

Note: This "error" has been fixed, as of kernel version 2.6.23.

(Thank you, Stéphane Chazelas for the clarification, and for providing
the above example.)

If a script sets environmental variables, they need to be "exported,"
that is, reported to the environment local to the script. This is the
function of the ◊code{export} command.

Note: A script can export variables only to child processes, that is,
only to commands or processes which that particular script
initiates. A script invoked from the command-line ◊emphasize{cannot}
export variables back to the command-line
environment. ◊emphasize{Child processes cannot export variables back
to the parent processes that spawned them}.

Definition: A ◊emphasize{child process} is a subprocess launched by
another process, its ◊emphasize{parent}.

}

◊definition-entry[#:name "Positional parameters"]{
Arguments passed to the script from the command line: ◊code{$0, $1,
$2, $3...}

◊code{$0} is the name of the script itself, ◊code{$1} is the first
argument, ◊code{$2} the second, ◊code{$3} the third, and so
forth. After ◊code{$9}, the arguments must be enclosed in brackets,
for example, ◊code{$◊escaped{◊"{"}10◊escaped{◊"}"},
$◊escaped{◊"{"}11◊escaped{◊"}"}, $◊escaped{◊"{"}12◊escaped{◊"}"}}.

The special variables ◊code{$*} and ◊code{$◊escaped{@}} denote all the
positional parameters.

Note: The process calling the script sets the ◊code{$0} parameter. By
convention, this parameter is the name of the script. See the manpage
(manual page) for ◊code{execv}.

From the command-line, however, ◊code{$0} is the name of the shell.

◊example{
bash$ echo $0
bash

tcsh% echo $0
tcsh
}

The special variables ◊code{$*} and ◊code{$◊escaped{@}} denote all the
positional parameters.

◊strong{Positional Parameters}

◊example{
#!/bin/bash

# Call this script with at least 10 parameters, for example
# ./scriptname 1 2 3 4 5 6 7 8 9 10
MINPARAMS=10

echo

echo "The name of this script is \"$0\"."
# Adds ./ for current directory
echo "The name of this script is \"`basename $0`\"."
# Strips out path name info (see 'basename')

echo

if [ -n "$1" ]              # Tested variable is quoted.
then
 echo "Parameter #1 is $1"  # Need quotes to escape #
fi

if [ -n "$2" ]
then
 echo "Parameter #2 is $2"
fi

if [ -n "$3" ]
then
 echo "Parameter #3 is $3"
fi

# ...


if [ -n "${10}" ]  # Parameters > $9 must be enclosed in {brackets}.
then
 echo "Parameter #10 is ${10}"
fi

echo "-----------------------------------"
echo "All the command-line parameters are: "$*""

if [ $# -lt "$MINPARAMS" ]
then
  echo
  echo "This script needs at least $MINPARAMS command-line arguments!"
fi

echo

exit 0
}

}

}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
