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

◊note{
In the early days of personal computing, the BASIC language enabled
anyone reasonably computer proficient to write programs on an early
generation of microcomputers. Decades later, the Bash scripting
language enables anyone with a rudimentary knowledge of Linux or UNIX
to do the same on modern machines.

We now have miniaturized single-board computers with amazing
capabilities, such as the Raspberry Pi. Bash scripting provides a way
to explore the capabilities of these fascinating devices.
}

A shell script is a quick-and-dirty method of prototyping a complex
application. Getting even a limited subset of the functionality to
work in a script is often a useful first stage in project
development. In this way, the structure of the application can be
tested and tinkered with, and the major pitfalls found before
proceeding to the final coding in C, C++, Java, Perl, or Python.
