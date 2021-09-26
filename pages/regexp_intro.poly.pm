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

}
