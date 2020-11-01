#lang pollen

◊page-init{}
◊define-meta[page-title]{Precedence}
◊define-meta[page-description]{Operator Precedence}

◊section{Precedence}

◊definition-block[#:type "code"]{
◊definition-entry[#:name "var++ var--"]{
post-increment, post-decrement (C-style)
}
◊definition-entry[#:name "++var --var"]{
pre-increment, pre-decrement
}
◊definition-entry[#:name "! ~"]{
negation
}
◊definition-entry[#:name "**"]{
exponentiation (arithmetic operation)
}
◊definition-entry[#:name "* / %"]{
multiplication, division, modulo (arithmetic operation)
}
◊definition-entry[#:name "+ -"]{
addition, subtraction (arithmetic operation)
}
◊definition-entry[#:name "<< >>"]{
left, right shift (bitwise)
}
◊definition-entry[#:name "-z -n"]{
unary comparison (string is/is-not null)
}
◊definition-entry[#:name "-e -f -t -x, etc."]{
unary comparison (file-test)
}
◊definition-entry[#:name "< -lt > -gt <= -le >= -ge"]{
compound comparison	(string and integer)
}
◊definition-entry[#:name "-nt -ot -ef"]{
compound comparison (file-test)
}
◊definition-entry[#:name "== -eq != -ne"]{
equality / inequality (test operators, string and integer)
}
◊definition-entry[#:name "&"]{
AND	(bitwise)
}
◊definition-entry[#:name "^"]{
XOR	(exclusive OR, bitwise)
}
◊definition-entry[#:name "|"]{
OR (bitwise)
}
◊definition-entry[#:name "&& -a"]{
AND	(logical, compound comparison)
}
◊definition-entry[#:name "|| -o"]{
OR (logical, compound comparison)
}
◊definition-entry[#:name "?:"]{
trinary operator (C-style)
}
◊definition-entry[#:name "="]{
assignment (do not confuse with equality test)
}
◊definition-entry[#:name "*= /= %= += -= <<= >>= &="]{
combination assignment (times-equal, divide-equal, mod-equal, etc.)
}
◊definition-entry[#:name ","]{
comma (links a sequence of operations)
}

} ◊; definition-block{}

◊section{Mental shortcut}

In practice, all you really need to remember is the following:

◊list-block[#:type "bullet"]{

◊list-entry{The "My Dear Aunt Sally" mantra (multiply, divide, add,
subtract) for the familiar arithmetic operations.}

◊list-entry{The compound logical operators, ◊code{&&}, ◊code{||},
◊code{-a}, and ◊code{-o} have low precedence.}

◊list-entry{The order of evaluation of equal-precedence operators is
usually left-to-right.}

}

◊section{Examples}

Now, let's utilize our knowledge of operator precedence to analyze a
couple of lines from the ◊fpath{/etc/init.d/functions} file, as found
in the Fedora Core Linux distro.

◊example{
while [ -n "$remaining" -a "$retry" -gt 0 ]; do

# This looks rather daunting at first glance.


# Separate the conditions:
while [ -n "$remaining" -a "$retry" -gt 0 ]; do
#       --condition 1-- ^^ --condition 2-

#  If variable "$remaining" is not zero length
#+      AND (-a)
#+ variable "$retry" is greater-than zero
#+ then
#+ the [ expresion-within-condition-brackets ] returns success (0)
#+ and the while-loop executes an iteration.
#  ==============================================================
#  Evaluate "condition 1" and "condition 2" ***before***
#+ ANDing them. Why? Because the AND (-a) has a lower precedence
#+ than the -n and -gt operators,
#+ and therefore gets evaluated *last*.

#################################################################

if [ -f /etc/sysconfig/i18n -a -z "${NOLOCALE:-}" ] ; then


# Again, separate the conditions:
if [ -f /etc/sysconfig/i18n -a -z "${NOLOCALE:-}" ] ; then
#    --condition 1--------- ^^ --condition 2-----

#  If file "/etc/sysconfig/i18n" exists
#+      AND (-a)
#+ variable $NOLOCALE is zero length
#+ then
#+ the [ test-expresion-within-condition-brackets ] returns success (0)
#+ and the commands following execute.
#
#  As before, the AND (-a) gets evaluated *last*
#+ because it has the lowest precedence of the operators within
#+ the test brackets.
#  ==============================================================
#  Note:
#  ${NOLOCALE:-} is a parameter expansion that seems redundant.
#  But, if $NOLOCALE has not been declared, it gets set to *null*,
#+ in effect declaring it.
#  This makes a difference in some contexts.
}

Tip: To avoid confusion or error in a complex sequence of test
operators, break up the sequence into bracketed sections.

◊example{
if [ "$v1" -gt "$v2"  -o  "$v1" -lt "$v2"  -a  -e "$filename" ]
# Unclear what's going on here...

if [[ "$v1" -gt "$v2" ]] || [[ "$v1" -lt "$v2" ]] && [[ -e "$filename" ]]
# Much better -- the condition tests are grouped in logical sections.
}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
