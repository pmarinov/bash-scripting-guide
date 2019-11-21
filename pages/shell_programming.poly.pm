#lang pollen

◊define-meta[page-title]{Shell Programming!}
◊define-meta[page-description]{What is shell scripting}

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
proceeding to the final coding in ◊term{C}, ◊term{C++}, ◊term{Java},
◊term{Perl}, or ◊term{Python}.

◊section["When not to use shell scripts"]

◊list-block[#:type "bullet"]{

◊list-entry{Resource-intensive tasks, especially where speed is a
factor (sorting, hashing, recursion ◊footnote{Although recursion is
possible in a shell script, it tends to be slow and its implementation
is often an ugly kludge.} ...)}

◊list-entry{Procedures involving heavy-duty math operations,
especially floating point arithmetic, arbitrary precision
calculations, or complex numbers (use ◊term{C++} or ◊term{FORTRAN}
instead)}

◊list-entry{Cross-platform portability required (use ◊term{C} or ◊term{Java}
instead)}

◊list-entry{Complex applications, where structured programming is a
necessity (type-checking of variables, function prototypes, etc.)}

◊list-entry{Mission-critical applications upon which you are betting
the future of the company}

◊list-entry{Situations where security is important, where you need to
guarantee the integrity of your system and protect against intrusion,
cracking, and vandalism}

◊list-entry{Project consists of subcomponents with interlocking
dependencies}

◊list-entry{Extensive file operations required (Bash is limited to
serial file access, and that only in a particularly clumsy and
inefficient line-by-line fashion.)}

◊list-entry{Need native support for multi-dimensional arrays}

◊list-entry{Need data structures, such as linked lists or trees}

◊list-entry{Need to generate / manipulate graphics or GUIs}

◊list-entry{Need direct access to system hardware or external
peripherals}

◊list-entry{Need port or socket I/O}

◊list-entry{Need to use libraries or interface with legacy code}

◊list-entry{Proprietary, closed-source applications (Shell scripts put
the source code right out in the open for all the world to see.)}
}

If any of the above applies, consider a more powerful scripting
language -- perhaps ◊term{Perl}, ◊term{Tcl}, ◊term{Python},
◊term{Ruby} -- or possibly a compiled language such as ◊term{C},
◊term{C++}, or ◊term{Java}. Even then, prototyping the application as
a shell script might still be a useful development step.

◊section["The Bourne-Again Shell"]

◊quotation[#:author "Edmund Spenser"]{
His countenance was bold and bashed not.
}

We will be using Bash, an acronym ◊footnote{An acronym is an ersatz
word formed by pasting together the initial letters of the words into
a tongue-tripping phrase. This morally corrupt and pernicious practice
deserves appropriately severe punishment. Public flogging suggests
itself.} for "Bourne-Again shell" and a pun on Stephen Bourne's now
classic Bourne shell. Bash has become a de facto standard for shell
scripting on most flavors of UNIX. Most of the principles this book
covers apply equally well to scripting with other shells, such as the
Korn Shell, from which Bash derives some of its features,
◊footnote{Many of the features of ksh88, and even a few from the
updated ksh93 have been merged into Bash.} and the C Shell and its
variants. (Note that C Shell programming is not recommended due to
certain inherent problems, as pointed out in an October, 1993
◊url[#:link
"http://www.faqs.org/faqs/unix-faq/shell/csh-whynot/"]{Usenet post} by
Tom Christiansen.)

What follows is a tutorial on shell scripting. It relies heavily on
examples to illustrate various features of the shell. The example
scripts work -- they've been tested, insofar as possible -- and some
of them are even useful in real life. The reader can play with the
actual working code of the examples in the source archive
(◊command{scriptname.sh} or ◊command{scriptname.bash}), ◊footnote{By
convention, user-written shell scripts that are Bourne shell compliant
generally take a name with a .sh extension. System scripts, such as
those found in ◊fname{/etc/rc.d}, do not necessarily conform to this
nomenclature.} give them ◊dfn{execute} permission (◊command{chmod
u+rx scriptname}), then run them to see what happens. Should the
source archive not be available, then cut-and-paste from the HTML or
pdf rendered versions. Be aware that some of the scripts presented
here introduce features before they are explained, and this may
require the reader to temporarily skip ahead for enlightenment.

Unless otherwise noted, the author of this book wrote the example
scripts that follow.

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
