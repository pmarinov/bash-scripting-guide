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

◊code{$◊escaped{◊"{"}string:position:length◊escaped{◊"}"}}

Extracts ◊code{$length} characters of substring from ◊code{$string} at
◊code{$position}.

◊example{
stringZ=abcABC123ABCabc
#       0123456789.....
#       0-based indexing.

echo ${stringZ:0}                            # abcABC123ABCabc
echo ${stringZ:1}                            # bcABC123ABCabc
echo ${stringZ:7}                            # 23ABCabc

echo ${stringZ:7:3}                          # 23A
                                             # Three characters of substring.


# Is it possible to index from the right end of the string?

echo ${stringZ:-4}                           # abcABC123ABCabc
# Defaults to full string, as in ${parameter:-default}.
# However . . .

echo ${stringZ:(-4)}                         # Cabc
echo ${stringZ: -4}                          # Cabc
# Now, it works.
# Parentheses or added space "escape" the position parameter.

# Thank you, Dan Jacobson, for pointing this out.
}

The position and length arguments can be "parameterized," that is,
represented as a variable, rather than as a numerical constant.

◊section-example[#:anchor "rand8_str1"]{Generating an 8-character
"random" string}

◊example{
#!/bin/bash
# rand-string.sh
# Generating an 8-character "random" string.

if [ -n "$1" ]  #  If command-line argument present,
then            #+ then set start-string to it.
  str0="$1"
else            #  Else use PID of script as start-string.
  str0="$$"
fi

POS=2  # Starting from position 2 in the string.
LEN=8  # Extract eight characters.

str1=$( echo "$str0" | md5sum | md5sum )
#  Doubly scramble     ^^^^^^   ^^^^^^
#+ by piping and repiping to md5sum.

randstring="${str1:$POS:$LEN}"
# Can parameterize ^^^^ ^^^^

echo "$randstring"

exit $?

# bozo$ ./rand-string.sh my-password
# 1bdd88c4

#  No, this is is not recommended
#+ as a method of generating hack-proof passwords.
}

If the ◊code{$string} parameter is "*" or "@", then this extracts a
maximum of ◊code{$length} positional parameters, starting at
◊code{$position}.

◊example{
echo ${*:2}          # Echoes second and following positional parameters.
echo ${@:2}          # Same as above.

echo ${*:2:3}        # Echoes three positional parameters, starting at second.
}

◊section{Substring Extraction Using expr}

◊code{expr substr $string $position $length}

Extracts ◊code{$length} characters from ◊code{$string} starting at
◊code{$position}.

◊example{
stringZ=abcABC123ABCabc
#       123456789......
#       1-based indexing.

echo `expr substr $stringZ 1 2`              # ab
echo `expr substr $stringZ 4 3`              # ABC
}

◊code{expr match "$string" '\($substring\)'}

Extracts ◊code{$substring} at beginning of ◊code{$string}, where
◊code{$substring} is a regular expression.

◊code{expr "$string" : '\($substring\)'}

Extracts ◊code{$substring} at beginning of ◊code{$string}, where
◊code{$substring} is a regular expression.

◊example{
stringZ=abcABC123ABCabc
#       =======	    

echo `expr match "$stringZ" '\(.[b-c]*[A-Z]..[0-9]\)'`   # abcABC1
echo `expr "$stringZ" : '\(.[b-c]*[A-Z]..[0-9]\)'`       # abcABC1
echo `expr "$stringZ" : '\(.......\)'`                   # abcABC1
# All of the above forms give an identical result.
}

◊code{expr match "$string" '.*\($substring\)'}

Extracts ◊code{$substring} at end of ◊code{$string}, where
◊code{$substring} is a regular expression.

◊code{expr "$string" : '.*\($substring\)'}

Extracts ◊code{$substring} at end of $string, where ◊code{$substring}
is a regular expression.

◊example{
stringZ=abcABC123ABCabc
#                ======

echo `expr match "$stringZ" '.*\([A-C][A-C][A-C][a-c]*\)'`    # ABCabc
echo `expr "$stringZ" : '.*\(......\)'`                       # ABCabc
}

◊section{Substring Removal}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
