#lang pollen

◊define-meta[page-title]{Internal Variables}
◊define-meta[page-description]{Internal variables}

Builtin variables: variables affecting bash script behavior

◊definition-block[#:type "code"]{
◊definition-entry[#:name "$BASH"]{
The path to the Bash binary itself

◊example{
bash$ echo $BASH
/bin/bash
}
}

◊definition-entry[#:name "$BASH_ENV"]{
An environmental variable pointing to a Bash startup file to be read
when a script is invoked

}

◊definition-entry[#:name "$BASH_SUBSHELL"]{
A variable indicating the subshell level. This is a new addition to
Bash, version 3.

See Example 21-1 for usage (TODO)

}

◊definition-entry[#:name "$BASHPID"]{

Process ID of the current instance of Bash. This is not the same as
the ◊code{$$} variable, but it often gives the same result.

◊example{
bash4$ echo $$
11015

bash4$ echo $BASHPID
11015

bash4$ ps ax | grep bash4
11015 pts/2    R      0:00 bash4
}

But ...

◊example{
#!/bin/bash4

echo "\$\$ outside of subshell = $$"                              # 9602
echo "\$BASH_SUBSHELL  outside of subshell = $BASH_SUBSHELL"      # 0
echo "\$BASHPID outside of subshell = $BASHPID"                   # 9602

echo

( echo "\$\$ inside of subshell = $$"                             # 9602
  echo "\$BASH_SUBSHELL inside of subshell = $BASH_SUBSHELL"      # 1
  echo "\$BASHPID inside of subshell = $BASHPID" )                # 9603
  # Note that $$ returns PID of parent process.
}

}

◊definition-entry[#:name "$BASH_VERSINFO[n]"]{

A 6-element array containing version information about the installed
release of Bash. This is similar to ◊code{$BASH_VERSION}, below, but a
bit more detailed.

◊example{
# Bash version info:

for n in 0 1 2 3 4 5
do
  echo "BASH_VERSINFO[$n] = ${BASH_VERSINFO[$n]}"
done

# BASH_VERSINFO[0] = 3                      # Major version no.
# BASH_VERSINFO[1] = 00                     # Minor version no.
# BASH_VERSINFO[2] = 14                     # Patch level.
# BASH_VERSINFO[3] = 1                      # Build version.
# BASH_VERSINFO[4] = release                # Release status.
# BASH_VERSINFO[5] = i386-redhat-linux-gnu  # Architecture
                                            # (same as $MACHTYPE).
}

}

◊definition-entry[#:name "$BASH_VERSION"]{
The version of Bash installed on the system

◊example{
bash$ echo $BASH_VERSION
3.2.25(1)-release
}

◊example{
tcsh% echo $BASH_VERSION
BASH_VERSION: Undefined variable.
}

}

◊definition-entry[#:name "$CDPATH"]{

A colon-separated list of search paths available to the cd command,
similar in function to the ◊code{$PATH} variable for binaries. The
◊code{$CDPATH} variable may be set in the local ◊fname{~/.bashrc}
file.

◊example{
bash$ cd bash-doc
bash: cd: bash-doc: No such file or directory


bash$ CDPATH=/usr/share/doc
bash$ cd bash-doc
/usr/share/doc/bash-doc


bash$ echo $PWD
/usr/share/doc/bash-doc
}

}

◊definition-entry[#:name "$DIRSTACK"]{
The top value in the directory stack (affected by ◊command{pushd} and
◊command{popd})

This builtin variable corresponds to the ◊command{dirs} command,
however ◊command{dirs} shows the entire contents of the directory
stack.

}

◊definition-entry[#:name "$EDITOR"]{
The default editor invoked by a script, usually ◊command{vi} or
◊command{emacs}.

}

◊definition-entry[#:name "$EUID"]{
"Effective" user ID number

Identification number of whatever identity the current user has
assumed, perhaps by means of ◊command{su}.

Caution: ◊code{$EUID} is not necessarily the same as the ◊code{$UID}.

}


◊definition-entry[#:name "$FUNCNAME"]{
Name of the current function

◊example{
xyz23 ()
{
  echo "$FUNCNAME now executing."  # xyz23 now executing.
}

xyz23

echo "FUNCNAME = $FUNCNAME"        # FUNCNAME =
                                   # Null value outside a function.
}

See also Example A-50 (TODO)

}

◊definition-entry[#:name "$GLOBIGNORE"]{
A list of filename patterns to be excluded from matching in globbing.

}


◊definition-entry[#:name "$GROUPS"]{
Groups current user belongs to

This is a listing (array) of the group id numbers for current user, as
recorded in ◊fname{/etc/passwd} and ◊fname{/etc/group}.

◊example{
root# echo $GROUPS
0

root# echo ${GROUPS[1]}
1

root# echo ${GROUPS[5]}
6
}

}

◊definition-entry[#:name "$HOME"]{
Home directory of the user, usually ◊fname{/home/username} (see
Example 10-7) (TODO)

}

◊definition-entry[#:name "$HOSTNAME"]{
The ◊command{hostname} command assigns the system host name at bootup
in an init script. However, the ◊code{gethostname()} function sets the
Bash internal variable ◊code{$HOSTNAME}. See also Example 10-7 (TODO).

}

◊definition-entry[#:name "$HOSTTYPE"]{
Host type

Like ◊code{$MACHTYPE}, identifies the system hardware.

◊example{
bash$ echo $HOSTTYPE
i686
}

}

◊definition-entry[#:name "$IFS"]{
internal field separator

This variable determines how Bash recognizes fields, or word
boundaries, when it interprets character strings.

◊code{$IFS} defaults to whitespace (space, tab, and newline), but may
be changed, for example, to parse a comma-separated data file. Note
that ◊code{$*} uses the first character held in ◊code{$IFS}. See
Example 5-1 (TODO)

◊example{
bash$ echo "$IFS"

(With $IFS set to default, a blank line displays.)


bash$ echo "$IFS" | cat -vte
 ^I$
 $
(Show whitespace: here a single space, ^I [horizontal tab],
  and newline, and display "$" at end-of-line.)


bash$ bash -c 'set w x y z; IFS=":-;"; echo "$*"'
w:x:y:z
(Read commands from string and assign any arguments to pos params.)

}

Set ◊code{$IFS} to eliminate whitespace in pathnames.

◊example{
IFS="$(printf '\n\t')"   # Per David Wheeler.
}

Caution: ◊code{$IFS} does not handle whitespace the same as it does
other characters.

◊anchored-example[#:anchor "ifs_wspc1"]{Example: $IFS and whitespace}

◊example{
#!/bin/bash
# ifs.sh


var1="a+b+c"
var2="d-e-f"
var3="g,h,i"

IFS=+
# The plus sign will be interpreted as a separator.
echo $var1     # a b c
echo $var2     # d-e-f
echo $var3     # g,h,i

echo

IFS="-"
# The plus sign reverts to default interpretation.
# The minus sign will be interpreted as a separator.
echo $var1     # a+b+c
echo $var2     # d e f
echo $var3     # g,h,i

echo

IFS=","
# The comma will be interpreted as a separator.
# The minus sign reverts to default interpretation.
echo $var1     # a+b+c
echo $var2     # d-e-f
echo $var3     # g h i

echo

IFS=" "
# The space character will be interpreted as a separator.
# The comma reverts to default interpretation.
echo $var1     # a+b+c
echo $var2     # d-e-f
echo $var3     # g,h,i

# ======================================================== #

# However ...
# $IFS treats whitespace differently than other characters.

output_args_one_per_line()
{
  for arg
  do
    echo "[$arg]"
  done #  ^    ^   Embed within brackets, for your viewing pleasure.
}

echo; echo "IFS=\" \""
echo "-------"

IFS=" "
var=" a  b c   "
#    ^ ^^   ^^^
output_args_one_per_line $var  # output_args_one_per_line `echo " a  b c   "`
# [a]
# [b]
# [c]


echo; echo "IFS=:"
echo "-----"

IFS=:
var=":a::b:c:::"               # Same pattern as above,
#    ^ ^^   ^^^                #+ but substituting ":" for " "  ...
output_args_one_per_line $var
# []
# [a]
# []
# [b]
# [c]
# []
# []

# Note "empty" brackets.
# The same thing happens with the "FS" field separator in awk.


echo

exit
}

(Many thanks, Stéphane Chazelas, for clarification and above
examples.)

See also Example 16-41, Example 11-8, and Example 19-14 (TODO) for
instructive examples of using ◊code{$IFS}.

}

◊definition-entry[#:name "$IGNOREEOF"]{
Ignore EOF: how many end-of-files (control-D) the shell will ignore
before logging out.

}

◊definition-entry[#:name "$LC_COLLATE"]{
Often set in the ◊fname{.bashrc} or ◊fname{/etc/profile} files, this
variable controls collation order in filename expansion and pattern
matching. If mishandled, ◊code{LC_COLLATE} can cause unexpected
results in filename globbing.

Note: As of version 2.05 of Bash, filename globbing no longer
distinguishes between lowercase and uppercase letters in a character
range between brackets. For example, ◊command{ls [A-M]*} would match
both ◊fname{File1.txt} and ◊fname{file1.txt}. To revert to the
customary behavior of bracket matching, set ◊code{LC_COLLATE} to
◊code{C} by an ◊command{export LC_COLLATE=C} in ◊fname{/etc/profile}
and/or ◊fname{~/.bashrc}.

}

◊definition-entry[#:name "$LC_CTYPE"]{
This internal variable controls character interpretation in globbing
and pattern matching.

}

◊definition-entry[#:name "$LINENO"]{
This variable is the line number of the shell script in which this
variable appears. It has significance only within the script in which
it appears, and is chiefly useful for debugging purposes.

◊example{
# *** BEGIN DEBUG BLOCK ***
last_cmd_arg=$_  # Save it.

echo "At line number $LINENO, variable \"v1\" = $v1"
echo "Last command argument processed = $last_cmd_arg"
# *** END DEBUG BLOCK ***
}

}

◊definition-entry[#:name "$MACHTYPE"]{
machine type

Identifies the system hardware.

◊example{
bash$ echo $MACHTYPE
i686
}

}

◊definition-entry[#:name "$OLDPWD"]{
Old working directory ("OLD-Print-Working-Directory", previous
directory you were in).

}

◊definition-entry[#:name "$OSTYPE"]{

operating system type

◊example{
bash$ echo $OSTYPE
linux
}

}

◊definition-entry[#:name "$PATH"]{
Path to binaries, usually ◊fname{/usr/bin/}, ◊fname{/usr/X11R6/bin/},
◊fname{/usr/local/bin}, etc.

When given a command, the shell automatically does a hash table search
on the directories listed in the path for the executable. The path is
stored in the environmental variable, ◊code{$PATH}, a list of
directories, separated by colons. Normally, the system stores the
◊code{$PATH} definition in ◊fname{/etc/profile} and/or
◊fname{~/.bashrc} (see Appendix H). (TODO)

◊example{
bash$ echo $PATH
/bin:/usr/bin:/usr/local/bin:/usr/X11R6/bin:/sbin:/usr/sbin
}

◊code{PATH=$◊escaped{◊"{"}PATH$◊escaped{◊"}"}:/opt/bin} appends the
◊fname{/opt/bin} directory to the current path. In a script, it may be
expedient to temporarily add a directory to the path in this way. When
the script exits, this restores the original ◊code{$PATH} (a child
process, such as a script, may not change the environment of the
parent process, the shell).

Note: The current "working directory", ◊fname{./}, is usually omitted
from the ◊code{$PATH} as a security measure.

}

◊definition-entry[#:name "$PIPESTATUS"]{
Array variable holding exit status(es) of last executed foreground
pipe.

◊example{
bash$ echo $PIPESTATUS
0

bash$ ls -al | bogus_command
bash: bogus_command: command not found
bash$ echo $◊escaped{◊"{"}PIPESTATUS[1]◊escaped{◊"}"}
127

bash$ ls -al | bogus_command
bash: bogus_command: command not found
bash$ echo $?
127
}

The members of the ◊code{$PIPESTATUS} array hold the exit status of
each respective command executed in a pipe. ◊code{$PIPESTATUS[0]}
holds the exit status of the first command in the pipe,
◊code{$PIPESTATUS[1]} the exit status of the second command, and so
on.


Caution: The ◊code{$PIPESTATUS} variable may contain an erroneous 0
value in a login shell (in releases prior to 3.0 of Bash).

◊example{
tcsh% bash

bash$ who | grep nobody | sort
bash$ echo $◊escaped{◊"{"}PIPESTATUS[*]◊escaped{◊"}"}
0

}

The above lines contained in a script would produce the expected
◊code{0 1 0} output.

Thank you, Wayne Pollock for pointing this out and supplying the above
example.

Note: The ◊code{$PIPESTATUS} variable gives unexpected results in some
contexts.

◊example{
bash$ echo $BASH_VERSION
3.00.14(1)-release

bash$ $ ls | bogus_command | wc
bash: bogus_command: command not found
 0       0       0

bash$ echo $◊escaped{◊"{"}PIPESTATUS[@]◊escaped{◊"}"}
141 127 0
}

Chet Ramey attributes the above output to the behavior of
◊code{ls}. If ◊code{ls} writes to a pipe whose output is not read,
then ◊code{SIGPIPE} kills it, and its exit status is 141. Otherwise
its exit status is 0, as expected. This likewise is the case for
◊code{tr}.

Note: ◊code{$PIPESTATUS} is a "volatile" variable. It needs to be
captured immediately after the pipe in question, before any other
command intervenes.

◊example{
bash$ $ ls | bogus_command | wc
bash: bogus_command: command not found
 0       0       0

bash$ echo $◊escaped{◊"{"}PIPESTATUS[◊escaped{◊"@"}]◊escaped{◊"}"}
0 127 0

bash$ echo $◊escaped{◊"{"}PIPESTATUS[◊escaped{◊"@"}]◊escaped{◊"}"}
0
}

Note: The ◊code{pipefail} option may be useful in cases where
◊code{$PIPESTATUS} does not give the desired information.

}


} ◊; definition-block

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
