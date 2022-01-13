#lang pollen

◊page-init{}
◊define-meta[page-title]{Exit Codes}
◊define-meta[page-description]{Exit Codes With Special Meanings}

◊definition-block[#:type "variables"]{
◊definition-entry[#:name "1"]{

Catchall for general errors

Example: ◊code{let "var1 = 1/0"}

Miscellaneous errors, such as "divide by zero" and other impermissible
operations

}

◊definition-entry[#:name "2"]{
Misuse of shell builtins (according to Bash documentation)

Example: ◊code{empty_function() ◊escaped{◊"{"}◊escaped{◊"}"}}

Missing keyword or command, or permission problem (and diff return
code on a failed binary file comparison).

}

◊definition-entry[#:name "126"]{

Command invoked cannot execute

Example: ◊code{/dev/null}

Permission problem or command is not an executable

}

◊definition-entry[#:name "127"]{

"command not found"

Possible problem with ◊code{$PATH} or a typo

}

◊definition-entry[#:name "128"]{

Invalid argument to exit

Example: ◊code{exit 3.14159}

◊command{exit} takes only integer args in the range 0 - 255 (see first
footnote)

}

◊definition-entry[#:name "128+n"]{

Fatal error signal "n"

Example: ◊code{kill -9 $PPID}

◊code{$?} returns 137 (128 + 9)

}

◊definition-entry[#:name "130"]{

Script terminated by Control-C

Example: ◊kbd{Ctl-C}

Control-C is fatal error signal 2, (130 = 128 + 2, see above)

}

◊definition-entry[#:name "255*"]{

Exit status out of range

Example: ◊code{exit -1}

◊code{exit} takes only integer args in the range 0 - 255

}

}

According to the above table, exit codes 1 - 2, 126 - 165, and 255
have special meanings, and should therefore be avoided for
user-specified exit parameters. Ending a script with exit 127 would
certainly cause confusion when troubleshooting (is the error code a
"command not found" or a user-defined one?). However, many scripts use
an exit 1 as a general bailout-upon-error. Since exit code 1 signifies
so many possible errors, it is not particularly useful in
debugging. ◊footnote{Out of range exit values can result in unexpected
exit codes. An exit value greater than 255 returns an exit code modulo
256. For example, ◊code{exit 3809} gives an exit code of 225 (3809 % 256 =
225).}

There has been an attempt to systematize exit status numbers (see
◊fname{/usr/include/sysexits.h}), but this is intended for C and C++
programmers. A similar standard for scripting might be
appropriate. The author of this document proposes restricting
user-defined exit codes to the range 64 - 113 (in addition to 0, for
success), to conform with the C/C++ standard. This would allot 50
valid codes, and make troubleshooting scripts more
straightforward. All user-defined exit codes in the accompanying
examples to this document conform to this standard, except where
overriding circumstances exist, as in TODO Example 9-2. ◊footnote{An
update of ◊fname{/usr/include/sysexits.h} allocates previously unused
exit codes from 64 - 78. It may be anticipated that the range of
unallotted exit codes will be further restricted in the future. The
author of this document will not do fixups on the scripting examples
to conform to the changing standard. This should not cause any
problems, since there is no overlap or conflict in usage of exit codes
between compiled C/C++ binaries and shell scripts.}

