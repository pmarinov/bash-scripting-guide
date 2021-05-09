#lang pollen

◊page-init{}
◊define-meta[page-title]{Untyped variables}
◊define-meta[page-description]{Bash Variables Are Untyped}

Unlike many other programming languages, Bash does not segregate its
variables by "type." Essentially, Bash variables are character
strings, but, depending on context, Bash permits arithmetic operations
and comparisons on variables. The determining factor is whether the
value of a variable contains only digits.

◊section-example[#:anchor "varassign_int_or_str"]{Integer or string?}

◊example{
#!/bin/bash
# int-or-string.sh

a=2334                   # Integer.
let "a += 1"
echo "a = $a "           # a = 2335
echo                     # Integer, still.


b=${a/23/BB}             # Substitute "BB" for "23".
                         # This transforms $b into a string.
echo "b = $b"            # b = BB35
declare -i b             # Declaring it an integer doesn't help.
echo "b = $b"            # b = BB35

let "b += 1"             # BB35 + 1
echo "b = $b"            # b = 1
echo                     # Bash sets the "integer value" of a string to 0.

c=BB34
echo "c = $c"            # c = BB34
d=${c/BB/23}             # Substitute "23" for "BB".
                         # This makes $d an integer.
echo "d = $d"            # d = 2334
let "d += 1"             # 2334 + 1
echo "d = $d"            # d = 2335
echo


# What about null variables?
e=''                     # ... Or e="" ... Or e=
echo "e = $e"            # e =
let "e += 1"             # Arithmetic operations allowed on a null variable?
echo "e = $e"            # e = 1
echo                     # Null variable transformed into an integer.

# What about undeclared variables?
echo "f = $f"            # f =
let "f += 1"             # Arithmetic operations allowed?
echo "f = $f"            # f = 1
echo                     # Undeclared variable transformed into an integer.
#
# However ...
let "f /= $undecl_var"   # Divide by zero?
#   let: f /= : syntax error: operand expected (error token is " ")
# Syntax error! Variable $undecl_var is not set to zero here!
#
# But still ...
let "f /= 0"
#   let: f /= 0: division by 0 (error token is "0")
# Expected behavior.


#  Bash (usually) sets the "integer value" of null to zero
#+ when performing an arithmetic operation.
#  But, don't try this at home, folks!
#  It's undocumented and probably non-portable behavior.


# Conclusion: Variables in Bash are untyped,
#+ with all attendant consequences.

exit $?
}

Untyped variables are both a blessing and a curse. They permit more
flexibility in scripting and make it easier to grind out lines of code
(and give you enough rope to hang yourself!). However, they likewise
permit subtle errors to creep in and encourage sloppy programming
habits.

To lighten the burden of keeping track of variable types in a script,
Bash does permit ◊emphasize{declaring} variables.

