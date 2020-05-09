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

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
