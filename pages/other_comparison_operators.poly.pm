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

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
