#lang pollen

◊define-meta[page-title]{Exit Status}
◊define-meta[page-description]{Exiting and Exit Status}

◊quotation[#:author "Chet Ramey"]{... there are dark corners in the
Bourne shell, and people use all of them.}

The  ◊code{exit}   command  terminates   a  script,   just  as   in  a
◊emphasize{C} program. It can also  return a value, which is available
to the script's parent process.

Every command returns an ◊emphasize{exit status} (sometimes referred
to as a ◊emphasize{return status} or ◊emphasize{exit code}). A
successful command returns a 0, while an unsuccessful one returns a
non-zero value that usually can be interpreted as an ◊emphasize{error
code}. Well-behaved UNIX commands, programs, and utilities return a 0
exit code upon successful completion, though there are some
exceptions.

Likewise, functions within a script and the script itself return an
exit status. The last command executed in the function or script
determines the exit status. Within a script, an ◊code{exit nnn}
command may be used to deliver an ◊code{nnn} exit status to the shell
(◊code{nnn} must be an integer in the 0 - 255 range).

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
