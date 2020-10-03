#lang pollen

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

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
