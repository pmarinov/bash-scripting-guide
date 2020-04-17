#lang pollen

◊define-meta[page-title]{Other comparison}
◊define-meta[page-description]{Other comparison operators}

A binary comparison operator compares two variables or
quantities. ◊strong{Note that} integer and string comparison use a
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

}  ◊; definition-block{}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
