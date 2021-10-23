#lang pollen

◊page-init{}
◊define-meta[page-title]{Here Documents}
◊define-meta[page-description]{Here Documents}

◊quotation[#:author "Aldous Huxley, Island"]{
Here and now, boys.
}

A here document is a special-purpose code block. It uses a form of I/O
redirection to feed a command list to an interactive program or a
command, such as ◊command{ftp}, ◊command{cat}, or the ◊command{ex}
text editor.

◊example{
COMMAND <<InputComesFromHERE
...
...
...
InputComesFromHERE
}

A limit string delineates (frames) the command list. The special
symbol ◊code{<<} precedes the limit string. This has the effect of
redirecting the output of a command block into the stdin of the
program or command. It is similar to ◊command{interactive-program <
command-file}, where command-file contains

◊example{
command #1
command #2
...
}

The here document equivalent looks like this:

◊example{
interactive-program <<LimitString
command #1
command #2
...
LimitString
}

Choose a limit string sufficiently unusual that it will not occur
anywhere in the command list and confuse matters.

◊anchored-example[#:anchor "here_doc1"]{broadcast: Sends message to
everyone logged in}

Note that here documents may sometimes be used to good effect with
non-interactive utilities and commands, such as, for example,
◊command{wall}.

◊example{
#!/bin/bash

wall <<zzz23EndOfMessagezzz23
E-mail your noontime orders for pizza to the system administrator.
    (Add an extra dollar for anchovy or mushroom topping.)
# Additional message text goes here.
# Note: 'wall' prints comment lines.
zzz23EndOfMessagezzz23

# Could have been done more efficiently by
#         wall <message-file
#  However, embedding the message template in a script
#+ is a quick-and-dirty one-off solution.

exit
}

Even such unlikely candidates as the ◊command{vi} text editor lend
themselves to here documents.

◊anchored-example[#:anchor "here_doc2"]{dummyfile: Creates a 2-line
dummy file}

◊example{
#!/bin/bash

# Noninteractive use of 'vi' to edit a file.
# Emulates 'sed'.

E_BADARGS=85

if [ -z "$1" ]
then
  echo "Usage: `basename $0` filename"
  exit $E_BADARGS
fi

TARGETFILE=$1

# Insert 2 lines in file, then save.
#--------Begin here document-----------#
vi $TARGETFILE <<x23LimitStringx23
i
This is line 1 of the example file.
This is line 2 of the example file.
^[
ZZ
x23LimitStringx23
#----------End here document-----------#

#  Note that ^[ above is a literal escape
#+ typed by Control-V <Esc>.

#  Bram Moolenaar points out that this may not work with 'vim'
#+ because of possible problems with terminal interaction.

exit
}

The above script could just as effectively have been implemented with
◊command{ex}, rather than ◊command{vi}. Here documents containing a
list of ◊command{ex} commands are common enough to form their own
category, known as ◊command{ex} scripts.

◊example{
#!/bin/bash
#  Replace all instances of "Smith" with "Jones"
#+ in files with a ".txt" filename suffix. 

ORIGINAL=Smith
REPLACEMENT=Jones

for word in $(fgrep -l $ORIGINAL *.txt)
do
  # -------------------------------------
  ex $word <<EOF
  :%s/$ORIGINAL/$REPLACEMENT/g
  :wq
EOF
  # :%s is the "ex" substitution command.
  # :wq is write-and-quit.
  # -------------------------------------
done
}

◊anchored-example[#:anchor "here_doc3"]{Multi-line message using cat}

Analogous to "ex scripts" are cat scripts.

◊example{
#!/bin/bash

#  'echo' is fine for printing single line messages,
#+  but somewhat problematic for for message blocks.
#   A 'cat' here document overcomes this limitation.

cat <<End-of-message
-------------------------------------
This is line 1 of the message.
This is line 2 of the message.
This is line 3 of the message.
This is line 4 of the message.
This is the last line of the message.
-------------------------------------
End-of-message

#  Replacing line 7, above, with
#+   cat > $Newfile <<End-of-message
#+       ^^^^^^^^^^
#+ writes the output to the file $Newfile, rather than to stdout.

exit 0


#--------------------------------------------
# Code below disabled, due to "exit 0" above.

# S.C. points out that the following also works.
echo "-------------------------------------
This is line 1 of the message.
This is line 2 of the message.
This is line 3 of the message.
This is line 4 of the message.
This is the last line of the message.
-------------------------------------"
# However, text may not include double quotes unless they are escaped.
}

◊anchored-example[#:anchor "here_doc4"]{Multi-line message, with tabs
suppressed}

The - option to mark a here document limit string (<<-LimitString)
suppresses leading tabs (but not spaces) in the output. This may be
useful in making a script more readable.

◊example{
#!/bin/bash
# Same as previous example, but...

#  The - option to a here document <<-
#+ suppresses leading tabs in the body of the document,
#+ but *not* spaces.

cat <<-ENDOFMESSAGE
	This is line 1 of the message.
	This is line 2 of the message.
	This is line 3 of the message.
	This is line 4 of the message.
	This is the last line of the message.
ENDOFMESSAGE
# The output of the script will be flush left.
# Leading tab in each line will not show.

# Above 5 lines of "message" prefaced by a tab, not spaces.
# Spaces not affected by   <<-  .

# Note that this option has no effect on *embedded* tabs.

exit 0
}

◊anchored-example[#:anchor "here_doc5"]{Here document with replaceable parameters}

A here document supports parameter and command substitution. It is
therefore possible to pass different parameters to the body of the
here document, changing its output accordingly.

◊example{
#!/bin/bash
# Another 'cat' here document, using parameter substitution.

# Try it with no command-line parameters,   ./scriptname
# Try it with one command-line parameter,   ./scriptname Mortimer
# Try it with one two-word quoted command-line parameter,
#                           ./scriptname "Mortimer Jones"

CMDLINEPARAM=1     #  Expect at least command-line parameter.

if [ $# -ge $CMDLINEPARAM ]
then
  NAME=$1          #  If more than one command-line param,
                   #+ then just take the first.
else
  NAME="John Doe"  #  Default, if no command-line parameter.
fi  

RESPONDENT="the author of this fine script"  
  

cat <<Endofmessage

Hello, there, $NAME.
Greetings to you, $NAME, from $RESPONDENT.

# This comment shows up in the output (why?).

Endofmessage

# Note that the blank lines show up in the output.
# So does the comment.

exit
}

◊anchored-example[#:anchor "here_doc6"]{Upload a file pair to Sunsite
incoming directory}

This is a useful script containing a here document with parameter
substitution.

◊example{
#!/bin/bash
# upload.sh

#  Upload file pair (Filename.lsm, Filename.tar.gz)
#+ to incoming directory at Sunsite/UNC (ibiblio.org).
#  Filename.tar.gz is the tarball itself.
#  Filename.lsm is the descriptor file.
#  Sunsite requires "lsm" file, otherwise will bounce contributions.


E_ARGERROR=85

if [ -z "$1" ]
then
  echo "Usage: `basename $0` Filename-to-upload"
  exit $E_ARGERROR
fi  


Filename=`basename $1`           # Strips pathname out of file name.

Server="ibiblio.org"
Directory="/incoming/Linux"
#  These need not be hard-coded into script,
#+ but may instead be changed to command-line argument.

Password="your.e-mail.address"   # Change above to suit.

ftp -n $Server <<End-Of-Session
# -n option disables auto-logon

user anonymous "$Password"       #  If this doesn't work, then try:
                                 #  quote user anonymous "$Password"
binary
bell                             # Ring 'bell' after each file transfer.
cd $Directory
put "$Filename.lsm"
put "$Filename.tar.gz"
bye
End-Of-Session

exit 0
}

◊anchored-example[#:anchor "here_doc7"]{Parameter substitution turned
off}

Quoting or escaping the "limit string" at the head of a here document
disables parameter substitution within its body. The reason for this
is that quoting/escaping the limit string effectively escapes the
◊code{$}, ◊code{`}, and ◊code{\} special characters, and causes them
to be interpreted literally.


◊example{
#!/bin/bash
#  A 'cat' here-document, but with parameter substitution disabled.

NAME="John Doe"
RESPONDENT="the author of this fine script"  

cat <<'Endofmessage'

Hello, there, $NAME.
Greetings to you, $NAME, from $RESPONDENT.

Endofmessage

#   No parameter substitution when the "limit string" is quoted or escaped.
#   Either of the following at the head of the here document would have
#+  the same effect.
#   cat <<"Endofmessage"
#   cat <<\Endofmessage



#   And, likewise:

cat <<"SpecialCharTest"

Directory listing would follow
if limit string were not quoted.
`ls -l`

Arithmetic expansion would take place
if limit string were not quoted.
$((5 + 3))

A a single backslash would echo
if limit string were not quoted.
\\

SpecialCharTest


exit
}

◊anchored-example[#:anchor "here_doc8"]{A script that generates another script}

Disabling parameter substitution permits outputting literal
text. Generating scripts or even program code is one use for this.

◊example{
#!/bin/bash
# generate-script.sh
# Based on an idea by Albert Reiner.

OUTFILE=generated.sh         # Name of the file to generate.


# -----------------------------------------------------------
# 'Here document containing the body of the generated script.
(
cat <<'EOF'
#!/bin/bash

echo "This is a generated shell script."
#  Note that since we are inside a subshell,
#+ we can't access variables in the "outside" script.

echo "Generated file will be named: $OUTFILE"
#  Above line will not work as normally expected
#+ because parameter expansion has been disabled.
#  Instead, the result is literal output.

a=7
b=3

let "c = $a * $b"
echo "c = $c"

exit 0
EOF
) > $OUTFILE
# -----------------------------------------------------------

#  Quoting the 'limit string' prevents variable expansion
#+ within the body of the above 'here document.'
#  This permits outputting literal strings in the output file.

if [ -f "$OUTFILE" ]
then
  chmod 755 $OUTFILE
  # Make the generated file executable.
else
  echo "Problem in creating file: \"$OUTFILE\""
fi

#  This method also works for generating
#+ C programs, Perl programs, Python programs, Makefiles,
#+ and the like.

exit 0
}

It is possible to set a variable from the output of a here
document. This is actually a devious form of command substitution.

◊example{
variable=$(cat <<SETVAR
This variable
runs over multiple lines.
SETVAR
)

echo "$variable"
}

◊anchored-example[#:anchor "here_doc8"]{A script that generates
another script}

A here document can supply input to a function in the same script.

◊example{
#!/bin/bash
# here-function.sh

GetPersonalData ()
{
  read firstname
  read lastname
  read address
  read city 
  read state 
  read zipcode
} # This certainly appears to be an interactive function, but . . .


# Supply input to the above function.
GetPersonalData <<RECORD001
Bozo
Bozeman
2726 Nondescript Dr.
Bozeman
MT
21226
RECORD001


echo
echo "$firstname $lastname"
echo "$address"
echo "$city, $state $zipcode"
echo

exit 0
}

◊anchored-example[#:anchor "here_doc9"]{"Anonymous" Here Document}

It is possible to use : as a dummy command accepting output from a
here document. This, in effect, creates an "anonymous" here document.

◊example{
#!/bin/bash

: <<TESTVARIABLES
${HOSTNAME?}${USER?}${MAIL?}  # Print error message if one of the variables not set.
TESTVARIABLES

exit $?
}

Tip: A variation of the above technique permits "commenting out"
blocks of code.

◊anchored-example[#:anchor "here_doc10"]{Commenting out a block of code}

◊example{
#!/bin/bash
# commentblock.sh

: <<COMMENTBLOCK
echo "This line will not echo."
This is a comment line missing the "#" prefix.
This is another comment line missing the "#" prefix.

&*@!!++=
The above line will cause no error message,
because the Bash interpreter will ignore it.
COMMENTBLOCK

echo "Exit value of above \"COMMENTBLOCK\" is $?."   # 0
# No error shown.
echo


#  The above technique also comes in useful for commenting out
#+ a block of working code for debugging purposes.
#  This saves having to put a "#" at the beginning of each line,
#+ then having to go back and delete each "#" later.
#  Note that the use of of colon, above, is optional.

echo "Just before commented-out code block."
#  The lines of code between the double-dashed lines will not execute.
#  ===================================================================
: <<DEBUGXXX
for file in *
do
 cat "$file"
done
DEBUGXXX
#  ===================================================================
echo "Just after commented-out code block."

exit 0



######################################################################
#  Note, however, that if a bracketed variable is contained within
#+ the commented-out code block,
#+ then this could cause problems.
#  for example:


#/!/bin/bash

  : <<COMMENTBLOCK
  echo "This line will not echo."
  &*@!!++=
  ${foo_bar_bazz?}
  $(rm -rf /tmp/foobar/)
  $(touch my_build_directory/cups/Makefile)
COMMENTBLOCK


$ sh commented-bad.sh
commented-bad.sh: line 3: foo_bar_bazz: parameter null or not set

# The remedy for this is to strong-quote the 'COMMENTBLOCK' in line 49, above.

  : <<'COMMENTBLOCK'
}

Tip: Yet another twist of this nifty trick makes "self-documenting"
scripts possible.

◊anchored-example[#:anchor "here_doc11"]{A self-documenting script}

◊example{
#!/bin/bash
# self-document.sh: self-documenting script
# Modification of "colm.sh".

DOC_REQUEST=70

if [ "$1" = "-h"  -o "$1" = "--help" ]     # Request help.
then
  echo; echo "Usage: $0 [directory-name]"; echo
  sed --silent -e '/DOCUMENTATIONXX$/,/^DOCUMENTATIONXX$/p' "$0" |
  sed -e '/DOCUMENTATIONXX$/d'; exit $DOC_REQUEST; fi


: <<DOCUMENTATIONXX
List the statistics of a specified directory in tabular format.
---------------------------------------------------------------
The command-line parameter gives the directory to be listed.
If no directory specified or directory specified cannot be read,
then list the current working directory.

DOCUMENTATIONXX

if [ -z "$1" -o ! -r "$1" ]
then
  directory=.
else
  directory="$1"
fi  

echo "Listing of "$directory":"; echo
(printf "PERMISSIONS LINKS OWNER GROUP SIZE MONTH DAY HH:MM PROG-NAME\n" \
; ls -l "$directory" | sed 1d) | column -t

exit 0
}

Using a ◊command{cat} script is an alternate way of accomplishing
this.

◊example{
DOC_REQUEST=70

if [ "$1" = "-h"  -o "$1" = "--help" ]     # Request help.
then                                       # Use a "cat script" . . .
  cat <<DOCUMENTATIONXX
List the statistics of a specified directory in tabular format.
---------------------------------------------------------------
The command-line parameter gives the directory to be listed.
If no directory specified or directory specified cannot be read,
then list the current working directory.

DOCUMENTATIONXX
exit $DOC_REQUEST
fi
}

See also TODO Example A-28, Example A-40, Example A-41, and Example
A-42 for more examples of self-documenting scripts.

Note: Here documents create temporary files, but these files are
deleted after opening and are not accessible to any other process.

◊example{
bash$ bash -c 'lsof -a -p $$ -d0' << EOF
> EOF
lsof    1213 bozo    0r   REG    3,5    0 30386 /tmp/t1213-0-sh (deleted)
}

Caution: Some utilities will not work inside a here document.

Warning: The closing limit string, on the final line of a here
document, must start in the first character position. There can be no
leading whitespace. Trailing whitespace after the limit string
likewise causes unexpected behavior. The whitespace prevents the limit
string from being recognized. (Except if using ◊code{<<-} to suppress
tabs.)

◊example{
#!/bin/bash

echo "----------------------------------------------------------------------"

cat <<LimitString
echo "This is line 1 of the message inside the here document."
echo "This is line 2 of the message inside the here document."
echo "This is the final line of the message inside the here document."
     LimitString
#^^^^Indented limit string. Error! This script will not behave as expected.

echo "----------------------------------------------------------------------"

#  These comments are outside the 'here document',
#+ and should not echo.

echo "Outside the here document."

exit 0

echo "This line had better not echo."  # Follows an 'exit' command.
}

Caution: Some people very cleverly use a single ◊code{!} as a limit
string. But, that's not necessarily a good idea.

◊example{
# This works.
cat <<!
Hello!
! Three more exclamations !!!
!


# But . . .
cat <<!
Hello!
Single exclamation point follows!
!
!
# Crashes with an error message.


# However, the following will work.
cat <<EOF
Hello!
Single exclamation point follows!
!
EOF
# It's safer to use a multi-character limit string.
}

For those tasks too complex for a here document, consider using the
expect scripting language, which was specifically designed for feeding
input into interactive programs.
