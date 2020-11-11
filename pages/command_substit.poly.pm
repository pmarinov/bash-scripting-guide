#lang pollen

◊; This is free and unencumbered software released into the public domain
◊; See LICENSE.txt

◊page-init{}
◊define-meta[page-title]{Command Substitution}
◊define-meta[page-description]{Command Substitution}

Command substitution reassigns the output of a command or even
multiple commands; it literally plugs the command output into another
context.

For purposes of command substitution, a command may be an external
system command, an internal scripting builtin, or even a script
function.

In a more technically correct sense, command substitution extracts the
stdout of a command, then assigns it to a variable using the ◊code{=}
operator.

The classic form of command substitution uses backquotes
(◊code{`...`}). Commands within backquotes (backticks) generate
command-line text.

◊example{
script_name=`basename $0`
echo "The name of this script is $script_name."
}

The output of commands can be used as arguments to another command, to
set a variable, and even for generating the argument list in a for
loop.

◊example{
rm `cat filename`   # "filename" contains a list of files to delete.
#
# S. C. points out that "arg list too long" error might result.
# Better is              xargs rm -- < filename
# ( -- covers those cases where "filename" begins with a "-" )

textfile_listing=`ls *.txt`
# Variable contains names of all *.txt files in current working directory.
echo $textfile_listing

textfile_listing2=$(ls *.txt)   # The alternative form of command substitution.
echo $textfile_listing2
# Same result.

# A possible problem with putting a list of files into a single string
# is that a newline may creep in.
#
# A safer way to assign a list of files to a parameter is with an array.
#      shopt -s nullglob    # If no match, filename expands to nothing.
#      textfile_listing=( *.txt )
#
# Thanks, S.C.
}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
