#lang pollen

◊page-init{}
◊define-meta[page-title]{Other comparison}
◊define-meta[page-description]{Other comparison operators}

A binary comparison operator compares two variables or
quantities. ◊strong{Note} that integer and string comparison use a
◊strong{different} set of operators.

◊section{Integer comparison}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "-eq"]{
Is ◊strong{equal} to

◊example{
if [ "$a" -eq "$b" ]
}

}

◊definition-entry[#:name "-ne"]{
Is ◊strong{no equal} to

◊example{
if [ "$a" -ne "$b" ]
}

}

◊definition-entry[#:name "-gt"]{
Is ◊strong{greater than} to

◊example{
if [ "$a" -gt "$b" ]
}

}

◊definition-entry[#:name "-ge"]{
Is ◊strong{greater than or equal} to

◊example{
if [ "$a" -ge "$b" ]
}

}

◊definition-entry[#:name "-lt"]{
Is ◊strong{less than} to

◊example{
if [ "$a" -lt "$b" ]
}

}

◊definition-entry[#:name "-le"]{
Is ◊strong{less than or equal} to

◊example{
if [ "$a" -le "$b" ]
}

}

◊definition-entry[#:name "<"]{
Is ◊strong{less than} (within double parentheses)

◊example{
(( "$a" < "$b" ))
}

}

◊definition-entry[#:name "<="]{
Is ◊strong{less than or equal} to (within double parentheses)

◊example{
(( "$a" <= "$b" ))
}

}

◊definition-entry[#:name ">"]{
Is ◊strong{greater than} (within double parentheses)

◊example{
(( "$a" > "$b" ))
}

}

◊definition-entry[#:name ">="]{
Is ◊strong{greater than or equal} to (within double parentheses)

◊example{
(( "$a" >= "$b" ))
}

}


}  ◊; definition-block{}

◊section{String comparison}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "="]{
Is ◊strong{equal} to

◊example{
if [ "$a" = "$b" ]
}

Caution: Note the whitespace framing the ◊code{=}!

◊code{if [ "$a"="$b" ]} is not equivalent to the above.

}

◊definition-entry[#:name "=="]{
Is ◊strong{equal} to

◊example{
if [ "$a" == "$b" ]
}

This is a synonym for ◊code{=}.

Note: The ◊code{==} comparison operator behaves differently within a
double-brackets test than within single brackets.

◊example{
[[ $a == z* ]]   # True if $a starts with an "z" (pattern matching).
[[ $a == "z*" ]] # True if $a is equal to z* (literal matching).

[ $a == z* ]     # File globbing and word splitting take place.
[ "$a" == "z*" ] # True if $a is equal to z* (literal matching).

# Thanks, Stéphane Chazelas
}

}

◊definition-entry[#:name "!="]{
Is ◊strong{not equal} to

◊example{
if [ "$a" != "$b" ]
}

This operator uses pattern matching within a ◊code{[[ ... ]]}
construct.

}

◊definition-entry[#:name "<"]{
Is ◊strong{less than} in ASCII alphabetical order

◊example{
if [[ "$a" < "$b" ]]

if [ "$a" \< "$b" ]
}

Note that the ◊code{<} needs to be escaped within a ◊code{[ ]}
construct.

}

◊definition-entry[#:name ">"]{
Is ◊strong{greater than} in ASCII alphabetical order

◊example{
if [[ "$a" > "$b" ]]

if [ "$a" \> "$b" ]
}

Note that the ◊code{>} needs to be escaped within a ◊code{[ ]}
construct.

TODO: See example for an application of this operator
}

◊definition-entry[#:name "-z"]{
String ◊strong{is null}, that is, has zero length

◊example{
String=''   # Zero-length ("null") string variable.

if [ -z "$String" ]
then
  echo "\$String is null."
else
  echo "\$String is NOT null."
fi     # $String is null.
}
}

◊definition-entry[#:name "-n"]{
String ◊strong{is not null}

Caution: The ◊code{-n} test requires that the string be quoted within
the test brackets. Using an unquoted string with ◊code{!} ◊code{-z},
or even just the unquoted string alone within test brackets (see
Example 7-6) normally works, however, this is an unsafe
practice. Always quote a tested string. ◊footnote{As S.C. points out,
in a compound test, even quoting the string variable might not
suffice. ◊code{[ -n "$string" -o "$a" = "$b" ]} may cause an error
with some versions of Bash if ◊code{$string} is empty. The safe way is
to append an extra character to possibly empty variables, ◊code{[
"x$string" != x -o "x$a" = "x$b" ]} (the "x's" cancel out).}

}

}  ◊; definition-block{}

◊section-example[#:anchor "test_nullstr1"]{Testing whether a string is
null}

◊example{
#!/bin/bash
#  str-test.sh: Testing null strings and unquoted strings,
#+ but not strings and sealing wax, not to mention cabbages and kings . . .

# Using   if [ ... ]

# If a string has not been initialized, it has no defined value.
# This state is called "null" (not the same as zero!).

if [ -n $string1 ]    # string1 has not been declared or initialized.
then
  echo "String \"string1\" is not null."
else  
  echo "String \"string1\" is null."
fi                    # Wrong result.
# Shows $string1 as not null, although it was not initialized.

echo

# Let's try it again.

if [ -n "$string1" ]  # This time, $string1 is quoted.
then
  echo "String \"string1\" is not null."
else  
  echo "String \"string1\" is null."
fi                    # Quote strings within test brackets!

echo

if [ $string1 ]       # This time, $string1 stands naked.
then
  echo "String \"string1\" is not null."
else  
  echo "String \"string1\" is null."
fi                    # This works fine.
# The [ ... ] test operator alone detects whether the string is null.
# However it is good practice to quote it (if [ "$string1" ]).
#
# As Stephane Chazelas points out,
#    if [ $string1 ]    has one argument, "]"
#    if [ "$string1" ]  has two arguments, the empty "$string1" and "]" 


echo


string1=initialized

if [ $string1 ]       # Again, $string1 stands unquoted.
then
  echo "String \"string1\" is not null."
else  
  echo "String \"string1\" is null."
fi                    # Again, gives correct result.
# Still, it is better to quote it ("$string1"), because . . .


string1="a = b"

if [ $string1 ]       # Again, $string1 stands unquoted.
then
  echo "String \"string1\" is not null."
else  
  echo "String \"string1\" is null."
fi                    # Not quoting "$string1" now gives wrong result!

exit 0   # Thank you, also, Florian Wisser, for the "heads-up".
}

◊section-example[#:anchor "zmore1"]{zmore}

◊example{
#!/bin/bash
# zmore

# View gzipped files with 'more' filter.

E_NOARGS=85
E_NOTFOUND=86
E_NOTGZIP=87

if [ $# -eq 0 ] # same effect as:  if [ -z "$1" ]
# $1 can exist, but be empty:  zmore "" arg2 arg3
then
  echo "Usage: `basename $0` filename" >&2
  # Error message to stderr.
  exit $E_NOARGS
  # Returns 85 as exit status of script (error code).
fi  

filename=$1

if [ ! -f "$filename" ]   # Quoting $filename allows for possible spaces.
then
  echo "File $filename not found!" >&2   # Error message to stderr.
  exit $E_NOTFOUND
fi  

if [ ${filename##*.} != "gz" ]
# Using bracket in variable substitution.
then
  echo "File $1 is not a gzipped file!"
  exit $E_NOTGZIP
fi  

zcat $1 | more

# Uses the 'more' filter.
# May substitute 'less' if desired.

exit $?   # Script returns exit status of pipe.
#  Actually "exit $?" is unnecessary, as the script will, in any case,
#+ return the exit status of the last command executed.
}

◊section{Compound Comparison}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "-a"]{
Logical ◊strong{and}

◊code{exp1 -a exp2} returns true if both exp1 and exp2 are true.

}

◊definition-entry[#:name "-o"]{
Logical ◊strong{or}

◊code{exp1 -o exp2} returns true if either exp1 or exp2 is true.

}

} ◊; definition-block{}

These are similar to the Bash comparison operators ◊code{&&} and
◊code{||}, used within double brackets.

◊example{
[[ condition1 && condition2 ]]
}

The ◊code{-o} and ◊code{-a} operators work with the ◊code{test}
command or occur within single test brackets.

◊example{
if [ "$expr1" -a "$expr2" ]
then
  echo "Both expr1 and expr2 are true."
else
  echo "Either expr1 or expr2 is false."
fi
}

Caution: But, as rihad points out:

◊example{
[ 1 -eq 1 ] && [ -n "`echo true 1>&2`" ]   # true
[ 1 -eq 2 ] && [ -n "`echo true 1>&2`" ]   # (no output)
# ^^^^^^^ False condition. So far, everything as expected.

# However ...
[ 1 -eq 2 -a -n "`echo true 1>&2`" ]       # true
# ^^^^^^^ False condition. So, why "true" output?

# Is it because both condition clauses within brackets evaluate?
[[ 1 -eq 2 && -n "`echo true 1>&2`" ]]     # (no output)
# No, that's not it.

# Apparently && and || "short-circuit" while -a and -o do not.
}

TODO: Refer to Example 8-3, Example 27-17, and Example A-29 to see
compound comparison operators in action.

