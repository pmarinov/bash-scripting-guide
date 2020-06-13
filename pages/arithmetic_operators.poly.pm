#lang pollen

◊define-meta[page-title]{Arithmetic operators}
◊define-meta[page-description]{Operators and expressions}

◊section{Assignment}

◊definition-block[#:type "code"]{
◊definition-entry[#:name "variable assignment"]{
Initializing or changing the value of a variable

}

◊definition-entry[#:name "="]{
All-purpose assignment operator, which works for both arithmetic and
string assignments.

◊example{
var=27
category=minerals  # No spaces allowed after the "=".
}

Caution: Do not confuse the ◊code{=} assignment operator with the
◊code{=} test operator.

◊example{
#   =  as a test operator

if [ "$string1" = "$string2" ]
then
   command
fi

#  if [ "X$string1" = "X$string2" ] is safer,
#+ to prevent an error message should one of the variables be empty.
#  (The prepended "X" characters cancel out.)
}

}

} ◊; definition-block{}

◊section{Arithmetic Operators}

◊definition-block[#:type "code"]{
◊definition-entry[#:name "+"]{
Plus

}

◊definition-entry[#:name "-"]{
Minus

}

◊definition-entry[#:name "*"]{
Multiplication

}

◊definition-entry[#:name "/"]{
Division

}

◊definition-entry[#:name "**"]{
Exponentation

◊example{
# Bash, version 2.02, introduced the "**" exponentiation operator.

let "z=5**3"    # 5 * 5 * 5
echo "z = $z"   # z = 125
}

}

◊definition-entry[#:name "%"]{
Modulo, or mod (returns the remainder of an integer division operation)

◊example{
bash$ expr 5 % 3
2
}

5/3 = 1, with remainder 2

This operator finds use in, among other things, generating numbers
within a specific range (TODO see Example 9-11 and Example 9-15) and
formatting program output (TODO see Example 27-16 and Example A-6). It
can even be used to generate prime numbers, (TODO see Example
A-15). Modulo turns up surprisingly often in numerical recipes.

◊; TODO: Section example here but doesn't work because of Info
◊strong{Greatest common divisor}

◊example{
#!/bin/bash
# gcd.sh: greatest common divisor
#         Uses Euclid's algorithm

#  The "greatest common divisor" (gcd) of two integers
#+ is the largest integer that will divide both, leaving no remainder.

#  Euclid's algorithm uses successive division.
#    In each pass,
#+      dividend <---  divisor
#+      divisor  <---  remainder
#+   until remainder = 0.
#    The gcd = dividend, on the final pass.
#
#  For an excellent discussion of Euclid's algorithm, see
#+ Jim Loy's site, http://www.jimloy.com/number/euclids.htm.


# ------------------------------------------------------
# Argument check
ARGS=2
E_BADARGS=85

if [ $# -ne "$ARGS" ]
then
  echo "Usage: `basename $0` first-number second-number"
  exit $E_BADARGS
fi
# ------------------------------------------------------


gcd ()
{

  dividend=$1             #  Arbitrary assignment.
  divisor=$2              #! It doesn't matter which of the two is larger.
                          #  Why not?

  remainder=1             #  If an uninitialized variable is used inside
                          #+ test brackets, an error message results.

  until [ "$remainder" -eq 0 ]
  do    #  ^^^^^^^^^^  Must be previously initialized!
    let "remainder = $dividend % $divisor"
    dividend=$divisor     # Now repeat with 2 smallest numbers.
    divisor=$remainder
  done                    # Euclid's algorithm

}                         # Last $dividend is the gcd.


gcd $1 $2

echo; echo "GCD of $1 and $2 = $dividend"; echo


# Exercises :
# ---------
# 1) Check command-line arguments to make sure they are integers,
#+   and exit the script with an appropriate error message if not.
# 2) Rewrite the gcd () function to use local variables.

exit 0
}

}

◊definition-entry[#:name "+="]{
Plus-equal (increment variable by a constant) ◊footnote{In a different
context, += can serve as a string concatenation operator. This can be
useful for modifying environmental variables.}

◊example{
let "var += 5"
}

Results in var being incremented by 5.

}

◊definition-entry[#:name "-="]{
Minus-equal (decrement variable by a constant)

}

◊definition-entry[#:name "*="]{
Times-equal (multiply variable by a constant)

◊example{
let "var *= 4"
}

Results in var being multiplied by 4.

}

◊definition-entry[#:name "/="]{
Slash-equal (divide variable by a constant)

}

◊definition-entry[#:name "%="]{
Mod-equal (remainder of dividing variable by a constant)

Arithmetic operators often occur in an ◊code{expr} or ◊code{let}
expression.

◊strong{Using Arithmetic Operations}

◊example{
#!/bin/bash
# Counting to 11 in 10 different ways.

n=1; echo -n "$n "

let "n = $n + 1"   # let "n = n + 1"  also works.
echo -n "$n "


: $((n = $n + 1))
#  ":" necessary because otherwise Bash attempts
#+ to interpret "$((n = $n + 1))" as a command.
echo -n "$n "

(( n = n + 1 ))
#  A simpler alternative to the method above.
#  Thanks, David Lombard, for pointing this out.
echo -n "$n "

n=$(($n + 1))
echo -n "$n "

: $[ n = $n + 1 ]
#  ":" necessary because otherwise Bash attempts
#+ to interpret "$[ n = $n + 1 ]" as a command.
#  Works even if "n" was initialized as a string.
echo -n "$n "

n=$[ $n + 1 ]
#  Works even if "n" was initialized as a string.
#* Avoid this type of construct, since it is obsolete and nonportable.
#  Thanks, Stephane Chazelas.
echo -n "$n "

# Now for C-style increment operators.
# Thanks, Frank Wang, for pointing this out.

let "n++"          # let "++n"  also works.
echo -n "$n "

(( n++ ))          # (( ++n ))  also works.
echo -n "$n "

: $(( n++ ))       # : $(( ++n )) also works.
echo -n "$n "

: $[ n++ ]         # : $[ ++n ] also works
echo -n "$n "

echo

exit 0
}

Note: Integer variables in older versions of Bash were signed long
(32-bit) integers, in the range of -2147483648 to 2147483647. An
operation that took a variable outside these limits gave an erroneous
result.

Example:
◊example{
echo $BASH_VERSION   # 1.14

a=2147483646
echo "a = $a"        # a = 2147483646
let "a+=1"           # Increment "a".
echo "a = $a"        # a = 2147483647
let "a+=1"           # increment "a" again, past the limit.
echo "a = $a"        # a = -2147483648
                     #      ERROR: out of range,
                     # +    and the leftmost bit, the sign bit,
                     # +    has been set, making the result negative.
}

As of version >= 2.05b, Bash supports 64-bit integers.

Caution: Bash does not understand floating point arithmetic. It treats
numbers containing a decimal point as strings.

Example:
◊example{
a=1.5

let "b = $a + 1.3"  # Error.
# t2.sh: let: b = 1.5 + 1.3: syntax error in expression
#                            (error token is ".5 + 1.3")

echo "b = $b"       # b=1
}

Use ◊fname{bc} in scripts that that need floating point calculations
or math library functions.

}

} ◊; definition-block{}

◊section{Bitwise operators}

◊definition-block[#:type "code"]{
◊definition-entry[#:name "<<"]{
bitwise left shift (multiplies by 2 for each shift position)

}
}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
