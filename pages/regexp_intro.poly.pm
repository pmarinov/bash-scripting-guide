#lang pollen

◊page-init{}
◊define-meta[page-title]{Introduction to Regular Expressions}
◊define-meta[page-description]{A Brief Introduction to Regular Expressions}

◊section{What is a regular expression}

An expression is a string of characters. Those characters having an
interpretation above and beyond their literal meaning are called
metacharacters. A quote symbol, for example, may denote speech by a
person, ditto, or a meta-meaning for the symbols that follow. Regular
Expressions are sets of characters and/or metacharacters that match
(or specify) patterns. ◊footnote{A meta-meaning is the meaning of a
term or expression on a higher level of abstraction. For example, the
literal meaning of regular expression is an ordinary expression that
conforms to accepted usage. The meta-meaning is drastically different,
as discussed at length in this chapter.}

A Regular Expression contains one or more of the following:

◊definition-block[#:type "code"]{

◊definition-entry[#:name "A character set"]{
These are the characters retaining their literal meaning. The simplest
type of Regular Expression consists only of a character set, with no
metacharacters.

For example: "Abc"

}

◊definition-entry[#:name "An anchor"]{
These designate (anchor) the position in the line of text that the RE
is to match. For example, ◊code{^}, and ◊code{$} are anchors.

For example: "^" or "$"

}

◊definition-entry[#:name "Modifiers"]{
These expand or narrow (modify) the range of text the RE is to
match. Modifiers include the asterisk, brackets, and the backslash.

For example: "[3]"

}

}

The main uses for Regular Expressions (REs) are text searches and
string manipulation.

◊section{Matches}

An RE matches a single character or a set of characters -- a string or
a part of a string.

◊definition-block[#:type "code"]{

◊definition-entry[#:name "*"]{
The asterisk matches any number of repeats of the character string or
RE preceding it, including zero instances.

"1133*" matches 11 + one or more 3's: 113, 1133, 1133333, and so forth.

}

◊definition-entry[#:name "."]{
The dot matches any one character, except a newline.

"13." matches 13 + at least one of any character (including a space):
1133, 11333, but not 13 (additional character missing).

See TODO Example 16-18 for a demonstration of dot single-character matching.

}

◊definition-entry[#:name "^"]{
The caret matches the beginning of a line, but sometimes, depending on
context, negates the meaning of a set of characters in an RE.

}

◊definition-entry[#:name "$"]{
The dollar sign at the end of an RE matches the end of a line.

◊code{"XXX$"} matches XXX at the end of a line.

◊code{"^$"} matches blank lines.

}

◊definition-entry[#:name "[...]"]{
Brackets enclose a set of characters to match in a single RE.

◊code{"[xyz]"} matches any one of the characters x, y, or z.

◊code{"[c-n]"} matches any one of the characters in the range c to n.

◊code{"[B-Pk-y]"} matches any one of the characters in the ranges B to
P and k to y.

◊code{"[a-z0-9]"} matches any single lowercase letter or any digit.

◊code{"[^b-d]"} matches any character except those in the range b to
d. This is an instance of ^ negating or inverting the meaning of the
following RE (taking on a role similar to ! in a different context).

Combined sequences of bracketed characters match common word
patterns. ◊code{"[Yy][Ee][Ss]"} matches yes, Yes, YES, yEs, and so
forth. ◊code{"[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]"}
matches any Social Security number.

}

◊definition-entry[#:name "\\"]{
The backslash escapes a special character, which means that character
gets interpreted literally (and is therefore no longer special).

A ◊code{"\$"} reverts back to its literal meaning of ◊code{"$"}, rather than its RE
meaning of end-of-line. Likewise a ◊code{"\\"} has the literal meaning of
◊code{"\"}.

}

◊definition-entry[#:name "\\<...\\>"]{
Escaped "angle brackets" mark word boundaries.

The angle brackets must be escaped, since otherwise they have only
their literal character meaning.

◊code{"\<the\>"} matches the word "the," but not the words "them," "there," "other," etc.

◊example{
bash$ cat textfile
This is line 1, of which there is only one instance.
 This is the only instance of line 2.
 This is line 3, another line.
 This is line 4.

bash$ grep 'the' textfile
This is line 1, of which there is only one instance.
 This is the only instance of line 2.
 This is line 3, another line.

bash$ grep '\<the\>' textfile
This is the only instance of line 2.
}

}

}

The only way to be certain that a particular RE works is to test it.

◊example{
bash$ cat tstfile
TEST FILE: tstfile                          # No match.
                                            # No match.
Run   grep "1133*"  on this file.           # Match.
                                            # No match.
                                            # No match.
This line contains the number 113.          # Match.
This line contains the number 13.           # No match.
This line contains the number 133.          # No match.
This line contains the number 1133.         # Match.
This line contains the number 113312.       # Match.
This line contains the number 1112.         # No match.
This line contains the number 113312312.    # Match.
This line contains no numbers at all.       # No match.

bash$ grep "1133*" tstfile
Run   grep "1133*"  on this file.           # Match.
 This line contains the number 113.          # Match.
 This line contains the number 1133.         # Match.
 This line contains the number 113312.       # Match.
 This line contains the number 113312312.    # Match.
}

◊section{Extended RE}

Additional metacharacters added to the basic set. Used in ◊command{egrep}, ◊command{awk}, and ◊command{perl}.
