#lang pollen

◊define-meta[page-title]{Variable Types}
◊define-meta[page-description]{Special Variable Types}

◊definition-block[#:type "variables"]{

◊definition-entry[#:name "Local variables"]{
Variables visible only within a code block or function (see also local variables in functions)

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

}
