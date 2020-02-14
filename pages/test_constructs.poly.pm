#lang pollen

◊define-meta[page-title]{Test constructs}
◊define-meta[page-description]{Tests constructs}

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

} ◊; list-block

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
