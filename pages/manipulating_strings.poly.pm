#lang pollen

◊define-meta[page-title]{Manipulating strings}
◊define-meta[page-description]{Manipulating Strings}

Bash supports a surprising number of string manipulation
operations. Unfortunately, these tools lack a unified focus. Some are
a subset of parameter substitution, and others fall under the
functionality of the UNIX ◊command{expr} command. This results in
inconsistent command syntax and overlap of functionality, not to
mention confusion.

◊section{String Length}

The expressions:

◊code{$◊escaped{◊"{"}#string◊escaped{◊"}"}}

◊code{expr length $string}

◊code{expr "$string" : '.*'}

These are the equivalent of ◊code{strlen()} in C.

◊example{

stringZ=abcABC123ABCabc

echo ${#stringZ}                 # 15
echo `expr length $stringZ`      # 15
echo `expr "$stringZ" : '.*'`    # 15
}


◊section-example[#:anchor "ins_blank1"]{Inserting a blank line between
paragraphs in a text file}

◊example{
#!/bin/bash
# paragraph-space.sh
# Ver. 2.1, Reldate 29Jul12 [fixup]

# Inserts a blank line between paragraphs of a single-spaced text file.
# Usage: $0 <FILENAME

MINLEN=60        # Change this value? It's a judgment call.
#  Assume lines shorter than $MINLEN characters ending in a period
#+ terminate a paragraph. See exercises below.

while read line  # For as many lines as the input file has ...
do
  echo "$line"   # Output the line itself.

  len=${#line}
  if [[ "$len" -lt "$MINLEN" && "$line" =~ [*{\.}]$ ]]
# if [[ "$len" -lt "$MINLEN" && "$line" =~ \[*\.\] ]]
# An update to Bash broke the previous version of this script. Ouch!
# Thank you, Halim Srama, for pointing this out and suggesting a fix.
    then echo    #  Add a blank line immediately
  fi             #+ after a short line terminated by a period.
done

exit

# Exercises:
# ---------
#  1) The script usually inserts a blank line at the end
#+    of the target file. Fix this.
#  2) Line 17 only considers periods as sentence terminators.
#     Modify this to include other common end-of-sentence characters,
#+    such as ?, !, and ".
}

◊section{Length of Matching Substring at Beginning of String}

The expressions:

◊code{expr match "$string" '$substring'}

◊code{expr "$string" : '$substring'}

◊code{$substring} is a regular expression.

◊example{
stringZ=abcABC123ABCabc
#       |------|
#       12345678

echo `expr match "$stringZ" 'abc[A-Z]*.2'`   # 8
echo `expr "$stringZ" : 'abc[A-Z]*.2'`       # 8
}

◊section{Index}

The expression:

◊code{expr index $string $substring}

Numerical position in ◊code{$string} of first character in
◊code{$substring} that matches.

◊example{
stringZ=abcABC123ABCabc
#       123456 ...
echo `expr index "$stringZ" C12`             # 6
                                             # C position.

echo `expr index "$stringZ" 1c`              # 3
# 'c' (in #3 position) matches before '1'.
}

This is the near equivalent of ◊code{strchr()} in C.

◊section{Substring Extraction}

The expression:

◊code{$◊escaped{◊"{"}string:position◊escaped{◊"}"}}

Extracts substring from ◊code{$string} at ◊code{$position}.

If the ◊code{$string} parameter is "*" or "@", then this extracts the
positional parameters, [1] starting at
◊code{$position}. ◊footnote{This applies to either command-line
arguments or parameters passed to a function.}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
