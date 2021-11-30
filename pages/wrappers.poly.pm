#lang pollen

◊page-init{}
◊define-meta[page-title]{Shell Wrappers}
◊define-meta[page-description]{Shell Wrappers}

A wrapper is a shell script that embeds a system command or utility,
that accepts and passes a set of parameters to that command.  Wrapping
a script around a complex command-line simplifies invoking it. This is
expecially useful with sed and awk. ◊footnote{Quite a number of Linux
utilities are, in fact, shell wrappers. Some examples are
◊fname{/usr/bin/pdf2ps}, ◊fname{/usr/bin/batch}, and ◊fname{/usr/bin/xmkmf}.}

A ◊command{sed} or ◊command{awk} script would normally be invoked from
the command-line by a ◊command{sed -e 'commands'} or ◊command{awk
'commands'}. Embedding such a script in a Bash script permits calling
it more simply, and makes it reusable. This also enables combining the
functionality of ◊command{sed} and ◊command{awk}, for example piping
the output of a set of ◊command{sed} commands to ◊command{awk}. As a
saved executable file, you can then repeatedly invoke it in its
original form or modified, without the inconvenience of retyping it on
the command-line.

◊anchored-example[#:anchor "sh_wrap1"]{shell wrapper}

◊example{
#!/bin/bash

# This simple script removes blank lines from a file.
# No argument checking.
#
# You might wish to add something like:
#
# E_NOARGS=85
# if [ -z "$1" ]
# then
#  echo "Usage: `basename $0` target-file"
#  exit $E_NOARGS
# fi



sed -e /^$/d "$1"
# Same as
#    sed -e '/^$/d' filename
# invoked from the command-line.

#  The '-e' means an "editing" command follows (optional here).
#  '^' indicates the beginning of line, '$' the end.
#  This matches lines with nothing between the beginning and the end --
#+ blank lines.
#  The 'd' is the delete command.

#  Quoting the command-line arg permits
#+ whitespace and special characters in the filename.

#  Note that this script doesn't actually change the target file.
#  If you need to do that, redirect its output.

exit
}

◊anchored-example[#:anchor "sh_wrap2"]{A slightly more complex shell
wrapper}

◊example{
#!/bin/bash

#  subst.sh: a script that substitutes one pattern for
#+ another in a file,
#+ i.e., "sh subst.sh Smith Jones letter.txt".
#                     Jones replaces Smith.

ARGS=3         # Script requires 3 arguments.
E_BADARGS=85   # Wrong number of arguments passed to script.

if [ $# -ne "$ARGS" ]
then
  echo "Usage: `basename $0` old-pattern new-pattern filename"
  exit $E_BADARGS
fi

old_pattern=$1
new_pattern=$2

if [ -f "$3" ]
then
    file_name=$3
else
    echo "File \"$3\" does not exist."
    exit $E_BADARGS
fi


# -----------------------------------------------
#  Here is where the heavy work gets done.
sed -e "s/$old_pattern/$new_pattern/g" $file_name
# -----------------------------------------------

#  's' is, of course, the substitute command in sed,
#+ and /pattern/ invokes address matching.
#  The 'g,' or global flag causes substitution for EVERY
#+ occurence of $old_pattern on each line, not just the first.
#  Read the 'sed' docs for an in-depth explanation.

exit $?  # Redirect the output of this script to write to a file.
}

◊anchored-example[#:anchor "sh_wrap3"]{A generic shell wrapper that
writes to a logfile}

◊example{
#!/bin/bash
#  logging-wrapper.sh
#  Generic shell wrapper that performs an operation
#+ and logs it.

DEFAULT_LOGFILE=logfile.txt

# Set the following two variables.
OPERATION=
#         Can be a complex chain of commands,
#+        for example an awk script or a pipe . . .

LOGFILE=
if [ -z "$LOGFILE" ]
then     # If not set, default to ...
  LOGFILE="$DEFAULT_LOGFILE"
fi

#         Command-line arguments, if any, for the operation.
OPTIONS="$@"


# Log it.
echo "`date` + `whoami` + $OPERATION "$@"" >> $LOGFILE
# Now, do it.
exec $OPERATION "$@"

# It's necessary to do the logging before the operation.
# Why?
}

◊anchored-example[#:anchor "sh_wrap3"]{A shell wrapper around an awk
script}

◊example{
#!/bin/bash
# pr-ascii.sh: Prints a table of ASCII characters.

START=33   # Range of printable ASCII characters (decimal).
END=127    # Will not work for unprintable characters (> 127).

echo " Decimal   Hex     Character"   # Header.
echo " -------   ---     ---------"

for ((i=START; i<=END; i++))
do
  echo $i | awk '{printf("  %3d       %2x         %c\n", $1, $1, $1)}'
# The Bash printf builtin will not work in this context:
#     printf "%c" "$i"
done

exit 0


#  Decimal   Hex     Character
#  -------   ---     ---------
#    33       21         !
#    34       22         "
#    35       23         #
#    36       24         $
#
#    . . .
#
#   122       7a         z
#   123       7b         {
#   124       7c         |
#   125       7d         }


#  Redirect the output of this script to a file
#+ or pipe it to "more":  sh pr-asc.sh | more
}

◊anchored-example[#:anchor "sh_wrap4"]{A shell wrapper around another
awk script}

◊example{
#!/bin/bash

# Adds up a specified column (of numbers) in the target file.
# Floating-point (decimal) numbers okay, because awk can handle them.

ARGS=2
E_WRONGARGS=85

if [ $# -ne "$ARGS" ] # Check for proper number of command-line args.
then
   echo "Usage: `basename $0` filename column-number"
   exit $E_WRONGARGS
fi

filename=$1
column_number=$2

#  Passing shell variables to the awk part of the script is a bit tricky.
#  One method is to strong-quote the Bash-script variable
#+ within the awk script.
#     $'$BASH_SCRIPT_VAR'
#      ^                ^
#  This is done in the embedded awk script below.
#  See the awk documentation for more details.

# A multi-line awk script is here invoked by
#   awk '
#   ...
#   ...
#   ...
#   '


# Begin awk script.
# -----------------------------
awk '

{ total += $'"${column_number}"'
}
END {
     print total
}     

' "$filename"
# -----------------------------
# End awk script.


#   It may not be safe to pass shell variables to an embedded awk script,
#+  so Stephane Chazelas proposes the following alternative:
#   ---------------------------------------
#   awk -v column_number="$column_number" '
#   { total += $column_number
#   }
#   END {
#       print total
#   }' "$filename"
#   ---------------------------------------


exit 0
}

For those scripts needing a single do-it-all tool, a Swiss army knife,
there is Perl. Perl combines the capabilities of sed and awk, and
throws in a large subset of C, to boot. It is modular and contains
support for everything ranging from object-oriented programming up to
and including the kitchen sink. Short Perl scripts lend themselves to
embedding within shell scripts, and there may be some substance to the
claim that Perl can totally replace shell scripting (though the author
of the ABS Guide remains skeptical).

◊anchored-example[#:anchor "sh_wrap5"]{Perl embedded in a Bash script}

◊example{
#!/bin/bash

# Shell commands may precede the Perl script.
echo "This precedes the embedded Perl script within \"$0\"."
echo "==============================================================="

perl -e 'print "This line prints from an embedded Perl script.\n";'
# Like sed, Perl also uses the "-e" option.

echo "==============================================================="
echo "However, the script may also contain shell and system commands."

exit 0
}

It is even possible to combine a Bash script and Perl script within
the same file. Depending on how the script is invoked, either the Bash
part or the Perl part will execute.

◊anchored-example[#:anchor "sh_wrap6"]{Bash and Perl scripts combined}

◊example{
#!/bin/bash
# bashandperl.sh

echo "Greetings from the Bash part of the script, $0."
# More Bash commands may follow here.

exit
# End of Bash part of the script.

# =======================================================

#!/usr/bin/perl
# This part of the script must be invoked with
#    perl -x bashandperl.sh

print "Greetings from the Perl part of the script, $0.\n";
#      Perl doesn't seem to like "echo" ...
# More Perl commands may follow here.

# End of Perl part of the script.
}

Invocation:

◊example{
bash$ bash bashandperl.sh
Greetings from the Bash part of the script.

bash$ perl -x bashandperl.sh
Greetings from the Perl part of the script.

}

It is, of course, possible to embed even more exotic scripting
languages within shell wrappers. Python, for example ...


◊anchored-example[#:anchor "sh_wrap7"]{A script that speaks}

Wrapping a script around mplayer and the Google's translation server,
you can create something that talks back to you.

◊example{
#!/bin/bash
#   Courtesy of:
#   http://elinux.org/RPi_Text_to_Speech_(Speech_Synthesis)

#  You must be on-line for this script to work,
#+ so you can access the Google translation server.
#  Of course, mplayer must be present on your computer.

speak()
  {
  local IFS=+
  # Invoke mplayer, then connect to Google translation server.
  /usr/bin/mplayer -ao alsa -really-quiet -noconsolecontrols \
 "http://translate.google.com/translate_tts?tl=en&q="$*""
  # Google translates, but can also speak.
  }

LINES=4

spk=$(tail -$LINES $0) # Tail end of same script!
speak "$spk"
exit
# Browns. Nice talking to you.
}

One interesting example of a complex shell wrapper is Martin
Matusiak's ◊command{undvd} script, which provides an easy-to-use
command-line interface to the complex mencoder utility. Another
example is Itzchak Rehberg's Ext3Undel, a set of scripts to recover
deleted file on an ext3 filesystem.

◊url[#:link "http://sourceforge.net/projects/undvd/"]

◊url[#:link "http://www.mplayerhq.hu/DOCS/HTML/en/mencoder.html"]

◊url[#:link "http://projects.izzysoft.de/trac/ext3undel"]

