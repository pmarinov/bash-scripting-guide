#lang pollen

◊page-init{}
◊define-meta[page-title]{Sed Micro-Primer}
◊define-meta[page-description]{Sed Micro-Primer}

Sed is a non-interactive stream editor. It receives text input,
whether from stdin or from a file, performs certain operations on
specified lines of the input, one line at a time, then outputs the
result to stdout or to a file. Within a shell script, ◊command{sed} is
usually one of several tool components in a pipe.

Sed determines which lines of its input that it will operate on from
the address range passed to it. [2] Specify this address range either
by line number or by a pattern to match. For example, ◊code{3d}
signals sed to delete line 3 of the input, and ◊code{/Windows/d} tells sed
that you want every line of the input containing a match to "Windows"
deleted.

Of all the operations in the ◊command{sed} toolkit, we will focus
primarily on the three most commonly used ones. These are printing (to
stdout), deletion, and substitution.

◊definition-block[#:type "code"]{
◊definition-entry[#:name "[address-range]/p"]{
Print

Print [specified address range]
}

◊definition-entry[#:name "[address-range]/d"]{
Delete

Delete [specified address range]
}

◊definition-entry[#:name "s/pattern1/pattern2/"]{
Substitute

Substitute pattern2 for first instance of pattern1 in a line
}

◊definition-entry[#:name "[address-range]/s/pattern1/pattern2/"]{
Substitute

Substitute pattern2 for first instance of pattern1 in a line, over
address-range
}

◊definition-entry[#:name "[address-range]/y/pattern1/pattern2/"]{
Transform

Replace any character in pattern1 with the corresponding character in
pattern2, over address-range (equivalent of ◊command{tr})
}

◊definition-entry[#:name "[address] i pattern"]{
Insert

Insert pattern at the address indicated
}

◊definition-entry[#:name "g"]{
Global

Unless the ◊code{g} (global) operator is appended to a substitute
command, the substitution operates only on the first instance of a
pattern match within each line.

}

}

From the command-line and in a shell script, a sed operation may require quoting and certain options.

◊example{
sed -e '/^$/d' $filename
# The -e option causes the next string to be interpreted as an editing instruction.
#  (If passing only a single instruction to sed, the "-e" is optional.)
#  The "strong" quotes ('') protect the RE characters in the instruction
#+ from reinterpretation as special characters by the body of the script.
# (This reserves RE expansion of the instruction for sed.)
#
# Operates on the text contained in file $filename.
}

In certain cases, a sed editing command will not work with single quotes.

◊example{
filename=file1.txt
pattern=BEGIN

  sed "/^$pattern/d" "$filename"  # Works as specified.
# sed '/^$pattern/d' "$filename"    has unexpected results.
#        In this instance, with strong quoting (' ... '),
#+      "$pattern" will not expand to "BEGIN".
}

