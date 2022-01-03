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



