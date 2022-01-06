#lang pollen

◊page-init{}
◊define-meta[page-title]{Reference Cards}
◊define-meta[page-description]{Reference Cards}

The following reference cards provide a useful summary of certain
scripting concepts. The foregoing text treats these matters in more
depth, as well as giving usage examples.

◊section{Special Shell Variables}

◊example{
+--------+-----------------------------------------------------+
| Var    | Meaning                                             |
|        |                                                     |
| $0     | Filename of script                                  |
| $1     | Positional parameter #1                             |
| $2     | Positional parameter #2                             |
| ...    |                                                     |
| $9     | Positional parameter #9                             |
| ${10}  | Positional parameter #10                            |
| $#     | Number of positional parameters                     |
| "$*"   | All the positional parameters (as a single word) *  |
| "$@"   | All the positional parameters (as separate strings) |
| ${#*}  | Number of positional parameters                     |
| ${#@}  | Number of positional parameters                     |
| $?     | Return value                                        |
| $$     | Process ID (PID) of script                          |
| $-     | Flags passed to script (using set)                  |
| $_     | Last argument of previous command                   |
| $!     | Process ID (PID) of last job run in background      |
+--------+-----------------------------------------------------+
}

* Must be quoted, otherwise it defaults to $@.

◊section{TEST Operators: Binary Comparison}

◊example{
+-----+--------------------------+----+------------------------+
|     | Arithmetic               |    | String                 |
|     |                          |    |                        |
| -eq | Equal to                 | =  | Equal to               |
|     |                          | == | Equal to               |
| -ne | Not equal to             | != | Not equal to           |
| -lt | Less than                | \< | Less than (ASCII) *    |
| -le | Less than or equal to    |    |                        |
| -gt | Greater than             | \> | Greater than (ASCII) * |
| -ge | Greater than or equal to |    |                        |
|     |                          | -z | String is empty        |
|     |                          | -n | String is not empty    |
+-----+--------------------------+----+------------------------+
}

* If within a double-bracket ◊code{[[ ... ]]} test construct, then no
  escape ◊code{\} is needed.

◊section{TEST: Arithmetic Comparison within double parentheses}

Within double parentheses ◊code{(( ... ))}:

◊example{
+----+--------------------------+
| >  | Greater than             |
| >= | Greater than or equal to |
| <  | Less than                |
| <= | Less than or equal to    |
+----+--------------------------+
}

◊section{TEST Operators: Files}

◊example{
+-----------+---------------------------------------------+
|           | Tests Whether                               |
|           |                                             |
| -e        | File exists                                 |
| -f        | File is a regular file                      |
| -d        | File is a directory                         |
| -h        | File is a symbolic link                     |
| -L        | File is a symbolic link                     |
| -b        | File is a block device                      |
| -c        | File is a character device                  |
| -p        | File is a pipe                              |
| -S        | File is a socket                            |
| -t        | File is associated with a terminal          |
| -s        | File is not zero size                       |
| -r        | File has read permission                    |
| -w        | File has write permission                   |
| -x        | File has execute permission                 |
| -g        | sgid flag set                               |
| -u        | suid flag set                               |
| -k        | "sticky bit" set                            |
| -N        | File modified since it was last read        |
| -O        | You own the file                            |
| -G        | Group id of file same as yours              |
| F1 -nt F2 | File F1 is newer than F2                    |
| F1 -ot F2 | File F1 is older than F2                    |
| F1 -ef F2 | Files F1 and F2 are hard links to same file |
| !         | NOT (inverts sense of above tests)          |
+-----------+---------------------------------------------+
}

◊section{Parameter Substitution and Expansion}

◊example{
+------------------+-----------------------------------------------------------+
| Expression       | Meaning                                                   |
|                  |                                                           |
| ${var}           | Value of var (same as $var)                               |
|                  |                                                           |
| ${var-$DEFAULT}  | If var not set,                                           |
|                  | evaluate expression as $DEFAULT *                         |
|                  |                                                           |
| ${var:-$DEFAULT} | If var not set or is empty,                               |
|                  | evaluate expression as $DEFAULT *                         |
|                  |                                                           |
| ${var=$DEFAULT}  | If var not set,                                           |
|                  | evaluate expression as $DEFAULT *                         |
|                  |                                                           |
| ${var:=$DEFAULT} | If var not set or is empty,                               |
|                  | evaluate expression as $DEFAULT *                         |
|                  |                                                           |
| ${var+$OTHER}    | If var set,                                               |
|                  | evaluate expression as $OTHER, otherwise as null string   |
|                  |                                                           |
| ${var:+$OTHER}   | If var set,                                               |
|                  | evaluate expression as $OTHER, otherwise as null string   |
|                  |                                                           |
| ${var?$ERR_MSG}  | If var not set,                                           |
|                  | print $ERR_MSG and abort script with an exit status of 1. |
|                  |                                                           |
| ${var:?$ERR_MSG} | If var not set,                                           |
|                  | print $ERR_MSG and abort script with an exit status of 1. |
|                  |                                                           |
| ${!varprefix*}   | Matches all previously declared variables                 |
|                  | beginning with varprefix                                  |
|                  |                                                           |
| ${!varprefix@}   | Matches all previously declared variables                 |
|                  | beginning with varprefix                                  |
+------------------+-----------------------------------------------------------+
}

* If ◊code{var} is set, evaluate the expression as ◊code{$var} with no
  side-effects.

Note: Some of the above behavior of operators has changed from earlier
versions of Bash.

◊section{String Operations}

◊example{
+----------------------------------+---------------------------------------------+
| Expression                       | Meaning                                     |
|----------------------------------+---------------------------------------------|
| ${#string}                       | Length of $string                           |
|                                  |                                             |
| ${string:position}               | Extract from $string at $position           |
|                                  |                                             |
| ${string:position:length}        | Extract $length characters from $string     |
|                                  | at $position [starting from 0]              |
|                                  |                                             |
| ${string#substring}              | Strip shortest match of $substring from     |
|                                  | front of $string                            |
|                                  |                                             |
| ${string##substring}             | Strip longest match of $substring from      |
|                                  | front of $string                            |
|                                  |                                             |
| ${string%substring}              | Strip shortest match of $substring from     |
|                                  | back of $string                             |
|                                  |                                             |
| ${string%%substring}             | Strip longest match of $substring           |
|                                  | from back of $string                        |
|                                  |                                             |
| ${string/substring/replacement}  | Replace first match of $substring           |
|                                  | with $replacement                           |
|                                  |                                             |
| ${string//substring/replacement} | Replace all matches of $substring           |
|                                  | with $replacement                           |
|                                  |                                             |
| ${string/#substring/replacement} | If $substring matches front end of $string, |
|                                  | substitute $replacement for $substring      |
|                                  |                                             |
| ${string/%substring/replacement} | If $substring matches back end of $string,  |
|                                  | substitute $replacement for $substring      |
+----------------------------------+---------------------------------------------+
}

◊section{String Operations with 'expr'}

◊example{
+-----------------------------------------+-----------------------------------------------------+
| Expression                              | Meaning                                             |
|-----------------------------------------+-----------------------------------------------------|
| expr match "$string" '$substring'       | Length of matching $substring*                      |
|                                         | at beginning of $string                             |
|                                         |                                                     |
| expr "$string" : '$substring'           | Length of matching $substring*                      |
|                                         | at beginning of $string                             |
|                                         |                                                     |
| expr index "$string" $substring         | Numerical position in $string of first character in |
|                                         | $substring* that matches [0 if no match, first      |
|                                         | character counts as position 1]                     |
|                                         |                                                     |
| expr substr $string $position $length   | Extract $length characters from $string starting    |
|                                         | at $position [0 if no match, first character counts |
|                                         | as position 1]                                      |
|                                         |                                                     |
| expr match "$string" '\($substring\)'   | Extract $substring*, searching from beginning       |
|                                         |                                                     |
| expr "$string" : '\($substring\)'       | Extract $substring* , searching from beginning      |
|                                         |                                                     |
| expr match "$string" '.*\($substring\)' | Extract $substring*, searching from end             |
|                                         |                                                     |
| expr "$string" : '.*\($substring\)'     | Extract $substring*, searching from end             |
+-----------------------------------------+-----------------------------------------------------+
}

* Where ◊code{$substring} is a Regular Expression.

◊section{Miscellaneous Constructs}

◊example{
+-----------------------------+-------------------------------------------------+
| Brackets                    |                                                 |
| if [ CONDITION ]            | Test construct                                  |
| if [[ CONDITION ]]          | Extended test construct                         |
| Array[1]=element1           | Array initialization                            |
| [a-z]                       | Range of characters within a Regular Expression |
|                             |                                                 |
| Curly Brackets              |                                                 |
| ${variable}                 | Parameter substitution                          |
| ${!variable}                | Indirect variable reference                     |
| { cmd1; cmd2; . . . cmdN; } | Block of code                                   |
| {str1,str2,str3,...}        | Brace expansion                                 |
| {a..z}                      | Extended brace expansion                        |
| {}                          | Text replacement, after find and xargs          |
|                             |                                                 |
| Parentheses                 |                                                 |
| ( command1; command2 )      | Command group executed within a subshell        |
| Array=(elem1 elem2 elem3)   | Array initialization                            |
| result=$(COMMAND)           | Command substitution, new style                 |
| >(COMMAND)                  | Process substitution                            |
| <(COMMAND)                  | Process substitution                            |
|                             |                                                 |
| Double Parentheses          |                                                 |
| (( var = 78 ))              | Integer arithmetic                              |
| var=$(( 20 + 5 ))           | Integer arithmetic, with variable assignment    |
| (( var++ ))                 | C-style variable increment                      |
| (( var-- ))                 | C-style variable decrement                      |
| (( var0 = var1<98?9:21 ))   | C-style ternary operation                       |
|                             |                                                 |
| Quoting                     |                                                 |
| "$variable"                 | "Weak" quoting                                  |
| 'string'                    | 'Strong' quoting                                |
|                             |                                                 |
| Back Quotes                 |                                                 |
| result=`COMMAND`            | Command substitution, classic style             |
+-----------------------------+-------------------------------------------------+
}

