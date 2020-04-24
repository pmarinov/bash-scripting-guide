#lang pollen

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


◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
