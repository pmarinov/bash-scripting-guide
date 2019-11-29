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

◊strong{Example: Positional Parameters}

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


◊emphasize{Bracket notation} for positional parameters leads to a
fairly simple way of referencing the ◊emphasize{last} argument passed
to a script on the command-line. This also requires
◊emphasize{indirect referencing}.

◊example{
args=$#           # Number of args passed.
lastarg=${!args}
# Note: This is an *indirect reference* to $args ...


# Or:       lastarg=${!#}             (Thanks, Chris Monson.)
# This is an *indirect reference* to the $# variable.
# Note that lastarg=${!$#} doesn't work.
}

Some scripts can perform different operations, depending on which name
they are invoked with. For this to work, the script needs to check
◊code{$0}, the name it was invoked by. ◊footnote{If the the script is
sourced or symlinked, then this will not work. It is safer to check
$BASH_Source.} There must also exist symbolic links to all the
alternate names of the script. See Example 16-2.

Tip: If a script expects a command-line parameter but is invoked
without one, this may cause a ◊emphasize{null variable assignment},
generally an undesirable result. One way to prevent this is to append
an extra character to both sides of the assignment statement using the
expected positional parameter.

◊example{
variable1_=$1_  # Rather than variable1=$1
# This will prevent an error, even if positional parameter is absent.

critical_argument01=$variable1_

# The extra character can be stripped off later, like so.
variable1=${variable1_/_/}
# Side effects only if $variable1_ begins with an underscore.
# This uses one of the parameter substitution templates discussed later.
# (Leaving out the replacement pattern results in a deletion.)

#  A more straightforward way of dealing with this is
#+ to simply test whether expected positional parameters have been passed.
if [ -z $1 ]
then
  exit $E_MISSING_POS_PARAM
fi


#  However, as Fabian Kreutz points out,
#+ the above method may have unexpected side-effects.
#  A better method is parameter substitution:
#         ${1:-$DefaultVal}
#  See the "Parameter Substition" section
#+ in the "Variables Revisited" chapter.
}

◊strong{Example: ◊emphasize{wh, whois} domain name lookup}

◊example{
#!/bin/bash
# ex18.sh

# Does a 'whois domain-name' lookup on any of 3 alternate servers:
#                    ripe.net, cw.net, radb.net

# Place this script -- renamed 'wh' -- in /usr/local/bin

# Requires symbolic links:
# ln -s /usr/local/bin/wh /usr/local/bin/wh-ripe
# ln -s /usr/local/bin/wh /usr/local/bin/wh-apnic
# ln -s /usr/local/bin/wh /usr/local/bin/wh-tucows

E_NOARGS=75


if [ -z "$1" ]
then
  echo "Usage: `basename $0` [domain-name]"
  exit $E_NOARGS
fi

# Check script name and call proper server.
case `basename $0` in    # Or:    case ${0##*/} in
    "wh"       ) whois $1@whois.tucows.com;;
    "wh-ripe"  ) whois $1@whois.ripe.net;;
    "wh-apnic" ) whois $1@whois.apnic.net;;
    "wh-cw"    ) whois $1@whois.cw.net;;
    *          ) echo "Usage: `basename $0` [domain-name]";;
esac

exit $?
}

}

}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
