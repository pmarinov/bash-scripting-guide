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
If parameter not set, use default.

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


} ◊;definition-block

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
