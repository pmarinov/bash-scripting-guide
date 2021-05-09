#lang pollen

◊page-init{}
◊define-meta[page-title]{Parameter Substitution}
◊define-meta[page-description]{Substitution in variables and parameters}

◊section{Manipulating and/or expanding variables}

◊definition-block[#:type "variables"]{
◊definition-entry[#:name "${parameter}"]{
Same as ◊code{$parameter}, i.e., value of the variable parameter. In
certain contexts, only the less ambiguous
◊code{$◊escaped{◊"{"}parameter◊escaped{◊"}"}} form works.

May be used for concatenating variables with strings.

◊example{
your_id=${USER}-on-${HOSTNAME}
echo "$your_id"
#
echo "Old \$PATH = $PATH"
PATH=${PATH}:/opt/bin  # Add /opt/bin to $PATH for duration of script.
echo "New \$PATH = $PATH"
}

}

◊definition-entry[#:name "${parameter-default}, ${parameter:-default}"]{
If ◊code{parameter} not set, use default.

◊example{
var1=1
var2=2
# var3 is unset.

echo ${var1-$var2}   # 1
echo ${var3-$var2}   # 2
#           ^          Note the $ prefix.


echo ${username-`whoami`}
# Echoes the result of `whoami`, if variable $username is still unset.
}

Note: ◊code{$◊escaped{◊"{"}parameter-default◊escaped{◊"}"}} and
◊code{$◊escaped{◊"{"}parameter:-default◊escaped{◊"}"}} are almost
equivalent. The extra ◊code{:} makes a difference only when
◊code{parameter} has been declared, but is null.

◊example{
#!/bin/bash
# param-sub.sh

#  Whether a variable has been declared
#+ affects triggering of the default option
#+ even if the variable is null.

username0=
echo "username0 has been declared, but is set to null."
echo "username0 = ${username0-`whoami`}"
# Will not echo.

echo

echo username1 has not been declared.
echo "username1 = ${username1-`whoami`}"
# Will echo.

username2=
echo "username2 has been declared, but is set to null."
echo "username2 = ${username2:-`whoami`}"
#                            ^
# Will echo because of :- rather than just - in condition test.
# Compare to first instance, above.


#

# Once again:

variable=
# variable has been declared, but is set to null.

echo "${variable-0}"    # (no output)
echo "${variable:-1}"   # 1
#               ^

unset variable

echo "${variable-2}"    # 2
echo "${variable:-3}"   # 3

exit 0
}

The default parameter construct finds use in providing "missing"
command-line arguments in scripts.

◊example{
DEFAULT_FILENAME=generic.data
filename=${1:-$DEFAULT_FILENAME}
#  If not otherwise specified, the following command block operates
#+ on the file "generic.data".
#  Begin-Command-Block
#  ...
#  ...
#  ...
#  End-Command-Block



#  From "hanoi2.bash" example:
DISKS=${1:-E_NOPARAM}   # Must specify how many disks.
#  Set $DISKS to $1 command-line-parameter,
#+ or to $E_NOPARAM if that is unset.
}

See also TODO Example 3-4, Example 31-2, and Example A-6.

Compare this method with using an ◊emphasize{and list} to supply a
default command-line argument.

}

◊definition-entry[#:name "${parameter=default}, ${parameter:=default}"]{
If parameter not set, set it to default.

Both forms nearly equivalent. The ◊code{:} makes a difference only
when ◊code{$parameter} has been declared and is null, as above.

Note: If ◊code{$parameter} is null in a non-interactive script, it
will terminate with a 127 exit status (the Bash error code for
"command not found").

◊example{
echo ${var=abc}   # abc
echo ${var=xyz}   # abc
# $var had already been set to abc, so it did not change.
}

}

◊definition-entry[#:name "${parameter+alt_value}, ${parameter:+alt_value}"]{
If parameter set, use ◊code{alt_value}, else use null string.

Both forms nearly equivalent. The ◊code{:} makes a difference only
when ◊code{parameter} has been declared and is null, see below.

◊example{
echo "###### \${parameter+alt_value} ########"
echo

a=${param1+xyz}
echo "a = $a"      # a =

param2=
a=${param2+xyz}
echo "a = $a"      # a = xyz

param3=123
a=${param3+xyz}
echo "a = $a"      # a = xyz

echo
echo "###### \${parameter:+alt_value} ########"
echo

a=${param4:+xyz}
echo "a = $a"      # a =

param5=
a=${param5:+xyz}
echo "a = $a"      # a =
# Different result from   a=${param5+xyz}

param6=123
a=${param6:+xyz}
echo "a = $a"      # a = xyz
}

}

◊definition-entry[#:name "${parameter?err_msg}, ${parameter:?err_msg}"]{

If parameter set, use it, else print ◊code{err_msg} and abort the
script with an exit status of 1.

Both forms nearly equivalent. The ◊code{:} makes a difference only
when ◊code{parameter} has been declared and is null, as above.


}

} ◊;definition-block

◊section-example[#:anchor "param_subst_err1"]{Using parameter
substitution and error messages}

◊example{
#!/bin/bash

#  Check some of the system's environmental variables.
#  This is good preventative maintenance.
#  If, for example, $USER, the name of the person at the console, is not set,
#+ the machine will not recognize you.

: ${HOSTNAME?} ${USER?} ${HOME?} ${MAIL?}
  echo
  echo "Name of the machine is $HOSTNAME."
  echo "You are $USER."
  echo "Your home directory is $HOME."
  echo "Your mail INBOX is located in $MAIL."
  echo
  echo "If you are reading this message,"
  echo "critical environmental variables have been set."
  echo
  echo

# ------------------------------------------------------

#  The ${variablename?} construction can also check
#+ for variables set within the script.

ThisVariable=Value-of-ThisVariable
#  Note, by the way, that string variables may be set
#+ to characters disallowed in their names.
: ${ThisVariable?}
echo "Value of ThisVariable is $ThisVariable".

echo; echo


: ${ZZXy23AB?"ZZXy23AB has not been set."}
#  Since ZZXy23AB has not been set,
#+ then the script terminates with an error message.

# You can specify the error message.
# : ${variablename?"ERROR MESSAGE"}


# Same result with:   dummy_variable=${ZZXy23AB?}
#                     dummy_variable=${ZZXy23AB?"ZXy23AB has not been set."}
#
#                     echo ${ZZXy23AB?} >/dev/null

#  Compare these methods of checking whether a variable has been set
#+ with "set -u" . . .



echo "You will not see this message, because script already terminated."

HERE=0
exit $HERE   # Will NOT exit here.

# In fact, this script will return an exit status (echo $?) of 1.
}

◊section-example[#:anchor "usg_msg1"]{Parameter substitution and
"usage" messages}

◊example{
#!/bin/bash
# usage-message.sh

: ${1?"Usage: $0 ARGUMENT"}
#  Script exits here if command-line parameter absent,
#+ with following error message.
#    usage-message.sh: 1: Usage: usage-message.sh ARGUMENT

echo "These two lines echo only if command-line parameter given."
echo "command-line parameter = \"$1\""

exit 0  # Will exit here only if command-line parameter present.

# Check the exit status, both with and without command-line parameter.
# If command-line parameter present, then "$?" is 0.
# If not, then "$?" is 1.
}

◊section{Parameter substitution and/or expansion.}

The following expressions are the complement to the ◊command{match} in
◊command{expr} string operations (TODO see Example 16-9). These
particular ones are used mostly in parsing file path names.

◊strong{Variable length / Substring removal}

◊definition-block[#:type "variables"]{
◊definition-entry[#:name "${#var}"]{

String length (number of characters in ◊code{$var}). For an array,
◊code{$◊escaped{◊"{"}#array◊escaped{◊"}"}} is the length of the first
element in the array.

Note, exceptions: ◊code{$◊escaped{◊"{"}#*◊escaped{◊"}"}} and
◊code{$◊escaped{◊"{"}#◊escaped{◊"@"}◊escaped{◊"}"}} give the number of
positional parameters. For an array,
◊code{$◊escaped{◊"{"}#array[*]◊escaped{◊"}"}} and
◊code{$◊escaped{◊"{"}#array[◊escaped{◊"@"}]◊escaped{◊"}"}} give the
number of elements in the array.

◊strong{Example: Length of a variable}

◊example{
#!/bin/bash
# length.sh

E_NO_ARGS=65

if [ $# -eq 0 ]  # Must have command-line args to demo script.
then
  echo "Please invoke this script with one or more command-line arguments."
  exit $E_NO_ARGS
fi

var01=abcdEFGH28ij
echo "var01 = ${var01}"
echo "Length of var01 = ${#var01}"
# Now, let's try embedding a space.
var02="abcd EFGH28ij"
echo "var02 = ${var02}"
echo "Length of var02 = ${#var02}"

echo "Number of command-line arguments passed to script = ${#@}"
echo "Number of command-line arguments passed to script = ${#*}"

exit 0
}

}

◊definition-entry[#:name "${var#Pattern}, ${var##Pattern}"]{
◊code{$◊escaped{◊"{"}var#Pattern◊escaped{◊"}"}} -- remove from
◊code{$var} the shortest part of ◊code{$Pattern} that matches the
front end of ◊code{$var}.

◊code{$◊escaped{◊"{"}var##Pattern◊escaped{◊"}"}} -- remove from
◊code{$var} the longest part of ◊code{$Pattern} that matches the front
end of ◊code{$var}.

◊example{
# Function from "days-between.sh" example.
# Strips leading zero(s) from argument passed.

strip_leading_zero () #  Strip possible leading zero(s)
{                     #+ from argument passed.
  return=${1#0}       #  The "1" refers to "$1" -- passed arg.
}                     #  The "0" is what to remove from "$1" -- strips zeros.

}

More elaborate variation of the above:

◊example{
strip_leading_zero2 () # Strip possible leading zero(s), since otherwise
{                      # Bash will interpret such numbers as octal values.
  shopt -s extglob     # Turn on extended globbing.
  local val=${1##+(0)} # Use local variable, longest matching series of 0's.
  shopt -u extglob     # Turn off extended globbing.
  _strip_leading_zero2=${val:-0}
                       # If input was 0, return 0 instead of "".
}

}

Another usage illustration:

◊example{
echo `basename $PWD`        # Basename of current working directory.
echo "${PWD##*/}"           # Basename of current working directory.
echo
echo `basename $0`          # Name of script.
echo $0                     # Name of script.
echo "${0##*/}"             # Name of script.
echo
filename=test.data
echo "${filename##*.}"      # data
                            # Extension of filename.
}


}

◊definition-entry[#:name "${var%Pattern}, ${var%%Pattern}"]{

◊code{$◊escaped{◊"{"}var%Pattern◊escaped{◊"}"}} Remove from
◊code{$var} the shortest part of ◊code{$Pattern} that matches the back
end of ◊code{$var}.

◊code{$◊escaped{◊"{"}var%%Pattern◊escaped{◊"}"}} Remove from
◊code{$var} the longest part of ◊code{$Pattern} that matches the back
end of ◊code{$var}.

Version 2 of Bash added additional options.

}

} ◊;definition-block

◊section-example[#:anchor "patt_match1"]{Pattern matching in parameter
substitution}

◊example{
#!/bin/bash
# patt-matching.sh

# Pattern matching  using the # ## % %% parameter substitution operators.

var1=abcd12345abc6789
pattern1=a*c  # * (wild card) matches everything between a - c.

echo
echo "var1 = $var1"           # abcd12345abc6789
echo "var1 = ${var1}"         # abcd12345abc6789
                              # (alternate form)
echo "Number of characters in ${var1} = ${#var1}"
echo

echo "pattern1 = $pattern1"   # a*c  (everything between 'a' and 'c')
echo "--------------"
echo '${var1#$pattern1}  =' "${var1#$pattern1}"    #         d12345abc6789
# Shortest possible match, strips out first 3 characters  abcd12345abc6789
#                                     ^^^^^               |-|
echo '${var1##$pattern1} =' "${var1##$pattern1}"   #                  6789
# Longest possible match, strips out first 12 characters  abcd12345abc6789
#                                    ^^^^^                |----------|

echo; echo; echo

pattern2=b*9            # everything between 'b' and '9'
echo "var1 = $var1"     # Still  abcd12345abc6789
echo
echo "pattern2 = $pattern2"
echo "--------------"
echo '${var1%pattern2}  =' "${var1%$pattern2}"     #     abcd12345a
# Shortest possible match, strips out last 6 characters  abcd12345abc6789
#                                     ^^^^                         |----|
echo '${var1%%pattern2} =' "${var1%%$pattern2}"    #     a
# Longest possible match, strips out last 12 characters  abcd12345abc6789
#                                    ^^^^                 |-------------|

# Remember, # and ## work from the left end (beginning) of string,
#           % and %% work from the right end.

echo

exit 0
}

◊section-example[#:anchor "ren_file1"]{Renaming file extensions}

◊example{
#!/bin/bash
# rfe.sh: Renaming file extensions.
#
#         rfe old_extension new_extension
#
# Example:
# To rename all *.gif files in working directory to *.jpg,
#          rfe gif jpg


E_BADARGS=65

case $# in
  0|1)             # The vertical bar means "or" in this context.
  echo "Usage: `basename $0` old_file_suffix new_file_suffix"
  exit $E_BADARGS  # If 0 or 1 arg, then bail out.
  ;;
esac


for filename in *.$1
# Traverse list of files ending with 1st argument.
do
  mv $filename ${filename%$1}$2
  #  Strip off part of filename matching 1st argument,
  #+ then append 2nd argument.
done

exit 0
}

◊section{Variable expansion / Substring replacement}

These constructs have been adopted from ◊command{ksh}.

◊definition-block[#:type "variables"]{
◊definition-entry[#:name "${var:pos}"]{
Variable ◊code{var} expanded, starting from offset ◊code{pos}.

}

◊definition-entry[#:name "${var:pos:len}"]{
Expansion to a max of ◊code{len} characters of variable ◊code{var},
from offset ◊code{pos}. See TODO Example A-13 for an example of the
creative use of this operator.

}

◊definition-entry[#:name "${var/Pattern/Replacement}"]{
First match of ◊code{Pattern}, within ◊code{var} replaced with
◊code{Replacement}.

If ◊code{Replacement} is omitted, then the first match of
◊code{Pattern} is replaced by nothing, that is, deleted.

}

◊definition-entry[#:name "${var//Pattern/Replacement}"]{
Global replacement. All matches of ◊code{Pattern}, within var replaced
with ◊code{Replacement}.

As above, if ◊code{Replacement} is omitted, then all occurrences of
◊code{Pattern} are replaced by nothing, that is, deleted.

}

◊definition-entry[#:name "${var/#Pattern/Replacement}"]{
If prefix of ◊code{var} matches ◊code{Pattern}, then substitute
◊code{Replacement} for ◊code{Pattern}.

}

◊definition-entry[#:name "${var/%Pattern/Replacement}"]{
If suffix of ◊code{var} matches ◊code{Pattern}, then substitute
◊code{Replacement} for ◊code{Pattern}.

}

◊definition-entry[#:name "${!varprefix*}, ${!varprefix@}"]{
Matches names of all previously declared variables beginning with
◊code{varprefix}.

◊example{
# This is a variation on indirect reference, but with a * or @.
# Bash, version 2.04, adds this feature.

xyz23=whatever
xyz24=

a=${!xyz*}         #  Expands to *names* of declared variables
# ^ ^   ^           + beginning with "xyz".
echo "a = $a"      #  a = xyz23 xyz24
a=${!xyz@}         #  Same as above.
echo "a = $a"      #  a = xyz23 xyz24

echo "---"

abc23=something_else
b=${!abc*}
echo "b = $b"      #  b = abc23
c=${!b}            #  Now, the more familiar type of indirect reference.
echo $c            #  something_else
}

}

} ◊;definition-block

◊section-example[#:anchor "glob_parse1"]{Using pattern matching to
parse arbitrary strings}

◊example{
#!/bin/bash

var1=abcd-1234-defg
echo "var1 = $var1"

t=${var1#*-*}
echo "var1 (with everything, up to and including first - stripped out) = $t"
#  t=${var1#*-}  works just the same,
#+ since # matches the shortest string,
#+ and * matches everything preceding, including an empty string.
# (Thanks, Stephane Chazelas, for pointing this out.)

t=${var1##*-*}
echo "If var1 contains a \"-\", returns empty string...   var1 = $t"


t=${var1%*-*}
echo "var1 (with everything from the last - on stripped out) = $t"

echo

# -------------------------------------------
path_name=/home/bozo/ideas/thoughts.for.today
# -------------------------------------------
echo "path_name = $path_name"
t=${path_name##/*/}
echo "path_name, stripped of prefixes = $t"
# Same effect as   t=`basename $path_name` in this particular case.
#  t=${path_name%/}; t=${t##*/}   is a more general solution,
#+ but still fails sometimes.
#  If $path_name ends with a newline, then `basename $path_name` will not work,
#+ but the above expression will.
# (Thanks, S.C.)

t=${path_name%/*.*}
# Same effect as   t=`dirname $path_name`
echo "path_name, stripped of suffixes = $t"
# These will fail in some cases, such as "../", "/foo////", # "foo/", "/".
#  Removing suffixes, especially when the basename has no suffix,
#+ but the dirname does, also complicates matters.
# (Thanks, S.C.)

echo

t=${path_name:11}
echo "$path_name, with first 11 chars stripped off = $t"
t=${path_name:11:5}
echo "$path_name, with first 11 chars stripped off, length 5 = $t"

echo

t=${path_name/bozo/clown}
echo "$path_name with \"bozo\" replaced  by \"clown\" = $t"
t=${path_name/today/}
echo "$path_name with \"today\" deleted = $t"
t=${path_name//o/O}
echo "$path_name with all o's capitalized = $t"
t=${path_name//o/}
echo "$path_name with all o's deleted = $t"

exit 0
}

◊section-example[#:anchor "ma_pref_suf1"]{Matching patterns at prefix
or suffix of string}

◊example{
#!/bin/bash
# var-match.sh:
# Demo of pattern replacement at prefix / suffix of string.

v0=abc1234zip1234abc    # Original variable.
echo "v0 = $v0"         # abc1234zip1234abc
echo

# Match at prefix (beginning) of string.
v1=${v0/#abc/ABCDEF}    # abc1234zip1234abc
                        # |-|
echo "v1 = $v1"         # ABCDEF1234zip1234abc
                        # |----|

# Match at suffix (end) of string.
v2=${v0/%abc/ABCDEF}    # abc1234zip123abc
                        #              |-|
echo "v2 = $v2"         # abc1234zip1234ABCDEF
                        #               |----|

echo

#  ----------------------------------------------------
#  Must match at beginning / end of string,
#+ otherwise no replacement results.
#  ----------------------------------------------------
v3=${v0/#123/000}       # Matches, but not at beginning.
echo "v3 = $v3"         # abc1234zip1234abc
                        # NO REPLACEMENT.
v4=${v0/%123/000}       # Matches, but not at end.
echo "v4 = $v4"         # abc1234zip1234abc
                        # NO REPLACEMENT.

exit 0
}

