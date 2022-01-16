#lang pollen

◊page-init{}
◊define-meta[page-title]{Command-Line Options}
◊define-meta[page-description]{Command-Line Options}

◊section{Standard Command-Line Options}

Over time, there has evolved a loose standard for the meanings of
command-line option flags. The GNU utilities conform more closely to
this "standard" than older UNIX utilities.

Traditionally, UNIX command-line options consist of a dash, followed
by one or more lowercase letters. The GNU utilities added a
double-dash, followed by a complete word or compound word.

The two most widely-accepted options are:

◊definition-block[#:type "code"]{

◊definition-entry[#:name "-h, --help"]{
Help

Give usage message and exit.

}

◊definition-entry[#:name "-v, --version"]{
Version

Show program version and exit.

}

}

Other common options are:

◊definition-block[#:type "code"]{

◊definition-entry[#:name "-a, --all"]{
All

Show all information or operate on all arguments.

}

◊definition-entry[#:name "-l, --list"]{
List

List files or arguments without taking other action.

}

◊definition-entry[#:name "-o"]{
Output filename

}

◊definition-entry[#:name "-q, --quiet"]{
Quiet

Suppress stdout.

}

◊definition-entry[#:name "-r, -R, --recursive"]{
Recursive

Operate recursively (down directory tree).

}

◊definition-entry[#:name "-v, --verbose"]{
Verbose

Output additional information to stdout or stderr.

}

◊definition-entry[#:name "-z, --compress"]{
Compress

Apply compression (usually ◊command{gzip}).

}

}

However:

◊definition-block[#:type "code"]{

◊definition-entry[#:name "In tar: -f, --file"]{
File

Filename follows.

}

◊definition-entry[#:name "In cp, mv, rm:: -f, --force"]{
Force

Force overwrite of target file(s).

}

}

Caution: Many UNIX and Linux utilities deviate from this "standard,"
so it is dangerous to assume that a given option will behave in a
standard way. Always check the man page for the command in question
when in doubt.

A complete table of recommended options for the GNU utilities is
available at the GNU standards page.

See: ◊url[#:link "https://www.gnu.org/prep/standards/"]{}

◊section{Bash Command-Line Options}

Bash itself has a number of command-line options. Here are some of the
more useful ones.

◊definition-block[#:type "code"]{

◊definition-entry[#:name "-c"]{
Read commands from the following string and assign any arguments to
the positional parameters.

◊example{
bash$ bash -c 'set a b c d; IFS="+-;"; echo "$*"'
a+b+c+d
}

}

◊definition-entry[#:name "-r, --restricted"]{
Runs the shell, or a script, in restricted mode.

}

◊definition-entry[#:name "--posix"]{
Forces Bash to conform to POSIX mode.

}

◊definition-entry[#:name "--"]{
End of options.

Anything further on the command line is an argument,
not an option.

}

}
