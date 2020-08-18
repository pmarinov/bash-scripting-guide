#lang pollen

◊define-meta[page-title]{Variable types}
◊define-meta[page-description]{Variable types: declare ot typeset}

The ◊code{declare} or ◊code{typeset} builtins, which are exact
synonyms, permit modifying the properties of variables. This is a very
weak form of setting the variable type available in certain
programming languages. The ◊code{declare} command is specific to
version 2 or later of Bash. The ◊code{typeset} command also works in
ksh scripts.

In this context, typing a variable means to classify it and restrict
its properties. For example, a variable declared or typed as an
integer is no longer available for string operations.

◊example{
declare -i intvar

intvar=23
echo "$intvar"   # 23
intvar=stringval
echo "$intvar"   # 0
}

◊section{declare/typeset options}

◊definition-block[#:type "code"]{
◊definition-entry[#:name "-r"]{
readonly

This is the rough equivalent of the C ◊code{const} type qualifier. An
attempt to change the value of a read-only variable fails with an
error message.

◊example{
declare -r var1=1
echo "var1 = $var1"   # var1 = 1

(( var1++ ))          # x.sh: line 4: var1: readonly variable
}

(◊code{declare -r var1} works the same as ◊code{readonly var1})

}

◊definition-entry[#:name "-i"]{
integer

◊example{
declare -i number
# The script will treat subsequent occurrences of "number" as an integer.		

number=3
echo "Number = $number"     # Number = 3

number=three
echo "Number = $number"     # Number = 0
# Tries to evaluate the string "three" as an integer.
}

Certain arithmetic operations are permitted for declared integer
variables without the need for ◊code{expr} or ◊code{let}.

◊example{
n=6/3
echo "n = $n"       # n = 6/3

declare -i n
n=6/3
echo "n = $n"       # n = 2
}

}


} ◊; definition-block

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
