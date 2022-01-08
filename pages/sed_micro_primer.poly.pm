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

Note: Sed uses the ◊code{-e} option to specify that the following
string is an instruction or set of instructions. If there is only a
single instruction contained in the string, then this may be omitted.

◊example{
sed -n '/xzy/p' $filename
# The -n option tells sed to print only those lines matching the pattern.
# Otherwise all input lines would print.
# The -e option not necessary here since there is only a single editing instruction.
}

◊anchored-example[#:anchor "sed_ex1"]{Examples of sed operators}

◊example{
# Delete 8th line of input.
sed -e 8d

# Delete all blank lines.
sed -e '/^$/d'

# Delete from beginning of input up to, and including first blank line.
sed -e '1,/^$/d'

# Print only lines containing "Jones" (with -n option).
sed -e '/Jones/p'

# Substitute "Linux" for first instance of "Windows" found in each input line.
sed -e 's/Windows/Linux/'

# Substitute "Linux" for first instance of "Windows" found in each input line.
sed -e 's/BSOD/stability/g'

# Delete all spaces at the end of every line.
sed -e 's/ *$//'

# Compress all consecutive sequences of zeroes into a single zero.
sed -e 's/00*/0/g'

# Prints "How far are you along?" as first line, "Working on it" as second.
echo "Working on it." | sed -e '1i How far are you along?'

# Inserts 'Linux is great.' at line 5 of the file file.txt.
sed -e 5i 'Linux is great.' file.txt

# Delete all lines containing "GUI".
sed -e '/GUI/d'

# Delete all instances of "GUI", leaving the remainder of each line intact.
sed -e 's/GUI//g'
}

An address range followed by one or more operations may require open
and closed curly brackets, with appropriate newlines.

◊example{
/[0-9A-Za-z]/,/^$/{
/^$/d
}
}

This deletes only the first of each set of consecutive blank
lines. That might be useful for single-spacing a text file, but
retaining the blank line(s) between paragraphs.

Note: The usual delimiter that sed uses is ◊code{/}. However, sed
allows other delimiters, such as %. This is useful when ◊code{/} is
part of a replacement string, as in a file pathname.


