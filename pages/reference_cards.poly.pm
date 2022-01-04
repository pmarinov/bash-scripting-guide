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



