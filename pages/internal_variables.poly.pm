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


} ◊; definition-block

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
