#lang pollen

◊define-meta[page-title]{Test constructs}
◊define-meta[page-description]{Tests constructs}

◊section{Testing values}

◊list-block[#:type "bullet"]{

◊list-entry{An ◊code{if/then} construct tests whether the exit status
of a list of commands is 0 (since 0 means "success" by UNIX
convention), and if so, executes one or more commands.  }

◊list-entry{There exists a dedicated command called ◊code{[} (left
bracket special character). It is a synonym for ◊code{test}, and a
◊emphasize{builtin} for efficiency reasons. This command considers its
arguments as comparison expressions or file tests and returns an exit
status corresponding to the result of the comparison (0 for true, 1
for false).
}

◊list-entry{With version 2.02, Bash introduced the ◊code{[[ ... ]]}
extended test command, which performs comparisons in a manner more
familiar to programmers from other languages. Note that ◊code{[[} is a
keyword, not a command.

Bash sees ◊code{[[ $a -lt $b ]]} as a single element, which returns an
exit status.
}

◊list-entry{The ◊code{(( ... ))} and ◊code{let ...} constructs return
an exit status, according to whether the arithmetic expressions they
evaluate expand to a non-zero value. These arithmetic-expansion
constructs may therefore be used to perform arithmetic comparisons.

◊example{
(( 0 && 1 ))                 # Logical AND
echo $?     # 1     ***
# And so ...
let "num = (( 0 && 1 ))"
echo $num   # 0
# But ...
let "num = (( 0 && 1 ))"
echo $?     # 1     ***


(( 200 || 11 ))              # Logical OR
echo $?     # 0     ***
# ...
let "num = (( 200 || 11 ))"
echo $num   # 1
let "num = (( 200 || 11 ))"
echo $?     # 0     ***


(( 200 | 11 ))               # Bitwise OR
echo $?                      # 0     ***
# ...
let "num = (( 200 | 11 ))"
echo $num                    # 203
let "num = (( 200 | 11 ))"
echo $?                      # 0     ***

# The "let" construct returns the same exit status
#+ as the double-parentheses arithmetic expansion.
}

Caution: Again, note that the exit status of an arithmetic expression
is not an error value.

◊example{
var=-2 && (( var+=2 ))
echo $?                   # 1

var=-2 && (( var+=2 )) && echo $var
                          # Will not echo $var!
}

}

◊list-entry{An ◊code{if} can test any command, not just conditions
enclosed within brackets.

◊example{
if cmp a b &> /dev/null  # Suppress output.
then echo "Files a and b are identical."
else echo "Files a and b differ."
fi

# The very useful "if-grep" construct:
# -----------------------------------
if grep -q Bash file
  then echo "File contains at least one occurrence of Bash."
fi

word=Linux
letter_sequence=inu
if echo "$word" | grep -q "$letter_sequence"
# The "-q" option to grep suppresses output.
then
  echo "$letter_sequence found in $word"
else
  echo "$letter_sequence not found in $word"
fi


if COMMAND_WHOSE_EXIT_STATUS_IS_0_UNLESS_ERROR_OCCURRED
  then echo "Command succeeded."
  else echo "Command failed."
fi
}

}

} ◊; list-block

◊section-example[#:anchor "whats_truth1"]{What is truth?}

◊example{
#!/bin/bash

#  Tip:
#  If you're unsure how a certain condition might evaluate,
#+ test it in an if-test.

echo

echo "Testing \"0\""
if [ 0 ]      # zero
then
  echo "0 is true."
else          # Or else ...
  echo "0 is false."
fi            # 0 is true.

echo

echo "Testing \"1\""
if [ 1 ]      # one
then
  echo "1 is true."
else
  echo "1 is false."
fi            # 1 is true.

echo

echo "Testing \"-1\""
if [ -1 ]     # minus one
then
  echo "-1 is true."
else
  echo "-1 is false."
fi            # -1 is true.

echo

echo "Testing \"NULL\""
if [ ]        # NULL (empty condition)
then
  echo "NULL is true."
else
  echo "NULL is false."
fi            # NULL is false.

echo

echo "Testing \"xyz\""
if [ xyz ]    # string
then
  echo "Random string is true."
else
  echo "Random string is false."
fi            # Random string is true.

echo

echo "Testing \"\$xyz\""
if [ $xyz ]   # Tests if $xyz is null, but...
              # it's only an uninitialized variable.
then
  echo "Uninitialized variable is true."
else
  echo "Uninitialized variable is false."
fi            # Uninitialized variable is false.

echo

echo "Testing \"-n \$xyz\""
if [ -n "$xyz" ]            # More pedantically correct.
then
  echo "Uninitialized variable is true."
else
  echo "Uninitialized variable is false."
fi            # Uninitialized variable is false.

echo


xyz=          # Initialized, but set to null value.

echo "Testing \"-n \$xyz\""
if [ -n "$xyz" ]
then
  echo "Null variable is true."
else
  echo "Null variable is false."
fi            # Null variable is false.


echo


# When is "false" true?

echo "Testing \"false\""
if [ "false" ]              #  It seems that "false" is just a string ...
then
  echo "\"false\" is true." #+ and it tests true.
else
  echo "\"false\" is false."
fi            # "false" is true.

echo

echo "Testing \"\$false\""  # Again, uninitialized variable.
if [ "$false" ]
then
  echo "\"\$false\" is true."
else
  echo "\"\$false\" is false."
fi            # "$false" is false.
              # Now, we get the expected result.

#  What would happen if we tested the uninitialized variable "$true"?

echo

exit 0
}

Exercise: Explain the behavior of example above.

◊example{
if [ condition-true ]
then
   command 1
   command 2
   ...
else  # Or else ...
      # Adds default code block executing if original condition tests false.
   command 3
   command 4
   ...
fi
}

Note: When ◊code{if} and ◊code{then} are on same line in a condition
test, a semicolon must terminate the ◊code{if} statement. Both
◊code{if} and ◊code{then} are keywords. Keywords (or commands) begin
statements, and before a new statement on the same line begins, the
old one must terminate.

◊example{
if [ -x "$filename" ]; then
}

◊section{Else if and elif}

◊code{elif} is a contraction for else if. The effect is to nest an inner
if/then construct within an outer one.

◊example{
if [ condition1 ]
then
   command1
   command2
   command3
elif [ condition2 ]
# Same as else if
then
   command4
   command5
else
   default-command
fi
}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
