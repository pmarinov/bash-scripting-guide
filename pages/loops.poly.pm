#lang pollen

◊define-meta[page-title]{Loops}
◊define-meta[page-description]{Loop forms: "for", "while"}

◊section{for arg in [list]}

This is the basic looping construct. It differs significantly from its C counterpart.

◊example{
for arg in [list]
do
  command(s)...
done
}

Note: During each pass through the loop, ◊code{arg} takes on the value
of each successive variable in the ◊code{list}.

◊example{
for arg in "$var1" "$var2" "$var3" ... "$varN"  
# In pass 1 of the loop, arg = $var1	    
# In pass 2 of the loop, arg = $var2	    
# In pass 3 of the loop, arg = $var3	    
# ...
# In pass N of the loop, arg = $varN

# Arguments in [list] quoted to prevent possible word splitting.
}

The argument ◊code{list} may contain wild cards.

If ◊code{do} is on same line as ◊code{for}, there needs to be a
semicolon after ◊code{list}: ◊code{for arg in [list] ; do}

◊section-example[#:anchor "simple_for1"]{Simple for loops}

◊example{
#!/bin/bash
# Listing the planets.

for planet in Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune Pluto
do
  echo $planet  # Each planet on a separate line.
done

echo; echo

for planet in "Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune Pluto"
    # All planets on same line.
    # Entire 'list' enclosed in quotes creates a single variable.
    # Why? Whitespace incorporated into the variable.
do
  echo $planet
done

echo; echo "Whoops! Pluto is no longer a planet!"

exit 0
}

◊section-example[#:anchor "for_twoelem1"]{for loop with two parameters
in each [list] element}

Each ◊code{[list]} element may contain multiple parameters. This is
useful when processing parameters in groups. In such cases, use the
◊code{set} command (TODO see Example 15-16) to force parsing of each
◊code{[list]} element and assignment of each component to the
positional parameters.

◊example{
#!/bin/bash
# Planets revisited.

# Associate the name of each planet with its distance from the sun.

for planet in "Mercury 36" "Venus 67" "Earth 93"  "Mars 142" "Jupiter 483"
do
  set -- $planet  #  Parses variable "planet"
                  #+ and sets positional parameters.
  #  The "--" prevents nasty surprises if $planet is null or
  #+ begins with a dash.

  #  May need to save original positional parameters,
  #+ since they get overwritten.
  #  One way of doing this is to use an array,
  #         original_params=("$@")

  echo "$1		$2,000,000 miles from the sun"
  #-------two  tabs---concatenate zeroes onto parameter $2
done

# (Thanks, S.C., for additional clarification.)

exit 0
}

◊section-example[#:anchor "fileinfo1"]{Fileinfo: operating on a file
list contained in a variable}

A variable may supply the ◊code{[list]} in a ◊code{for} loop.

◊example{
#!/bin/bash
# fileinfo.sh

FILES="/usr/sbin/accept
/usr/sbin/pwck
/usr/sbin/chroot
/usr/bin/fakefile
/sbin/badblocks
/sbin/ypbind"     # List of files you are curious about.
                  # Threw in a dummy file, /usr/bin/fakefile.

echo

for file in $FILES
do

  if [ ! -e "$file" ]       # Check if file exists.
  then
    echo "$file does not exist."; echo
    continue                # On to next.
   fi

  ls -l $file | awk '{ print $8 "         file size: " $5 }'  # Print 2 fields.
  whatis `basename $file`   # File info.
  # Note that the whatis database needs to have been set up for this to work.
  # To do this, as root run /usr/bin/makewhatis.
  echo
done  

exit 0
}

◊section-example[#:anchor "for_paramlst1"]{Operating on a
parameterized file list}

The ◊code{[list]} in a ◊code{for} loop may be parameterized.

◊example{
#!/bin/bash

filename="*txt"

for file in $filename
do
  echo "Contents of $file"
  echo "---"
  cat "$file"
  echo
done
}

◊section-example[#:anchor "files_forloo1"]{Operating on files with a
for loop}

If the ◊code{[list]} in a ◊code{for} loop contains wild cards
(◊code{*} and ◊code{?}) used in filename expansion, then globbing
takes place.

◊example{
#!/bin/bash
# list-glob.sh: Generating [list] in a for-loop, using "globbing" ...
# Globbing = filename expansion.

echo

for file in *
#           ^  Bash performs filename expansion
#+             on expressions that globbing recognizes.
do
  ls -l "$file"  # Lists all files in $PWD (current directory).
  #  Recall that the wild card character "*" matches every filename,
  #+ however, in "globbing," it doesn't match dot-files.

  #  If the pattern matches no file, it is expanded to itself.
  #  To prevent this, set the nullglob option
  #+   (shopt -s nullglob).
  #  Thanks, S.C.
done

echo; echo

for file in [jx]*
do
  rm -f $file    # Removes only files beginning with "j" or "x" in $PWD.
  echo "Removed file \"$file\"".
done

echo

exit 0
}

◊section-example[#:anchor "for_missing_lst1"]{Missing in [list] in a
for loop}

Omitting the ◊code{in [list]} part of a ◊code{for} loop causes the
loop to operate on ◊code{$◊escaped{@}} -- the positional parameters. A
particularly clever illustration of this is TODO Example A-15. See
also Example 15-17.

◊example{
#!/bin/bash

#  Invoke this script both with and without arguments,
#+ and see what happens.

for a
do
 echo -n "$a "
done

#  The 'in list' missing, therefore the loop operates on '$@'
#+ (command-line argument list, including whitespace).

echo

exit 0
}


◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
