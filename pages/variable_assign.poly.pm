#lang pollen

◊page-init{}
◊define-meta[page-title]{Variable Assignment}
◊define-meta[page-description]{The assignment operator}

◊definition-block[#:type "variables"]{

◊definition-entry[#:name "="]{
◊strong{the assignment operator} (no space ◊emphasize{before} and
◊emphasize{after})

Caution: Do not confuse this with ◊code{=} and ◊code{-eq}, which test,
rather than assign!

Note that ◊code{=} can be either an ◊emphasize{assignment} or a
◊emphasize{test} operator, depending on context.

◊strong{Plain Variable Assignment}

◊example{
#!/bin/bash
# Naked variables

echo

# When is a variable "naked", i.e., lacking the '$' in front?
# When it is being assigned, rather than referenced.

# Assignment
a=879
echo "The value of \"a\" is $a."

# Assignment using 'let'
let a=16+5
echo "The value of \"a\" is now $a."

echo

# In a 'for' loop (really, a type of disguised assignment):
echo -n "Values of \"a\" in the loop are: "
for a in 7 8 9 11
do
  echo -n "$a "
done

echo
echo

# In a 'read' statement (also a type of assignment):
echo -n "Enter \"a\" "
read a
echo "The value of \"a\" is now $a."

echo

exit 0
}

◊strong{Variable Assignment, plain and fancy}

◊example{
#!/bin/bash

a=23              # Simple case
echo $a
b=$a
echo $b

# Now, getting a little bit fancier (command substitution).

a=`echo Hello!`   # Assigns result of 'echo' command to 'a' ...
echo $a
#  Note that including an exclamation mark (!) within a
#+ command substitution construct will not work from the command-line,
#+ since this triggers the Bash "history mechanism."
#  Inside a script, however, the history functions are disabled by default.

a=`ls -l`         # Assigns result of 'ls -l' command to 'a'
echo $a           # Unquoted, however, it removes tabs and newlines.
echo
echo "$a"         # The quoted variable preserves whitespace.
                  # (See the chapter on "Quoting.")

exit 0
}

Variable assignment using the ◊code{$(...)} mechanism (a newer method than
backquotes). This is likewise a form of ◊emphasize{command substitution}.

◊example{
# From /etc/rc.d/rc.local
R=$(cat /etc/redhat-release)
arch=$(uname -m)
}

}  ◊; definition entry
}  ◊; section definitions

