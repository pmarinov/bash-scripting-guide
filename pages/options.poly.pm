#lang pollen

◊page-init{}
◊define-meta[page-title]{Options}
◊define-meta[page-description]{Options}

Options are settings that change shell and/or script behavior.

◊section{Options within a script}

The ◊command{set} command enables options within a script. At the
point in the script where you want the options to take effect, use set
◊code{-o option-name} or, in short form, ◊command{set
-option-abbrev}. These two forms are equivalent.

◊example{
#!/bin/bash

set -o verbose
# Echoes all commands before executing.
}

Or

◊example{
#!/bin/bash

set -v
# Exact same effect as above.
}

Note: To disable an option within a script, use ◊command{set +o
option-name} or ◊command{set +option-abbrev}.

◊example{
#!/bin/bash

set -o verbose
# Command echoing on.
command
...
command

set +o verbose
# Command echoing off.
command
# Not echoed.


set -v
# Command echoing on.
command
...
command

set +v
# Command echoing off.
command

exit 0
}

An alternate method of enabling options in a script is to specify them
immediately following the ◊code{#!} script header.

◊example{
#!/bin/bash -x
#
# Body of script follows.
}

◊section{Options from the command line}

It is also possible to enable script options from the command
line. Some options that will not work with set are available this
way. Among these are ◊code{-i}, force script to run interactive.

Example:

◊example{
bash -v script-name
}

is the same as:

◊example{
bash -o verbose script-name
}

The following is a listing of some useful options. They may be
specified in either abbreviated form (preceded by a single dash) or by
complete name (preceded by a double dash or by -o).

◊definition-block[#:type "code"]{
◊definition-entry[#:name "-B"]{
brace expansion: Enable brace expansion (default setting = on)

}

◊definition-entry[#:name "+B"]{
brace expansion: Disable brace expansion

}

◊definition-entry[#:name "-C"]{
noclobber: Prevent overwriting of files by redirection (may be
overridden by ◊code{>|})

}

◊definition-entry[#:name "-D"]{
List double-quoted strings prefixed by ◊code{$}, but do not execute
commands in script

}

◊definition-entry[#:name "-a"]{
allexport: Export all defined variables

}

◊definition-entry[#:name "-b"]{
notify: Notify when jobs running in background terminate (not of much
use in a script)

}

◊definition-entry[#:name "-c ..."]{
Read commands from ...

}

◊definition-entry[#:name "checkjobs"]{
Informs user of any open jobs upon shell exit. Introduced in version 4
of Bash, and still "experimental." Usage: shopt -s checkjobs (Caution:
may hang!)

}

◊definition-entry[#:name "-e"]{
errexit: Abort script at first error, when a command exits with
non-zero status (except in ◊command{until} or ◊command{while} loops,
◊command{if}-tests, list constructs)

}

◊definition-entry[#:name "-f"]{
noglob: Filename expansion (globbing) disabled

}

◊definition-entry[#:name "globstar"]{
Enables the ◊code{**} globbing operator (version 4+ of Bash). Usage:
shopt -s globstar

}

◊definition-entry[#:name "-i"]{
interactive: Script runs in interactive mode

}

◊definition-entry[#:name "-n"]{
noexec: Read commands in script, but do not execute them (syntax
check)

}

◊definition-entry[#:name "-o Option-Name"]{
Invoke the Option-Name option

}

◊definition-entry[#:name "-o posix"]{
Change the behavior of Bash, or invoked script, to conform to POSIX
standard.

}

◊definition-entry[#:name "-o pipefail"]{
Causes a pipeline to return the exit status of the last command in the
pipe that returned a non-zero return value.

}

◊definition-entry[#:name "-p"]{
privileged: Script runs as "suid" (caution!)

}

◊definition-entry[#:name "-r"]{
restricted: Script runs in restricted mode (see TODO Chapter 22).

}

◊definition-entry[#:name "-s"]{
stdin: Read commands from stdin

}

◊definition-entry[#:name "-t"]{
Exit after first command

}

◊definition-entry[#:name "-u"]{
nounset: Attempt to use undefined variable outputs error message, and
forces an exit

}

◊definition-entry[#:name "-v"]{
verbose: Print each command to stdout before executing it

}

◊definition-entry[#:name "-x"]{
xtrace: Similar to -v, but expands commands

}

◊definition-entry[#:name "-"]{
End of options flag. All other arguments are positional parameters.

}

◊definition-entry[#:name "--"]{
Unset positional parameters. If arguments given (◊code{-- arg1 arg2}),
positional parameters set to arguments.

}

}

