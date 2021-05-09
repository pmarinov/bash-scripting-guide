#lang pollen

◊page-init{}
◊define-meta[page-title]{Variable types}
◊define-meta[page-description]{Variable types: declare or typeset}

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

◊definition-entry[#:name "-a"]{
array

◊example{
declare -a indices
}

The variable ◊code{indices} will be treated as an array.

}

◊definition-entry[#:name "-f"]{
function

◊example{
declare -f
}

A ◊code{declare -f} line with no arguments in a script causes a
listing of all the functions previously defined in that script.

◊example{
declare -f function_name
}

A ◊code{declare -f function_name} in a script lists just the function
named.

}

◊definition-entry[#:name "-x"]{
export

◊example{
declare -x var3
}

This declares a variable as available for exporting outside the
environment of the script itself.

}

◊definition-entry[#:name "-x"]{
var=$value

◊example{
declare -x var3=373
}

The ◊code{declare} command permits assigning a value to a variable in
the same statement as setting its properties.

}

} ◊; definition-block

◊section-example[#:anchor "decl_vars1"]{Using declare to type variables}

◊example{
#!/bin/bash

func1 ()
{
  echo This is a function.
}

declare -f        # Lists the function above.

echo

declare -i var1   # var1 is an integer.
var1=2367
echo "var1 declared as $var1"
var1=var1+1       # Integer declaration eliminates the need for 'let'.
echo "var1 incremented by 1 is $var1."
# Attempt to change variable declared as integer.
echo "Attempting to change var1 to floating point value, 2367.1."
var1=2367.1       # Results in error message, with no change to variable.
echo "var1 is still $var1"

echo

declare -r var2=13.36         # 'declare' permits setting a variable property
                              #+ and simultaneously assigning it a value.
echo "var2 declared as $var2" # Attempt to change readonly variable.
var2=13.37                    # Generates error message, and exit from script.

echo "var2 is still $var2"    # This line will not execute.

exit 0                        # Script will not exit here.
}

Caution: Using the ◊code{declare} builtin restricts the scope of a variable.

◊example{
foo ()
{
FOO="bar"
}

bar ()
{
foo
echo $FOO
}

bar   # Prints bar.
}

However . . .

◊example{
foo (){
declare FOO="bar"
}

bar ()
{
foo
echo $FOO
}

bar  # Prints nothing.


# Thank you, Michael Iatrou, for pointing this out.
}

◊section{Another use for declare}

The ◊command{declare} command can be helpful in identifying variables,
environmental or otherwise. This can be especially useful with arrays.

◊example{
bash$ declare | grep HOME
HOME=/home/bozo


bash$ zzy=68
bash$ declare | grep zzy
zzy=68


bash$ Colors=([0]="purple" [1]="reddish-orange" [2]="light green")
bash$ echo ${Colors[@]}
purple reddish-orange light green
bash$ declare | grep Colors
Colors=([0]="purple" [1]="reddish-orange" [2]="light green")
}

