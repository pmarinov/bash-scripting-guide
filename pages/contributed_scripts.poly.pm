#lang pollen

◊page-init{}
◊define-meta[page-title]{Contributed Scripts}
◊define-meta[page-description]{Contributed Scripts}

These scripts, while not fitting into the text of this document, do
illustrate some interesting shell programming techniques. Some are
useful, too. Have fun analyzing and running them.

◊anchored-example[#:anchor "mail_fmt1"]{mailformat: Formatting an
e-mail message}

◊example{
#!/bin/bash
# mail-format.sh (ver. 1.1): Format e-mail messages.

# Gets rid of carets, tabs, and also folds excessively long lines.

# =================================================================
#                 Standard Check for Script Argument(s)
ARGS=1
E_BADARGS=85
E_NOFILE=86

if [ $# -ne $ARGS ]  # Correct number of arguments passed to script?
then
  echo "Usage: `basename $0` filename"
  exit $E_BADARGS
fi

if [ -f "$1" ]       # Check if file exists.
then
    file_name=$1
else
    echo "File \"$1\" does not exist."
    exit $E_NOFILE
fi
# -----------------------------------------------------------------

MAXWIDTH=70          # Width to fold excessively long lines to.

# =================================
# A variable can hold a sed script.
# It's a useful technique.
sedscript='s/^>//
s/^  *>//
s/^  *//
s/		*//'
# =================================

#  Delete carets and tabs at beginning of lines,
#+ then fold lines to $MAXWIDTH characters.
sed "$sedscript" $1 | fold -s --width=$MAXWIDTH
                        #  -s option to "fold"
                        #+ breaks lines at whitespace, if possible.


#  This script was inspired by an article in a well-known trade journal
#+ extolling a 164K MS Windows utility with similar functionality.
#
#  An nice set of text processing utilities and an efficient
#+ scripting language provide an alternative to the bloated executables
#+ of a clunky operating system.

exit $?

}

◊anchored-example[#:anchor "rn1"]{rn: A simple-minded file renaming
utility}

◊example{
#! /bin/bash
# rn.sh

# Very simpleminded filename "rename" utility (based on "lowercase.sh").
#
#  The "ren" utility, by Vladimir Lanin (lanin@csd2.nyu.edu),
#+ does a much better job of this.


ARGS=2
E_BADARGS=85
ONE=1                     # For getting singular/plural right (see below).

if [ $# -ne "$ARGS" ]
then
  echo "Usage: `basename $0` old-pattern new-pattern"
  # As in "rn gif jpg", which renames all gif files in working directory to jpg.
  exit $E_BADARGS
fi

number=0                  # Keeps track of how many files actually renamed.


for filename in *$1*      #Traverse all matching files in directory.
do
   if [ -f "$filename" ]  # If finds match...
   then
     fname=`basename $filename`            # Strip off path.
     n=`echo $fname | sed -e "s/$1/$2/"`   # Substitute new for old in filename.
     mv $fname $n                          # Rename.
     let "number += 1"
   fi
done   

if [ "$number" -eq "$ONE" ]                # For correct grammar.
then
 echo "$number file renamed."
else 
 echo "$number files renamed."
fi 

exit $?


# Exercises:
# ---------
# What types of files will this not work on?
# How can this be fixed?
}

◊anchored-example[#:anchor "rn_blank1"]{blank-rename: Renames
filenames containing blanks}

This is a simpler-minded version of previous script.

◊example{
#! /bin/bash
# blank-rename.sh
#
# Substitutes underscores for blanks in all the filenames in a directory.

ONE=1                     # For getting singular/plural right (see below).
number=0                  # Keeps track of how many files actually renamed.
FOUND=0                   # Successful return value.

for filename in *         #Traverse all files in directory.
do
     echo "$filename" | grep -q " "         #  Check whether filename
     if [ $? -eq $FOUND ]                   #+ contains space(s).
     then
       fname=$filename                      # Yes, this filename needs work.
       n=`echo $fname | sed -e "s/ /_/g"`   # Substitute underscore for blank.
       mv "$fname" "$n"                     # Do the actual renaming.
       let "number += 1"
     fi
done   

if [ "$number" -eq "$ONE" ]                 # For correct grammar.
then
 echo "$number file renamed."
else 
 echo "$number files renamed."
fi 

exit 0
}

◊anchored-example[#:anchor "enc_ftp1"]{encryptedpw: Uploading to an
ftp site, using a locally encrypted password}

◊example{
#!/bin/bash

# Example "ex72.sh" modified to use encrypted password.

#  Note that this is still rather insecure,
#+ since the decrypted password is sent in the clear.
#  Use something like "ssh" if this is a concern.

E_BADARGS=85

if [ -z "$1" ]
then
  echo "Usage: `basename $0` filename"
  exit $E_BADARGS
fi  

Username=bozo           # Change to suit.
pword=/home/bozo/secret/password_encrypted.file
# File containing encrypted password.

Filename=`basename $1`  # Strips pathname out of file name.

Server="XXX"
Directory="YYY"         # Change above to actual server name & directory.


Password=`cruft <$pword`          # Decrypt password.
#  Uses the author's own "cruft" file encryption package,
#+ based on the classic "onetime pad" algorithm,
#+ and obtainable from:
#+ Primary-site:   ftp://ibiblio.org/pub/Linux/utils/file
#+                 cruft-0.2.tar.gz [16k]


ftp -n $Server <<End-Of-Session
user $Username $Password
binary
bell
cd $Directory
put $Filename
bye
End-Of-Session
# -n option to "ftp" disables auto-logon.
# Note that "bell" rings 'bell' after each file transfer.

exit 0
}

◊anchored-example[#:anchor "copy_cd1"]{copy-cd: Copying a data CD}

◊example{
#!/bin/bash
# copy-cd.sh: copying a data CD

CDROM=/dev/cdrom                           # CD ROM device
OF=/home/bozo/projects/cdimage.iso         # output file
#       /xxxx/xxxxxxxx/                      Change to suit your system.
BLOCKSIZE=2048
# SPEED=10                                 # If unspecified, uses max spd.
# DEVICE=/dev/cdrom                          older version.
DEVICE="1,0,0"

echo; echo "Insert source CD, but do *not* mount it."
echo "Press ENTER when ready. "
read ready                                 # Wait for input, $ready not used.

echo; echo "Copying the source CD to $OF."
echo "This may take a while. Please be patient."

dd if=$CDROM of=$OF bs=$BLOCKSIZE          # Raw device copy.


echo; echo "Remove data CD."
echo "Insert blank CDR."
echo "Press ENTER when ready. "
read ready                                 # Wait for input, $ready not used.

echo "Copying $OF to CDR."

# cdrecord -v -isosize speed=$SPEED dev=$DEVICE $OF   # Old version.
wodim -v -isosize dev=$DEVICE $OF
# Uses Joerg Schilling's "cdrecord" package (see its docs).
# http://www.fokus.gmd.de/nthp/employees/schilling/cdrecord.html
# Newer Linux distros may use "wodim" rather than "cdrecord" ...


echo; echo "Done copying $OF to CDR on device $CDROM."

echo "Do you want to erase the image file (y/n)? "  # Probably a huge file.
read answer

case "$answer" in
[yY]) rm -f $OF
      echo "$OF erased."
      ;;
*)    echo "$OF not erased.";;
esac

echo

# Exercise:
# Change the above "case" statement to also accept "yes" and "Yes" as input.

exit 0
}

◊anchored-example[#:anchor "collats1"]{Collatz series}

◊example{
#!/bin/bash
# collatz.sh

#  The notorious "hailstone" or Collatz series.
#  -------------------------------------------
#  1) Get the integer "seed" from the command-line.
#  2) NUMBER <-- seed
#  3) Print NUMBER.
#  4)  If NUMBER is even, divide by 2, or
#  5)+ if odd, multiply by 3 and add 1.
#  6) NUMBER <-- result 
#  7) Loop back to step 3 (for specified number of iterations).
#
#  The theory is that every such sequence,
#+ no matter how large the initial value,
#+ eventually settles down to repeating "4,2,1..." cycles,
#+ even after fluctuating through a wide range of values.
#
#  This is an instance of an "iterate,"
#+ an operation that feeds its output back into its input.
#  Sometimes the result is a "chaotic" series.


MAX_ITERATIONS=200
# For large seed numbers (>32000), try increasing MAX_ITERATIONS.

h=${1:-$$}                      #  Seed.
                                #  Use $PID as seed,
                                #+ if not specified as command-line arg.

echo
echo "C($h) -*- $MAX_ITERATIONS Iterations"
echo

for ((i=1; i<=MAX_ITERATIONS; i++))
do

# echo -n "$h	"
#            ^^^ 
#            tab
# printf does it better ...
COLWIDTH=%7d
printf $COLWIDTH $h

  let "remainder = h % 2"
  if [ "$remainder" -eq 0 ]   # Even?
  then
    let "h /= 2"              # Divide by 2.
  else
    let "h = h*3 + 1"         # Multiply by 3 and add 1.
  fi


COLUMNS=10                    # Output 10 values per line.
let "line_break = i % $COLUMNS"
if [ "$line_break" -eq 0 ]
then
  echo
fi  

done

echo

#  For more information on this strange mathematical function,
#+ see _Computers, Pattern, Chaos, and Beauty_, by Pickover, p. 185 ff.,
#+ as listed in the bibliography.

exit 0
}

◊anchored-example[#:anchor "dbetween1"]{days-between: Days between two dates}

◊example{
#!/bin/bash
# days-between.sh:    Number of days between two dates.
# Usage: ./days-between.sh [M]M/[D]D/YYYY [M]M/[D]D/YYYY
#
# Note: Script modified to account for changes in Bash, v. 2.05b +,
#+      that closed the loophole permitting large negative
#+      integer return values.

ARGS=2                # Two command-line parameters expected.
E_PARAM_ERR=85        # Param error.

REFYR=1600            # Reference year.
CENTURY=100
DIY=365
ADJ_DIY=367           # Adjusted for leap year + fraction.
MIY=12
DIM=31
LEAPCYCLE=4

MAXRETVAL=255         #  Largest permissible
                      #+ positive return value from a function.

diff=                 # Declare global variable for date difference.
value=                # Declare global variable for absolute value.
day=                  # Declare globals for day, month, year.
month=
year=


Param_Error ()        # Command-line parameters wrong.
{
  echo "Usage: `basename $0` [M]M/[D]D/YYYY [M]M/[D]D/YYYY"
  echo "       (date must be after 1/3/1600)"
  exit $E_PARAM_ERR
}  


Parse_Date ()                 # Parse date from command-line params.
{
  month=${1%%/**}
  dm=${1%/**}                 # Day and month.
  day=${dm#*/}
  let "year = `basename $1`"  # Not a filename, but works just the same.
}  


check_date ()                 # Checks for invalid date(s) passed.
{
  [ "$day" -gt "$DIM" ] || [ "$month" -gt "$MIY" ] ||
  [ "$year" -lt "$REFYR" ] && Param_Error
  # Exit script on bad value(s).
  # Uses or-list / and-list.
  #
  # Exercise: Implement more rigorous date checking.
}


strip_leading_zero () #  Better to strip possible leading zero(s)
{                     #+ from day and/or month
  return ${1#0}       #+ since otherwise Bash will interpret them
}                     #+ as octal values (POSIX.2, sect 2.9.2.1).


day_index ()          # Gauss' Formula:
{                     # Days from March 1, 1600 to date passed as param.
                      #           ^^^^^^^^^^^^^
  day=$1
  month=$2
  year=$3

  let "month = $month - 2"
  if [ "$month" -le 0 ]
  then
    let "month += 12"
    let "year -= 1"
  fi  

  let "year -= $REFYR"
  let "indexyr = $year / $CENTURY"


  let "Days = $DIY*$year + $year/$LEAPCYCLE - $indexyr \
              + $indexyr/$LEAPCYCLE + $ADJ_DIY*$month/$MIY + $day - $DIM"
  #  For an in-depth explanation of this algorithm, see
  #+   http://weblogs.asp.net/pgreborio/archive/2005/01/06/347968.aspx


  echo $Days

}  


calculate_difference ()            # Difference between two day indices.
{
  let "diff = $1 - $2"             # Global variable.
}  


abs ()                             #  Absolute value
{                                  #  Uses global "value" variable.
  if [ "$1" -lt 0 ]                #  If negative
  then                             #+ then
    let "value = 0 - $1"           #+ change sign,
  else                             #+ else
    let "value = $1"               #+ leave it alone.
  fi
}



if [ $# -ne "$ARGS" ]              # Require two command-line params.
then
  Param_Error
fi  

Parse_Date $1
check_date $day $month $year       #  See if valid date.

strip_leading_zero $day            #  Remove any leading zeroes
day=$?                             #+ on day and/or month.
strip_leading_zero $month
month=$?

let "date1 = `day_index $day $month $year`"


Parse_Date $2
check_date $day $month $year

strip_leading_zero $day
day=$?
strip_leading_zero $month
month=$?

date2=$(day_index $day $month $year) # Command substitution.


calculate_difference $date1 $date2

abs $diff                            # Make sure it's positive.
diff=$value

echo $diff

exit 0

#  Exercise:
#  --------
#  If given only one command-line parameter, have the script
#+ use today's date as the second.


#  Compare this script with
#+ the implementation of Gauss' Formula in a C program at
#+    http://buschencrew.hypermart.net/software/datedif
}

◊anchored-example[#:anchor "mdict1"]{Making a dictionary}

◊example{
#!/bin/bash
# makedict.sh  [make dictionary]

# Modification of /usr/sbin/mkdict (/usr/sbin/cracklib-forman) script.
# Original script copyright 1993, by Alec Muffett.
#
#  This modified script included in this document in a manner
#+ consistent with the "LICENSE" document of the "Crack" package
#+ that the original script is a part of.

#  This script processes text files to produce a sorted list
#+ of words found in the files.
#  This may be useful for compiling dictionaries
#+ and for other lexicographic purposes.


E_BADARGS=85

if [ ! -r "$1" ]                    #  Need at least one
then                                #+ valid file argument.
  echo "Usage: $0 files-to-process"
  exit $E_BADARGS
fi  


# SORT="sort"                       #  No longer necessary to define
                                    #+ options to sort. Changed from
                                    #+ original script.

cat $* |                            #  Dump specified files to stdout.
        tr A-Z a-z |                #  Convert to lowercase.
        tr ' ' '\012' |             #  New: change spaces to newlines.
#       tr -cd '\012[a-z][0-9]' |   #  Get rid of everything
                                    #+ non-alphanumeric (in orig. script).
        tr -c '\012a-z'  '\012' |   #  Rather than deleting non-alpha
                                    #+ chars, change them to newlines.
        sort |                      #  $SORT options unnecessary now.
        uniq |                      #  Remove duplicates.
        grep -v '^#' |              #  Delete lines starting with #.
        grep -v '^$'                #  Delete blank lines.

exit $?
}

◊anchored-example[#:anchor "sndx1"]{Soundex conversion}

◊example{
#!/bin/bash
# soundex.sh: Calculate "soundex" code for names

# =======================================================
#        Soundex script
#              by
#         Mendel Cooper
#     thegrendel.abs@gmail.com
#     reldate: 23 January, 2002
#
#   Placed in the Public Domain.
#
# A slightly different version of this script appeared in
#+ Ed Schaefer's July, 2002 "Shell Corner" column
#+ in "Unix Review" on-line,
#+ http://www.unixreview.com/documents/uni1026336632258/
# =======================================================


ARGCOUNT=1                     # Need name as argument.
E_WRONGARGS=90

if [ $# -ne "$ARGCOUNT" ]
then
  echo "Usage: `basename $0` name"
  exit $E_WRONGARGS
fi  


assign_value ()                #  Assigns numerical value
{                              #+ to letters of name.

  val1=bfpv                    # 'b,f,p,v' = 1
  val2=cgjkqsxz                # 'c,g,j,k,q,s,x,z' = 2
  val3=dt                      #  etc.
  val4=l
  val5=mn
  val6=r

# Exceptionally clever use of 'tr' follows.
# Try to figure out what is going on here.

value=$( echo "$1" \
| tr -d wh \
| tr $val1 1 | tr $val2 2 | tr $val3 3 \
| tr $val4 4 | tr $val5 5 | tr $val6 6 \
| tr -s 123456 \
| tr -d aeiouy )

# Assign letter values.
# Remove duplicate numbers, except when separated by vowels.
# Ignore vowels, except as separators, so delete them last.
# Ignore 'w' and 'h', even as separators, so delete them first.
#
# The above command substitution lays more pipe than a plumber <g>.

}  


input_name="$1"
echo
echo "Name = $input_name"


# Change all characters of name input to lowercase.
# ------------------------------------------------
name=$( echo $input_name | tr A-Z a-z )
# ------------------------------------------------
# Just in case argument to script is mixed case.


# Prefix of soundex code: first letter of name.
# --------------------------------------------


char_pos=0                     # Initialize character position. 
prefix0=${name:$char_pos:1}
prefix=`echo $prefix0 | tr a-z A-Z`
                               # Uppercase 1st letter of soundex.

let "char_pos += 1"            # Bump character position to 2nd letter of name.
name1=${name:$char_pos}


# ++++++++++++++++++++++++++ Exception Patch ++++++++++++++++++++++++++++++
#  Now, we run both the input name and the name shifted one char
#+ to the right through the value-assigning function.
#  If we get the same value out, that means that the first two characters
#+ of the name have the same value assigned, and that one should cancel.
#  However, we also need to test whether the first letter of the name
#+ is a vowel or 'w' or 'h', because otherwise this would bollix things up.

char1=`echo $prefix | tr A-Z a-z`    # First letter of name, lowercased.

assign_value $name
s1=$value
assign_value $name1
s2=$value
assign_value $char1
s3=$value
s3=9$s3                              #  If first letter of name is a vowel
                                     #+ or 'w' or 'h',
                                     #+ then its "value" will be null (unset).
				     #+ Therefore, set it to 9, an otherwise
				     #+ unused value, which can be tested for.


if [[ "$s1" -ne "$s2" || "$s3" -eq 9 ]]
then
  suffix=$s2
else  
  suffix=${s2:$char_pos}
fi  
# ++++++++++++++++++++++ end Exception Patch ++++++++++++++++++++++++++++++


padding=000                    # Use at most 3 zeroes to pad.


soun=$prefix$suffix$padding    # Pad with zeroes.

MAXLEN=4                       # Truncate to maximum of 4 chars.
soundex=${soun:0:$MAXLEN}

echo "Soundex = $soundex"

echo

#  The soundex code is a method of indexing and classifying names
#+ by grouping together the ones that sound alike.
#  The soundex code for a given name is the first letter of the name,
#+ followed by a calculated three-number code.
#  Similar sounding names should have almost the same soundex codes.

#   Examples:
#   Smith and Smythe both have a "S-530" soundex.
#   Harrison = H-625
#   Hargison = H-622
#   Harriman = H-655

#  This works out fairly well in practice, but there are numerous anomalies.
#
#
#  The U.S. Census and certain other governmental agencies use soundex,
#  as do genealogical researchers.
#
#  For more information,
#+ see the "National Archives and Records Administration home page",
#+ http://www.nara.gov/genealogy/soundex/soundex.html



# Exercise:
# --------
# Simplify the "Exception Patch" section of this script.

exit 0
}

◊anchored-example[#:anchor "gm_life1"]{Game of Life}

◊example{
#!/bin/bash
# life.sh: "Life in the Slow Lane"
# Author: Mendel Cooper
# License: GPL3

# Version 0.2:   Patched by Daniel Albers
#+               to allow non-square grids as input.
# Version 0.2.1: Added 2-second delay between generations.

# ##################################################################### #
# This is the Bash script version of John Conway's "Game of Life".      #
# "Life" is a simple implementation of cellular automata.               #
# --------------------------------------------------------------------- #
# On a rectangular grid, let each "cell" be either "living" or "dead."  #
# Designate a living cell with a dot, and a dead one with a blank space.#
#      Begin with an arbitrarily drawn dot-and-blank grid,              #
#+     and let this be the starting generation: generation 0.           #
# Determine each successive generation by the following rules:          #
#   1) Each cell has 8 neighbors, the adjoining cells                   #
#+     left, right, top, bottom, and the 4 diagonals.                   #
#                                                                       #
#                       123                                             #
#                       4*5     The * is the cell under consideration.  #
#                       678                                             #
#                                                                       #
# 2) A living cell with either 2 or 3 living neighbors remains alive.   #
SURVIVE=2                                                               #
# 3) A dead cell with 3 living neighbors comes alive, a "birth."        #
BIRTH=3                                                                 #
# 4) All other cases result in a dead cell for the next generation.     #
# ##################################################################### #


startfile=gen0   # Read the starting generation from the file "gen0" ...
                 # Default, if no other file specified when invoking script.
                 #
if [ -n "$1" ]   # Specify another "generation 0" file.
then
    startfile="$1"
fi  

############################################
#  Abort script if "startfile" not specified
#+ and
#+ default file "gen0" not present.

E_NOSTARTFILE=86

if [ ! -e "$startfile" ]
then
  echo "Startfile \""$startfile"\" missing!"
  exit $E_NOSTARTFILE
fi
############################################


ALIVE1=.
DEAD1=_
                 # Represent living and dead cells in the start-up file.

#  -----------------------------------------------------#
#  This script uses a 10 x 10 grid (may be increased,
#+ but a large grid will slow down execution).
ROWS=10
COLS=10
#  Change above two variables to match desired grid size.
#  -----------------------------------------------------#

GENERATIONS=10          #  How many generations to cycle through.
                        #  Adjust this upwards
                        #+ if you have time on your hands.

NONE_ALIVE=85           #  Exit status on premature bailout,
                        #+ if no cells left alive.
DELAY=2                 #  Pause between generations.
TRUE=0
FALSE=1
ALIVE=0
DEAD=1

avar=                   # Global; holds current generation.
generation=0            # Initialize generation count.

# =================================================================

let "cells = $ROWS * $COLS"   # How many cells.

# Arrays containing "cells."
declare -a initial
declare -a current

display ()
{

alive=0                 # How many cells alive at any given time.
                        # Initially zero.

declare -a arr
arr=( `echo "$1"` )     # Convert passed arg to array.

element_count=${#arr[*]}

local i
local rowcheck

for ((i=0; i<$element_count; i++))
do

  # Insert newline at end of each row.
  let "rowcheck = $i % COLS"
  if [ "$rowcheck" -eq 0 ]
  then
    echo                # Newline.
    echo -n "      "    # Indent.
  fi  

  cell=${arr[i]}

  if [ "$cell" = . ]
  then
    let "alive += 1"
  fi  

  echo -n "$cell" | sed -e 's/_/ /g'
  # Print out array, changing underscores to spaces.
done  

return

}

IsValid ()                            # Test if cell coordinate valid.
{

  if [ -z "$1"  -o -z "$2" ]          # Mandatory arguments missing?
  then
    return $FALSE
  fi

local row
local lower_limit=0                   # Disallow negative coordinate.
local upper_limit
local left
local right

let "upper_limit = $ROWS * $COLS - 1" # Total number of cells.


if [ "$1" -lt "$lower_limit" -o "$1" -gt "$upper_limit" ]
then
  return $FALSE                       # Out of array bounds.
fi  

row=$2
let "left = $row * $COLS"             # Left limit.
let "right = $left + $COLS - 1"       # Right limit.

if [ "$1" -lt "$left" -o "$1" -gt "$right" ]
then
  return $FALSE                       # Beyond row boundary.
fi  

return $TRUE                          # Valid coordinate.

}  


IsAlive ()              #  Test whether cell is alive.
                        #  Takes array, cell number, and
{                       #+ state of cell as arguments.
  GetCount "$1" $2      #  Get alive cell count in neighborhood.
  local nhbd=$?

  if [ "$nhbd" -eq "$BIRTH" ]  # Alive in any case.
  then
    return $ALIVE
  fi

  if [ "$3" = "." -a "$nhbd" -eq "$SURVIVE" ]
  then                  # Alive only if previously alive.
    return $ALIVE
  fi  

  return $DEAD          # Defaults to dead.

}  


GetCount ()             # Count live cells in passed cell's neighborhood.
                        # Two arguments needed:
			# $1) variable holding array
			# $2) cell number
{
  local cell_number=$2
  local array
  local top
  local center
  local bottom
  local r
  local row
  local i
  local t_top
  local t_cen
  local t_bot
  local count=0
  local ROW_NHBD=3

  array=( `echo "$1"` )

  let "top = $cell_number - $COLS - 1"    # Set up cell neighborhood.
  let "center = $cell_number - 1"
  let "bottom = $cell_number + $COLS - 1"
  let "r = $cell_number / $COLS"

  for ((i=0; i<$ROW_NHBD; i++))           # Traverse from left to right. 
  do
    let "t_top = $top + $i"
    let "t_cen = $center + $i"
    let "t_bot = $bottom + $i"


    let "row = $r"                        # Count center row.
    IsValid $t_cen $row                   # Valid cell position?
    if [ $? -eq "$TRUE" ]
    then
      if [ ${array[$t_cen]} = "$ALIVE1" ] # Is it alive?
      then                                # If yes, then ...
        let "count += 1"                  # Increment count.
      fi	
    fi  

    let "row = $r - 1"                    # Count top row.          
    IsValid $t_top $row
    if [ $? -eq "$TRUE" ]
    then
      if [ ${array[$t_top]} = "$ALIVE1" ] # Redundancy here.
      then                                # Can it be optimized?
        let "count += 1"
      fi	
    fi  

    let "row = $r + 1"                    # Count bottom row.
    IsValid $t_bot $row
    if [ $? -eq "$TRUE" ]
    then
      if [ ${array[$t_bot]} = "$ALIVE1" ] 
      then
        let "count += 1"
      fi	
    fi  

  done  


  if [ ${array[$cell_number]} = "$ALIVE1" ]
  then
    let "count -= 1"        #  Make sure value of tested cell itself
  fi                        #+ is not counted.


  return $count
  
}

next_gen ()               # Update generation array.
{

local array
local i=0

array=( `echo "$1"` )     # Convert passed arg to array.

while [ "$i" -lt "$cells" ]
do
  IsAlive "$1" $i ${array[$i]}   # Is the cell alive?
  if [ $? -eq "$ALIVE" ]
  then                           #  If alive, then
    array[$i]=.                  #+ represent the cell as a period.
  else  
    array[$i]="_"                #  Otherwise underscore
   fi                            #+ (will later be converted to space).
  let "i += 1" 
done   


#    let "generation += 1"       # Increment generation count.
###  Why was the above line commented out?


# Set variable to pass as parameter to "display" function.
avar=`echo ${array[@]}`   # Convert array back to string variable.
display "$avar"           # Display it.
echo; echo
echo "Generation $generation  -  $alive alive"

if [ "$alive" -eq 0 ]
then
  echo
  echo "Premature exit: no more cells alive!"
  exit $NONE_ALIVE        #  No point in continuing
fi                        #+ if no live cells.

}


# =========================================================

# main ()
# {

# Load initial array with contents of startup file.
initial=( `cat "$startfile" | sed -e '/#/d' | tr -d '\n' |\
# Delete lines containing '#' comment character.
           sed -e 's/\./\. /g' -e 's/_/_ /g'` )
# Remove linefeeds and insert space between elements.

clear          # Clear screen.

echo #         Title
setterm -reverse on
echo "======================="
setterm -reverse off
echo "    $GENERATIONS generations"
echo "           of"
echo "\"Life in the Slow Lane\""
setterm -reverse on
echo "======================="
setterm -reverse off

sleep $DELAY   # Display "splash screen" for 2 seconds.


# -------- Display first generation. --------
Gen0=`echo ${initial[@]}`
display "$Gen0"           # Display only.
echo; echo
echo "Generation $generation  -  $alive alive"
sleep $DELAY
# -------------------------------------------


let "generation += 1"     # Bump generation count.
echo

# ------- Display second generation. -------
Cur=`echo ${initial[@]}`
next_gen "$Cur"          # Update & display.
sleep $DELAY
# ------------------------------------------

let "generation += 1"     # Increment generation count.

# ------ Main loop for displaying subsequent generations ------
while [ "$generation" -le "$GENERATIONS" ]
do
  Cur="$avar"
  next_gen "$Cur"
  let "generation += 1"
  sleep $DELAY
done
# ==============================================================

echo
# }

exit 0   # CEOF:EOF



# The grid in this script has a "boundary problem."
# The the top, bottom, and sides border on a void of dead cells.
# Exercise: Change the script to have the grid wrap around,
# +         so that the left and right sides will "touch,"      
# +         as will the top and bottom.
#
# Exercise: Create a new "gen0" file to seed this script.
#           Use a 12 x 16 grid, instead of the original 10 x 10 one.
#           Make the necessary changes to the script,
#+          so it will run with the altered file.
#
# Exercise: Modify this script so that it can determine the grid size
#+          from the "gen0" file, and set any variables necessary
#+          for the script to run.
#           This would make unnecessary any changes to variables
#+          in the script for an altered grid size.
#
# Exercise: Optimize this script.
#           It has redundant code.
}

◊anchored-example[#:anchor ""]{Data file for Game of Life}

◊example{
# gen0
#
# This is an example "generation 0" start-up file for "life.sh".
# --------------------------------------------------------------
#  The "gen0" file is a 10 x 10 grid using a period (.) for live cells,
#+ and an underscore (_) for dead ones. We cannot simply use spaces
#+ for dead cells in this file because of a peculiarity in Bash arrays.
#  [Exercise for the reader: explain this.]
#
# Lines beginning with a '#' are comments, and the script ignores them.
__.__..___
__.._.____
____.___..
_._______.
____._____
..__...___
____._____
___...____
__.._..___
_..___..__
}

◊anchored-example[#:anchor "passwd_gen1"]{password: Generating random
8-character passwords}

◊example{
#!/bin/bash
#
#
#  Random password generator for Bash 2.x +
#+ by Antek Sawicki <tenox@tenox.tc>,
#+ who generously gave usage permission to the ABS Guide author.
#
# ==> Comments added by document author ==>


MATRIX="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
# ==> Password will consist of alphanumeric characters.
LENGTH="8"
# ==> May change 'LENGTH' for longer password.


while [ "${n:=1}" -le "$LENGTH" ]
# ==> Recall that := is "default substitution" operator.
# ==> So, if 'n' has not been initialized, set it to 1.
do
	PASS="$PASS${MATRIX:$(($RANDOM%${#MATRIX})):1}"
	# ==> Very clever, but tricky.

	# ==> Starting from the innermost nesting...
	# ==> ${#MATRIX} returns length of array MATRIX.

	# ==> $RANDOM%${#MATRIX} returns random number between 1
	# ==> and [length of MATRIX] - 1.

	# ==> ${MATRIX:$(($RANDOM%${#MATRIX})):1}
	# ==> returns expansion of MATRIX at random position, by length 1. 
	# ==> See {var:pos:len} parameter substitution in Chapter 9.
	# ==> and the associated examples.

	# ==> PASS=... simply pastes this result onto previous PASS (concatenation).

	# ==> To visualize this more clearly, uncomment the following line
	#                 echo "$PASS"
	# ==> to see PASS being built up,
	# ==> one character at a time, each iteration of the loop.

	let n+=1
	# ==> Increment 'n' for next pass.
done

echo "$PASS"      # ==> Or, redirect to a file, as desired.

exit 0
}

◊anchored-example[#:anchor "fifo_bak1"]{fifo: Making daily backups, using named
pipes}

◊example{
#!/bin/bash
# ==> Script by James R. Van Zandt, and used here with his permission.

# ==> Comments added by author of this document.
  
HERE=`uname -n`    # ==> hostname
THERE=bilbo
echo "starting remote backup to $THERE at `date +%r`"
# ==> `date +%r` returns time in 12-hour format, i.e. "08:08:34 PM".

# make sure /pipe really is a pipe and not a plain file
rm -rf /pipe
mkfifo /pipe       # ==> Create a "named pipe", named "/pipe" ...

# ==> 'su xyz' runs commands as user "xyz".
# ==> 'ssh' invokes secure shell (remote login client).
su xyz -c "ssh $THERE \"cat > /home/xyz/backup/${HERE}-daily.tar.gz\" < /pipe"&
cd /
tar -czf - bin boot dev etc home info lib man root sbin share usr var > /pipe
# ==> Uses named pipe, /pipe, to communicate between processes:
# ==> 'tar/gzip' writes to /pipe and 'ssh' reads from /pipe.

# ==> The end result is this backs up the main directories, from / on down.

# ==>  What are the advantages of a "named pipe" in this situation,
# ==>+ as opposed to an "anonymous pipe", with |?
# ==>  Will an anonymous pipe even work here?

# ==>  Is it necessary to delete the pipe before exiting the script?
# ==>  How could that be done?

exit 0
}

◊anchored-example[#:anchor ""]{Generating prime numbers using the
modulo operator}

◊example{
#!/bin/bash
# primes.sh: Generate prime numbers, without using arrays.
# Script contributed by Stephane Chazelas.

#  This does *not* use the classic "Sieve of Eratosthenes" algorithm,
#+ but instead the more intuitive method of testing each candidate number
#+ for factors (divisors), using the "%" modulo operator.


LIMIT=1000                    # Primes, 2 ... 1000.

Primes()
{
 (( n = $1 + 1 ))             # Bump to next integer.
 shift                        # Next parameter in list.
#  echo "_n=$n i=$i_"
 
 if (( n == LIMIT ))
 then echo $*
 return
 fi

 for i; do                    # "i" set to "@", previous values of $n.
#   echo "-n=$n i=$i-"
   (( i * i > n )) && break   # Optimization.
   (( n % i )) && continue    # Sift out non-primes using modulo operator.
   Primes $n $@               # Recursion inside loop.
   return
   done

   Primes $n $@ $n            #  Recursion outside loop.
                              #  Successively accumulate
			      #+ positional parameters.
                              #  "$@" is the accumulating list of primes.
}

Primes 1

exit $?

# Pipe output of the script to 'fmt' for prettier printing.

#  Uncomment lines 16 and 24 to help figure out what is going on.

#  Compare the speed of this algorithm for generating primes
#+ with the Sieve of Eratosthenes (ex68.sh).


#  Exercise: Rewrite this script without recursion.
}

◊anchored-example[#:anchor "dir_tree1"]{tree: Displaying a directory tree}

◊example{
#!/bin/bash
# tree.sh

#  Written by Rick Boivie.
#  Used with permission.
#  This is a revised and simplified version of a script
#+ by Jordi Sanfeliu (the original author), and patched by Ian Kjos.
#  This script replaces the earlier version used in
#+ previous releases of the Advanced Bash Scripting Guide.
#  Copyright (c) 2002, by Jordi Sanfeliu, Rick Boivie, and Ian Kjos.

# ==> Comments added by the author of this document.


search () {
for dir in `echo *`
#  ==> `echo *` lists all the files in current working directory,
#+ ==> without line breaks.
#  ==> Similar effect to for dir in *
#  ==> but "dir in `echo *`" will not handle filenames with blanks.
do
  if [ -d "$dir" ] ; then # ==> If it is a directory (-d)...
  zz=0                    # ==> Temp variable, keeping track of
                          #     directory level.
  while [ $zz != $1 ]     # Keep track of inner nested loop.
    do
      echo -n "| "        # ==> Display vertical connector symbol,
                          # ==> with 2 spaces & no line feed
                          #     in order to indent.
      zz=`expr $zz + 1`   # ==> Increment zz.
    done

    if [ -L "$dir" ] ; then # ==> If directory is a symbolic link...
      echo "+---$dir" `ls -l $dir | sed 's/^.*'$dir' //'`
      # ==> Display horiz. connector and list directory name, but...
      # ==> delete date/time part of long listing.
    else
      echo "+---$dir"       # ==> Display horizontal connector symbol...
      # ==> and print directory name.
      numdirs=`expr $numdirs + 1` # ==> Increment directory count.
      if cd "$dir" ; then         # ==> If can move to subdirectory...
        search `expr $1 + 1`      # with recursion ;-)
        # ==> Function calls itself.
        cd ..
      fi
    fi
  fi
done
}

if [ $# != 0 ] ; then
  cd $1   # Move to indicated directory.
  #else   # stay in current directory
fi

echo "Initial directory = `pwd`"
numdirs=0

search 0
echo "Total directories = $numdirs"

exit 0
}

◊anchored-example[#:anchor "dir_tree2"]{tree2: Alternate directory
tree script}

◊example{
#!/bin/bash
# tree2.sh

# Lightly modified/reformatted by ABS Guide author.
# Included in ABS Guide with permission of script author (thanks!).

## Recursive file/dirsize checking script, by Patsie
##
## This script builds a list of files/directories and their size (du -akx)
## and processes this list to a human readable tree shape
## The 'du -akx' is only as good as the permissions the owner has.
## So preferably run as root* to get the best results, or use only on
## directories for which you have read permissions. Anything you can't
## read is not in the list.

#* ABS Guide author advises caution when running scripts as root!


##########  THIS IS CONFIGURABLE  ##########

TOP=5                   # Top 5 biggest (sub)directories.
MAXRECURS=5             # Max 5 subdirectories/recursions deep.
E_BL=80                 # Blank line already returned.
E_DIR=81                # Directory not specified.


##########  DON'T CHANGE ANYTHING BELOW THIS LINE  ##########

PID=$$                            # Our own process ID.
SELF=`basename $0`                # Our own program name.
TMP="/tmp/${SELF}.${PID}.tmp"     # Temporary 'du' result.

# Convert number to dotted thousand.
function dot { echo "            $*" |
               sed -e :a -e 's/\(.*[0-9]\)\([0-9]\{3\}\)/\1,\2/;ta' |
               tail -c 12; }

# Usage: tree <recursion> <indent prefix> <min size> <directory>
function tree {
  recurs="$1"           # How deep nested are we?
  prefix="$2"           # What do we display before file/dirname?
  minsize="$3"          # What is the minumum file/dirsize?
  dirname="$4"          # Which directory are we checking?

# Get ($TOP) biggest subdirs/subfiles from TMP file.
  LIST=`egrep "[[:space:]]${dirname}/[^/]*$" "$TMP" |
        awk '{if($1>'$minsize') print;}' | sort -nr | head -$TOP`
  [ -z "$LIST" ] && return        # Empty list, then go back.

  cnt=0
  num=`echo "$LIST" | wc -l`      # How many entries in the list.

  ## Main loop
  echo "$LIST" | while read size name; do
    ((cnt+=1))		          # Count entry number.
    bname=`basename "$name"`      # We only need a basename of the entry.
    [ -d "$name" ] && bname="$bname/"
                                  # If it's a directory, append a slash.
    echo "`dot $size`$prefix +-$bname"
                                  # Display the result.
    #  Call ourself recursively if it's a directory
    #+ and we're not nested too deep ($MAXRECURS).
    #  The recursion goes up: $((recurs+1))
    #  The prefix gets a space if it's the last entry,
    #+ or a pipe if there are more entries.
    #  The minimum file/dirsize becomes
    #+ a tenth of his parent: $((size/10)).
    # Last argument is the full directory name to check.
    if [ -d "$name" -a $recurs -lt $MAXRECURS ]; then
      [ $cnt -lt $num ] \
        || (tree $((recurs+1)) "$prefix  " $((size/10)) "$name") \
        && (tree $((recurs+1)) "$prefix |" $((size/10)) "$name")
    fi
  done

  [ $? -eq 0 ] && echo "           $prefix"
  # Every time we jump back add a 'blank' line.
  return $E_BL
  # We return 80 to tell we added a blank line already.
}

###                ###
###  main program  ###
###                ###

rootdir="$@"
[ -d "$rootdir" ] ||
  { echo "$SELF: Usage: $SELF <directory>" >&2; exit $E_DIR; }
  # We should be called with a directory name.

echo "Building inventory list, please wait ..."
     # Show "please wait" message.
du -akx "$rootdir" 1>"$TMP" 2>/dev/null
     # Build a temporary list of all files/dirs and their size.
size=`tail -1 "$TMP" | awk '{print $1}'`
     # What is our rootdirectory's size?
echo "`dot $size` $rootdir"
     # Display rootdirectory's entry.
tree 0 "" 0 "$rootdir"
     # Display the tree below our rootdirectory.

rm "$TMP" 2>/dev/null
     # Clean up TMP file.

exit $?
}

◊anchored-example[#:anchor "str_c1"]{string functions: C-style string
functions}

◊example{
#!/bin/bash

# string.bash --- bash emulation of string(3) library routines
# Author: Noah Friedman <friedman@prep.ai.mit.edu>
# ==>     Used with his kind permission in this document.
# Created: 1992-07-01
# Last modified: 1993-09-29
# Public domain

# Conversion to bash v2 syntax done by Chet Ramey

# Commentary:
# Code:

#:docstring strcat:
# Usage: strcat s1 s2
#
# Strcat appends the value of variable s2 to variable s1. 
#
# Example:
#    a="foo"
#    b="bar"
#    strcat a b
#    echo $a
#    => foobar
#
#:end docstring:

###;;;autoload   ==> Autoloading of function commented out.
function strcat ()
{
    local s1_val s2_val

    s1_val=${!1}                        # indirect variable expansion
    s2_val=${!2}
    eval "$1"=\'"${s1_val}${s2_val}"\'
    # ==> eval $1='${s1_val}${s2_val}' avoids problems,
    # ==> if one of the variables contains a single quote.
}

#:docstring strncat:
# Usage: strncat s1 s2 $n
# 
# Line strcat, but strncat appends a maximum of n characters from the value
# of variable s2.  It copies fewer if the value of variabl s2 is shorter
# than n characters.  Echoes result on stdout.
#
# Example:
#    a=foo
#    b=barbaz
#    strncat a b 3
#    echo $a
#    => foobar
#
#:end docstring:

###;;;autoload
function strncat ()
{
    local s1="$1"
    local s2="$2"
    local -i n="$3"
    local s1_val s2_val

    s1_val=${!s1}                       # ==> indirect variable expansion
    s2_val=${!s2}

    if [ ${#s2_val} -gt ${n} ]; then
       s2_val=${s2_val:0:$n}            # ==> substring extraction
    fi

    eval "$s1"=\'"${s1_val}${s2_val}"\'
    # ==> eval $1='${s1_val}${s2_val}' avoids problems,
    # ==> if one of the variables contains a single quote.
}

#:docstring strcmp:
# Usage: strcmp $s1 $s2
#
# Strcmp compares its arguments and returns an integer less than, equal to,
# or greater than zero, depending on whether string s1 is lexicographically
# less than, equal to, or greater than string s2.
#:end docstring:

###;;;autoload
function strcmp ()
{
    [ "$1" = "$2" ] && return 0

    [ "${1}" '<' "${2}" ] > /dev/null && return -1

    return 1
}

#:docstring strncmp:
# Usage: strncmp $s1 $s2 $n
# 
# Like strcmp, but makes the comparison by examining a maximum of n
# characters (n less than or equal to zero yields equality).
#:end docstring:

###;;;autoload
function strncmp ()
{
    if [ -z "${3}" -o "${3}" -le "0" ]; then
       return 0
    fi
   
    if [ ${3} -ge ${#1} -a ${3} -ge ${#2} ]; then
       strcmp "$1" "$2"
       return $?
    else
       s1=${1:0:$3}
       s2=${2:0:$3}
       strcmp $s1 $s2
       return $?
    fi
}

#:docstring strlen:
# Usage: strlen s
#
# Strlen returns the number of characters in string literal s.
#:end docstring:

###;;;autoload
function strlen ()
{
    eval echo "\${#${1}}"
    # ==> Returns the length of the value of the variable
    # ==> whose name is passed as an argument.
}

#:docstring strspn:
# Usage: strspn $s1 $s2
# 
# Strspn returns the length of the maximum initial segment of string s1,
# which consists entirely of characters from string s2.
#:end docstring:

###;;;autoload
function strspn ()
{
    # Unsetting IFS allows whitespace to be handled as normal chars. 
    local IFS=
    local result="${1%%[!${2}]*}"
 
    echo ${#result}
}

#:docstring strcspn:
# Usage: strcspn $s1 $s2
#
# Strcspn returns the length of the maximum initial segment of string s1,
# which consists entirely of characters not from string s2.
#:end docstring:

###;;;autoload
function strcspn ()
{
    # Unsetting IFS allows whitspace to be handled as normal chars. 
    local IFS=
    local result="${1%%[${2}]*}"
 
    echo ${#result}
}

#:docstring strstr:
# Usage: strstr s1 s2
# 
# Strstr echoes a substring starting at the first occurrence of string s2 in
# string s1, or nothing if s2 does not occur in the string.  If s2 points to
# a string of zero length, strstr echoes s1.
#:end docstring:

###;;;autoload
function strstr ()
{
    # if s2 points to a string of zero length, strstr echoes s1
    [ ${#2} -eq 0 ] && { echo "$1" ; return 0; }

    # strstr echoes nothing if s2 does not occur in s1
    case "$1" in
    *$2*) ;;
    *) return 1;;
    esac

    # use the pattern matching code to strip off the match and everything
    # following it
    first=${1/$2*/}

    # then strip off the first unmatched portion of the string
    echo "${1##$first}"
}

#:docstring strtok:
# Usage: strtok s1 s2
#
# Strtok considers the string s1 to consist of a sequence of zero or more
# text tokens separated by spans of one or more characters from the
# separator string s2.  The first call (with a non-empty string s1
# specified) echoes a string consisting of the first token on stdout. The
# function keeps track of its position in the string s1 between separate
# calls, so that subsequent calls made with the first argument an empty
# string will work through the string immediately following that token.  In
# this way subsequent calls will work through the string s1 until no tokens
# remain.  The separator string s2 may be different from call to call.
# When no token remains in s1, an empty value is echoed on stdout.
#:end docstring:

###;;;autoload
function strtok ()
{
 :
}

#:docstring strtrunc:
# Usage: strtrunc $n $s1 {$s2} {$...}
#
# Used by many functions like strncmp to truncate arguments for comparison.
# Echoes the first n characters of each string s1 s2 ... on stdout. 
#:end docstring:

###;;;autoload
function strtrunc ()
{
    n=$1 ; shift
    for z; do
        echo "${z:0:$n}"
    done
}

# provide string

# string.bash ends here


# ========================================================================== #
# ==> Everything below here added by the document author.

# ==> Suggested use of this script is to delete everything below here,
# ==> and "source" this file into your own scripts.

# strcat
string0=one
string1=two
echo
echo "Testing \"strcat\" function:"
echo "Original \"string0\" = $string0"
echo "\"string1\" = $string1"
strcat string0 string1
echo "New \"string0\" = $string0"
echo

# strlen
echo
echo "Testing \"strlen\" function:"
str=123456789
echo "\"str\" = $str"
echo -n "Length of \"str\" = "
strlen str
echo



# Exercise:
# --------
# Add code to test all the other string functions above.


exit 0
}

◊anchored-example[#:anchor "dir_info1"]{Directory information}

◊example{
#! /bin/bash
# directory-info.sh
# Parses and lists directory information.

# NOTE: Change lines 273 and 353 per "README" file.

# Michael Zick is the author of this script.
# Used here with his permission.

# Controls
# If overridden by command arguments, they must be in the order:
#   Arg1: "Descriptor Directory"
#   Arg2: "Exclude Paths"
#   Arg3: "Exclude Directories"
#
# Environment Settings override Defaults.
# Command arguments override Environment Settings.

# Default location for content addressed file descriptors.
MD5UCFS=${1:-${MD5UCFS:-'/tmpfs/ucfs'}}

# Directory paths never to list or enter
declare -a \
  EXCLUDE_PATHS=${2:-${EXCLUDE_PATHS:-'(/proc /dev /devfs /tmpfs)'}}

# Directories never to list or enter
declare -a \
  EXCLUDE_DIRS=${3:-${EXCLUDE_DIRS:-'(ucfs lost+found tmp wtmp)'}}

# Files never to list or enter
declare -a \
  EXCLUDE_FILES=${3:-${EXCLUDE_FILES:-'(core "Name with Spaces")'}}


# Here document used as a comment block.
: <<LSfieldsDoc
# # # # # List Filesystem Directory Information # # # # #
#
#	ListDirectory "FileGlob" "Field-Array-Name"
# or
#	ListDirectory -of "FileGlob" "Field-Array-Filename"
#	'-of' meaning 'output to filename'
# # # # #

String format description based on: ls (GNU fileutils) version 4.0.36

Produces a line (or more) formatted:
inode permissions hard-links owner group ...
32736 -rw-------    1 mszick   mszick

size    day month date hh:mm:ss year path
2756608 Sun Apr 20 08:53:06 2003 /home/mszick/core

Unless it is formatted:
inode permissions hard-links owner group ...
266705 crw-rw----    1    root  uucp

major minor day month date hh:mm:ss year path
4,  68 Sun Apr 20 09:27:33 2003 /dev/ttyS4
NOTE: that pesky comma after the major number

NOTE: the 'path' may be multiple fields:
/home/mszick/core
/proc/982/fd/0 -> /dev/null
/proc/982/fd/1 -> /home/mszick/.xsession-errors
/proc/982/fd/13 -> /tmp/tmpfZVVOCs (deleted)
/proc/982/fd/7 -> /tmp/kde-mszick/ksycoca
/proc/982/fd/8 -> socket:[11586]
/proc/982/fd/9 -> pipe:[11588]

If that isn't enough to keep your parser guessing,
either or both of the path components may be relative:
../Built-Shared -> Built-Static
../linux-2.4.20.tar.bz2 -> ../../../SRCS/linux-2.4.20.tar.bz2

The first character of the 11 (10?) character permissions field:
's' Socket
'd' Directory
'b' Block device
'c' Character device
'l' Symbolic link
NOTE: Hard links not marked - test for identical inode numbers
on identical filesystems.
All information about hard linked files are shared, except
for the names and the name's location in the directory system.
NOTE: A "Hard link" is known as a "File Alias" on some systems.
'-' An undistingushed file

Followed by three groups of letters for: User, Group, Others
Character 1: '-' Not readable; 'r' Readable
Character 2: '-' Not writable; 'w' Writable
Character 3, User and Group: Combined execute and special
'-' Not Executable, Not Special
'x' Executable, Not Special
's' Executable, Special
'S' Not Executable, Special
Character 3, Others: Combined execute and sticky (tacky?)
'-' Not Executable, Not Tacky
'x' Executable, Not Tacky
't' Executable, Tacky
'T' Not Executable, Tacky

Followed by an access indicator
Haven't tested this one, it may be the eleventh character
or it may generate another field
' ' No alternate access
'+' Alternate access
LSfieldsDoc


ListDirectory()
{
	local -a T
	local -i of=0		# Default return in variable
#	OLD_IFS=$IFS		# Using BASH default ' \t\n'

	case "$#" in
	3)	case "$1" in
		-of)	of=1 ; shift ;;
		 * )	return 1 ;;
		esac ;;
	2)	: ;;		# Poor man's "continue"
	*)	return 1 ;;
	esac

	# NOTE: the (ls) command is NOT quoted (")
	T=( $(ls --inode --ignore-backups --almost-all --directory \
	--full-time --color=none --time=status --sort=none \
	--format=long $1) )

	case $of in
	# Assign T back to the array whose name was passed as $2
		0) eval $2=\( \"\$\{T\[@\]\}\" \) ;;
	# Write T into filename passed as $2
		1) echo "${T[@]}" > "$2" ;;
	esac
	return 0
   }

# # # # # Is that string a legal number? # # # # #
#
#	IsNumber "Var"
# # # # # There has to be a better way, sigh...

IsNumber()
{
	local -i int
	if [ $# -eq 0 ]
	then
		return 1
	else
		(let int=$1)  2>/dev/null
		return $?	# Exit status of the let thread
	fi
}

# # # # # Index Filesystem Directory Information # # # # #
#
#	IndexList "Field-Array-Name" "Index-Array-Name"
# or
#	IndexList -if Field-Array-Filename Index-Array-Name
#	IndexList -of Field-Array-Name Index-Array-Filename
#	IndexList -if -of Field-Array-Filename Index-Array-Filename
# # # # #

: <<IndexListDoc
Walk an array of directory fields produced by ListDirectory

Having suppressed the line breaks in an otherwise line oriented
report, build an index to the array element which starts each line.

Each line gets two index entries, the first element of each line
(inode) and the element that holds the pathname of the file.

The first index entry pair (Line-Number==0) are informational:
Index-Array-Name[0] : Number of "Lines" indexed
Index-Array-Name[1] : "Current Line" pointer into Index-Array-Name

The following index pairs (if any) hold element indexes into
the Field-Array-Name per:
Index-Array-Name[Line-Number * 2] : The "inode" field element.
NOTE: This distance may be either +11 or +12 elements.
Index-Array-Name[(Line-Number * 2) + 1] : The "pathname" element.
NOTE: This distance may be a variable number of elements.
Next line index pair for Line-Number+1.
IndexListDoc



IndexList()
{
	local -a LIST			# Local of listname passed
	local -a -i INDEX=( 0 0 )	# Local of index to return
	local -i Lidx Lcnt
	local -i if=0 of=0		# Default to variable names

	case "$#" in			# Simplistic option testing
		0) return 1 ;;
		1) return 1 ;;
		2) : ;;			# Poor man's continue
		3) case "$1" in
			-if) if=1 ;;
			-of) of=1 ;;
			 * ) return 1 ;;
		   esac ; shift ;;
		4) if=1 ; of=1 ; shift ; shift ;;
		*) return 1
	esac

	# Make local copy of list
	case "$if" in
		0) eval LIST=\( \"\$\{$1\[@\]\}\" \) ;;
		1) LIST=( $(cat $1) ) ;;
	esac

	# Grok (grope?) the array
	Lcnt=${#LIST[@]}
	Lidx=0
	until (( Lidx >= Lcnt ))
	do
	if IsNumber ${LIST[$Lidx]}
	then
		local -i inode name
		local ft
		inode=Lidx
		local m=${LIST[$Lidx+2]}	# Hard Links field
		ft=${LIST[$Lidx+1]:0:1} 	# Fast-Stat
		case $ft in
		b)	((Lidx+=12)) ;;		# Block device
		c)	((Lidx+=12)) ;;		# Character device
		*)	((Lidx+=11)) ;;		# Anything else
		esac
		name=Lidx
		case $ft in
		-)	((Lidx+=1)) ;;		# The easy one
		b)	((Lidx+=1)) ;;		# Block device
		c)	((Lidx+=1)) ;;		# Character device
		d)	((Lidx+=1)) ;;		# The other easy one
		l)	((Lidx+=3)) ;;		# At LEAST two more fields
#  A little more elegance here would handle pipes,
#+ sockets, deleted files - later.
		*)	until IsNumber ${LIST[$Lidx]} || ((Lidx >= Lcnt))
			do
				((Lidx+=1))
			done
			;;			# Not required
		esac
		INDEX[${#INDEX[*]}]=$inode
		INDEX[${#INDEX[*]}]=$name
		INDEX[0]=${INDEX[0]}+1		# One more "line" found
# echo "Line: ${INDEX[0]} Type: $ft Links: $m Inode: \
# ${LIST[$inode]} Name: ${LIST[$name]}"

	else
		((Lidx+=1))
	fi
	done
	case "$of" in
		0) eval $2=\( \"\$\{INDEX\[@\]\}\" \) ;;
		1) echo "${INDEX[@]}" > "$2" ;;
	esac
	return 0				# What could go wrong?
}

# # # # # Content Identify File # # # # #
#
#	DigestFile Input-Array-Name Digest-Array-Name
# or
#	DigestFile -if Input-FileName Digest-Array-Name
# # # # #

# Here document used as a comment block.
: <<DigestFilesDoc

The key (no pun intended) to a Unified Content File System (UCFS)
is to distinguish the files in the system based on their content.
Distinguishing files by their name is just so 20th Century.

The content is distinguished by computing a checksum of that content.
This version uses the md5sum program to generate a 128 bit checksum
representative of the file's contents.
There is a chance that two files having different content might
generate the same checksum using md5sum (or any checksum).  Should
that become a problem, then the use of md5sum can be replace by a
cyrptographic signature.  But until then...

The md5sum program is documented as outputting three fields (and it
does), but when read it appears as two fields (array elements).  This
is caused by the lack of whitespace between the second and third field.
So this function gropes the md5sum output and returns:
	[0]	32 character checksum in hexidecimal (UCFS filename)
	[1]	Single character: ' ' text file, '*' binary file
	[2]	Filesystem (20th Century Style) name
	Note: That name may be the character '-' indicating STDIN read.

DigestFilesDoc



DigestFile()
{
	local if=0		# Default, variable name
	local -a T1 T2

	case "$#" in
	3)	case "$1" in
		-if)	if=1 ; shift ;;
		 * )	return 1 ;;
		esac ;;
	2)	: ;;		# Poor man's "continue"
	*)	return 1 ;;
	esac

	case $if in
	0) eval T1=\( \"\$\{$1\[@\]\}\" \)
	   T2=( $(echo ${T1[@]} | md5sum -) )
	   ;;
	1) T2=( $(md5sum $1) )
	   ;;
	esac

	case ${#T2[@]} in
	0) return 1 ;;
	1) return 1 ;;
	2) case ${T2[1]:0:1} in		# SanScrit-2.0.5
	   \*) T2[${#T2[@]}]=${T2[1]:1}
	       T2[1]=\*
	       ;;
	    *) T2[${#T2[@]}]=${T2[1]}
	       T2[1]=" "
	       ;;
	   esac
	   ;;
	3) : ;; # Assume it worked
	*) return 1 ;;
	esac

	local -i len=${#T2[0]}
	if [ $len -ne 32 ] ; then return 1 ; fi
	eval $2=\( \"\$\{T2\[@\]\}\" \)
}

# # # # # Locate File # # # # #
#
#	LocateFile [-l] FileName Location-Array-Name
# or
#	LocateFile [-l] -of FileName Location-Array-FileName
# # # # #

# A file location is Filesystem-id and inode-number

# Here document used as a comment block.
: <<StatFieldsDoc
	Based on stat, version 2.2
	stat -t and stat -lt fields
	[0]	name
	[1]	Total size
		File - number of bytes
		Symbolic link - string length of pathname
	[2]	Number of (512 byte) blocks allocated
	[3]	File type and Access rights (hex)
	[4]	User ID of owner
	[5]	Group ID of owner
	[6]	Device number
	[7]	Inode number
	[8]	Number of hard links
	[9]	Device type (if inode device) Major
	[10]	Device type (if inode device) Minor
	[11]	Time of last access
		May be disabled in 'mount' with noatime
		atime of files changed by exec, read, pipe, utime, mknod (mmap?)
		atime of directories changed by addition/deletion of files
	[12]	Time of last modification
		mtime of files changed by write, truncate, utime, mknod
		mtime of directories changed by addtition/deletion of files
	[13]	Time of last change
		ctime reflects time of changed inode information (owner, group
		permissions, link count
-*-*- Per:
	Return code: 0
	Size of array: 14
	Contents of array
	Element 0: /home/mszick
	Element 1: 4096
	Element 2: 8
	Element 3: 41e8
	Element 4: 500
	Element 5: 500
	Element 6: 303
	Element 7: 32385
	Element 8: 22
	Element 9: 0
	Element 10: 0
	Element 11: 1051221030
	Element 12: 1051214068
	Element 13: 1051214068

	For a link in the form of linkname -> realname
	stat -t  linkname returns the linkname (link) information
	stat -lt linkname returns the realname information

	stat -tf and stat -ltf fields
	[0]	name
	[1]	ID-0?		# Maybe someday, but Linux stat structure
	[2]	ID-0?		# does not have either LABEL nor UUID
				# fields, currently information must come
				# from file-system specific utilities
	These will be munged into:
	[1]	UUID if possible
	[2]	Volume Label if possible
	Note: 'mount -l' does return the label and could return the UUID

	[3]	Maximum length of filenames
	[4]	Filesystem type
	[5]	Total blocks in the filesystem
	[6]	Free blocks
	[7]	Free blocks for non-root user(s)
	[8]	Block size of the filesystem
	[9]	Total inodes
	[10]	Free inodes

-*-*- Per:
	Return code: 0
	Size of array: 11
	Contents of array
	Element 0: /home/mszick
	Element 1: 0
	Element 2: 0
	Element 3: 255
	Element 4: ef53
	Element 5: 2581445
	Element 6: 2277180
	Element 7: 2146050
	Element 8: 4096
	Element 9: 1311552
	Element 10: 1276425

StatFieldsDoc


#	LocateFile [-l] FileName Location-Array-Name
#	LocateFile [-l] -of FileName Location-Array-FileName

LocateFile()
{
	local -a LOC LOC1 LOC2
	local lk="" of=0

	case "$#" in
	0) return 1 ;;
	1) return 1 ;;
	2) : ;;
	*) while (( "$#" > 2 ))
	   do
	      case "$1" in
	       -l) lk=-1 ;;
	      -of) of=1 ;;
	        *) return 1 ;;
	      esac
	   shift
           done ;;
	esac

# More Sanscrit-2.0.5
      # LOC1=( $(stat -t $lk $1) )
      # LOC2=( $(stat -tf $lk $1) )
      # Uncomment above two lines if system has "stat" command installed.
	LOC=( ${LOC1[@]:0:1} ${LOC1[@]:3:11}
	      ${LOC2[@]:1:2} ${LOC2[@]:4:1} )

	case "$of" in
		0) eval $2=\( \"\$\{LOC\[@\]\}\" \) ;;
		1) echo "${LOC[@]}" > "$2" ;;
	esac
	return 0
# Which yields (if you are lucky, and have "stat" installed)
# -*-*- Location Discriptor -*-*-
#	Return code: 0
#	Size of array: 15
#	Contents of array
#	Element 0: /home/mszick		20th Century name
#	Element 1: 41e8			Type and Permissions
#	Element 2: 500			User
#	Element 3: 500			Group
#	Element 4: 303			Device
#	Element 5: 32385		inode
#	Element 6: 22			Link count
#	Element 7: 0			Device Major
#	Element 8: 0			Device Minor
#	Element 9: 1051224608		Last Access
#	Element 10: 1051214068		Last Modify
#	Element 11: 1051214068		Last Status
#	Element 12: 0			UUID (to be)
#	Element 13: 0			Volume Label (to be)
#	Element 14: ef53		Filesystem type
}



# And then there was some test code

ListArray() # ListArray Name
{
	local -a Ta

	eval Ta=\( \"\$\{$1\[@\]\}\" \)
	echo
	echo "-*-*- List of Array -*-*-"
	echo "Size of array $1: ${#Ta[*]}"
	echo "Contents of array $1:"
	for (( i=0 ; i<${#Ta[*]} ; i++ ))
	do
	    echo -e "\tElement $i: ${Ta[$i]}"
	done
	return 0
}

declare -a CUR_DIR
# For small arrays
ListDirectory "${PWD}" CUR_DIR
ListArray CUR_DIR

declare -a DIR_DIG
DigestFile CUR_DIR DIR_DIG
echo "The new \"name\" (checksum) for ${CUR_DIR[9]} is ${DIR_DIG[0]}"

declare -a DIR_ENT
# BIG_DIR # For really big arrays - use a temporary file in ramdisk
# BIG-DIR # ListDirectory -of "${CUR_DIR[11]}/*" "/tmpfs/junk2"
ListDirectory "${CUR_DIR[11]}/*" DIR_ENT

declare -a DIR_IDX
# BIG-DIR # IndexList -if "/tmpfs/junk2" DIR_IDX
IndexList DIR_ENT DIR_IDX

declare -a IDX_DIG
# BIG-DIR # DIR_ENT=( $(cat /tmpfs/junk2) )
# BIG-DIR # DigestFile -if /tmpfs/junk2 IDX_DIG
DigestFile DIR_ENT IDX_DIG
# Small (should) be able to parallize IndexList & DigestFile
# Large (should) be able to parallize IndexList & DigestFile & the assignment
echo "The \"name\" (checksum) for the contents of ${PWD} is ${IDX_DIG[0]}"

declare -a FILE_LOC
LocateFile ${PWD} FILE_LOC
ListArray FILE_LOC

exit 0
}

◊anchored-example[#:anchor "lib1"]{Library of hash functions}

Mariusz Gniazdowski contributed a hash library for use in scripts.

◊example{
# Hash:
# Hash function library
# Author: Mariusz Gniazdowski <mariusz.gn-at-gmail.com>
# Date: 2005-04-07

# Functions making emulating hashes in Bash a little less painful.


#    Limitations:
#  * Only global variables are supported.
#  * Each hash instance generates one global variable per value.
#  * Variable names collisions are possible
#+   if you define variable like __hash__hashname_key
#  * Keys must use chars that can be part of a Bash variable name
#+   (no dashes, periods, etc.).
#  * The hash is created as a variable:
#    ... hashname_keyname
#    So if somone will create hashes like:
#      myhash_ + mykey = myhash__mykey
#      myhash + _mykey = myhash__mykey
#    Then there will be a collision.
#    (This should not pose a major problem.)


Hash_config_varname_prefix=__hash__


# Emulates:  hash[key]=value
#
# Params:
# 1 - hash
# 2 - key
# 3 - value
function hash_set {
	eval "${Hash_config_varname_prefix}${1}_${2}=\"${3}\""
}


# Emulates:  value=hash[key]
#
# Params:
# 1 - hash
# 2 - key
# 3 - value (name of global variable to set)
function hash_get_into {
	eval "$3=\"\$${Hash_config_varname_prefix}${1}_${2}\""
}


# Emulates:  echo hash[key]
#
# Params:
# 1 - hash
# 2 - key
# 3 - echo params (like -n, for example)
function hash_echo {
	eval "echo $3 \"\$${Hash_config_varname_prefix}${1}_${2}\""
}


# Emulates:  hash1[key1]=hash2[key2]
#
# Params:
# 1 - hash1
# 2 - key1
# 3 - hash2
# 4 - key2
function hash_copy {
eval "${Hash_config_varname_prefix}${1}_${2}\
=\"\$${Hash_config_varname_prefix}${3}_${4}\""
}


# Emulates:  hash[keyN-1]=hash[key2]=...hash[key1]
#
# Copies first key to rest of keys.
#
# Params:
# 1 - hash1
# 2 - key1
# 3 - key2
# . . .
# N - keyN
function hash_dup {
  local hashName="$1" keyName="$2"
  shift 2
  until [ ${#} -le 0 ]; do
    eval "${Hash_config_varname_prefix}${hashName}_${1}\
=\"\$${Hash_config_varname_prefix}${hashName}_${keyName}\""
  shift;
  done;
}


# Emulates:  unset hash[key]
#
# Params:
# 1 - hash
# 2 - key
function hash_unset {
	eval "unset ${Hash_config_varname_prefix}${1}_${2}"
}


# Emulates something similar to:  ref=&hash[key]
#
# The reference is name of the variable in which value is held.
#
# Params:
# 1 - hash
# 2 - key
# 3 - ref - Name of global variable to set.
function hash_get_ref_into {
	eval "$3=\"${Hash_config_varname_prefix}${1}_${2}\""
}


# Emulates something similar to:  echo &hash[key]
#
# That reference is name of variable in which value is held.
#
# Params:
# 1 - hash
# 2 - key
# 3 - echo params (like -n for example)
function hash_echo_ref {
	eval "echo $3 \"${Hash_config_varname_prefix}${1}_${2}\""
}



# Emulates something similar to:  $$hash[key](param1, param2, ...)
#
# Params:
# 1 - hash
# 2 - key
# 3,4, ... - Function parameters
function hash_call {
  local hash key
  hash=$1
  key=$2
  shift 2
  eval "eval \"\$${Hash_config_varname_prefix}${hash}_${key} \\\"\\\$@\\\"\""
}


# Emulates something similar to:  isset(hash[key]) or hash[key]==NULL
#
# Params:
# 1 - hash
# 2 - key
# Returns:
# 0 - there is such key
# 1 - there is no such key
function hash_is_set {
  eval "if [[ \"\${${Hash_config_varname_prefix}${1}_${2}-a}\" = \"a\" && 
  \"\${${Hash_config_varname_prefix}${1}_${2}-b}\" = \"b\" ]]
    then return 1; else return 0; fi"
}


# Emulates something similar to:
#   foreach($hash as $key => $value) { fun($key,$value); }
#
# It is possible to write different variations of this function.
# Here we use a function call to make it as "generic" as possible.
#
# Params:
# 1 - hash
# 2 - function name
function hash_foreach {
  local keyname oldIFS="$IFS"
  IFS=' '
  for i in $(eval "echo \${!${Hash_config_varname_prefix}${1}_*}"); do
    keyname=$(eval "echo \${i##${Hash_config_varname_prefix}${1}_}")
    eval "$2 $keyname \"\$$i\""
  done
IFS="$oldIFS"
}

#  NOTE: In lines 103 and 116, ampersand changed.
#  But, it doesn't matter, because these are comment lines anyhow.
}

◊anchored-example[#:anchor "hash_color1"]{Colorizing text using hash
functions}

Here is an example script using the foregoing hash library.

◊example{
#!/bin/bash
# hash-example.sh: Colorizing text.
# Author: Mariusz Gniazdowski <mariusz.gn-at-gmail.com>

. Hash.lib      # Load the library of functions.

hash_set colors red          "\033[0;31m"
hash_set colors blue         "\033[0;34m"
hash_set colors light_blue   "\033[1;34m"
hash_set colors light_red    "\033[1;31m"
hash_set colors cyan         "\033[0;36m"
hash_set colors light_green  "\033[1;32m"
hash_set colors light_gray   "\033[0;37m"
hash_set colors green        "\033[0;32m"
hash_set colors yellow       "\033[1;33m"
hash_set colors light_purple "\033[1;35m"
hash_set colors purple       "\033[0;35m"
hash_set colors reset_color  "\033[0;00m"


# $1 - keyname
# $2 - value
try_colors() {
	echo -en "$2"
	echo "This line is $1."
}
hash_foreach colors try_colors
hash_echo colors reset_color -en

echo -e '\nLet us overwrite some colors with yellow.\n'
# It's hard to read yellow text on some terminals.
hash_dup colors yellow   red light_green blue green light_gray cyan
hash_foreach colors try_colors
hash_echo colors reset_color -en

echo -e '\nLet us delete them and try colors once more . . .\n'

for i in red light_green blue green light_gray cyan; do
	hash_unset colors $i
done
hash_foreach colors try_colors
hash_echo colors reset_color -en

hash_set other txt "Other examples . . ."
hash_echo other txt
hash_get_into other txt text
echo $text

hash_set other my_fun try_colors
hash_call other my_fun   purple "`hash_echo colors purple`"
hash_echo colors reset_color -en

echo; echo "Back to normal?"; echo

exit $?

#  On some terminals, the "light" colors print in bold,
#  and end up looking darker than the normal ones.
#  Why is this?
}

◊anchored-example[#:anchor "hash1"]{More on hash functions}

An example illustrating the mechanics of hashing, but from a different
point of view.

◊example{
#!/bin/bash
# $Id: ha.sh,v 1.2 2005/04/21 23:24:26 oliver Exp $
# Copyright 2005 Oliver Beckstein
# Released under the GNU Public License
# Author of script granted permission for inclusion in ABS Guide.
# (Thank you!)

#----------------------------------------------------------------
# pseudo hash based on indirect parameter expansion
# API: access through functions:
# 
# create the hash:
#  
#      newhash Lovers
#
# add entries (note single quotes for spaces)
#    
#      addhash Lovers Tristan Isolde
#      addhash Lovers 'Romeo Montague' 'Juliet Capulet'
#
# access value by key
#
#      gethash Lovers Tristan   ---->  Isolde
#
# show all keys
#
#      keyshash Lovers         ----> 'Tristan'  'Romeo Montague'
#
#
# Convention: instead of perls' foo{bar} = boing' syntax,
# use
#       '_foo_bar=boing' (two underscores, no spaces)
#
# 1) store key   in _NAME_keys[]
# 2) store value in _NAME_values[] using the same integer index
# The integer index for the last entry is _NAME_ptr
#
# NOTE: No error or sanity checks, just bare bones.


function _inihash () {
    # private function
    # call at the beginning of each procedure
    # defines: _keys _values _ptr
    #
    # Usage: _inihash NAME
    local name=$1
    _keys=_${name}_keys
    _values=_${name}_values
    _ptr=_${name}_ptr
}

function newhash () {
    # Usage: newhash NAME
    #        NAME should not contain spaces or dots.
    #        Actually: it must be a legal name for a Bash variable.
    # We rely on Bash automatically recognising arrays.
    local name=$1 
    local _keys _values _ptr
    _inihash ${name}
    eval ${_ptr}=0
}


function addhash () {
    # Usage: addhash NAME KEY 'VALUE with spaces'
    #        arguments with spaces need to be quoted with single quotes ''
    local name=$1 k="$2" v="$3" 
    local _keys _values _ptr
    _inihash ${name}

    #echo "DEBUG(addhash): ${_ptr}=${!_ptr}"

    eval let ${_ptr}=${_ptr}+1
    eval "$_keys[${!_ptr}]=\"${k}\""
    eval "$_values[${!_ptr}]=\"${v}\""
}

function gethash () {
    #  Usage: gethash NAME KEY
    #         Returns boing
    #         ERR=0 if entry found, 1 otherwise
    #  That's not a proper hash --
    #+ we simply linearly search through the keys.
    local name=$1 key="$2" 
    local _keys _values _ptr 
    local k v i found h
    _inihash ${name}
    
    # _ptr holds the highest index in the hash
    found=0

    for i in $(seq 1 ${!_ptr}); do
	h="\${${_keys}[${i}]}"  #  Safer to do it in two steps,
	eval k=${h}             #+ especially when quoting for spaces.
	if [ "${k}" = "${key}" ]; then found=1; break; fi
    done;

    [ ${found} = 0 ] && return 1;
    # else: i is the index that matches the key
    h="\${${_values}[${i}]}"
    eval echo "${h}"
    return 0;	
}

function keyshash () {
    # Usage: keyshash NAME
    # Returns list of all keys defined for hash name.
    local name=$1 key="$2" 
    local _keys _values _ptr 
    local k i h
    _inihash ${name}
    
    # _ptr holds the highest index in the hash
    for i in $(seq 1 ${!_ptr}); do
	h="\${${_keys}[${i}]}"   #  Safer to do it in two steps,
	eval k=${h}              #+ especially when quoting for spaces.
	echo -n "'${k}' "
    done;
}


# -----------------------------------------------------------------------

# Now, let's test it.
# (Per comments at the beginning of the script.)
newhash Lovers
addhash Lovers Tristan Isolde
addhash Lovers 'Romeo Montague' 'Juliet Capulet'

# Output results.
echo
gethash Lovers Tristan      # Isolde
echo
keyshash Lovers             # 'Tristan' 'Romeo Montague'
echo; echo


exit 0

# Exercise:
# --------

# Add error checks to the functions.
}

◊anchored-example[#:anchor "mount_usb1"]{Mounting USB keychain storage
devices}

Now for a script that installs and mounts those cute USB keychain
solid-state "hard drives."

◊example{
#!/bin/bash
# ==> usb.sh
# ==> Script for mounting and installing pen/keychain USB storage devices.
# ==> Runs as root at system startup (see below).
# ==>
# ==> Newer Linux distros (2004 or later) autodetect
# ==> and install USB pen drives, and therefore don't need this script.
# ==> But, it's still instructive.
 
#  This code is free software covered by GNU GPL license version 2 or above.
#  Please refer to http://www.gnu.org/ for the full license text.
#
#  Some code lifted from usb-mount by Michael Hamilton's usb-mount (LGPL)
#+ see http://users.actrix.co.nz/michael/usbmount.html
#
#  INSTALL
#  -------
#  Put this in /etc/hotplug/usb/diskonkey.
#  Then look in /etc/hotplug/usb.distmap, and copy all usb-storage entries
#+ into /etc/hotplug/usb.usermap, substituting "usb-storage" for "diskonkey".
#  Otherwise this code is only run during the kernel module invocation/removal
#+ (at least in my tests), which defeats the purpose.
#
#  TODO
#  ----
#  Handle more than one diskonkey device at one time (e.g. /dev/diskonkey1
#+ and /mnt/diskonkey1), etc. The biggest problem here is the handling in
#+ devlabel, which I haven't yet tried.
#
#  AUTHOR and SUPPORT
#  ------------------
#  Konstantin Riabitsev, <icon linux duke edu>.
#  Send any problem reports to my email address at the moment.
#
# ==> Comments added by ABS Guide author.



SYMLINKDEV=/dev/diskonkey
MOUNTPOINT=/mnt/diskonkey
DEVLABEL=/sbin/devlabel
DEVLABELCONFIG=/etc/sysconfig/devlabel
IAM=$0

##
# Functions lifted near-verbatim from usb-mount code.
#
function allAttachedScsiUsb {
  find /proc/scsi/ -path '/proc/scsi/usb-storage*' -type f |
  xargs grep -l 'Attached: Yes'
}
function scsiDevFromScsiUsb {
  echo $1 | awk -F"[-/]" '{ n=$(NF-1);
  print "/dev/sd" substr("abcdefghijklmnopqrstuvwxyz", n+1, 1) }'
}

if [ "${ACTION}" = "add" ] && [ -f "${DEVICE}" ]; then
    ##
    # lifted from usbcam code.
    #
    if [ -f /var/run/console.lock ]; then
        CONSOLEOWNER=`cat /var/run/console.lock`
    elif [ -f /var/lock/console.lock ]; then
        CONSOLEOWNER=`cat /var/lock/console.lock`
    else
        CONSOLEOWNER=
    fi
    for procEntry in $(allAttachedScsiUsb); do
        scsiDev=$(scsiDevFromScsiUsb $procEntry)
        #  Some bug with usb-storage?
        #  Partitions are not in /proc/partitions until they are accessed
        #+ somehow.
        /sbin/fdisk -l $scsiDev >/dev/null
        ##
        #  Most devices have partitioning info, so the data would be on
        #+ /dev/sd?1. However, some stupider ones don't have any partitioning
        #+ and use the entire device for data storage. This tries to
        #+ guess semi-intelligently if we have a /dev/sd?1 and if not, then
        #+ it uses the entire device and hopes for the better.
        #
        if grep -q `basename $scsiDev`1 /proc/partitions; then
            part="$scsiDev""1"
        else
            part=$scsiDev
        fi
        ##
        #  Change ownership of the partition to the console user so they can
        #+ mount it.
        #
        if [ ! -z "$CONSOLEOWNER" ]; then
            chown $CONSOLEOWNER:disk $part
        fi
        ##
        # This checks if we already have this UUID defined with devlabel.
        # If not, it then adds the device to the list.
        #
        prodid=`$DEVLABEL printid -d $part`
        if ! grep -q $prodid $DEVLABELCONFIG; then
            # cross our fingers and hope it works
            $DEVLABEL add -d $part -s $SYMLINKDEV 2>/dev/null
        fi
        ##
        # Check if the mount point exists and create if it doesn't.
        #
        if [ ! -e $MOUNTPOINT ]; then
            mkdir -p $MOUNTPOINT
        fi
        ##
        # Take care of /etc/fstab so mounting is easy.
        #
        if ! grep -q "^$SYMLINKDEV" /etc/fstab; then
            # Add an fstab entry
            echo -e \
                "$SYMLINKDEV\t\t$MOUNTPOINT\t\tauto\tnoauto,owner,kudzu 0 0" \
                >> /etc/fstab
        fi
    done
    if [ ! -z "$REMOVER" ]; then
        ##
        # Make sure this script is triggered on device removal.
        #
        mkdir -p `dirname $REMOVER`
        ln -s $IAM $REMOVER
    fi
elif [ "${ACTION}" = "remove" ]; then
    ##
    # If the device is mounted, unmount it cleanly.
    #
    if grep -q "$MOUNTPOINT" /etc/mtab; then
        # unmount cleanly
        umount -l $MOUNTPOINT
    fi
    ##
    # Remove it from /etc/fstab if it's there.
    #
    if grep -q "^$SYMLINKDEV" /etc/fstab; then
        grep -v "^$SYMLINKDEV" /etc/fstab > /etc/.fstab.new
        mv -f /etc/.fstab.new /etc/fstab
    fi
fi

exit 0
}

◊anchored-example[#:anchor "conv_to_html1"]{Converting to HTML}

◊example{
#!/bin/bash
# tohtml.sh [v. 0.2.01, reldate: 04/13/12, a teeny bit less buggy]

# Convert a text file to HTML format.
# Author: Mendel Cooper
# License: GPL3
# Usage: sh tohtml.sh < textfile > htmlfile
# Script can easily be modified to accept source and target filenames.

#    Assumptions:
# 1) Paragraphs in (target) text file are separated by a blank line.
# 2) Jpeg images (*.jpg) are located in "images" subdirectory.
#    In the target file, the image names are enclosed in square brackets,
#    for example, [image01.jpg].
# 3) Emphasized (italic) phrases begin with a space+underscore
#+   or the first character on the line is an underscore,
#+   and end with an underscore+space or underscore+end-of-line.


# Settings
FNTSIZE=2        # Small-medium font size
IMGDIR="images"  # Image directory
# Headers
HDR01='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
HDR02='<!-- Converted to HTML by ***tohtml.sh*** script -->'
HDR03='<!-- script author: M. Leo Cooper <thegrendel.abs@gmail.com> -->'
HDR10='<html>'
HDR11='<head>'
HDR11a='</head>'
HDR12a='<title>'
HDR12b='</title>'
HDR121='<META NAME="GENERATOR" CONTENT="tohtml.sh script">'
HDR13='<body bgcolor="#dddddd">'   # Change background color to suit.
HDR14a='<font size='
HDR14b='>'
# Footers
FTR10='</body>'
FTR11='</html>'
# Tags
BOLD="<b>"
CENTER="<center>"
END_CENTER="</center>"
LF="<br>"


write_headers ()
  {
  echo "$HDR01"
  echo
  echo "$HDR02"
  echo "$HDR03"
  echo
  echo
  echo "$HDR10"
  echo "$HDR11"
  echo "$HDR121"
  echo "$HDR11a"
  echo "$HDR13"
  echo
  echo -n "$HDR14a"
  echo -n "$FNTSIZE"
  echo "$HDR14b"
  echo
  echo "$BOLD"        # Everything in bold (more easily readable).
  }


process_text ()
  {
  while read line     # Read one line at a time.
  do
    {
    if [ ! "$line" ]  # Blank line?
    then              # Then new paragraph must follow.
      echo
      echo "$LF"      # Insert two <br> tags.
      echo "$LF"
      echo
      continue        # Skip the underscore test.
    else              # Otherwise . . .

      if [[ "$line" =~ \[*jpg\] ]]    # Is a graphic?
      then                            # Strip away brackets.
        temp=$( echo "$line" | sed -e 's/\[//' -e 's/\]//' )
        line=""$CENTER" <img src="\"$IMGDIR"/$temp\"> "$END_CENTER" "
                                      # Add image tag.
                                      # And, center it.
      fi

    fi


    echo "$line" | grep -q _
    if [ "$?" -eq 0 ]    # If line contains underscore ...
    then
      # ===================================================
      # Convert underscored phrase to italics.
      temp=$( echo "$line" |
              sed -e 's/ _/ <i>/' -e 's/_/<\/i> /' |
              sed -e 's/^_/<i>/'  -e 's/_/<\/i>/' )
      #  Process only underscores prefixed by space,
      #+ or at beginning or end of line.
      #  Do not convert underscores embedded within a word!
      line="$temp"
      # Slows script execution. Can be optimized?
      # ===================================================
    fi


   
#   echo
    echo "$line"
#   echo
#   Don't want extra blank lines in generated text!
    } # End while
  done
  }   # End process_text ()


write_footers ()  # Termination tags.
  {
  echo "$FTR10"
  echo "$FTR11"
  }


# main () {
# =========
write_headers
process_text
write_footers
# =========
#         }

exit $?

#  Exercises:
#  ---------
#  1) Fixup: Check for closing underscore before a comma or period.
#  2) Add a test for the presence of a closing underscore
#+    in phrases to be italicized.
}

◊anchored-example[#:anchor "weblogs1"]{Preserving weblogs}

◊example{
#!/bin/bash
# archiveweblogs.sh v1.0

# Troy Engel <tengel@fluid.com>
# Slightly modified by document author.
# Used with permission.
#
#  This script will preserve the normally rotated and
#+ thrown away weblogs from a default RedHat/Apache installation.
#  It will save the files with a date/time stamp in the filename,
#+ bzipped, to a given directory.
#
#  Run this from crontab nightly at an off hour,
#+ as bzip2 can suck up some serious CPU on huge logs:
#  0 2 * * * /opt/sbin/archiveweblogs.sh


PROBLEM=66

# Set this to your backup dir.
BKP_DIR=/opt/backups/weblogs

# Default Apache/RedHat stuff
LOG_DAYS="4 3 2 1"
LOG_DIR=/var/log/httpd
LOG_FILES="access_log error_log"

# Default RedHat program locations
LS=/bin/ls
MV=/bin/mv
ID=/usr/bin/id
CUT=/bin/cut
COL=/usr/bin/column
BZ2=/usr/bin/bzip2

# Are we root?
USER=`$ID -u`
if [ "X$USER" != "X0" ]; then
  echo "PANIC: Only root can run this script!"
  exit $PROBLEM
fi

# Backup dir exists/writable?
if [ ! -x $BKP_DIR ]; then
  echo "PANIC: $BKP_DIR doesn't exist or isn't writable!"
  exit $PROBLEM
fi

# Move, rename and bzip2 the logs
for logday in $LOG_DAYS; do
  for logfile in $LOG_FILES; do
    MYFILE="$LOG_DIR/$logfile.$logday"
    if [ -w $MYFILE ]; then
      DTS=`$LS -lgo --time-style=+%Y%m%d $MYFILE | $COL -t | $CUT -d ' ' -f7`
      $MV $MYFILE $BKP_DIR/$logfile.$DTS
      $BZ2 $BKP_DIR/$logfile.$DTS
    else
      # Only spew an error if the file exits (ergo non-writable).
      if [ -f $MYFILE ]; then
        echo "ERROR: $MYFILE not writable. Skipping."
      fi
    fi
  done
done

exit 0
}

◊anchored-example[#:anchor "lit_str1"]{Protecting literal strings}

How to keep the shell from expanding and reinterpreting text strings.

◊example{
#! /bin/bash
# protect_literal.sh

# set -vx

:<<-'_Protect_Literal_String_Doc'

    Copyright (c) Michael S. Zick, 2003; All Rights Reserved
    License: Unrestricted reuse in any form, for any purpose.
    Warranty: None
    Revision: $ID$

    Documentation redirected to the Bash no-operation.
    Bash will '/dev/null' this block when the script is first read.
    (Uncomment the above set command to see this action.)

    Remove the first (Sha-Bang) line when sourcing this as a library
    procedure.  Also comment out the example use code in the two
    places where shown.


    Usage:
        _protect_literal_str 'Whatever string meets your ${fancy}'
        Just echos the argument to standard out, hard quotes
        restored.

        $(_protect_literal_str 'Whatever string meets your ${fancy}')
        as the right-hand-side of an assignment statement.

    Does:
        As the right-hand-side of an assignment, preserves the
        hard quotes protecting the contents of the literal during
        assignment.

    Notes:
        The strange names (_*) are used to avoid trampling on
        the user's chosen names when this is sourced as a
        library.

_Protect_Literal_String_Doc

# The 'for illustration' function form

_protect_literal_str() {

# Pick an un-used, non-printing character as local IFS.
# Not required, but shows that we are ignoring it.
    local IFS=$'\x1B'               # \ESC character

# Enclose the All-Elements-Of in hard quotes during assignment.
    local tmp=$'\x27'$@$'\x27'
#    local tmp=$'\''$@$'\''         # Even uglier.

    local len=${#tmp}               # Info only.
    echo $tmp is $len long.         # Output AND information.
}

# This is the short-named version.
_pls() {
    local IFS=$'x1B'                # \ESC character (not required)
    echo $'\x27'$@$'\x27'           # Hard quoted parameter glob
}

# :<<-'_Protect_Literal_String_Test'
# # # Remove the above "# " to disable this code. # # #

# See how that looks when printed.
echo
echo "- - Test One - -"
_protect_literal_str 'Hello $user'
_protect_literal_str 'Hello "${username}"'
echo

# Which yields:
# - - Test One - -
# 'Hello $user' is 13 long.
# 'Hello "${username}"' is 21 long.

#  Looks as expected, but why all of the trouble?
#  The difference is hidden inside the Bash internal order
#+ of operations.
#  Which shows when you use it on the RHS of an assignment.

# Declare an array for test values.
declare -a arrayZ

# Assign elements with various types of quotes and escapes.
arrayZ=( zero "$(_pls 'Hello ${Me}')" 'Hello ${You}' "\'Pass: ${pw}\'" )

# Now list that array and see what is there.
echo "- - Test Two - -"
for (( i=0 ; i<${#arrayZ[*]} ; i++ ))
do
    echo  Element $i: ${arrayZ[$i]} is: ${#arrayZ[$i]} long.
done
echo

# Which yields:
# - - Test Two - -
# Element 0: zero is: 4 long.           # Our marker element
# Element 1: 'Hello ${Me}' is: 13 long. # Our "$(_pls '...' )"
# Element 2: Hello ${You} is: 12 long.  # Quotes are missing
# Element 3: \'Pass: \' is: 10 long.    # ${pw} expanded to nothing

# Now make an assignment with that result.
declare -a array2=( ${arrayZ[@]} )

# And print what happened.
echo "- - Test Three - -"
for (( i=0 ; i<${#array2[*]} ; i++ ))
do
    echo  Element $i: ${array2[$i]} is: ${#array2[$i]} long.
done
echo

# Which yields:
# - - Test Three - -
# Element 0: zero is: 4 long.           # Our marker element.
# Element 1: Hello ${Me} is: 11 long.   # Intended result.
# Element 2: Hello is: 5 long.          # ${You} expanded to nothing.
# Element 3: 'Pass: is: 6 long.         # Split on the whitespace.
# Element 4: ' is: 1 long.              # The end quote is here now.

#  Our Element 1 has had its leading and trailing hard quotes stripped.
#  Although not shown, leading and trailing whitespace is also stripped.
#  Now that the string contents are set, Bash will always, internally,
#+ hard quote the contents as required during its operations.

#  Why?
#  Considering our "$(_pls 'Hello ${Me}')" construction:
#  " ... " -> Expansion required, strip the quotes.
#  $( ... ) -> Replace with the result of..., strip this.
#  _pls ' ... ' -> called with literal arguments, strip the quotes.
#  The result returned includes hard quotes; BUT the above processing
#+ has already been done, so they become part of the value assigned.
#
#  Similarly, during further usage of the string variable, the ${Me}
#+ is part of the contents (result) and survives any operations
#  (Until explicitly told to evaluate the string).

#  Hint: See what happens when the hard quotes ($'\x27') are replaced
#+ with soft quotes ($'\x22') in the above procedures.
#  Interesting also is to remove the addition of any quoting.

# _Protect_Literal_String_Test
# # # Remove the above "# " to disable this code. # # #

exit 0
}

◊anchored-example[#:anchor "lit_str2"]{Unprotecting literal strings}

But, what if you want the shell to expand and reinterpret strings?

◊example{
#! /bin/bash
# unprotect_literal.sh

# set -vx

:<<-'_UnProtect_Literal_String_Doc'

    Copyright (c) Michael S. Zick, 2003; All Rights Reserved
    License: Unrestricted reuse in any form, for any purpose.
    Warranty: None
    Revision: $ID$

    Documentation redirected to the Bash no-operation. Bash will
    '/dev/null' this block when the script is first read.
    (Uncomment the above set command to see this action.)

    Remove the first (Sha-Bang) line when sourcing this as a library
    procedure.  Also comment out the example use code in the two
    places where shown.


    Usage:
        Complement of the "$(_pls 'Literal String')" function.
        (See the protect_literal.sh example.)

        StringVar=$(_upls ProtectedSringVariable)

    Does:
        When used on the right-hand-side of an assignment statement;
        makes the substitions embedded in the protected string.

    Notes:
        The strange names (_*) are used to avoid trampling on
        the user's chosen names when this is sourced as a
        library.


_UnProtect_Literal_String_Doc

_upls() {
    local IFS=$'x1B'                # \ESC character (not required)
    eval echo $@                    # Substitution on the glob.
}

# :<<-'_UnProtect_Literal_String_Test'
# # # Remove the above "# " to disable this code. # # #


_pls() {
    local IFS=$'x1B'                # \ESC character (not required)
    echo $'\x27'$@$'\x27'           # Hard quoted parameter glob
}

# Declare an array for test values.
declare -a arrayZ

# Assign elements with various types of quotes and escapes.
arrayZ=( zero "$(_pls 'Hello ${Me}')" 'Hello ${You}' "\'Pass: ${pw}\'" )

# Now make an assignment with that result.
declare -a array2=( ${arrayZ[@]} )

# Which yielded:
# - - Test Three - -
# Element 0: zero is: 4 long            # Our marker element.
# Element 1: Hello ${Me} is: 11 long    # Intended result.
# Element 2: Hello is: 5 long           # ${You} expanded to nothing.
# Element 3: 'Pass: is: 6 long          # Split on the whitespace.
# Element 4: ' is: 1 long               # The end quote is here now.

# set -vx

#  Initialize 'Me' to something for the embedded ${Me} substitution.
#  This needs to be done ONLY just prior to evaluating the
#+ protected string.
#  (This is why it was protected to begin with.)

Me="to the array guy."

# Set a string variable destination to the result.
newVar=$(_upls ${array2[1]})

# Show what the contents are.
echo $newVar

# Do we really need a function to do this?
newerVar=$(eval echo ${array2[1]})
echo $newerVar

#  I guess not, but the _upls function gives us a place to hang
#+ the documentation on.
#  This helps when we forget what a # construction like:
#+ $(eval echo ... ) means.

# What if Me isn't set when the protected string is evaluated?
unset Me
newestVar=$(_upls ${array2[1]})
echo $newestVar

# Just gone, no hints, no runs, no errors.

#  Why in the world?
#  Setting the contents of a string variable containing character
#+ sequences that have a meaning in Bash is a general problem in
#+ script programming.
#
#  This problem is now solved in eight lines of code
#+ (and four pages of description).

#  Where is all this going?
#  Dynamic content Web pages as an array of Bash strings.
#  Content set per request by a Bash 'eval' command
#+ on the stored page template.
#  Not intended to replace PHP, just an interesting thing to do.
###
#  Don't have a webserver application?
#  No problem, check the example directory of the Bash source;
#+ there is a Bash script for that also.

# _UnProtect_Literal_String_Test
# # # Remove the above "# " to disable this code. # # #

exit 0
}

◊anchored-example[#:anchor "spam1"]{Spammer Identification}

This interesting script helps hunt down spammers.

◊example{
#!/bin/bash

# $Id: is_spammer.bash,v 1.12.2.11 2004/10/01 21:42:33 mszick Exp $
# Above line is RCS info.

# The latest version of this script is available from http://www.morethan.org.
#
# Spammer-identification
# by Michael S. Zick
# Used in the ABS Guide with permission.



#######################################################
# Documentation
# See also "Quickstart" at end of script.
#######################################################

:<<-'__is_spammer_Doc_'

    Copyright (c) Michael S. Zick, 2004
    License: Unrestricted reuse in any form, for any purpose.
    Warranty: None -{Its a script; the user is on their own.}-

Impatient?
    Application code: goto "# # # Hunt the Spammer' program code # # #"
    Example output: ":<<-'_is_spammer_outputs_'"
    How to use: Enter script name without arguments.
                Or goto "Quickstart" at end of script.

Provides
    Given a domain name or IP(v4) address as input:

    Does an exhaustive set of queries to find the associated
    network resources (short of recursing into TLDs).

    Checks the IP(v4) addresses found against Blacklist
    nameservers.

    If found to be a blacklisted IP(v4) address,
    reports the blacklist text records.
    (Usually hyper-links to the specific report.)

Requires
    A working Internet connection.
    (Exercise: Add check and/or abort if not on-line when running script.)
    Bash with arrays (2.05b+).

    The external program 'dig' --
    a utility program provided with the 'bind' set of programs.
    Specifically, the version which is part of Bind series 9.x
    See: http://www.isc.org

    All usages of 'dig' are limited to wrapper functions,
    which may be rewritten as required.
    See: dig_wrappers.bash for details.
         ("Additional documentation" -- below)

Usage
    Script requires a single argument, which may be:
    1) A domain name;
    2) An IP(v4) address;
    3) A filename, with one name or address per line.

    Script accepts an optional second argument, which may be:
    1) A Blacklist server name;
    2) A filename, with one Blacklist server name per line.

    If the second argument is not provided, the script uses
    a built-in set of (free) Blacklist servers.

    See also, the Quickstart at the end of this script (after 'exit').

Return Codes
    0 - All OK
    1 - Script failure
    2 - Something is Blacklisted

Optional environment variables
    SPAMMER_TRACE
        If set to a writable file,
        script will log an execution flow trace.

    SPAMMER_DATA
        If set to a writable file, script will dump its
        discovered data in the form of GraphViz file.
        See: http://www.research.att.com/sw/tools/graphviz

    SPAMMER_LIMIT
        Limits the depth of resource tracing.

        Default is 2 levels.

        A setting of 0 (zero) means 'unlimited' . . .
          Caution: script might recurse the whole Internet!

        A limit of 1 or 2 is most useful when processing
        a file of domain names and addresses.
        A higher limit can be useful when hunting spam gangs.


Additional documentation
    Download the archived set of scripts
    explaining and illustrating the function contained within this script.
    http://bash.deta.in/mszick_clf.tar.bz2


Study notes
    This script uses a large number of functions.
    Nearly all general functions have their own example script.
    Each of the example scripts have tutorial level comments.

Scripting project
    Add support for IP(v6) addresses.
    IP(v6) addresses are recognized but not processed.

Advanced project
    Add the reverse lookup detail to the discovered information.

    Report the delegation chain and abuse contacts.

    Modify the GraphViz file output to include the
    newly discovered information.

__is_spammer_Doc_

#######################################################




#### Special IFS settings used for string parsing. ####

# Whitespace == :Space:Tab:Line Feed:Carriage Return:
WSP_IFS=$'\x20'$'\x09'$'\x0A'$'\x0D'

# No Whitespace == Line Feed:Carriage Return
NO_WSP=$'\x0A'$'\x0D'

# Field separator for dotted decimal IP addresses
ADR_IFS=${NO_WSP}'.'

# Array to dotted string conversions
DOT_IFS='.'${WSP_IFS}

# # # Pending operations stack machine # # #
# This set of functions described in func_stack.bash.
# (See "Additional documentation" above.)
# # #

# Global stack of pending operations.
declare -f -a _pending_
# Global sentinel for stack runners
declare -i _p_ctrl_
# Global holder for currently executing function
declare -f _pend_current_

# # # Debug version only - remove for regular use # # #
#
# The function stored in _pend_hook_ is called
# immediately before each pending function is
# evaluated.  Stack clean, _pend_current_ set.
#
# This thingy demonstrated in pend_hook.bash.
declare -f _pend_hook_
# # #

# The do nothing function
pend_dummy() { : ; }

# Clear and initialize the function stack.
pend_init() {
    unset _pending_[@]
    pend_func pend_stop_mark
    _pend_hook_='pend_dummy'  # Debug only.
}

# Discard the top function on the stack.
pend_pop() {
    if [ ${#_pending_[@]} -gt 0 ]
    then
        local -i _top_
        _top_=${#_pending_[@]}-1
        unset _pending_[$_top_]
    fi
}

# pend_func function_name [$(printf '%q\n' arguments)]
pend_func() {
    local IFS=${NO_WSP}
    set -f
    _pending_[${#_pending_[@]}]=$@
    set +f
}

# The function which stops the release:
pend_stop_mark() {
    _p_ctrl_=0
}

pend_mark() {
    pend_func pend_stop_mark
}

# Execute functions until 'pend_stop_mark' . . .
pend_release() {
    local -i _top_             # Declare _top_ as integer.
    _p_ctrl_=${#_pending_[@]}
    while [ ${_p_ctrl_} -gt 0 ]
    do
       _top_=${#_pending_[@]}-1
       _pend_current_=${_pending_[$_top_]}
       unset _pending_[$_top_]
       $_pend_hook_            # Debug only.
       eval $_pend_current_
    done
}

# Drop functions until 'pend_stop_mark' . . .
pend_drop() {
    local -i _top_
    local _pd_ctrl_=${#_pending_[@]}
    while [ ${_pd_ctrl_} -gt 0 ]
    do
       _top_=$_pd_ctrl_-1
       if [ "${_pending_[$_top_]}" == 'pend_stop_mark' ]
       then
           unset _pending_[$_top_]
           break
       else
           unset _pending_[$_top_]
           _pd_ctrl_=$_top_
       fi
    done
    if [ ${#_pending_[@]} -eq 0 ]
    then
        pend_func pend_stop_mark
    fi
}

#### Array editors ####

# This function described in edit_exact.bash.
# (See "Additional documentation," above.)
# edit_exact <excludes_array_name> <target_array_name>
edit_exact() {
    [ $# -eq 2 ] ||
    [ $# -eq 3 ] || return 1
    local -a _ee_Excludes
    local -a _ee_Target
    local _ee_x
    local _ee_t
    local IFS=${NO_WSP}
    set -f
    eval _ee_Excludes=\( \$\{$1\[@\]\} \)
    eval _ee_Target=\( \$\{$2\[@\]\} \)
    local _ee_len=${#_ee_Target[@]}     # Original length.
    local _ee_cnt=${#_ee_Excludes[@]}   # Exclude list length.
    [ ${_ee_len} -ne 0 ] || return 0    # Can't edit zero length.
    [ ${_ee_cnt} -ne 0 ] || return 0    # Can't edit zero length.
    for (( x = 0; x < ${_ee_cnt} ; x++ ))
    do
        _ee_x=${_ee_Excludes[$x]}
        for (( n = 0 ; n < ${_ee_len} ; n++ ))
        do
            _ee_t=${_ee_Target[$n]}
            if [ x"${_ee_t}" == x"${_ee_x}" ]
            then
                unset _ee_Target[$n]     # Discard match.
                [ $# -eq 2 ] && break    # If 2 arguments, then done.
            fi
        done
    done
    eval $2=\( \$\{_ee_Target\[@\]\} \)
    set +f
    return 0
}

# This function described in edit_by_glob.bash.
# edit_by_glob <excludes_array_name> <target_array_name>
edit_by_glob() {
    [ $# -eq 2 ] ||
    [ $# -eq 3 ] || return 1
    local -a _ebg_Excludes
    local -a _ebg_Target
    local _ebg_x
    local _ebg_t
    local IFS=${NO_WSP}
    set -f
    eval _ebg_Excludes=\( \$\{$1\[@\]\} \)
    eval _ebg_Target=\( \$\{$2\[@\]\} \)
    local _ebg_len=${#_ebg_Target[@]}
    local _ebg_cnt=${#_ebg_Excludes[@]}
    [ ${_ebg_len} -ne 0 ] || return 0
    [ ${_ebg_cnt} -ne 0 ] || return 0
    for (( x = 0; x < ${_ebg_cnt} ; x++ ))
    do
        _ebg_x=${_ebg_Excludes[$x]}
        for (( n = 0 ; n < ${_ebg_len} ; n++ ))
        do
            [ $# -eq 3 ] && _ebg_x=${_ebg_x}'*'  #  Do prefix edit
            if [ ${_ebg_Target[$n]:=} ]          #+ if defined & set.
            then
                _ebg_t=${_ebg_Target[$n]/#${_ebg_x}/}
                [ ${#_ebg_t} -eq 0 ] && unset _ebg_Target[$n]
            fi
        done
    done
    eval $2=\( \$\{_ebg_Target\[@\]\} \)
    set +f
    return 0
}

# This function described in unique_lines.bash.
# unique_lines <in_name> <out_name>
unique_lines() {
    [ $# -eq 2 ] || return 1
    local -a _ul_in
    local -a _ul_out
    local -i _ul_cnt
    local -i _ul_pos
    local _ul_tmp
    local IFS=${NO_WSP}
    set -f
    eval _ul_in=\( \$\{$1\[@\]\} \)
    _ul_cnt=${#_ul_in[@]}
    for (( _ul_pos = 0 ; _ul_pos < ${_ul_cnt} ; _ul_pos++ ))
    do
        if [ ${_ul_in[${_ul_pos}]:=} ]      # If defined & not empty
        then
            _ul_tmp=${_ul_in[${_ul_pos}]}
            _ul_out[${#_ul_out[@]}]=${_ul_tmp}
            for (( zap = _ul_pos ; zap < ${_ul_cnt} ; zap++ ))
            do
                [ ${_ul_in[${zap}]:=} ] &&
                [ 'x'${_ul_in[${zap}]} == 'x'${_ul_tmp} ] &&
                    unset _ul_in[${zap}]
            done
        fi
    done
    eval $2=\( \$\{_ul_out\[@\]\} \)
    set +f
    return 0
}

# This function described in char_convert.bash.
# to_lower <string>
to_lower() {
    [ $# -eq 1 ] || return 1
    local _tl_out
    _tl_out=${1//A/a}
    _tl_out=${_tl_out//B/b}
    _tl_out=${_tl_out//C/c}
    _tl_out=${_tl_out//D/d}
    _tl_out=${_tl_out//E/e}
    _tl_out=${_tl_out//F/f}
    _tl_out=${_tl_out//G/g}
    _tl_out=${_tl_out//H/h}
    _tl_out=${_tl_out//I/i}
    _tl_out=${_tl_out//J/j}
    _tl_out=${_tl_out//K/k}
    _tl_out=${_tl_out//L/l}
    _tl_out=${_tl_out//M/m}
    _tl_out=${_tl_out//N/n}
    _tl_out=${_tl_out//O/o}
    _tl_out=${_tl_out//P/p}
    _tl_out=${_tl_out//Q/q}
    _tl_out=${_tl_out//R/r}
    _tl_out=${_tl_out//S/s}
    _tl_out=${_tl_out//T/t}
    _tl_out=${_tl_out//U/u}
    _tl_out=${_tl_out//V/v}
    _tl_out=${_tl_out//W/w}
    _tl_out=${_tl_out//X/x}
    _tl_out=${_tl_out//Y/y}
    _tl_out=${_tl_out//Z/z}
    echo ${_tl_out}
    return 0
}

#### Application helper functions ####

# Not everybody uses dots as separators (APNIC, for example).
# This function described in to_dot.bash
# to_dot <string>
to_dot() {
    [ $# -eq 1 ] || return 1
    echo ${1//[#|@|%]/.}
    return 0
}

# This function described in is_number.bash.
# is_number <input>
is_number() {
    [ "$#" -eq 1 ]    || return 1  # is blank?
    [ x"$1" == 'x0' ] && return 0  # is zero?
    local -i tst
    let tst=$1 2>/dev/null         # else is numeric!
    return $?
}

# This function described in is_address.bash.
# is_address <input>
is_address() {
    [ $# -eq 1 ] || return 1    # Blank ==> false
    local -a _ia_input
    local IFS=${ADR_IFS}
    _ia_input=( $1 )
    if  [ ${#_ia_input[@]} -eq 4 ]  &&
        is_number ${_ia_input[0]}   &&
        is_number ${_ia_input[1]}   &&
        is_number ${_ia_input[2]}   &&
        is_number ${_ia_input[3]}   &&
        [ ${_ia_input[0]} -lt 256 ] &&
        [ ${_ia_input[1]} -lt 256 ] &&
        [ ${_ia_input[2]} -lt 256 ] &&
        [ ${_ia_input[3]} -lt 256 ]
    then
        return 0
    else
        return 1
    fi
}

#  This function described in split_ip.bash.
#  split_ip <IP_address>
#+ <array_name_norm> [<array_name_rev>]
split_ip() {
    [ $# -eq 3 ] ||              #  Either three
    [ $# -eq 2 ] || return 1     #+ or two arguments
    local -a _si_input
    local IFS=${ADR_IFS}
    _si_input=( $1 )
    IFS=${WSP_IFS}
    eval $2=\(\ \$\{_si_input\[@\]\}\ \)
    if [ $# -eq 3 ]
    then
        # Build query order array.
        local -a _dns_ip
        _dns_ip[0]=${_si_input[3]}
        _dns_ip[1]=${_si_input[2]}
        _dns_ip[2]=${_si_input[1]}
        _dns_ip[3]=${_si_input[0]}
        eval $3=\(\ \$\{_dns_ip\[@\]\}\ \)
    fi
    return 0
}

# This function described in dot_array.bash.
# dot_array <array_name>
dot_array() {
    [ $# -eq 1 ] || return 1     # Single argument required.
    local -a _da_input
    eval _da_input=\(\ \$\{$1\[@\]\}\ \)
    local IFS=${DOT_IFS}
    local _da_output=${_da_input[@]}
    IFS=${WSP_IFS}
    echo ${_da_output}
    return 0
}

# This function described in file_to_array.bash
# file_to_array <file_name> <line_array_name>
file_to_array() {
    [ $# -eq 2 ] || return 1  # Two arguments required.
    local IFS=${NO_WSP}
    local -a _fta_tmp_
    _fta_tmp_=( $(cat $1) )
    eval $2=\( \$\{_fta_tmp_\[@\]\} \)
    return 0
}

#  Columnized print of an array of multi-field strings.
#  col_print <array_name> <min_space> <
#+ tab_stop [tab_stops]>
col_print() {
    [ $# -gt 2 ] || return 0
    local -a _cp_inp
    local -a _cp_spc
    local -a _cp_line
    local _cp_min
    local _cp_mcnt
    local _cp_pos
    local _cp_cnt
    local _cp_tab
    local -i _cp
    local -i _cpf
    local _cp_fld
    # WARNING: FOLLOWING LINE NOT BLANK -- IT IS QUOTED SPACES.
    local _cp_max='                                                            '
    set -f
    local IFS=${NO_WSP}
    eval _cp_inp=\(\ \$\{$1\[@\]\}\ \)
    [ ${#_cp_inp[@]} -gt 0 ] || return 0 # Empty is easy.
    _cp_mcnt=$2
    _cp_min=${_cp_max:1:${_cp_mcnt}}
    shift
    shift
    _cp_cnt=$#
    for (( _cp = 0 ; _cp < _cp_cnt ; _cp++ ))
    do
        _cp_spc[${#_cp_spc[@]}]="${_cp_max:2:$1}" #"
        shift
    done
    _cp_cnt=${#_cp_inp[@]}
    for (( _cp = 0 ; _cp < _cp_cnt ; _cp++ ))
    do
        _cp_pos=1
        IFS=${NO_WSP}$'\x20'
        _cp_line=( ${_cp_inp[${_cp}]} )
        IFS=${NO_WSP}
        for (( _cpf = 0 ; _cpf < ${#_cp_line[@]} ; _cpf++ ))
        do
            _cp_tab=${_cp_spc[${_cpf}]:${_cp_pos}}
            if [ ${#_cp_tab} -lt ${_cp_mcnt} ]
            then
                _cp_tab="${_cp_min}"
            fi
            echo -n "${_cp_tab}"
            (( _cp_pos = ${_cp_pos} + ${#_cp_tab} ))
            _cp_fld="${_cp_line[${_cpf}]}"
            echo -n ${_cp_fld}
            (( _cp_pos = ${_cp_pos} + ${#_cp_fld} ))
        done
        echo
    done
    set +f
    return 0
}

# # # # 'Hunt the Spammer' data flow # # # #

# Application return code
declare -i _hs_RC

# Original input, from which IP addresses are removed
# After which, domain names to check
declare -a uc_name

# Original input IP addresses are moved here
# After which, IP addresses to check
declare -a uc_address

# Names against which address expansion run
# Ready for name detail lookup
declare -a chk_name

# Addresses against which name expansion run
# Ready for address detail lookup
declare -a chk_address

#  Recursion is depth-first-by-name.
#  The expand_input_address maintains this list
#+ to prohibit looking up addresses twice during
#+ domain name recursion.
declare -a been_there_addr
been_there_addr=( '127.0.0.1' ) # Whitelist localhost

# Names which we have checked (or given up on)
declare -a known_name

# Addresses which we have checked (or given up on)
declare -a known_address

#  List of zero or more Blacklist servers to check.
#  Each 'known_address' will be checked against each server,
#+ with negative replies and failures suppressed.
declare -a list_server

# Indirection limit - set to zero == no limit
indirect=${SPAMMER_LIMIT:=2}

# # # # 'Hunt the Spammer' information output data # # # #

# Any domain name may have multiple IP addresses.
# Any IP address may have multiple domain names.
# Therefore, track unique address-name pairs.
declare -a known_pair
declare -a reverse_pair

#  In addition to the data flow variables; known_address
#+ known_name and list_server, the following are output to the
#+ external graphics interface file.

# Authority chain, parent -> SOA fields.
declare -a auth_chain

# Reference chain, parent name -> child name
declare -a ref_chain

# DNS chain - domain name -> address
declare -a name_address

# Name and service pairs - domain name -> service
declare -a name_srvc

# Name and resource pairs - domain name -> Resource Record
declare -a name_resource

# Parent and Child pairs - parent name -> child name
# This MAY NOT be the same as the ref_chain followed!
declare -a parent_child

# Address and Blacklist hit pairs - address->server
declare -a address_hits

# Dump interface file data
declare -f _dot_dump
_dot_dump=pend_dummy   # Initially a no-op

#  Data dump is enabled by setting the environment variable SPAMMER_DATA
#+ to the name of a writable file.
declare _dot_file

# Helper function for the dump-to-dot-file function
# dump_to_dot <array_name> <prefix>
dump_to_dot() {
    local -a _dda_tmp
    local -i _dda_cnt
    local _dda_form='    '${2}'%04u %s\n'
    local IFS=${NO_WSP}
    eval _dda_tmp=\(\ \$\{$1\[@\]\}\ \)
    _dda_cnt=${#_dda_tmp[@]}
    if [ ${_dda_cnt} -gt 0 ]
    then
        for (( _dda = 0 ; _dda < _dda_cnt ; _dda++ ))
        do
            printf "${_dda_form}" \
                   "${_dda}" "${_dda_tmp[${_dda}]}" >>${_dot_file}
        done
    fi
}

# Which will also set _dot_dump to this function . . .
dump_dot() {
    local -i _dd_cnt
    echo '# Data vintage: '$(date -R) >${_dot_file}
    echo '# ABS Guide: is_spammer.bash; v2, 2004-msz' >>${_dot_file}
    echo >>${_dot_file}
    echo 'digraph G {' >>${_dot_file}

    if [ ${#known_name[@]} -gt 0 ]
    then
        echo >>${_dot_file}
        echo '# Known domain name nodes' >>${_dot_file}
        _dd_cnt=${#known_name[@]}
        for (( _dd = 0 ; _dd < _dd_cnt ; _dd++ ))
        do
            printf '    N%04u [label="%s"] ;\n' \
                   "${_dd}" "${known_name[${_dd}]}" >>${_dot_file}
        done
    fi

    if [ ${#known_address[@]} -gt 0 ]
    then
        echo >>${_dot_file}
        echo '# Known address nodes' >>${_dot_file}
        _dd_cnt=${#known_address[@]}
        for (( _dd = 0 ; _dd < _dd_cnt ; _dd++ ))
        do
            printf '    A%04u [label="%s"] ;\n' \
                   "${_dd}" "${known_address[${_dd}]}" >>${_dot_file}
        done
    fi

    echo                                   >>${_dot_file}
    echo '/*'                              >>${_dot_file}
    echo ' * Known relationships :: User conversion to'  >>${_dot_file}
    echo ' * graphic form by hand or program required.'  >>${_dot_file}
    echo ' *'                              >>${_dot_file}

    if [ ${#auth_chain[@]} -gt 0 ]
    then
      echo >>${_dot_file}
      echo '# Authority ref. edges followed & field source.' >>${_dot_file}
        dump_to_dot auth_chain AC
    fi

    if [ ${#ref_chain[@]} -gt 0 ]
    then
        echo >>${_dot_file}
        echo '# Name ref. edges followed and field source.' >>${_dot_file}
        dump_to_dot ref_chain RC
    fi

    if [ ${#name_address[@]} -gt 0 ]
    then
        echo >>${_dot_file}
        echo '# Known name->address edges' >>${_dot_file}
        dump_to_dot name_address NA
    fi

    if [ ${#name_srvc[@]} -gt 0 ]
    then
        echo >>${_dot_file}
        echo '# Known name->service edges' >>${_dot_file}
        dump_to_dot name_srvc NS
    fi

    if [ ${#name_resource[@]} -gt 0 ]
    then
        echo >>${_dot_file}
        echo '# Known name->resource edges' >>${_dot_file}
        dump_to_dot name_resource NR
    fi

    if [ ${#parent_child[@]} -gt 0 ]
    then
        echo >>${_dot_file}
        echo '# Known parent->child edges' >>${_dot_file}
        dump_to_dot parent_child PC
    fi

    if [ ${#list_server[@]} -gt 0 ]
    then
        echo >>${_dot_file}
        echo '# Known Blacklist nodes' >>${_dot_file}
        _dd_cnt=${#list_server[@]}
        for (( _dd = 0 ; _dd < _dd_cnt ; _dd++ ))
        do
            printf '    LS%04u [label="%s"] ;\n' \
                   "${_dd}" "${list_server[${_dd}]}" >>${_dot_file}
        done
    fi

    unique_lines address_hits address_hits
    if [ ${#address_hits[@]} -gt 0 ]
    then
      echo >>${_dot_file}
      echo '# Known address->Blacklist_hit edges' >>${_dot_file}
      echo '# CAUTION: dig warnings can trigger false hits.' >>${_dot_file}
       dump_to_dot address_hits AH
    fi
    echo          >>${_dot_file}
    echo ' *'     >>${_dot_file}
    echo ' * That is a lot of relationships. Happy graphing.' >>${_dot_file}
    echo ' */'    >>${_dot_file}
    echo '}'      >>${_dot_file}
    return 0
}

# # # # 'Hunt the Spammer' execution flow # # # #

#  Execution trace is enabled by setting the
#+ environment variable SPAMMER_TRACE to the name of a writable file.
declare -a _trace_log
declare _log_file

# Function to fill the trace log
trace_logger() {
    _trace_log[${#_trace_log[@]}]=${_pend_current_}
}

# Dump trace log to file function variable.
declare -f _log_dump
_log_dump=pend_dummy   # Initially a no-op.

# Dump the trace log to a file.
dump_log() {
    local -i _dl_cnt
    _dl_cnt=${#_trace_log[@]}
    for (( _dl = 0 ; _dl < _dl_cnt ; _dl++ ))
    do
        echo ${_trace_log[${_dl}]} >> ${_log_file}
    done
    _dl_cnt=${#_pending_[@]}
    if [ ${_dl_cnt} -gt 0 ]
    then
        _dl_cnt=${_dl_cnt}-1
        echo '# # # Operations stack not empty # # #' >> ${_log_file}
        for (( _dl = ${_dl_cnt} ; _dl >= 0 ; _dl-- ))
        do
            echo ${_pending_[${_dl}]} >> ${_log_file}
        done
    fi
}

# # # Utility program 'dig' wrappers # # #
#
#  These wrappers are derived from the
#+ examples shown in dig_wrappers.bash.
#
#  The major difference is these return
#+ their results as a list in an array.
#
#  See dig_wrappers.bash for details and
#+ use that script to develop any changes.
#
# # #

# Short form answer: 'dig' parses answer.

# Forward lookup :: Name -> Address
# short_fwd <domain_name> <array_name>
short_fwd() {
    local -a _sf_reply
    local -i _sf_rc
    local -i _sf_cnt
    IFS=${NO_WSP}
echo -n '.'
# echo 'sfwd: '${1}
  _sf_reply=( $(dig +short ${1} -c in -t a 2>/dev/null) )
  _sf_rc=$?
  if [ ${_sf_rc} -ne 0 ]
  then
    _trace_log[${#_trace_log[@]}]='## Lookup error '${_sf_rc}' on '${1}' ##'
# [ ${_sf_rc} -ne 9 ] && pend_drop
        return ${_sf_rc}
    else
        # Some versions of 'dig' return warnings on stdout.
        _sf_cnt=${#_sf_reply[@]}
        for (( _sf = 0 ; _sf < ${_sf_cnt} ; _sf++ ))
        do
            [ 'x'${_sf_reply[${_sf}]:0:2} == 'x;;' ] &&
                unset _sf_reply[${_sf}]
        done
        eval $2=\( \$\{_sf_reply\[@\]\} \)
    fi
    return 0
}

# Reverse lookup :: Address -> Name
# short_rev <ip_address> <array_name>
short_rev() {
    local -a _sr_reply
    local -i _sr_rc
    local -i _sr_cnt
    IFS=${NO_WSP}
echo -n '.'
# echo 'srev: '${1}
  _sr_reply=( $(dig +short -x ${1} 2>/dev/null) )
  _sr_rc=$?
  if [ ${_sr_rc} -ne 0 ]
  then
    _trace_log[${#_trace_log[@]}]='## Lookup error '${_sr_rc}' on '${1}' ##'
# [ ${_sr_rc} -ne 9 ] && pend_drop
        return ${_sr_rc}
    else
        # Some versions of 'dig' return warnings on stdout.
        _sr_cnt=${#_sr_reply[@]}
        for (( _sr = 0 ; _sr < ${_sr_cnt} ; _sr++ ))
        do
            [ 'x'${_sr_reply[${_sr}]:0:2} == 'x;;' ] &&
                unset _sr_reply[${_sr}]
        done
        eval $2=\( \$\{_sr_reply\[@\]\} \)
    fi
    return 0
}

# Special format lookup used to query blacklist servers.
# short_text <ip_address> <array_name>
short_text() {
    local -a _st_reply
    local -i _st_rc
    local -i _st_cnt
    IFS=${NO_WSP}
# echo 'stxt: '${1}
  _st_reply=( $(dig +short ${1} -c in -t txt 2>/dev/null) )
  _st_rc=$?
  if [ ${_st_rc} -ne 0 ]
  then
    _trace_log[${#_trace_log[@]}]='##Text lookup error '${_st_rc}' on '${1}'##'
# [ ${_st_rc} -ne 9 ] && pend_drop
        return ${_st_rc}
    else
        # Some versions of 'dig' return warnings on stdout.
        _st_cnt=${#_st_reply[@]}
        for (( _st = 0 ; _st < ${#_st_cnt} ; _st++ ))
        do
            [ 'x'${_st_reply[${_st}]:0:2} == 'x;;' ] &&
                unset _st_reply[${_st}]
        done
        eval $2=\( \$\{_st_reply\[@\]\} \)
    fi
    return 0
}

# The long forms, a.k.a., the parse it yourself versions

# RFC 2782   Service lookups
# dig +noall +nofail +answer _ldap._tcp.openldap.org -t srv
# _<service>._<protocol>.<domain_name>
# _ldap._tcp.openldap.org. 3600   IN     SRV    0 0 389 ldap.openldap.org.
# domain TTL Class SRV Priority Weight Port Target

# Forward lookup :: Name -> poor man's zone transfer
# long_fwd <domain_name> <array_name>
long_fwd() {
    local -a _lf_reply
    local -i _lf_rc
    local -i _lf_cnt
    IFS=${NO_WSP}
echo -n ':'
# echo 'lfwd: '${1}
  _lf_reply=( $(
     dig +noall +nofail +answer +authority +additional \
         ${1} -t soa ${1} -t mx ${1} -t any 2>/dev/null) )
  _lf_rc=$?
  if [ ${_lf_rc} -ne 0 ]
  then
    _trace_log[${#_trace_log[@]}]='# Zone lookup err '${_lf_rc}' on '${1}' #'
# [ ${_lf_rc} -ne 9 ] && pend_drop
        return ${_lf_rc}
    else
        # Some versions of 'dig' return warnings on stdout.
        _lf_cnt=${#_lf_reply[@]}
        for (( _lf = 0 ; _lf < ${_lf_cnt} ; _lf++ ))
        do
            [ 'x'${_lf_reply[${_lf}]:0:2} == 'x;;' ] &&
                unset _lf_reply[${_lf}]
        done
        eval $2=\( \$\{_lf_reply\[@\]\} \)
    fi
    return 0
}
#  The reverse lookup domain name corresponding to the IPv6 address:
#      4321:0:1:2:3:4:567:89ab
#  would be (nibble, I.E: Hexdigit) reversed:
#  b.a.9.8.7.6.5.0.4.0.0.0.3.0.0.0.2.0.0.0.1.0.0.0.0.0.0.0.1.2.3.4.IP6.ARPA.

# Reverse lookup :: Address -> poor man's delegation chain
# long_rev <rev_ip_address> <array_name>
long_rev() {
    local -a _lr_reply
    local -i _lr_rc
    local -i _lr_cnt
    local _lr_dns
    _lr_dns=${1}'.in-addr.arpa.'
    IFS=${NO_WSP}
echo -n ':'
# echo 'lrev: '${1}
  _lr_reply=( $(
       dig +noall +nofail +answer +authority +additional \
           ${_lr_dns} -t soa ${_lr_dns} -t any 2>/dev/null) )
  _lr_rc=$?
  if [ ${_lr_rc} -ne 0 ]
  then
    _trace_log[${#_trace_log[@]}]='# Deleg lkp error '${_lr_rc}' on '${1}' #'
# [ ${_lr_rc} -ne 9 ] && pend_drop
        return ${_lr_rc}
    else
        # Some versions of 'dig' return warnings on stdout.
        _lr_cnt=${#_lr_reply[@]}
        for (( _lr = 0 ; _lr < ${_lr_cnt} ; _lr++ ))
        do
            [ 'x'${_lr_reply[${_lr}]:0:2} == 'x;;' ] &&
                unset _lr_reply[${_lr}]
        done
        eval $2=\( \$\{_lr_reply\[@\]\} \)
    fi
    return 0
}

# # # Application specific functions # # #

# Mung a possible name; suppresses root and TLDs.
# name_fixup <string>
name_fixup(){
    local -a _nf_tmp
    local -i _nf_end
    local _nf_str
    local IFS
    _nf_str=$(to_lower ${1})
    _nf_str=$(to_dot ${_nf_str})
    _nf_end=${#_nf_str}-1
    [ ${_nf_str:${_nf_end}} != '.' ] &&
        _nf_str=${_nf_str}'.'
    IFS=${ADR_IFS}
    _nf_tmp=( ${_nf_str} )
    IFS=${WSP_IFS}
    _nf_end=${#_nf_tmp[@]}
    case ${_nf_end} in
    0) # No dots, only dots.
        echo
        return 1
    ;;
    1) # Only a TLD.
        echo
        return 1
    ;;
    2) # Maybe okay.
       echo ${_nf_str}
       return 0
       # Needs a lookup table?
       if [ ${#_nf_tmp[1]} -eq 2 ]
       then # Country coded TLD.
           echo
           return 1
       else
           echo ${_nf_str}
           return 0
       fi
    ;;
    esac
    echo ${_nf_str}
    return 0
}

# Grope and mung original input(s).
split_input() {
    [ ${#uc_name[@]} -gt 0 ] || return 0
    local -i _si_cnt
    local -i _si_len
    local _si_str
    unique_lines uc_name uc_name
    _si_cnt=${#uc_name[@]}
    for (( _si = 0 ; _si < _si_cnt ; _si++ ))
    do
        _si_str=${uc_name[$_si]}
        if is_address ${_si_str}
        then
            uc_address[${#uc_address[@]}]=${_si_str}
            unset uc_name[$_si]
        else
            if ! uc_name[$_si]=$(name_fixup ${_si_str})
            then
                unset ucname[$_si]
            fi
        fi
    done
  uc_name=( ${uc_name[@]} )
  _si_cnt=${#uc_name[@]}
  _trace_log[${#_trace_log[@]}]='#Input '${_si_cnt}' unchkd name input(s).#'
  _si_cnt=${#uc_address[@]}
  _trace_log[${#_trace_log[@]}]='#Input '${_si_cnt}' unchkd addr input(s).#'
    return 0
}

# # # Discovery functions -- recursively interlocked by external data # # #
# # # The leading 'if list is empty; return 0' in each is required. # # #

# Recursion limiter
# limit_chk() <next_level>
limit_chk() {
    local -i _lc_lmt
    # Check indirection limit.
    if [ ${indirect} -eq 0 ] || [ $# -eq 0 ]
    then
        # The 'do-forever' choice
        echo 1                 # Any value will do.
        return 0               # OK to continue.
    else
        # Limiting is in effect.
        if [ ${indirect} -lt ${1} ]
        then
            echo ${1}          # Whatever.
            return 1           # Stop here.
        else
            _lc_lmt=${1}+1     # Bump the given limit.
            echo ${_lc_lmt}    # Echo it.
            return 0           # OK to continue.
        fi
    fi
}

# For each name in uc_name:
#     Move name to chk_name.
#     Add addresses to uc_address.
#     Pend expand_input_address.
#     Repeat until nothing new found.
# expand_input_name <indirection_limit>
expand_input_name() {
    [ ${#uc_name[@]} -gt 0 ] || return 0
    local -a _ein_addr
    local -a _ein_new
    local -i _ucn_cnt
    local -i _ein_cnt
    local _ein_tst
    _ucn_cnt=${#uc_name[@]}

    if  ! _ein_cnt=$(limit_chk ${1})
    then
        return 0
    fi

    for (( _ein = 0 ; _ein < _ucn_cnt ; _ein++ ))
    do
        if short_fwd ${uc_name[${_ein}]} _ein_new
        then
          for (( _ein_cnt = 0 ; _ein_cnt < ${#_ein_new[@]}; _ein_cnt++ ))
          do
              _ein_tst=${_ein_new[${_ein_cnt}]}
              if is_address ${_ein_tst}
              then
                  _ein_addr[${#_ein_addr[@]}]=${_ein_tst}
              fi
    done
        fi
    done
    unique_lines _ein_addr _ein_addr     # Scrub duplicates.
    edit_exact chk_address _ein_addr     # Scrub pending detail.
    edit_exact known_address _ein_addr   # Scrub already detailed.
 if [ ${#_ein_addr[@]} -gt 0 ]        # Anything new?
 then
   uc_address=( ${uc_address[@]} ${_ein_addr[@]} )
   pend_func expand_input_address ${1}
   _trace_log[${#_trace_log[@]}]='#Add '${#_ein_addr[@]}' unchkd addr inp.#'
    fi
    edit_exact chk_name uc_name          # Scrub pending detail.
    edit_exact known_name uc_name        # Scrub already detailed.
    if [ ${#uc_name[@]} -gt 0 ]
    then
        chk_name=( ${chk_name[@]} ${uc_name[@]}  )
        pend_func detail_each_name ${1}
    fi
    unset uc_name[@]
    return 0
}

# For each address in uc_address:
#     Move address to chk_address.
#     Add names to uc_name.
#     Pend expand_input_name.
#     Repeat until nothing new found.
# expand_input_address <indirection_limit>
expand_input_address() {
    [ ${#uc_address[@]} -gt 0 ] || return 0
    local -a _eia_addr
    local -a _eia_name
    local -a _eia_new
    local -i _uca_cnt
    local -i _eia_cnt
    local _eia_tst
    unique_lines uc_address _eia_addr
    unset uc_address[@]
    edit_exact been_there_addr _eia_addr
    _uca_cnt=${#_eia_addr[@]}
    [ ${_uca_cnt} -gt 0 ] &&
        been_there_addr=( ${been_there_addr[@]} ${_eia_addr[@]} )

    for (( _eia = 0 ; _eia < _uca_cnt ; _eia++ ))
     do
       if short_rev ${_eia_addr[${_eia}]} _eia_new
       then
         for (( _eia_cnt = 0 ; _eia_cnt < ${#_eia_new[@]} ; _eia_cnt++ ))
         do
           _eia_tst=${_eia_new[${_eia_cnt}]}
           if _eia_tst=$(name_fixup ${_eia_tst})
           then
             _eia_name[${#_eia_name[@]}]=${_eia_tst}
       fi
     done
           fi
    done
    unique_lines _eia_name _eia_name     # Scrub duplicates.
    edit_exact chk_name _eia_name        # Scrub pending detail.
    edit_exact known_name _eia_name      # Scrub already detailed.
 if [ ${#_eia_name[@]} -gt 0 ]        # Anything new?
 then
   uc_name=( ${uc_name[@]} ${_eia_name[@]} )
   pend_func expand_input_name ${1}
   _trace_log[${#_trace_log[@]}]='#Add '${#_eia_name[@]}' unchkd name inp.#'
    fi
    edit_exact chk_address _eia_addr     # Scrub pending detail.
    edit_exact known_address _eia_addr   # Scrub already detailed.
    if [ ${#_eia_addr[@]} -gt 0 ]        # Anything new?
    then
        chk_address=( ${chk_address[@]} ${_eia_addr[@]} )
        pend_func detail_each_address ${1}
    fi
    return 0
}

# The parse-it-yourself zone reply.
# The input is the chk_name list.
# detail_each_name <indirection_limit>
detail_each_name() {
    [ ${#chk_name[@]} -gt 0 ] || return 0
    local -a _den_chk       # Names to check
    local -a _den_name      # Names found here
    local -a _den_address   # Addresses found here
    local -a _den_pair      # Pairs found here
    local -a _den_rev       # Reverse pairs found here
    local -a _den_tmp       # Line being parsed
    local -a _den_auth      # SOA contact being parsed
    local -a _den_new       # The zone reply
    local -a _den_pc        # Parent-Child gets big fast
    local -a _den_ref       # So does reference chain
    local -a _den_nr        # Name-Resource can be big
    local -a _den_na        # Name-Address
    local -a _den_ns        # Name-Service
    local -a _den_achn      # Chain of Authority
    local -i _den_cnt       # Count of names to detail
    local -i _den_lmt       # Indirection limit
    local _den_who          # Named being processed
    local _den_rec          # Record type being processed
    local _den_cont         # Contact domain
    local _den_str          # Fixed up name string
    local _den_str2         # Fixed up reverse
    local IFS=${WSP_IFS}

    # Local, unique copy of names to check
    unique_lines chk_name _den_chk
    unset chk_name[@]       # Done with globals.

    # Less any names already known
    edit_exact known_name _den_chk
    _den_cnt=${#_den_chk[@]}

    # If anything left, add to known_name.
    [ ${_den_cnt} -gt 0 ] &&
        known_name=( ${known_name[@]} ${_den_chk[@]} )

    # for the list of (previously) unknown names . . .
    for (( _den = 0 ; _den < _den_cnt ; _den++ ))
    do
        _den_who=${_den_chk[${_den}]}
        if long_fwd ${_den_who} _den_new
        then
            unique_lines _den_new _den_new
            if [ ${#_den_new[@]} -eq 0 ]
            then
                _den_pair[${#_den_pair[@]}]='0.0.0.0 '${_den_who}
            fi

            # Parse each line in the reply.
            for (( _line = 0 ; _line < ${#_den_new[@]} ; _line++ ))
            do
                IFS=${NO_WSP}$'\x09'$'\x20'
                _den_tmp=( ${_den_new[${_line}]} )
                IFS=${WSP_IFS}
              # If usable record and not a warning message . . .
              if [ ${#_den_tmp[@]} -gt 4 ] && [ 'x'${_den_tmp[0]} != 'x;;' ]
              then
                    _den_rec=${_den_tmp[3]}
                    _den_nr[${#_den_nr[@]}]=${_den_who}' '${_den_rec}
                    # Begin at RFC1033 (+++)
                    case ${_den_rec} in

#<name> [<ttl>]  [<class>] SOA <origin> <person>
                    SOA) # Start Of Authority
    if _den_str=$(name_fixup ${_den_tmp[0]})
    then
      _den_name[${#_den_name[@]}]=${_den_str}
      _den_achn[${#_den_achn[@]}]=${_den_who}' '${_den_str}' SOA'
      # SOA origin -- domain name of master zone record
      if _den_str2=$(name_fixup ${_den_tmp[4]})
      then
        _den_name[${#_den_name[@]}]=${_den_str2}
        _den_achn[${#_den_achn[@]}]=${_den_who}' '${_den_str2}' SOA.O'
      fi
      # Responsible party e-mail address (possibly bogus).
      # Possibility of first.last@domain.name ignored.
      set -f
      if _den_str2=$(name_fixup ${_den_tmp[5]})
      then
        IFS=${ADR_IFS}
        _den_auth=( ${_den_str2} )
        IFS=${WSP_IFS}
        if [ ${#_den_auth[@]} -gt 2 ]
        then
          _den_cont=${_den_auth[1]}
          for (( _auth = 2 ; _auth < ${#_den_auth[@]} ; _auth++ ))
          do
            _den_cont=${_den_cont}'.'${_den_auth[${_auth}]}
          done
          _den_name[${#_den_name[@]}]=${_den_cont}'.'
          _den_achn[${#_den_achn[@]}]=${_den_who}' '${_den_cont}'. SOA.C'
                                fi
        fi
        set +f
                        fi
                    ;;


      A) # IP(v4) Address Record
      if _den_str=$(name_fixup ${_den_tmp[0]})
      then
        _den_name[${#_den_name[@]}]=${_den_str}
        _den_pair[${#_den_pair[@]}]=${_den_tmp[4]}' '${_den_str}
        _den_na[${#_den_na[@]}]=${_den_str}' '${_den_tmp[4]}
        _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str}' A'
      else
        _den_pair[${#_den_pair[@]}]=${_den_tmp[4]}' unknown.domain'
        _den_na[${#_den_na[@]}]='unknown.domain '${_den_tmp[4]}
        _den_ref[${#_den_ref[@]}]=${_den_who}' unknown.domain A'
      fi
      _den_address[${#_den_address[@]}]=${_den_tmp[4]}
      _den_pc[${#_den_pc[@]}]=${_den_who}' '${_den_tmp[4]}
             ;;

             NS) # Name Server Record
             # Domain name being serviced (may be other than current)
               if _den_str=$(name_fixup ${_den_tmp[0]})
                 then
                   _den_name[${#_den_name[@]}]=${_den_str}
                   _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str}' NS'

             # Domain name of service provider
             if _den_str2=$(name_fixup ${_den_tmp[4]})
             then
               _den_name[${#_den_name[@]}]=${_den_str2}
               _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str2}' NSH'
               _den_ns[${#_den_ns[@]}]=${_den_str2}' NS'
               _den_pc[${#_den_pc[@]}]=${_den_str}' '${_den_str2}
              fi
               fi
                    ;;

             MX) # Mail Server Record
                 # Domain name being serviced (wildcards not handled here)
             if _den_str=$(name_fixup ${_den_tmp[0]})
             then
               _den_name[${#_den_name[@]}]=${_den_str}
               _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str}' MX'
             fi
             # Domain name of service provider
             if _den_str=$(name_fixup ${_den_tmp[5]})
             then
               _den_name[${#_den_name[@]}]=${_den_str}
               _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str}' MXH'
               _den_ns[${#_den_ns[@]}]=${_den_str}' MX'
               _den_pc[${#_den_pc[@]}]=${_den_who}' '${_den_str}
             fi
                    ;;

             PTR) # Reverse address record
                  # Special name
             if _den_str=$(name_fixup ${_den_tmp[0]})
             then
               _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str}' PTR'
               # Host name (not a CNAME)
               if _den_str2=$(name_fixup ${_den_tmp[4]})
               then
                 _den_rev[${#_den_rev[@]}]=${_den_str}' '${_den_str2}
                 _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str2}' PTRH'
                 _den_pc[${#_den_pc[@]}]=${_den_who}' '${_den_str}
               fi
             fi
                    ;;

             AAAA) # IP(v6) Address Record
             if _den_str=$(name_fixup ${_den_tmp[0]})
             then
               _den_name[${#_den_name[@]}]=${_den_str}
               _den_pair[${#_den_pair[@]}]=${_den_tmp[4]}' '${_den_str}
               _den_na[${#_den_na[@]}]=${_den_str}' '${_den_tmp[4]}
               _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str}' AAAA'
               else
                 _den_pair[${#_den_pair[@]}]=${_den_tmp[4]}' unknown.domain'
                 _den_na[${#_den_na[@]}]='unknown.domain '${_den_tmp[4]}
                 _den_ref[${#_den_ref[@]}]=${_den_who}' unknown.domain'
               fi
               # No processing for IPv6 addresses
               _den_pc[${#_den_pc[@]}]=${_den_who}' '${_den_tmp[4]}
                    ;;

             CNAME) # Alias name record
                    # Nickname
             if _den_str=$(name_fixup ${_den_tmp[0]})
             then
               _den_name[${#_den_name[@]}]=${_den_str}
               _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str}' CNAME'
               _den_pc[${#_den_pc[@]}]=${_den_who}' '${_den_str}
             fi
                    # Hostname
             if _den_str=$(name_fixup ${_den_tmp[4]})
             then
               _den_name[${#_den_name[@]}]=${_den_str}
               _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str}' CHOST'
               _den_pc[${#_den_pc[@]}]=${_den_who}' '${_den_str}
             fi
                    ;;
#            TXT)
#            ;;
                    esac
                fi
            done
        else # Lookup error == 'A' record 'unknown address'
            _den_pair[${#_den_pair[@]}]='0.0.0.0 '${_den_who}
        fi
    done

    # Control dot array growth.
    unique_lines _den_achn _den_achn      # Works best, all the same.
    edit_exact auth_chain _den_achn       # Works best, unique items.
    if [ ${#_den_achn[@]} -gt 0 ]
    then
        IFS=${NO_WSP}
        auth_chain=( ${auth_chain[@]} ${_den_achn[@]} )
        IFS=${WSP_IFS}
    fi

    unique_lines _den_ref _den_ref      # Works best, all the same.
    edit_exact ref_chain _den_ref       # Works best, unique items.
    if [ ${#_den_ref[@]} -gt 0 ]
    then
        IFS=${NO_WSP}
        ref_chain=( ${ref_chain[@]} ${_den_ref[@]} )
        IFS=${WSP_IFS}
    fi

    unique_lines _den_na _den_na
    edit_exact name_address _den_na
    if [ ${#_den_na[@]} -gt 0 ]
    then
        IFS=${NO_WSP}
        name_address=( ${name_address[@]} ${_den_na[@]} )
        IFS=${WSP_IFS}
    fi

    unique_lines _den_ns _den_ns
    edit_exact name_srvc _den_ns
    if [ ${#_den_ns[@]} -gt 0 ]
    then
        IFS=${NO_WSP}
        name_srvc=( ${name_srvc[@]} ${_den_ns[@]} )
        IFS=${WSP_IFS}
    fi

    unique_lines _den_nr _den_nr
    edit_exact name_resource _den_nr
    if [ ${#_den_nr[@]} -gt 0 ]
    then
        IFS=${NO_WSP}
        name_resource=( ${name_resource[@]} ${_den_nr[@]} )
        IFS=${WSP_IFS}
    fi

    unique_lines _den_pc _den_pc
    edit_exact parent_child _den_pc
    if [ ${#_den_pc[@]} -gt 0 ]
    then
        IFS=${NO_WSP}
        parent_child=( ${parent_child[@]} ${_den_pc[@]} )
        IFS=${WSP_IFS}
    fi

    # Update list known_pair (Address and Name).
    unique_lines _den_pair _den_pair
    edit_exact known_pair _den_pair
    if [ ${#_den_pair[@]} -gt 0 ]  # Anything new?
    then
        IFS=${NO_WSP}
        known_pair=( ${known_pair[@]} ${_den_pair[@]} )
        IFS=${WSP_IFS}
    fi

    # Update list of reverse pairs.
    unique_lines _den_rev _den_rev
    edit_exact reverse_pair _den_rev
    if [ ${#_den_rev[@]} -gt 0 ]   # Anything new?
    then
        IFS=${NO_WSP}
        reverse_pair=( ${reverse_pair[@]} ${_den_rev[@]} )
        IFS=${WSP_IFS}
    fi

    # Check indirection limit -- give up if reached.
    if ! _den_lmt=$(limit_chk ${1})
    then
        return 0
    fi

# Execution engine is LIFO. Order of pend operations is important.
# Did we define any new addresses?
unique_lines _den_address _den_address    # Scrub duplicates.
edit_exact known_address _den_address     # Scrub already processed.
edit_exact un_address _den_address        # Scrub already waiting.
if [ ${#_den_address[@]} -gt 0 ]          # Anything new?
then
  uc_address=( ${uc_address[@]} ${_den_address[@]} )
  pend_func expand_input_address ${_den_lmt}
  _trace_log[${#_trace_log[@]}]='# Add '${#_den_address[@]}' unchkd addr. #'
    fi

# Did we find any new names?
unique_lines _den_name _den_name          # Scrub duplicates.
edit_exact known_name _den_name           # Scrub already processed.
edit_exact uc_name _den_name              # Scrub already waiting.
if [ ${#_den_name[@]} -gt 0 ]             # Anything new?
then
  uc_name=( ${uc_name[@]} ${_den_name[@]} )
  pend_func expand_input_name ${_den_lmt}
  _trace_log[${#_trace_log[@]}]='#Added '${#_den_name[@]}' unchkd name#'
    fi
    return 0
}

# The parse-it-yourself delegation reply
# Input is the chk_address list.
# detail_each_address <indirection_limit>
detail_each_address() {
    [ ${#chk_address[@]} -gt 0 ] || return 0
    unique_lines chk_address chk_address
    edit_exact known_address chk_address
    if [ ${#chk_address[@]} -gt 0 ]
    then
        known_address=( ${known_address[@]} ${chk_address[@]} )
        unset chk_address[@]
    fi
    return 0
}

# # # Application specific output functions # # #

# Pretty print the known pairs.
report_pairs() {
    echo
    echo 'Known network pairs.'
    col_print known_pair 2 5 30

    if [ ${#auth_chain[@]} -gt 0 ]
    then
        echo
        echo 'Known chain of authority.'
        col_print auth_chain 2 5 30 55
    fi

    if [ ${#reverse_pair[@]} -gt 0 ]
    then
        echo
        echo 'Known reverse pairs.'
        col_print reverse_pair 2 5 55
    fi
    return 0
}

# Check an address against the list of blacklist servers.
# A good place to capture for GraphViz: address->status(server(reports))
# check_lists <ip_address>
check_lists() {
    [ $# -eq 1 ] || return 1
    local -a _cl_fwd_addr
    local -a _cl_rev_addr
    local -a _cl_reply
    local -i _cl_rc
    local -i _ls_cnt
    local _cl_dns_addr
    local _cl_lkup

    split_ip ${1} _cl_fwd_addr _cl_rev_addr
    _cl_dns_addr=$(dot_array _cl_rev_addr)'.'
    _ls_cnt=${#list_server[@]}
    echo '    Checking address '${1}
    for (( _cl = 0 ; _cl < _ls_cnt ; _cl++ ))
    do
      _cl_lkup=${_cl_dns_addr}${list_server[${_cl}]}
      if short_text ${_cl_lkup} _cl_reply
      then
        if [ ${#_cl_reply[@]} -gt 0 ]
        then
          echo '        Records from '${list_server[${_cl}]}
          address_hits[${#address_hits[@]}]=${1}' '${list_server[${_cl}]}
          _hs_RC=2
          for (( _clr = 0 ; _clr < ${#_cl_reply[@]} ; _clr++ ))
          do
            echo '            '${_cl_reply[${_clr}]}
          done
        fi
      fi
    done
    return 0
}

# # # The usual application glue # # #

# Who did it?
credits() {
   echo
   echo 'Advanced Bash Scripting Guide: is_spammer.bash, v2, 2004-msz'
}

# How to use it?
# (See also, "Quickstart" at end of script.)
usage() {
    cat <<-'_usage_statement_'
    The script is_spammer.bash requires either one or two arguments.

    arg 1) May be one of:
        a) A domain name
        b) An IPv4 address
        c) The name of a file with any mix of names
           and addresses, one per line.

    arg 2) May be one of:
        a) A Blacklist server domain name
        b) The name of a file with Blacklist server
           domain names, one per line.
        c) If not present, a default list of (free)
           Blacklist servers is used.
        d) If a filename of an empty, readable, file
           is given,
           Blacklist server lookup is disabled.

    All script output is written to stdout.

    Return codes: 0 -> All OK, 1 -> Script failure,
                  2 -> Something is Blacklisted.

    Requires the external program 'dig' from the 'bind-9'
    set of DNS programs.  See: http://www.isc.org

    The domain name lookup depth limit defaults to 2 levels.
    Set the environment variable SPAMMER_LIMIT to change.
    SPAMMER_LIMIT=0 means 'unlimited'

    Limit may also be set on the command-line.
    If arg#1 is an integer, the limit is set to that value
    and then the above argument rules are applied.

    Setting the environment variable 'SPAMMER_DATA' to a filename
    will cause the script to write a GraphViz graphic file.

    For the development version;
    Setting the environment variable 'SPAMMER_TRACE' to a filename
    will cause the execution engine to log a function call trace.

_usage_statement_
}

# The default list of Blacklist servers:
# Many choices, see: http://www.spews.org/lists.html

declare -a default_servers
# See: http://www.spamhaus.org (Conservative, well maintained)
default_servers[0]='sbl-xbl.spamhaus.org'
# See: http://ordb.org (Open mail relays)
default_servers[1]='relays.ordb.org'
# See: http://www.spamcop.net/ (You can report spammers here)
default_servers[2]='bl.spamcop.net'
# See: http://www.spews.org (An 'early detect' system)
default_servers[3]='l2.spews.dnsbl.sorbs.net'
# See: http://www.dnsbl.us.sorbs.net/using.shtml
default_servers[4]='dnsbl.sorbs.net'
# See: http://dsbl.org/usage (Various mail relay lists)
default_servers[5]='list.dsbl.org'
default_servers[6]='multihop.dsbl.org'
default_servers[7]='unconfirmed.dsbl.org'

# User input argument #1
setup_input() {
    if [ -e ${1} ] && [ -r ${1} ]  # Name of readable file
    then
        file_to_array ${1} uc_name
        echo 'Using filename >'${1}'< as input.'
    else
        if is_address ${1}          # IP address?
        then
            uc_address=( ${1} )
            echo 'Starting with address >'${1}'<'
        else                       # Must be a name.
            uc_name=( ${1} )
            echo 'Starting with domain name >'${1}'<'
        fi
    fi
    return 0
}

# User input argument #2
setup_servers() {
    if [ -e ${1} ] && [ -r ${1} ]  # Name of a readable file
    then
        file_to_array ${1} list_server
        echo 'Using filename >'${1}'< as blacklist server list.'
    else
        list_server=( ${1} )
        echo 'Using blacklist server >'${1}'<'
    fi
    return 0
}

# User environment variable SPAMMER_TRACE
live_log_die() {
    if [ ${SPAMMER_TRACE:=} ]    # Wants trace log?
    then
        if [ ! -e ${SPAMMER_TRACE} ]
        then
            if ! touch ${SPAMMER_TRACE} 2>/dev/null
            then
                pend_func echo $(printf '%q\n' \
                'Unable to create log file >'${SPAMMER_TRACE}'<')
                pend_release
                exit 1
            fi
            _log_file=${SPAMMER_TRACE}
            _pend_hook_=trace_logger
            _log_dump=dump_log
        else
            if [ ! -w ${SPAMMER_TRACE} ]
            then
                pend_func echo $(printf '%q\n' \
                'Unable to write log file >'${SPAMMER_TRACE}'<')
                pend_release
                exit 1
            fi
            _log_file=${SPAMMER_TRACE}
            echo '' > ${_log_file}
            _pend_hook_=trace_logger
            _log_dump=dump_log
        fi
    fi
    return 0
}

# User environment variable SPAMMER_DATA
data_capture() {
    if [ ${SPAMMER_DATA:=} ]    # Wants a data dump?
    then
        if [ ! -e ${SPAMMER_DATA} ]
        then
            if ! touch ${SPAMMER_DATA} 2>/dev/null
            then
                pend_func echo $(printf '%q]n' \
                'Unable to create data output file >'${SPAMMER_DATA}'<')
                pend_release
                exit 1
            fi
            _dot_file=${SPAMMER_DATA}
            _dot_dump=dump_dot
        else
            if [ ! -w ${SPAMMER_DATA} ]
            then
                pend_func echo $(printf '%q\n' \
                'Unable to write data output file >'${SPAMMER_DATA}'<')
                pend_release
                exit 1
            fi
            _dot_file=${SPAMMER_DATA}
            _dot_dump=dump_dot
        fi
    fi
    return 0
}

# Grope user specified arguments.
do_user_args() {
    if [ $# -gt 0 ] && is_number $1
    then
        indirect=$1
        shift
    fi

    case $# in                     # Did user treat us well?
        1)
            if ! setup_input $1    # Needs error checking.
            then
                pend_release
                $_log_dump
                exit 1
            fi
            list_server=( ${default_servers[@]} )
            _list_cnt=${#list_server[@]}
            echo 'Using default blacklist server list.'
            echo 'Search depth limit: '${indirect}
            ;;
        2)
            if ! setup_input $1    # Needs error checking.
            then
                pend_release
                $_log_dump
                exit 1
            fi
            if ! setup_servers $2  # Needs error checking.
            then
                pend_release
                $_log_dump
                exit 1
            fi
            echo 'Search depth limit: '${indirect}
            ;;
        *)
            pend_func usage
            pend_release
            $_log_dump
            exit 1
            ;;
    esac
    return 0
}

# A general purpose debug tool.
# list_array <array_name>
list_array() {
    [ $# -eq 1 ] || return 1  # One argument required.

    local -a _la_lines
    set -f
    local IFS=${NO_WSP}
    eval _la_lines=\(\ \$\{$1\[@\]\}\ \)
    echo
    echo "Element count "${#_la_lines[@]}" array "${1}
    local _ln_cnt=${#_la_lines[@]}

    for (( _i = 0; _i < ${_ln_cnt}; _i++ ))
    do
        echo 'Element '$_i' >'${_la_lines[$_i]}'<'
    done
    set +f
    return 0
}

# # # 'Hunt the Spammer' program code # # #
pend_init                               # Ready stack engine.
pend_func credits                       # Last thing to print.

# # # Deal with user # # #
live_log_die                            # Setup debug trace log.
data_capture                            # Setup data capture file.
echo
do_user_args $@

# # # Haven't exited yet - There is some hope # # #
# Discovery group - Execution engine is LIFO - pend
# in reverse order of execution.
_hs_RC=0                                # Hunt the Spammer return code
pend_mark
    pend_func report_pairs              # Report name-address pairs.

    # The two detail_* are mutually recursive functions.
    # They also pend expand_* functions as required.
    # These two (the last of ???) exit the recursion.
    pend_func detail_each_address       # Get all resources of addresses.
    pend_func detail_each_name          # Get all resources of names.

    #  The two expand_* are mutually recursive functions,
    #+ which pend additional detail_* functions as required.
    pend_func expand_input_address 1    # Expand input names by address.
    pend_func expand_input_name 1       # #xpand input addresses by name.

    # Start with a unique set of names and addresses.
    pend_func unique_lines uc_address uc_address
    pend_func unique_lines uc_name uc_name

    # Separate mixed input of names and addresses.
    pend_func split_input
pend_release

# # # Pairs reported -- Unique list of IP addresses found
echo
_ip_cnt=${#known_address[@]}
if [ ${#list_server[@]} -eq 0 ]
then
    echo 'Blacklist server list empty, none checked.'
else
    if [ ${_ip_cnt} -eq 0 ]
    then
        echo 'Known address list empty, none checked.'
    else
        _ip_cnt=${_ip_cnt}-1   # Start at top.
        echo 'Checking Blacklist servers.'
        for (( _ip = _ip_cnt ; _ip >= 0 ; _ip-- ))
        do
          pend_func check_lists $( printf '%q\n' ${known_address[$_ip]} )
        done
    fi
fi
pend_release
$_dot_dump                   # Graphics file dump
$_log_dump                   # Execution trace
echo


##############################
# Example output from script #
##############################
:<<-'_is_spammer_outputs_'

./is_spammer.bash 0 web4.alojamentos7.com

Starting with domain name >web4.alojamentos7.com<
Using default blacklist server list.
Search depth limit: 0
.:....::::...:::...:::.......::..::...:::.......::
Known network pairs.
    66.98.208.97             web4.alojamentos7.com.
    66.98.208.97             ns1.alojamentos7.com.
    69.56.202.147            ns2.alojamentos.ws.
    66.98.208.97             alojamentos7.com.
    66.98.208.97             web.alojamentos7.com.
    69.56.202.146            ns1.alojamentos.ws.
    69.56.202.146            alojamentos.ws.
    66.235.180.113           ns1.alojamentos.org.
    66.235.181.192           ns2.alojamentos.org.
    66.235.180.113           alojamentos.org.
    66.235.180.113           web6.alojamentos.org.
    216.234.234.30           ns1.theplanet.com.
    12.96.160.115            ns2.theplanet.com.
    216.185.111.52           mail1.theplanet.com.
    69.56.141.4              spooling.theplanet.com.
    216.185.111.40           theplanet.com.
    216.185.111.40           www.theplanet.com.
    216.185.111.52           mail.theplanet.com.

Checking Blacklist servers.
  Checking address 66.98.208.97
      Records from dnsbl.sorbs.net
  "Spam Received See: http://www.dnsbl.sorbs.net/lookup.shtml?66.98.208.97"
    Checking address 69.56.202.147
    Checking address 69.56.202.146
    Checking address 66.235.180.113
    Checking address 66.235.181.192
    Checking address 216.185.111.40
    Checking address 216.234.234.30
    Checking address 12.96.160.115
    Checking address 216.185.111.52
    Checking address 69.56.141.4

Advanced Bash Scripting Guide: is_spammer.bash, v2, 2004-msz

_is_spammer_outputs_

exit ${_hs_RC}

####################################################
#  The script ignores everything from here on down #
#+ because of the 'exit' command, just above.      #
####################################################



Quickstart
==========

 Prerequisites

  Bash version 2.05b or 3.00 (bash --version)
  A version of Bash which supports arrays. Array 
  support is included by default Bash configurations.

  'dig,' version 9.x.x (dig $HOSTNAME, see first line of output)
  A version of dig which supports the +short options. 
  See: dig_wrappers.bash for details.


 Optional Prerequisites

  'named,' a local DNS caching program. Any flavor will do.
  Do twice: dig $HOSTNAME 
  Check near bottom of output for: SERVER: 127.0.0.1#53
  That means you have one running.


 Optional Graphics Support

  'date,' a standard *nix thing. (date -R)

  dot Program to convert graphic description file to a 
  diagram. (dot -V)
  A part of the Graph-Viz set of programs.
  See: [http://www.research.att.com/sw/tools/graphviz||GraphViz]

  'dotty,' a visual editor for graphic description files.
  Also a part of the Graph-Viz set of programs.




 Quick Start

In the same directory as the is_spammer.bash script; 
Do: ./is_spammer.bash

 Usage Details

1. Blacklist server choices.

  (a) To use default, built-in list: Do nothing.

  (b) To use your own list: 

    i. Create a file with a single Blacklist server 
       domain name per line.

    ii. Provide that filename as the last argument to 
        the script.

  (c) To use a single Blacklist server: Last argument 
      to the script.

  (d) To disable Blacklist lookups:

    i. Create an empty file (touch spammer.nul)
       Your choice of filename.

    ii. Provide the filename of that empty file as the 
        last argument to the script.

2. Search depth limit.

  (a) To use the default value of 2: Do nothing.

  (b) To set a different limit: 
      A limit of 0 means: no limit.

    i. export SPAMMER_LIMIT=1
       or whatever limit you want.

    ii. OR provide the desired limit as the first 
       argument to the script.

3. Optional execution trace log.

  (a) To use the default setting of no log output: Do nothing.

  (b) To write an execution trace log:
      export SPAMMER_TRACE=spammer.log
      or whatever filename you want.

4. Optional graphic description file.

  (a) To use the default setting of no graphic file: Do nothing.

  (b) To write a Graph-Viz graphic description file:
      export SPAMMER_DATA=spammer.dot
      or whatever filename you want.

5. Where to start the search.

  (a) Starting with a single domain name:

    i. Without a command-line search limit: First 
       argument to script.

    ii. With a command-line search limit: Second 
        argument to script.

  (b) Starting with a single IP address:

    i. Without a command-line search limit: First 
       argument to script.

    ii. With a command-line search limit: Second 
        argument to script.

  (c) Starting with (mixed) multiple name(s) and/or address(es):
      Create a file with one name or address per line.
      Your choice of filename.

    i. Without a command-line search limit: Filename as 
       first argument to script.

    ii. With a command-line search limit: Filename as 
        second argument to script.

6. What to do with the display output.

  (a) To view display output on screen: Do nothing.

  (b) To save display output to a file: Redirect stdout to a filename.

  (c) To discard display output: Redirect stdout to /dev/null.

7. Temporary end of decision making. 
   press RETURN 
   wait (optionally, watch the dots and colons).

8. Optionally check the return code.

  (a) Return code 0: All OK

  (b) Return code 1: Script setup failure

  (c) Return code 2: Something was blacklisted.

9. Where is my graph (diagram)?

The script does not directly produce a graph (diagram). 
It only produces a graphic description file. You can 
process the graphic descriptor file that was output 
with the 'dot' program.

Until you edit that descriptor file, to describe the 
relationships you want shown, all that you will get is 
a bunch of labeled name and address nodes.

All of the script's discovered relationships are within 
a comment block in the graphic descriptor file, each 
with a descriptive heading.

The editing required to draw a line between a pair of 
nodes from the information in the descriptor file may 
be done with a text editor. 

Given these lines somewhere in the descriptor file:

# Known domain name nodes

N0000 [label="guardproof.info."] ;

N0002 [label="third.guardproof.info."] ;



# Known address nodes

A0000 [label="61.141.32.197"] ;



/*

# Known name->address edges

NA0000 third.guardproof.info. 61.141.32.197



# Known parent->child edges

PC0000 guardproof.info. third.guardproof.info.

 */

Turn that into the following lines by substituting node 
identifiers into the relationships:

# Known domain name nodes

N0000 [label="guardproof.info."] ;

N0002 [label="third.guardproof.info."] ;



# Known address nodes

A0000 [label="61.141.32.197"] ;



# PC0000 guardproof.info. third.guardproof.info.

N0000->N0002 ;



# NA0000 third.guardproof.info. 61.141.32.197

N0002->A0000 ;



/*

# Known name->address edges

NA0000 third.guardproof.info. 61.141.32.197



# Known parent->child edges

PC0000 guardproof.info. third.guardproof.info.

 */

Process that with the 'dot' program, and you have your 
first network diagram.

In addition to the conventional graphic edges, the 
descriptor file includes similar format pair-data that 
describes services, zone records (sub-graphs?), 
blacklisted addresses, and other things which might be 
interesting to include in your graph. This additional 
information could be displayed as different node 
shapes, colors, line sizes, etc.

The descriptor file can also be read and edited by a 
Bash script (of course). You should be able to find 
most of the functions required within the 
"is_spammer.bash" script.

# End Quickstart.



Additional Note
========== ====

Michael Zick points out that there is a "makeviz.bash" interactive
Web site at rediris.es. Can't give the full URL, since this is not
a publically accessible site.
}

◊anchored-example[#:anchor "lit_str2"]{Spammer Hunt}

Another anti-spam script.

◊example{
#!/bin/bash
# whx.sh: "whois" spammer lookup
# Author: Walter Dnes
# Slight revisions (first section) by ABS Guide author.
# Used in ABS Guide with permission.

# Needs version 3.x or greater of Bash to run (because of =~ operator).
# Commented by script author and ABS Guide author.



E_BADARGS=85        # Missing command-line arg.
E_NOHOST=86         # Host not found.
E_TIMEOUT=87        # Host lookup timed out.
E_UNDEF=88          # Some other (undefined) error.

HOSTWAIT=10         # Specify up to 10 seconds for host query reply.
                    # The actual wait may be a bit longer.
OUTFILE=whois.txt   # Output file.
PORT=4321


if [ -z "$1" ]      # Check for (required) command-line arg.
then
  echo "Usage: $0 domain name or IP address"
  exit $E_BADARGS
fi


if [[ "$1" =~ [a-zA-Z][a-zA-Z]$ ]]  #  Ends in two alpha chars?
then                                  #  It's a domain name &&
                                      #+ must do host lookup.
  IPADDR=$(host -W $HOSTWAIT $1 | awk '{print $4}')
                                      #  Doing host lookup
                                      #+ to get IP address.
				      #  Extract final field.
else
  IPADDR="$1"                         #  Command-line arg was IP address.
fi

echo; echo "IP Address is: "$IPADDR""; echo

if [ -e "$OUTFILE" ]
then
  rm -f "$OUTFILE"
  echo "Stale output file \"$OUTFILE\" removed."; echo
fi


#  Sanity checks.
#  (This section needs more work.)
#  ===============================
if [ -z "$IPADDR" ]
# No response.
then
  echo "Host not found!"
  exit $E_NOHOST    # Bail out.
fi

if [[ "$IPADDR" =~ ^[;;] ]]
#  ;; Connection timed out; no servers could be reached.
then
  echo "Host lookup timed out!"
  exit $E_TIMEOUT   # Bail out.
fi

if [[ "$IPADDR" =~ [(NXDOMAIN)]$ ]]
#  Host xxxxxxxxx.xxx not found: 3(NXDOMAIN)
then
  echo "Host not found!"
  exit $E_NOHOST    # Bail out.
fi

if [[ "$IPADDR" =~ [(SERVFAIL)]$ ]]
#  Host xxxxxxxxx.xxx not found: 2(SERVFAIL)
then
  echo "Host not found!"
  exit $E_NOHOST    # Bail out.
fi




# ======================== Main body of script ========================

AFRINICquery() {
#  Define the function that queries AFRINIC. Echo a notification to the
#+ screen, and then run the actual query, redirecting output to $OUTFILE.

  echo "Searching for $IPADDR in whois.afrinic.net"
  whois -h whois.afrinic.net "$IPADDR" > $OUTFILE

#  Check for presence of reference to an rwhois.
#  Warn about non-functional rwhois.infosat.net server
#+ and attempt rwhois query.
  if grep -e "^remarks: .*rwhois\.[^ ]\+" "$OUTFILE"
  then
    echo " " >> $OUTFILE
    echo "***" >> $OUTFILE
    echo "***" >> $OUTFILE
    echo "Warning: rwhois.infosat.net was not working \
      as of 2005/02/02" >> $OUTFILE
    echo "         when this script was written." >> $OUTFILE
    echo "***" >> $OUTFILE
    echo "***" >> $OUTFILE
    echo " " >> $OUTFILE
    RWHOIS=`grep "^remarks: .*rwhois\.[^ ]\+" "$OUTFILE" | tail -n 1 |\
    sed "s/\(^.*\)\(rwhois\..*\)\(:4.*\)/\2/"`
    whois -h ${RWHOIS}:${PORT} "$IPADDR" >> $OUTFILE
  fi
}

APNICquery() {
  echo "Searching for $IPADDR in whois.apnic.net"
  whois -h whois.apnic.net "$IPADDR" > $OUTFILE

#  Just  about  every  country has its own internet registrar.
#  I don't normally bother consulting them, because the regional registry
#+ usually supplies sufficient information.
#  There are a few exceptions, where the regional registry simply
#+ refers to the national registry for direct data.
#  These are Japan and South Korea in APNIC, and Brasil in LACNIC.
#  The following if statement checks $OUTFILE (whois.txt) for the presence
#+ of "KR" (South Korea) or "JP" (Japan) in the country field.
#  If either is found, the query is re-run against the appropriate
#+ national registry.

  if grep -E "^country:[ ]+KR$" "$OUTFILE"
  then
    echo "Searching for $IPADDR in whois.krnic.net"
    whois -h whois.krnic.net "$IPADDR" >> $OUTFILE
  elif grep -E "^country:[ ]+JP$" "$OUTFILE"
  then
    echo "Searching for $IPADDR in whois.nic.ad.jp"
    whois -h whois.nic.ad.jp "$IPADDR"/e >> $OUTFILE
  fi
}

ARINquery() {
  echo "Searching for $IPADDR in whois.arin.net"
  whois -h whois.arin.net "$IPADDR" > $OUTFILE

#  Several large internet providers listed by ARIN have their own
#+ internal whois service, referred to as "rwhois".
#  A large block of IP addresses is listed with the provider
#+ under the ARIN registry.
#  To get the IP addresses of 2nd-level ISPs or other large customers,
#+ one has to refer to the rwhois server on port 4321.
#  I originally started with a bunch of "if" statements checking for
#+ the larger providers.
#  This approach is unwieldy, and there's always another rwhois server
#+ that I didn't know about.
#  A more elegant approach is to check $OUTFILE for a reference
#+ to a whois server, parse that server name out of the comment section,
#+ and re-run the query against the appropriate rwhois server.
#  The parsing looks a bit ugly, with a long continued line inside
#+ backticks.
#  But it only has to be done once, and will work as new servers are added.
#@   ABS Guide author comment: it isn't all that ugly, and is, in fact,
#@+  an instructive use of Regular Expressions.

  if grep -E "^Comment: .*rwhois.[^ ]+" "$OUTFILE"
  then
    RWHOIS=`grep -e "^Comment:.*rwhois\.[^ ]\+" "$OUTFILE" | tail -n 1 |\
    sed "s/^\(.*\)\(rwhois\.[^ ]\+\)\(.*$\)/\2/"`
    echo "Searching for $IPADDR in ${RWHOIS}"
    whois -h ${RWHOIS}:${PORT} "$IPADDR" >> $OUTFILE
  fi
}

LACNICquery() {
  echo "Searching for $IPADDR in whois.lacnic.net"
  whois -h whois.lacnic.net "$IPADDR" > $OUTFILE

#  The  following if statement checks $OUTFILE (whois.txt) for
#+ the presence of "BR" (Brasil) in the country field.
#  If it is found, the query is re-run against whois.registro.br.

  if grep -E "^country:[ ]+BR$" "$OUTFILE"
  then
    echo "Searching for $IPADDR in whois.registro.br"
    whois -h whois.registro.br "$IPADDR" >> $OUTFILE
  fi
}

RIPEquery() {
  echo "Searching for $IPADDR in whois.ripe.net"
  whois -h whois.ripe.net "$IPADDR" > $OUTFILE
}

#  Initialize a few variables.
#  * slash8 is the most significant octet
#  * slash16 consists of the two most significant octets
#  * octet2 is the second most significant octet




slash8=`echo $IPADDR | cut -d. -f 1`
  if [ -z "$slash8" ]  # Yet another sanity check.
  then
    echo "Undefined error!"
    exit $E_UNDEF
  fi
slash16=`echo $IPADDR | cut -d. -f 1-2`
#                             ^ Period specified as 'cut" delimiter.
  if [ -z "$slash16" ]
  then
    echo "Undefined error!"
    exit $E_UNDEF
  fi
octet2=`echo $slash16 | cut -d. -f 2`
  if [ -z "$octet2" ]
  then
    echo "Undefined error!"
    exit $E_UNDEF
  fi


#  Check for various odds and ends of reserved space.
#  There is no point in querying for those addresses.

if [ $slash8 == 0 ]; then
  echo $IPADDR is '"This Network"' space\; Not querying
elif [ $slash8 == 10 ]; then
  echo $IPADDR is RFC1918 space\; Not querying
elif [ $slash8 == 14 ]; then
  echo $IPADDR is '"Public Data Network"' space\; Not querying
elif [ $slash8 == 127 ]; then
  echo $IPADDR is loopback space\; Not querying
elif [ $slash16 == 169.254 ]; then
  echo $IPADDR is link-local space\; Not querying
elif [ $slash8 == 172 ] && [ $octet2 -ge 16 ] && [ $octet2 -le 31 ];then
  echo $IPADDR is RFC1918 space\; Not querying
elif [ $slash16 == 192.168 ]; then
  echo $IPADDR is RFC1918 space\; Not querying
elif [ $slash8 -ge 224 ]; then
  echo $IPADDR is either Multicast or reserved space\; Not querying
elif [ $slash8 -ge 200 ] && [ $slash8 -le 201 ]; then LACNICquery "$IPADDR"
elif [ $slash8 -ge 202 ] && [ $slash8 -le 203 ]; then APNICquery "$IPADDR"
elif [ $slash8 -ge 210 ] && [ $slash8 -le 211 ]; then APNICquery "$IPADDR"
elif [ $slash8 -ge 218 ] && [ $slash8 -le 223 ]; then APNICquery "$IPADDR"

#  If we got this far without making a decision, query ARIN.
#  If a reference is found in $OUTFILE to APNIC, AFRINIC, LACNIC, or RIPE,
#+ query the appropriate whois server.

else
  ARINquery "$IPADDR"
  if grep "whois.afrinic.net" "$OUTFILE"; then
    AFRINICquery "$IPADDR"
  elif grep -E "^OrgID:[ ]+RIPE$" "$OUTFILE"; then
    RIPEquery "$IPADDR"
  elif grep -E "^OrgID:[ ]+APNIC$" "$OUTFILE"; then
    APNICquery "$IPADDR"
  elif grep -E "^OrgID:[ ]+LACNIC$" "$OUTFILE"; then
    LACNICquery "$IPADDR"
  fi
fi

#@  ---------------------------------------------------------------
#   Try also:
#   wget http://logi.cc/nw/whois.php3?ACTION=doQuery&DOMAIN=$IPADDR
#@  ---------------------------------------------------------------

#  We've  now  finished  the querying.
#  Echo a copy of the final result to the screen.

cat $OUTFILE
# Or "less $OUTFILE" . . .


exit 0

#@  ABS Guide author comments:
#@  Nothing fancy here, but still a very useful tool for hunting spammers.
#@  Sure, the script can be cleaned up some, and it's still a bit buggy,
#@+ (exercise for reader), but all the same, it's a nice piece of coding
#@+ by Walter Dnes.
#@  Thank you!
}

◊anchored-example[#:anchor "wget1"]{Making wget easier to use}

"Little Monster's" front end to wget.

◊example{
#!/bin/bash
# wgetter2.bash

# Author: Little Monster [monster@monstruum.co.uk]
# ==> Used in ABS Guide with permission of script author.
# ==> This script still needs debugging and fixups (exercise for reader).
# ==> It could also use some additional editing in the comments.


#  This is wgetter2 --
#+ a Bash script to make wget a bit more friendly, and save typing.

#  Carefully crafted by Little Monster.
#  More or less complete on 02/02/2005.
#  If you think this script can be improved,
#+ email me at: monster@monstruum.co.uk
# ==> and cc: to the author of the ABS Guide, please.
#  This script is licenced under the GPL.
#  You are free to copy, alter and re-use it,
#+ but please don't try to claim you wrote it.
#  Log your changes here instead.

# =======================================================================
# changelog:

# 07/02/2005.  Fixups by Little Monster.
# 02/02/2005.  Minor additions by Little Monster.
#              (See after # +++++++++++ )
# 29/01/2005.  Minor stylistic edits and cleanups by author of ABS Guide.
#              Added exit error codes.
# 22/11/2004.  Finished initial version of second version of wgetter:
#              wgetter2 is born.
# 01/12/2004.  Changed 'runn' function so it can be run 2 ways --
#              either ask for a file name or have one input on the CL.
# 01/12/2004.  Made sensible handling of no URL's given.
# 01/12/2004.  Made loop of main options, so you don't
#              have to keep calling wgetter 2 all the time.
#              Runs as a session instead.
# 01/12/2004.  Added looping to 'runn' function.
#              Simplified and improved.
# 01/12/2004.  Added state to recursion setting.
#              Enables re-use of previous value.
# 05/12/2004.  Modified the file detection routine in the 'runn' function
#              so it's not fooled by empty values, and is cleaner.
# 01/02/2004.  Added cookie finding routine from later version (which 
#              isn't ready yet), so as not to have hard-coded paths.
# =======================================================================

# Error codes for abnormal exit.
E_USAGE=67        # Usage message, then quit.
E_NO_OPTS=68      # No command-line args entered.
E_NO_URLS=69      # No URLs passed to script.
E_NO_SAVEFILE=70  # No save filename passed to script.
E_USER_EXIT=71    # User decides to quit.


#  Basic default wget command we want to use.
#  This is the place to change it, if required.
#  NB: if using a proxy, set http_proxy = yourproxy in .wgetrc.
#  Otherwise delete --proxy=on, below.
# ====================================================================
CommandA="wget -nc -c -t 5 --progress=bar --random-wait --proxy=on -r"
# ====================================================================



# --------------------------------------------------------------------
# Set some other variables and explain them.

pattern=" -A .jpg,.JPG,.jpeg,.JPEG,.gif,.GIF,.htm,.html,.shtml,.php"
                    # wget's option to only get certain types of file.
                    # comment out if not using
today=`date +%F`    # Used for a filename.
home=$HOME          # Set HOME to an internal variable.
                    # In case some other path is used, change it here.
depthDefault=3      # Set a sensible default recursion.
Depth=$depthDefault # Otherwise user feedback doesn't tie in properly.
RefA=""             # Set blank referring page.
Flag=""             #  Default to not saving anything,
                    #+ or whatever else might be wanted in future.
lister=""           # Used for passing a list of urls directly to wget.
Woptions=""         # Used for passing wget some options for itself.
inFile=""           # Used for the run function.
newFile=""          # Used for the run function.
savePath="$home/w-save"
Config="$home/.wgetter2rc"
                    #  This is where some variables can be stored, 
                    #+ if permanently changed from within the script.
Cookie_List="$home/.cookielist"
                    # So we know where the cookies are kept . . .
cFlag=""            # Part of the cookie file selection routine.

# Define the options available. Easy to change letters here if needed.
# These are the optional options; you don't just wait to be asked.

save=s   # Save command instead of executing it.
cook=c   # Change cookie file for this session.
help=h   # Usage guide.
list=l   # Pass wget the -i option and URL list.
runn=r   # Run saved commands as an argument to the option.
inpu=i   # Run saved commands interactively.
wopt=w   # Allow to enter options to pass directly to wget.
# --------------------------------------------------------------------


if [ -z "$1" ]; then   # Make sure we get something for wget to eat.
   echo "You must at least enter a URL or option!"
   echo "-$help for usage."
   exit $E_NO_OPTS
fi



# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# added added added added added added added added added added added added

if [ ! -e "$Config" ]; then   # See if configuration file exists.
   echo "Creating configuration file, $Config"
   echo "# This is the configuration file for wgetter2" > "$Config"
   echo "# Your customised settings will be saved in this file" >> "$Config"
else
   source $Config             # Import variables we set outside the script.
fi

if [ ! -e "$Cookie_List" ]; then
   # Set up a list of cookie files, if there isn't one.
   echo "Hunting for cookies . . ."
   find -name cookies.txt >> $Cookie_List # Create the list of cookie files.
fi #  Isolate this in its own 'if' statement,
   #+ in case we got interrupted while searching.

if [ -z "$cFlag" ]; then # If we haven't already done this . . .
   echo                  # Make a nice space after the command prompt.
   echo "Looks like you haven't set up your source of cookies yet."
   n=0                   #  Make sure the counter
                         #+ doesn't contain random values.
   while read; do
      Cookies[$n]=$REPLY # Put the cookie files we found into an array.
      echo "$n) ${Cookies[$n]}"  # Create a menu.
      n=$(( n + 1 ))     # Increment the counter.
   done < $Cookie_List   # Feed the read statement.
   echo "Enter the number of the cookie file you want to use."
   echo "If you won't be using cookies, just press RETURN."
   echo
   echo "I won't be asking this again. Edit $Config"
   echo "If you decide to change at a later date"
   echo "or use the -${cook} option for per session changes."
   read
   if [ ! -z $REPLY ]; then   # User didn't just press return.
      Cookie=" --load-cookies ${Cookies[$REPLY]}"
      # Set the variable here as well as in the config file.

      echo "Cookie=\" --load-cookies ${Cookies[$REPLY]}\"" >> $Config
   fi
   echo "cFlag=1" >> $Config  # So we know not to ask again.
fi

# end added section end added section end added section end added section
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



# Another variable.
# This one may or may not be subject to variation.
# A bit like the small print.
CookiesON=$Cookie
# echo "cookie file is $CookiesON" # For debugging.
# echo "home is ${home}"           # For debugging.
                                   # Got caught with this one!


wopts()
{
echo "Enter options to pass to wget."
echo "It is assumed you know what you're doing."
echo
echo "You can pass their arguments here too."
# That is to say, everything passed here is passed to wget.

read Wopts
# Read in the options to be passed to wget.

Woptions=" $Wopts"
#         ^  Why the leading space?
# Assign to another variable.
# Just for fun, or something . . .

echo "passing options ${Wopts} to wget"
# Mainly for debugging.
# Is cute.

return
}


save_func()
{
echo "Settings will be saved."
if [ ! -d $savePath ]; then  #  See if directory exists.
   mkdir $savePath           #  Create the directory to save things in
                             #+ if it isn't already there.
fi

Flag=S
# Tell the final bit of code what to do.
# Set a flag since stuff is done in main.

return
}


usage() # Tell them how it works.
{
    echo "Welcome to wgetter.  This is a front end to wget."
    echo "It will always run wget with these options:"
    echo "$CommandA"
    echo "and the pattern to match: $pattern \
(which you can change at the top of this script)."
    echo "It will also ask you for recursion depth, \
and if you want to use a referring page."
    echo "Wgetter accepts the following options:"
    echo ""
    echo "-$help : Display this help."
    echo "-$save : Save the command to a file $savePath/wget-($today) \
instead of running it."
    echo "-$runn : Run saved wget commands instead of starting a new one -"
    echo "Enter filename as argument to this option."
    echo "-$inpu : Run saved wget commands interactively --"
    echo "The script will ask you for the filename."
    echo "-$cook : Change the cookies file for this session."
    echo "-$list : Tell wget to use URL's from a list instead of \
from the command-line."
    echo "-$wopt : Pass any other options direct to wget."
    echo ""
    echo "See the wget man page for additional options \
you can pass to wget."
    echo ""

    exit $E_USAGE  # End here. Don't process anything else.
}



list_func() #  Gives the user the option to use the -i option to wget,
            #+ and a list of URLs.
{
while [ 1 ]; do
   echo "Enter the name of the file containing URL's (press q to change
your mind)."
   read urlfile
   if [ ! -e "$urlfile" ] && [ "$urlfile" != q ]; then
       # Look for a file, or the quit option.
       echo "That file does not exist!"
   elif [ "$urlfile" = q ]; then # Check quit option.
       echo "Not using a url list."
       return
   else
      echo "using $urlfile."
      echo "If you gave url's on the command-line, I'll use those first."
                            # Report wget standard behaviour to the user.
      lister=" -i $urlfile" # This is what we want to pass to wget.
      return
   fi
done
}


cookie_func() # Give the user the option to use a different cookie file.
{
while [ 1 ]; do
   echo "Change the cookies file. Press return if you don't want to change 
it."
   read Cookies
   # NB: this is not the same as Cookie, earlier.
   # There is an 's' on the end.
   # Bit like chocolate chips.
   if [ -z "$Cookies" ]; then                 # Escape clause for wusses.
      return
   elif [ ! -e "$Cookies" ]; then
      echo "File does not exist.  Try again." # Keep em going . . .
   else
       CookiesON=" --load-cookies $Cookies"   # File is good -- use it!
       return
   fi
done
}



run_func()
{
if [ -z "$OPTARG" ]; then
# Test to see if we used the in-line option or the query one.
   if [ ! -d "$savePath" ]; then      # If directory doesn't exist . . .
      echo "$savePath does not appear to exist."
      echo "Please supply path and filename of saved wget commands:"
      read newFile
         until [ -f "$newFile" ]; do  # Keep going till we get something.
            echo "Sorry, that file does not exist.  Please try again."
            # Try really hard to get something.
            read newFile
         done


# -----------------------------------------------------------------------
#       if [ -z ( grep wget ${newfile} ) ]; then
        # Assume they haven't got the right file and bail out.
#       echo "Sorry, that file does not contain wget commands.  Aborting."
#       exit
#       fi
#
# This is bogus code.
# It doesn't actually work.
# If anyone wants to fix it, feel free!
# -----------------------------------------------------------------------


      filePath="${newFile}"
   else
   echo "Save path is $savePath"
     echo "Please enter name of the file which you want to use."
     echo "You have a choice of:"
     ls $savePath                                    # Give them a choice.
     read inFile
       until [ -f "$savePath/$inFile" ]; do         #  Keep going till
                                                    #+ we get something.
          if [ ! -f "${savePath}/${inFile}" ]; then # If file doesn't exist.
             echo "Sorry, that file does not exist.  Please choose from:"
             ls $savePath                           # If a mistake is made.
             read inFile
          fi
         done
      filePath="${savePath}/${inFile}"  # Make one variable . . .
   fi
else filePath="${savePath}/${OPTARG}"   # Which can be many things . . .
fi

if [ ! -f "$filePath" ]; then           # If a bogus file got through.
   echo "You did not specify a suitable file."
   echo "Run this script with the -${save} option first."
   echo "Aborting."
   exit $E_NO_SAVEFILE
fi
echo "Using: $filePath"
while read; do
    eval $REPLY
    echo "Completed: $REPLY"
done < $filePath  # Feed the actual file we are using into a 'while' loop.

exit
}



# Fish out any options we are using for the script.
# This is based on the demo in "Learning The Bash Shell" (O'Reilly).
while getopts ":$save$cook$help$list$runn:$inpu$wopt" opt
do
  case $opt in
     $save) save_func;;   #  Save some wgetter sessions for later.
     $cook) cookie_func;; #  Change cookie file.
     $help) usage;;       #  Get help.
     $list) list_func;;   #  Allow wget to use a list of URLs.
     $runn) run_func;;    #  Useful if you are calling wgetter from,
                          #+ for example, a cron script.
     $inpu) run_func;;    #  When you don't know what your files are named.
     $wopt) wopts;;       #  Pass options directly to wget.
        \?) echo "Not a valid option."
            echo "Use -${wopt} to pass options directly to wget,"
            echo "or -${help} for help";;      # Catch anything else.
  esac
done
shift $((OPTIND - 1))     # Do funky magic stuff with $#.


if [ -z "$1" ] && [ -z "$lister" ]; then
                          #  We should be left with at least one URL
                          #+ on the command-line, unless a list is 
			  #+ being used -- catch empty CL's.
   echo "No URL's given! You must enter them on the same line as wgetter2."
   echo "E.g.,  wgetter2 http://somesite http://anothersite."
   echo "Use $help option for more information."
   exit $E_NO_URLS        # Bail out, with appropriate error code.
fi

URLS=" $@"
# Use this so that URL list can be changed if we stay in the option loop.

while [ 1 ]; do
   # This is where we ask for the most used options.
   # (Mostly unchanged from version 1 of wgetter)
   if [ -z $curDepth ]; then
      Current=""
   else Current=" Current value is $curDepth"
   fi
       echo "How deep should I go? \
(integer: Default is $depthDefault.$Current)"
       read Depth   # Recursion -- how far should we go?
       inputB=""    # Reset this to blank on each pass of the loop.
       echo "Enter the name of the referring page (default is none)."
       read inputB  # Need this for some sites.

       echo "Do you want to have the output logged to the terminal"
       echo "(y/n, default is yes)?"
       read noHide  # Otherwise wget will just log it to a file.

       case $noHide in    # Now you see me, now you don't.
          y|Y ) hide="";;
          n|N ) hide=" -b";;
            * ) hide="";;
       esac

       if [ -z ${Depth} ]; then
       #  User accepted either default or current depth,
       #+ in which case Depth is now empty.
          if [ -z ${curDepth} ]; then
          #  See if a depth was set on a previous iteration.
             Depth="$depthDefault"
             #  Set the default recursion depth if nothing
             #+ else to use.
          else Depth="$curDepth" #  Otherwise, set the one we used before.
          fi
       fi
   Recurse=" -l $Depth"          # Set how deep we want to go.
   curDepth=$Depth               # Remember setting for next time.

       if [ ! -z $inputB ]; then
          RefA=" --referer=$inputB"   # Option to use referring page.
       fi

   WGETTER="${CommandA}${pattern}${hide}${RefA}${Recurse}\
${CookiesON}${lister}${Woptions}${URLS}"
   #  Just string the whole lot together . . .
   #  NB: no embedded spaces.
   #  They are in the individual elements so that if any are empty,
   #+ we don't get an extra space.

   if [ -z "${CookiesON}" ] && [ "$cFlag" = "1" ] ; then
       echo "Warning -- can't find cookie file"
       #  This should be changed,
       #+ in case the user has opted to not use cookies.
   fi

   if [ "$Flag" = "S" ]; then
      echo "$WGETTER" >> $savePath/wget-${today}
      #  Create a unique filename for today, or append to it if it exists.
      echo "$inputB" >> $savePath/site-list-${today}
      #  Make a list, so it's easy to refer back to,
      #+ since the whole command is a bit confusing to look at.
      echo "Command saved to the file $savePath/wget-${today}"
           # Tell the user.
      echo "Referring page URL saved to the file$ \
savePath/site-list-${today}"
           # Tell the user.
      Saver=" with save option"
      # Stick this somewhere, so it appears in the loop if set.
   else
       echo "*****************"
       echo "*****Getting*****"
       echo "*****************"
       echo ""
       echo "$WGETTER"
       echo ""
       echo "*****************"
       eval "$WGETTER"
   fi

       echo ""
       echo "Starting over$Saver."
       echo "If you want to stop, press q."
       echo "Otherwise, enter some URL's:"
       # Let them go again. Tell about save option being set.

       read
       case $REPLY in
       # Need to change this to a 'trap' clause.
          q|Q ) exit $E_USER_EXIT;;  # Exercise for the reader?
            * ) URLS=" $REPLY";;
       esac

       echo ""
done


exit 0
}

◊anchored-example[#:anchor "podca1"]{A podcasting script}

◊example{
#!/bin/bash

#  bashpodder.sh:
#  By Linc 10/1/2004
#  Find the latest script at
#+ http://linc.homeunix.org:8080/scripts/bashpodder
#  Last revision 12/14/2004 - Many Contributors!
#  If you use this and have made improvements or have comments
#+ drop me an email at linc dot fessenden at gmail dot com
#  I'd appreciate it!

# ==>  ABS Guide extra comments.

# ==>  Author of this script has kindly granted permission
# ==>+ for inclusion in ABS Guide.


# ==> ################################################################
# 
# ==> What is "podcasting"?

# ==> It's broadcasting "radio shows" over the Internet.
# ==> These shows can be played on iPods and other music file players.

# ==> This script makes it possible.
# ==> See documentation at the script author's site, above.

# ==> ################################################################


# Make script crontab friendly:
cd $(dirname $0)
# ==> Change to directory where this script lives.

# datadir is the directory you want podcasts saved to:
datadir=$(date +%Y-%m-%d)
# ==> Will create a date-labeled directory, named: YYYY-MM-DD

# Check for and create datadir if necessary:
if test ! -d $datadir
        then
        mkdir $datadir
fi

# Delete any temp file:
rm -f temp.log

#  Read the bp.conf file and wget any url not already
#+ in the podcast.log file:
while read podcast
  do # ==> Main action follows.
  file=$(wget -q $podcast -O - | tr '\r' '\n' | tr \' \" | \
sed -n 's/.*url="\([^"]*\)".*/\1/p')
  for url in $file
                do
                echo $url >> temp.log
                if ! grep "$url" podcast.log > /dev/null
                        then
                        wget -q -P $datadir "$url"
                fi
                done
    done < bp.conf

# Move dynamically created log file to permanent log file:
cat podcast.log >> temp.log
sort temp.log | uniq > podcast.log
rm temp.log
# Create an m3u playlist:
ls $datadir | grep -v m3u > $datadir/podcast.m3u


exit 0

#################################################
For a different scripting approach to Podcasting,
see Phil Salkie's article, 
"Internet Radio to Podcast with Shell Tools"
in the September, 2005 issue of LINUX JOURNAL,
http://www.linuxjournal.com/article/8171
#################################################
}

◊anchored-example[#:anchor "bak1"]{Nightly backup to a firewire HD}

◊example{
#!/bin/bash
# nightly-backup.sh
# http://www.richardneill.org/source.php#nightly-backup-rsync
# Copyright (c) 2005 Richard Neill <backup@richardneill.org>.
# This is Free Software licensed under the GNU GPL.
# ==> Included in ABS Guide with script author's kind permission.
# ==> (Thanks!)

#  This does a backup from the host computer to a locally connected
#+ firewire HDD using rsync and ssh.
#  (Script should work with USB-connected device (see lines 40-43).
#  It then rotates the backups.
#  Run it via cron every night at 5am.
#  This only backs up the home directory.
#  If ownerships (other than the user's) should be preserved,
#+ then run the rsync process as root (and re-instate the -o).
#  We save every day for 7 days, then every week for 4 weeks,
#+ then every month for 3 months.

#  See: http://www.mikerubel.org/computers/rsync_snapshots/
#+ for more explanation of the theory.
#  Save as: $HOME/bin/nightly-backup_firewire-hdd.sh

#  Known bugs:
#  ----------
#  i)  Ideally, we want to exclude ~/.tmp and the browser caches.

#  ii) If the user is sitting at the computer at 5am,
#+     and files are modified while the rsync is occurring,
#+     then the BACKUP_JUSTINCASE branch gets triggered.
#      To some extent, this is a 
#+     feature, but it also causes a "disk-space leak".





##### BEGIN CONFIGURATION SECTION ############################################
LOCAL_USER=rjn                # User whose home directory should be backed up.
MOUNT_POINT=/backup           # Mountpoint of backup drive.
                              # NO trailing slash!
                              # This must be unique (eg using a udev symlink)
# MOUNT_POINT=/media/disk     # For USB-connected device.
SOURCE_DIR=/home/$LOCAL_USER  # NO trailing slash - it DOES matter to rsync.
BACKUP_DEST_DIR=$MOUNT_POINT/backup/`hostname -s`.${LOCAL_USER}.nightly_backup
DRY_RUN=false                 #If true, invoke rsync with -n, to do a dry run.
                              # Comment out or set to false for normal use.
VERBOSE=false                 # If true, make rsync verbose.
                              # Comment out or set to false otherwise.
COMPRESS=false                # If true, compress.
                              # Good for internet, bad on LAN.
                              # Comment out or set to false otherwise.

### Exit Codes ###
E_VARS_NOT_SET=64
E_COMMANDLINE=65
E_MOUNT_FAIL=70
E_NOSOURCEDIR=71
E_UNMOUNTED=72
E_BACKUP=73
##### END CONFIGURATION SECTION ##############################################


# Check that all the important variables have been set:
if [ -z "$LOCAL_USER" ] ||
   [ -z "$SOURCE_DIR" ] ||
   [ -z "$MOUNT_POINT" ]  ||
   [ -z "$BACKUP_DEST_DIR" ]
then
   echo 'One of the variables is not set! Edit the file: $0. BACKUP FAILED.'
   exit $E_VARS_NOT_SET
fi

if [ "$#" != 0 ]  # If command-line param(s) . . .
then              # Here document(ation).
  cat <<-ENDOFTEXT
    Automatic Nightly backup run from cron.
    Read the source for more details: $0
    The backup directory is $BACKUP_DEST_DIR .
    It will be created if necessary; initialisation is no longer required.

    WARNING: Contents of $BACKUP_DEST_DIR are rotated.
    Directories named 'backup.\$i' will eventually be DELETED.
    We keep backups from every day for 7 days (1-8),
    then every week for 4 weeks (9-12),
    then every month for 3 months (13-15).

    You may wish to add this to your crontab using 'crontab -e'
    #  Back up files: $SOURCE_DIR to $BACKUP_DEST_DIR
    #+ every night at 3:15 am
         15 03 * * * /home/$LOCAL_USER/bin/nightly-backup_firewire-hdd.sh

    Don't forget to verify the backups are working,
    especially if you don't read cron's mail!"
	ENDOFTEXT
   exit $E_COMMANDLINE
fi


# Parse the options.
# ==================

if [ "$DRY_RUN" == "true" ]; then
  DRY_RUN="-n"
  echo "WARNING:"
  echo "THIS IS A 'DRY RUN'!"
  echo "No data will actually be transferred!"
else
  DRY_RUN=""
fi

if [ "$VERBOSE" == "true" ]; then
  VERBOSE="-v"
else
  VERBOSE=""
fi

if [ "$COMPRESS" == "true" ]; then
  COMPRESS="-z"
else
  COMPRESS=""
fi


#  Every week (actually of 8 days) and every month,
#+ extra backups are preserved.
DAY_OF_MONTH=`date +%d`            # Day of month (01..31).
if [ $DAY_OF_MONTH = 01 ]; then    # First of month.
  MONTHSTART=true
elif [ $DAY_OF_MONTH = 08 \
    -o $DAY_OF_MONTH = 16 \
    -o $DAY_OF_MONTH = 24 ]; then
    # Day 8,16,24  (use 8, not 7 to better handle 31-day months)
      WEEKSTART=true
fi



#  Check that the HDD is mounted.
#  At least, check that *something* is mounted here!
#  We can use something unique to the device, rather than just guessing
#+ the scsi-id by having an appropriate udev rule in
#+ /etc/udev/rules.d/10-rules.local
#+ and by putting a relevant entry in /etc/fstab.
#  Eg: this udev rule:
# BUS="scsi", KERNEL="sd*", SYSFS{vendor}="WDC WD16",
# SYSFS{model}="00JB-00GVA0     ", NAME="%k", SYMLINK="lacie_1394d%n"

if mount | grep $MOUNT_POINT >/dev/null; then
  echo "Mount point $MOUNT_POINT is indeed mounted. OK"
else
  echo -n "Attempting to mount $MOUNT_POINT..."	
           # If it isn't mounted, try to mount it.
  sudo mount $MOUNT_POINT 2>/dev/null

  if mount | grep $MOUNT_POINT >/dev/null; then
    UNMOUNT_LATER=TRUE
    echo "OK"
    #  Note: Ensure that this is also unmounted
    #+ if we exit prematurely with failure.
  else
    echo "FAILED"
    echo -e "Nothing is mounted at $MOUNT_POINT. BACKUP FAILED!"
    exit $E_MOUNT_FAIL
  fi
fi


# Check that source dir exists and is readable.
if [ ! -r  $SOURCE_DIR ] ; then
  echo "$SOURCE_DIR does not exist, or cannot be read. BACKUP FAILED."
  exit $E_NOSOURCEDIR
fi


# Check that the backup directory structure is as it should be.
# If not, create it.
# Create the subdirectories.
# Note that backup.0 will be created as needed by rsync.

for ((i=1;i<=15;i++)); do
  if [ ! -d $BACKUP_DEST_DIR/backup.$i ]; then
    if /bin/mkdir -p $BACKUP_DEST_DIR/backup.$i ; then
    #  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  No [ ] test brackets. Why?
      echo "Warning: directory $BACKUP_DEST_DIR/backup.$i is missing,"
      echo "or was not initialised. (Re-)creating it."
    else
      echo "ERROR: directory $BACKUP_DEST_DIR/backup.$i"
      echo "is missing and could not be created."
    if  [ "$UNMOUNT_LATER" == "TRUE" ]; then
        # Before we exit, unmount the mount point if necessary.
        cd
	sudo umount $MOUNT_POINT &&
	echo "Unmounted $MOUNT_POINT again. Giving up."
    fi
      exit $E_UNMOUNTED
  fi
fi
done


#  Set the permission to 700 for security
#+ on an otherwise permissive multi-user system.
if ! /bin/chmod 700 $BACKUP_DEST_DIR ; then
  echo "ERROR: Could not set permissions on $BACKUP_DEST_DIR to 700."

  if  [ "$UNMOUNT_LATER" == "TRUE" ]; then
  # Before we exit, unmount the mount point if necessary.
     cd ; sudo umount $MOUNT_POINT \
     && echo "Unmounted $MOUNT_POINT again. Giving up."
  fi

  exit $E_UNMOUNTED
fi

# Create the symlink: current -> backup.1 if required.
# A failure here is not critical.
cd $BACKUP_DEST_DIR
if [ ! -h current ] ; then
  if ! /bin/ln -s backup.1 current ; then
    echo "WARNING: could not create symlink current -> backup.1"
  fi
fi


# Now, do the rsync.
echo "Now doing backup with rsync..."
echo "Source dir: $SOURCE_DIR"
echo -e "Backup destination dir: $BACKUP_DEST_DIR\n"


/usr/bin/rsync $DRY_RUN $VERBOSE -a -S --delete --modify-window=60 \
--link-dest=../backup.1 $SOURCE_DIR $BACKUP_DEST_DIR/backup.0/

#  Only warn, rather than exit if the rsync failed,
#+ since it may only be a minor problem.
#  E.g., if one file is not readable, rsync will fail.
#  This shouldn't prevent the rotation.
#  Not using, e.g., `date +%a`  since these directories
#+ are just full of links and don't consume *that much* space.

if [ $? != 0 ]; then
  BACKUP_JUSTINCASE=backup.`date +%F_%T`.justincase
  echo "WARNING: the rsync process did not entirely succeed."
  echo "Something might be wrong."
  echo "Saving an extra copy at: $BACKUP_JUSTINCASE"
  echo "WARNING: if this occurs regularly, a LOT of space will be consumed,"
  echo "even though these are just hard-links!"
fi

# Save a readme in the backup parent directory.
# Save another one in the recent subdirectory.
echo "Backup of $SOURCE_DIR on `hostname` was last run on \
`date`" > $BACKUP_DEST_DIR/README.txt
echo "This backup of $SOURCE_DIR on `hostname` was created on \
`date`" > $BACKUP_DEST_DIR/backup.0/README.txt

# If we are not in a dry run, rotate the backups.
[ -z "$DRY_RUN" ] &&

  #  Check how full the backup disk is.
  #  Warn if 90%. if 98% or more, we'll probably fail, so give up.
  #  (Note: df can output to more than one line.)
  #  We test this here, rather than before
  #+ so that rsync may possibly have a chance.
  DISK_FULL_PERCENT=`/bin/df $BACKUP_DEST_DIR |
  tr "\n" ' ' | awk '{print $12}' | grep -oE [0-9]+ `
  echo "Disk space check on backup partition \
  $MOUNT_POINT $DISK_FULL_PERCENT% full."
  if [ $DISK_FULL_PERCENT -gt 90 ]; then
    echo "Warning: Disk is greater than 90% full."
  fi
  if [ $DISK_FULL_PERCENT -gt 98 ]; then
    echo "Error: Disk is full! Giving up."
      if  [ "$UNMOUNT_LATER" == "TRUE" ]; then
        # Before we exit, unmount the mount point if necessary.
        cd; sudo umount $MOUNT_POINT &&
        echo "Unmounted $MOUNT_POINT again. Giving up."
      fi
    exit $E_UNMOUNTED
  fi


 # Create an extra backup.
 # If this copy fails, give up.
 if [ -n "$BACKUP_JUSTINCASE" ]; then
   if ! /bin/cp -al $BACKUP_DEST_DIR/backup.0 \
      $BACKUP_DEST_DIR/$BACKUP_JUSTINCASE
   then
     echo "ERROR: Failed to create extra copy \
     $BACKUP_DEST_DIR/$BACKUP_JUSTINCASE"
     if  [ "$UNMOUNT_LATER" == "TRUE" ]; then
       # Before we exit, unmount the mount point if necessary.
       cd ;sudo umount $MOUNT_POINT &&
       echo "Unmounted $MOUNT_POINT again. Giving up."
     fi
     exit $E_UNMOUNTED
   fi
 fi


 # At start of month, rotate the oldest 8.
 if [ "$MONTHSTART" == "true" ]; then
   echo -e "\nStart of month. \
   Removing oldest backup: $BACKUP_DEST_DIR/backup.15"  &&
   /bin/rm -rf  $BACKUP_DEST_DIR/backup.15  &&
   echo "Rotating monthly,weekly backups: \
   $BACKUP_DEST_DIR/backup.[8-14] -> $BACKUP_DEST_DIR/backup.[9-15]"  &&
     /bin/mv $BACKUP_DEST_DIR/backup.14 $BACKUP_DEST_DIR/backup.15  &&
     /bin/mv $BACKUP_DEST_DIR/backup.13 $BACKUP_DEST_DIR/backup.14  &&
     /bin/mv $BACKUP_DEST_DIR/backup.12 $BACKUP_DEST_DIR/backup.13  &&
     /bin/mv $BACKUP_DEST_DIR/backup.11 $BACKUP_DEST_DIR/backup.12  &&
     /bin/mv $BACKUP_DEST_DIR/backup.10 $BACKUP_DEST_DIR/backup.11  &&
     /bin/mv $BACKUP_DEST_DIR/backup.9 $BACKUP_DEST_DIR/backup.10  &&
     /bin/mv $BACKUP_DEST_DIR/backup.8 $BACKUP_DEST_DIR/backup.9

 # At start of week, rotate the second-oldest 4.
 elif [ "$WEEKSTART" == "true" ]; then
   echo -e "\nStart of week. \
   Removing oldest weekly backup: $BACKUP_DEST_DIR/backup.12"  &&
   /bin/rm -rf  $BACKUP_DEST_DIR/backup.12  &&

   echo "Rotating weekly backups: \
   $BACKUP_DEST_DIR/backup.[8-11] -> $BACKUP_DEST_DIR/backup.[9-12]"  &&
     /bin/mv $BACKUP_DEST_DIR/backup.11 $BACKUP_DEST_DIR/backup.12  &&
     /bin/mv $BACKUP_DEST_DIR/backup.10 $BACKUP_DEST_DIR/backup.11  &&
     /bin/mv $BACKUP_DEST_DIR/backup.9 $BACKUP_DEST_DIR/backup.10  &&
     /bin/mv $BACKUP_DEST_DIR/backup.8 $BACKUP_DEST_DIR/backup.9

 else
   echo -e "\nRemoving oldest daily backup: $BACKUP_DEST_DIR/backup.8"  &&
     /bin/rm -rf  $BACKUP_DEST_DIR/backup.8

 fi  &&

 # Every day, rotate the newest 8.
 echo "Rotating daily backups: \
 $BACKUP_DEST_DIR/backup.[1-7] -> $BACKUP_DEST_DIR/backup.[2-8]"  &&
     /bin/mv $BACKUP_DEST_DIR/backup.7 $BACKUP_DEST_DIR/backup.8  &&
     /bin/mv $BACKUP_DEST_DIR/backup.6 $BACKUP_DEST_DIR/backup.7  &&
     /bin/mv $BACKUP_DEST_DIR/backup.5 $BACKUP_DEST_DIR/backup.6  &&
     /bin/mv $BACKUP_DEST_DIR/backup.4 $BACKUP_DEST_DIR/backup.5  &&
     /bin/mv $BACKUP_DEST_DIR/backup.3 $BACKUP_DEST_DIR/backup.4  &&
     /bin/mv $BACKUP_DEST_DIR/backup.2 $BACKUP_DEST_DIR/backup.3  &&
     /bin/mv $BACKUP_DEST_DIR/backup.1 $BACKUP_DEST_DIR/backup.2  &&
     /bin/mv $BACKUP_DEST_DIR/backup.0 $BACKUP_DEST_DIR/backup.1  &&

 SUCCESS=true


if  [ "$UNMOUNT_LATER" == "TRUE" ]; then
  # Unmount the mount point if it wasn't mounted to begin with.
  cd ; sudo umount $MOUNT_POINT && echo "Unmounted $MOUNT_POINT again."
fi


if [ "$SUCCESS" == "true" ]; then
  echo 'SUCCESS!'
  exit 0
fi

# Should have already exited if backup worked.
echo 'BACKUP FAILED! Is this just a dry run? Is the disk full?) '
exit $E_BACKUP
}

