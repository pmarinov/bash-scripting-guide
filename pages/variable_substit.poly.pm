#lang pollen

◊define-meta[page-title]{Variable Substitution}
◊define-meta[page-description]{Retrieving values of variables}

◊dfn{Variables} are how programming and scripting languages represent
data. A variable is nothing more than a label, a name assigned to a
location or set of locations in computer memory holding an item of
data.

Variables appear in arithmetic operations and manipulation of
quantities, and in string parsing.

The name of a variable is a placeholder for its value, the data it
holds. Referencing (retrieving) its value is called variable
substitution.

◊section{$ -- Reference to a variable's value}

Let us carefully distinguish between the ◊emphasize{name} of a
variable and its ◊emphasize{value}. If ◊code{variable1} is the name of
a variable, then ◊code{$variable1} is a reference to its value, the
data item it contains. ◊footnote{Technically, the name of a variable
is called an ◊dfn{lvalue}, meaning that it appears on the left side of
an assignment statment, as in ◊code{VARIABLE=23}. A variable's value
is an rvalue, meaning that it appears on the right side of an
assignment statement, as in ◊code{VAR2=$VARIABLE}.

A variable's name is, in fact, a reference, a ◊emphasize{pointer} to
the memory location(s) where the actual data associated with that
variable is kept.}

◊example{
bash$ variable1=23


bash$ echo variable1
variable1

bash$ echo $variable1
23
}

The only times a variable appears "naked" -- without the $ prefix --
is when declared or assigned, when ◊emphasize{unset}, when exported,
in an arithmetic expression within double parentheses (( ... )), or in
the special case of a variable representing a signal (see Example
32-5). Assignment may be with an = (as in ◊code{var1=27}), in a
◊emphasize{read} statement, and at the head of a loop (◊code{for var2
in 1 2 3}).

Enclosing a referenced value in ◊emphasize{double quotes} (" ... ")
does not interfere with variable substitution. This is called
◊dfn{partial quoting}, sometimes referred to as "weak quoting." Using
single quotes (' ... ') causes the variable name to be used literally,
and no substitution will take place. This is ◊dfn{full quoting},
sometimes referred to as 'strong quoting.' TODO: See Chapter 5 for a
detailed discussion.

Note that ◊code{$variable} is actually a simplified form of
◊code{$◊escaped{◊"{"}variable◊escaped{◊"}"}}. In contexts where the
◊code{$variable} syntax causes an error, the longer form may work (see
Section 10.2, below).

◊section-example[#:anchor "var_assignment1"]{Variable assignment and
substitution}

◊example{
#!/bin/bash
# ex9.sh

# Variables: assignment and substitution

a=375
hello=$a
#   ^ ^

#-------------------------------------------------------------------------
# No space permitted on either side of = sign when initializing variables.
# What happens if there is a space?

#  "VARIABLE =value"
#           ^
#% Script tries to run "VARIABLE" command with one argument, "=value".

#  "VARIABLE= value"
#            ^
#% Script tries to run "value" command with
#+ the environmental variable "VARIABLE" set to "".
#-------------------------------------------------------------------------


echo hello    # hello
# Not a variable reference, just the string "hello" ...

echo $hello   # 375
#    ^          This *is* a variable reference.
echo ${hello} # 375
#               Likewise a variable reference, as above.

# Quoting . . .
echo "$hello"    # 375
echo "${hello}"  # 375

echo

hello="A B  C   D"
echo $hello   # A B C D
echo "$hello" # A B  C   D
# As we see, echo $hello   and   echo "$hello"   give different results.
# =======================================
# Quoting a variable preserves whitespace.
# =======================================

echo

echo '$hello'  # $hello
#    ^      ^
#  Variable referencing disabled (escaped) by single quotes,
#+ which causes the "$" to be interpreted literally.

# Notice the effect of different types of quoting.


hello=    # Setting it to a null value.
echo "\$hello (null value) = $hello"      # $hello (null value) =
#  Note that setting a variable to a null value is not the same as
#+ unsetting it, although the end result is the same (see below).

# --------------------------------------------------------------

#  It is permissible to set multiple variables on the same line,
#+ if separated by white space.
#  Caution, this may reduce legibility, and may not be portable.

var1=21  var2=22  var3=$V3
echo
echo "var1=$var1   var2=$var2   var3=$var3"

# May cause problems with legacy versions of "sh" . . .

# --------------------------------------------------------------

echo; echo

numbers="one two three"
#           ^   ^
other_numbers="1 2 3"
#               ^ ^
#  If there is whitespace embedded within a variable,
#+ then quotes are necessary.
#  other_numbers=1 2 3                  # Gives an error message.
echo "numbers = $numbers"
echo "other_numbers = $other_numbers"   # other_numbers = 1 2 3
#  Escaping the whitespace also works.
mixed_bag=2\ ---\ Whatever
#           ^    ^ Space after escape (\).

echo "$mixed_bag"         # 2 --- Whatever

echo; echo

echo "uninitialized_variable = $uninitialized_variable"
# Uninitialized variable has null value (no value at all!).
uninitialized_variable=   #  Declaring, but not initializing it --
                          #+ same as setting it to a null value, as above.
echo "uninitialized_variable = $uninitialized_variable"
                          # It still has a null value.

uninitialized_variable=23       # Set it.
unset uninitialized_variable    # Unset it.
echo "uninitialized_variable = $uninitialized_variable"
                                # uninitialized_variable =
                                # It still has a null value.
echo

exit 0
}

◊section{Caution}

An uninitialized variable has a "null" value -- no assigned value at
all (◊emphasize{not} zero!).

◊example{
if [ -z "$unassigned" ]
then
  echo "\$unassigned is NULL."
fi     # $unassigned is NULL.
}

Using a variable before assigning a value to it may cause problems. It
is nevertheless possible to perform arithmetic operations on an
uninitialized variable.

◊example{
echo "$uninitialized"                                # (blank line)
let "uninitialized += 5"                             # Add 5 to it.
echo "$uninitialized"                                # 5

#  Conclusion:
#  An uninitialized variable has no value,
#+ however it evaluates as 0 in an arithmetic operation.
}

TODO: See also Example 15-23.

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
