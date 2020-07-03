#lang pollen

◊define-meta[page-title]{Double parens}
◊define-meta[page-description]{The Double-Parentheses Construct}

Similar to the let command, the ◊code{(( ... ))} construct permits
arithmetic expansion and evaluation. In its simplest form, ◊code{a=$((
5 + 3 ))} would set ◊code{a} to ◊code{5 + 3}, or ◊code{8}. However,
this double-parentheses construct is also a mechanism for allowing
C-style manipulation of variables in Bash, for example, ◊coe{(( var++
))}.

◊section-example[#:anchor "cstyle_vars1"]{C-style manipulation of variables}

◊example{
#!/bin/bash
# c-vars.sh
# Manipulating a variable, C-style, using the (( ... )) construct.


echo

(( a = 23 ))  #  Setting a value, C-style,
              #+ with spaces on both sides of the "=".
echo "a (initial value) = $a"   # 23

(( a++ ))     #  Post-increment 'a', C-style.
echo "a (after a++) = $a"       # 24

(( a-- ))     #  Post-decrement 'a', C-style.
echo "a (after a--) = $a"       # 23


(( ++a ))     #  Pre-increment 'a', C-style.
echo "a (after ++a) = $a"       # 24

(( --a ))     #  Pre-decrement 'a', C-style.
echo "a (after --a) = $a"       # 23

echo

########################################################
#  Note that, as in C, pre- and post-decrement operators
#+ have different side-effects.

n=1; let --n && echo "True" || echo "False"  # False
n=1; let n-- && echo "True" || echo "False"  # True

#  Thanks, Jeroen Domburg.
########################################################

echo

(( t = a<45?7:11 ))   # C-style trinary operator.
#       ^  ^ ^
echo "If a < 45, then t = 7, else t = 11."  # a = 23
echo "t = $t "                              # t = 7

echo


# -----------------
# Easter Egg alert!
# -----------------
#  Chet Ramey seems to have snuck a bunch of undocumented C-style
#+ constructs into Bash (actually adapted from ksh, pretty much).
#  In the Bash docs, Ramey calls (( ... )) shell arithmetic,
#+ but it goes far beyond that.
#  Sorry, Chet, the secret is out.

# See also "for" and "while" loops using the (( ... )) construct.

# These work only with version 2.04 or later of Bash.

exit

}

TODO See also Example 11-13 and Example 8-4.

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
