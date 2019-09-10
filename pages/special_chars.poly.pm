#lang pollen

◊define-meta[page-title]{Special Characters}
◊define-meta[page-description]{Special Characters}

What makes a character special? If it has a meaning beyond its
◊emphasize{literal meaning}, a meta-meaning, then we refer to it as a
special character. Along with commands and keywords,
◊emphasize{special characters} are building blocks of Bash scripts.

◊section{Special Characters Found In Scripts and Elsewhere}

◊definition-block[#:type "variables"]{
◊definition-entry[#:name ";"]{
◊strong{Command separator [semicolon]}. Permits putting two or more
commands on the same line.

◊example{echo hello; echo there

if [ -x "$filename" ]; then    #  Note the space after the semicolon.
#+                   ^^
  echo "File $filename exists."; cp $filename $filename.bak
else   #                       ^^
  echo "File $filename not found."; touch $filename
fi; echo "File test complete."
}

Note that the ";" sometimes needs to be ◊emphasize{escaped}.

}

◊definition-entry[#:name ";;"]{
◊strong{Terminator in a case option [double semicolon]}. 

◊example{
case "$variable" in
  abc)  echo "\$variable = abc" ;;
  xyz)  echo "\$variable = xyz" ;;
esac
}

◊definition-entry[#:name "#"]{
◊strong{Comments}. Lines beginning with a # (with the exception of #!)
are comments and will ◊emphasize{not} be executed.

◊example{# This line is a comment.}

Comments may also occur following the end of a command.

◊example{echo "A comment will follow." # Comment here.
#                            ^ Note whitespace before #
}
}

Comments may also follow whitespace at the beginning of a line.

◊example{# A tab precedes this comment.}

Comments may even be embedded within a pipe.

◊example{initial=( `cat "$startfile" | sed -e '/#/d' | tr -d '\n' |\
# Delete lines containing '#' comment character.
           sed -e 's/\./\. /g' -e 's/_/_ /g'` )
# Excerpted from life.sh script}

◊note{Caution: A command may not follow a comment on the same
line. There is no method of terminating the comment, in order for
"live code" to begin on the same line. Use a new line for the next
command.}

A quoted or an escaped # in an ◊command{echo} statement does
◊emphasize{not} begin a comment. Likewise, a # appears in certain
parameter-substitution constructs and in numerical constant
expressions.

◊example{echo "The # here does not begin a comment."
echo 'The # here does not begin a comment.'
echo The \# here does not begin a comment.
echo The # here begins a comment.

echo ${PATH#*:}       # Parameter substitution, not a comment.
echo $(( 2#101011 ))  # Base conversion, not a comment.

# Thanks, S.C.
}

The standard quoting and escape characters (" ' \) escape the #.

Certain pattern matching operations also use the #.

}

◊definition-entry[#:name ";&, ;&"]{
◊strong{Terminators in a ◊emphasize{case} option (version 4+ of Bash)}. 
}

◊definition-entry[#:name "."]{
◊strong{"dot" command [period]}. Equivalent to ◊command{source} (see
Example 15-22). This is a bash ◊emphasize{builtin}.
}

◊definition-entry[#:name "."]{
◊strong{"dot", as a component of a filename}. When working with
filenames, a leading dot is the prefix of a "hidden" file, a file that
an ◊command{ls} will not normally show.

◊example{
bash$ touch .hidden-file
bash$ ls -l	      
total 10
 -rw-r--r--    1 bozo      4034 Jul 18 22:04 data1.addressbook
 -rw-r--r--    1 bozo      4602 May 25 13:58 data1.addressbook.bak
 -rw-r--r--    1 bozo       877 Dec 17  2000 employment.addressbook


bash$ ls -al	      
total 14
 drwxrwxr-x    2 bozo  bozo      1024 Aug 29 20:54 ./
 drwx------   52 bozo  bozo      3072 Aug 29 20:51 ../
 -rw-r--r--    1 bozo  bozo      4034 Jul 18 22:04 data1.addressbook
 -rw-r--r--    1 bozo  bozo      4602 May 25 13:58 data1.addressbook.bak
 -rw-r--r--    1 bozo  bozo       877 Dec 17  2000 employment.addressbook
 -rw-rw-r--    1 bozo  bozo         0 Aug 29 20:54 .hidden-file
}

When considering directory names, ◊emphasize{a single dot} represents
the current working directory, and ◊emphasize{two dots} denote the
parent directory.

◊example{
bash$ pwd
/home/bozo/projects

bash$ cd .
bash$ pwd
/home/bozo/projects

bash$ cd ..
bash$ pwd
/home/bozo/
}

The ◊emphasize{dot} often appears as the destination (directory) of a
file movement command, in this context meaning ◊emphasize{current
directory}.

◊example{
bash$ cp /home/bozo/current_work/junk/* .
}       

Copy all the "junk" files to ◊code{$PWD}.
}

◊definition-entry[#:name "."]{
◊strong{"dot" character match}. When matching characters, as part of a
◊emphasize{regular expression}, a "dot" matches a single character.
}

◊definition-entry[#:name "\""]{
◊strong{partial quoting [double quote]}. "STRING" preserves (from
interpretation) most of the special characters within STRING.
}

◊definition-entry[#:name "'"]{
◊strong{full quoting [single quote]}. 'STRING' preserves all special
characters within STRING. This is a stronger form of quoting than
"STRING".
}

◊definition-entry[#:name ","]{
◊strong{comma operator}. The ◊emphasize{comma operator} ◊footnote{An
◊emphasize{operator} is an agent that carries out an
◊emphasize{operation}. Some examples are the common
◊emphasize{arithmetic operators}, ◊code{+ - * /}. In Bash, there is
some overlap between the concepts of ◊emphasize{operator} and
◊emphasize{keyword}.} links together a series of arithmetic
operations. All are evaluated, but only the last one is returned.

◊example{
let "t2 = ((a = 9, 15 / 3))"
# Set "a = 9" and "t2 = 15 / 3"
}

The comma operator can also concatenate strings.

◊example{
for file in /{,usr/}bin/*calc
#             ^    Find all executable files ending in "calc"
#+                 in /bin and /usr/bin directories.
do
        if [ -x "$file" ]
        then
          echo $file
        fi
done

# /bin/ipcalc
# /usr/bin/kcalc
# /usr/bin/oidcalc
# /usr/bin/oocalc


# Thank you, Rory Winston, for pointing this out.
}

}

◊definition-entry[#:name ",, and ,"]{
◊strong{Lowercase conversion in parameter substitution} (added in
version 4 of Bash).
}

◊definition-entry[#:name "\\"]{
◊strong{escape [backslash]}. A quoting mechanism for single
characters.

\X escapes the character X. This has the effect of "quoting" X,
equivalent to 'X'. The \ may be used to quote " and ', so they are
expressed literally.
}

◊definition-entry[#:name "/"]{
◊strong{Filename path separator [forward slash]}. Separates the
components of a filename (as in ◊fname{/home/bozo/projects/Makefile}).

This is also the division ◊emphasize{arithmetic operator}.
}

◊definition-entry[#:name "`"]{
◊strong{command substitution}. The ◊command{`command`} construct makes
available the output of ◊command{command} for assignment to a
variable. This is also known as backquotes or backticks.
}

◊definition-entry[#:name ":"]{

◊strong{null command [colon]}. This is the shell equivalent of a "NOP"
(◊emphasize{no op}, a do-nothing operation). It may be considered a synonym for
the shell builtin ◊command{true}. The ":" command is itself a Bash ◊emphasize{builtin}, and
its ◊emphasize{exit status} is ◊emphasize{true} (0).

◊example{
:
echo $?   # 0
}

Endless loop:

◊example{
while :
do
   operation-1
   operation-2
   ...
   operation-n
done

# Same as:
#    while true
#    do
#      ...
#    done
}

Placeholder in if/then test:

◊example{
if condition
then :   # Do nothing and branch ahead
else     # Or else ...
   take-some-action
fi
}

Provide a placeholder where a binary operation is expected

◊example{
: ${username=`whoami`}
# ${username=`whoami`}   Gives an error without the leading :
#                        unless "username" is a command or builtin...

: ${1?"Usage: $0 ARGUMENT"}     # From "usage-message.sh example script.
}

Provide a placeholder where a command is expected in a ◊emphasize{here document}.

Evaluate string of variables using parameter substitution.

◊example{
: ${HOSTNAME?} ${USER?} ${MAIL?}
#  Prints error message
#+ if one or more of essential environmental variables not set.
}

◊emphasize{Variable expansion / substring replacement}.

In combination with the ◊command{>} redirection operator, truncates a file to
zero length, without changing its permissions. If the file did not
previously exist, creates it.

◊example{
: > data.xxx   # File "data.xxx" now empty.	      

# Same effect as   cat /dev/null >data.xxx
# However, this does not fork a new process, since ":" is a builtin.
}

In combination with the ◊command{>>} redirection operator, has no effect on a
pre-existing target file ◊command{(: >> target_file)}. If the file did not
previously exist, creates it.

 ◊note{Note: This applies to regular files, not pipes, symlinks, and
 certain special files.}

May be used to begin a comment line, although this is not
recommended. Using # for a comment turns off error checking for the
remainder of that line, so almost anything may appear in a
comment. However, this is not the case with :.

◊example{
: This is a comment that generates an error, ( if [ $x -eq 3] ).
}

The ":" serves as a field separator, in ◊fname{/etc/passwd}, and in the ◊code{$PATH} variable.

◊example{
bash$ echo $PATH
/usr/local/bin:/bin:/usr/bin:/usr/X11R6/bin:/sbin:/usr/sbin:/usr/games
}

A ◊emphasize{colon} is acceptable as a function name.

◊example{
:()
{
  echo "The name of this function is "$FUNCNAME" "
  # Why use a colon as a function name?
  # It's a way of obfuscating your code.
}

:

# The name of this function is :
}

This is not portable behavior, and therefore not a recommended
practice. In fact, more recent releases of Bash do not permit this
usage. An underscore ◊command{_} works, though.

A ◊emphasize{colon} can serve as a placeholder in an otherwise empty function.

◊example{
not_empty ()
{
  :
} # Contains a : (null command), and so is not empty.
}

}

} ◊;definition-block
