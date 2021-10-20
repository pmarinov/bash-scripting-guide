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

