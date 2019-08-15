#lang pollen

◊define-meta[page-title]{Shell Programming!}
◊define-meta[page-description]{What is shell scripting}

◊; TODO: display: Chapter 1. Shell Programming!

◊quotation[#:author "Herbert Mayer"]{
No programming language is perfect. There is not even a single best
language; there are only languages well suited or perhaps poorly
suited for particular purposes.
}

A working knowledge of shell scripting is essential to anyone wishing
to become reasonably proficient at system administration, even if they
do not anticipate ever having to actually write a script. Consider
that as a Linux machine boots up, it executes the shell scripts in
◊fname{/etc/rc.d} to restore the system configuration and set up services. A
detailed understanding of these startup scripts is important for
analyzing the behavior of a system, and possibly modifying it.

The craft of scripting is not hard to master, since scripts can be
built in bite-sized sections and there is only a fairly small set of
shell-specific operators and options ◊footnote{These are referred to
as builtins, features internal to the shell.} to learn. The syntax is
simple -- even austere -- similar to that of invoking and chaining
together utilities at the command line, and there are only a few
"rules" governing their use. Most short scripts work right the first
time, and debugging even the longer ones is straightforward.
