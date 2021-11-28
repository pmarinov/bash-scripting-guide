#lang pollen

◊page-init{}
◊define-meta[page-title]{Style}
◊define-meta[page-description]{Scripting With Style}

◊quotation[#:author "Landon Noll"]{... reading the UNIX source code to
the Bourne shell (◊fname{/bin/sh}). I was shocked at how much simple
algorithms could be made cryptic, and therefore useless, by a poor
choice of code style. I asked myself, "Could someone be proud of this
code?"}

Get into the habit of writing shell scripts in a structured and
systematic manner. Even on-the-fly and "written on the back of an
envelope" scripts will benefit if you take a few minutes to plan and
organize your thoughts before sitting down and coding.

Herewith are a few stylistic guidelines. This is not (necessarily)
intended as an ◊strong{Official Shell Scripting Stylesheet}.

◊list-block[#:type "bullet"]{

◊list-entry{Comment your code. This makes it easier for others to
understand (and appreciate), and easier for you to maintain.

◊example{
PASS="$PASS${MATRIX:$(($RANDOM%${#MATRIX})):1}"
#  It made perfect sense when you wrote it last year,
#+ but now it's a complete mystery.
#  (From Antek Sawicki's "pw.sh" script.)
}

Add descriptive headers to your scripts and functions.

◊example{
#!/bin/bash

#************************************************#
#                   xyz.sh                       #
#           written by Bozo Bozeman              #
#                July 05, 2001                   #
#                                                #
#           Clean up project files.              #
#************************************************#

E_BADDIR=85                       # No such directory.
projectdir=/home/bozo/projects    # Directory to clean up.

# --------------------------------------------------------- #
# cleanup_pfiles ()                                         #
# Removes all files in designated directory.                #
# Parameter: $target_directory                              #
# Returns: 0 on success, $E_BADDIR if something went wrong. #
# --------------------------------------------------------- #
cleanup_pfiles ()
{
  if [ ! -d "$1" ]  # Test if target directory exists.
  then
    echo "$1 is not a directory."
    return $E_BADDIR
  fi

  rm -f "$1"/*
  return 0   # Success.
}  

cleanup_pfiles $projectdir

exit $?
}

}

◊list-entry{Avoid using "magic numbers," that is, "hard-wired" literal
constants. Use meaningful variable names instead. This makes the
script easier to understand and permits making changes and updates
without breaking the application. ◊footnote{In this context, "magic
numbers" have an entirely different meaning than the magic numbers
used to designate file types.}

◊example{
if [ -f /var/log/messages ]
then
  ...
fi
#  A year later, you decide to change the script to check /var/log/syslog.
#  It is now necessary to manually change the script, instance by instance,
#+ and hope nothing breaks.

# A better way:
LOGFILE=/var/log/messages  # Only line that needs to be changed.
if [ -f "$LOGFILE" ]
then
  ...
fi
}

}

◊list-entry{Choose descriptive names for variables and functions.

◊example{
fl=`ls -al $dirname`                 # Cryptic.
file_listing=`ls -al $dirname`       # Better.


MAXVAL=10   # All caps used for a script constant.
while [ "$index" -le "$MAXVAL" ]
...


E_NOTFOUND=95                        #  Uppercase for an errorcode,
                                     #+ and name prefixed with E_.
if [ ! -e "$filename" ]
then
  echo "File $filename not found."
  exit $E_NOTFOUND
fi  


MAIL_DIRECTORY=/var/spool/mail/bozo  #  Uppercase for an environmental
export MAIL_DIRECTORY                #+ variable.


GetAnswer ()                         #  Mixed case works well for a
{                                    #+ function name, especially
  prompt=$1                          #+ when it improves legibility.
  echo -n $prompt
  read answer
  return $answer
}  

GetAnswer "What is your favorite number? "
favorite_number=$?
echo $favorite_number


_uservariable=23                     # Permissible, but not recommended.
# It's better for user-defined variables not to start with an underscore.
# Leave that for system variables.
}

}

◊list-entry{Use exit codes in a systematic and meaningful way.

◊example{
E_WRONG_ARGS=95
...
...
exit $E_WRONG_ARGS
}

See also TODO Appendix E.

Ender suggests using the exit codes in ◊fname{/usr/include/sysexits.h}
in shell scripts, though these are primarily intended for C and C++
programming.

}

◊list-entry{Use standardized parameter flags for script
invocation. Ender proposes the following set of flags.

◊example{
-a      All: Return all information (including hidden file info).
-b      Brief: Short version, usually for other scripts.
-c      Copy, concatenate, etc.
-d      Daily: Use information from the whole day, and not merely
        information for a specific instance/user.
-e      Extended/Elaborate: (often does not include hidden file info).
-h      Help: Verbose usage w/descs, aux info, discussion, help.
        See also -V.
-l      Log output of script.
-m      Manual: Launch man-page for base command.
-n      Numbers: Numerical data only.
-r      Recursive: All files in a directory (and/or all sub-dirs).
-s      Setup & File Maintenance: Config files for this script.
-u      Usage: List of invocation flags for the script.
-v      Verbose: Human readable output, more or less formatted.
-V      Version / License / Copy(right|left) / Contribs (email too).
}

See also TODO Section G.1.

}

◊list-entry{Break complex scripts into simpler modules. Use functions
where appropriate. See TODO Example 37-4.

}

◊list-entry{Don't use a complex construct where a simpler one will do.

◊example{
COMMAND
if [ $? -eq 0 ]
...
# Redundant and non-intuitive.

if COMMAND
...
# More concise (if perhaps not quite as legible).
}

}

}


