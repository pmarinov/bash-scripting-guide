#lang pollen

◊; This is free software released into the public domain
◊; See LICENSE.txt

◊page-init{}
◊define-meta[page-title]{Math}
◊define-meta[page-description]{Math Commands}

◊section{"Doing the numbers"}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "factor"]{
Decompose an integer into prime factors.

◊example{
bash$ factor 27417
27417: 3 13 19 37

}

◊anchored-example[#:anchor "factor_genprime1"]{Generating prime numbers}

◊example{
#!/bin/bash
# primes2.sh

#  Generating prime numbers the quick-and-easy way,
#+ without resorting to fancy algorithms.

CEILING=10000   # 1 to 10000
PRIME=0
E_NOTPRIME=

is_prime ()
{
  local factors
  factors=( $(factor $1) )  # Load output of `factor` into array.

if [ -z "${factors[2]}" ]
#  Third element of "factors" array:
#+ ${factors[2]} is 2nd factor of argument.
#  If it is blank, then there is no 2nd factor,
#+ and the argument is therefore prime.
then
  return $PRIME             # 0
else
  return $E_NOTPRIME        # null
fi
}

echo
for n in $(seq $CEILING)
do
  if is_prime $n
  then
    printf %5d $n
  fi   #    ^  Five positions per number suffices.
done   #       For a higher $CEILING, adjust upward, as necessary.

echo

exit
}

}

◊definition-entry[#:name "bc"]{
Bash can't handle floating point calculations, and it lacks operators
for certain important mathematical functions. Fortunately,
◊command{bc} gallops to the rescue.

Not just a versatile, arbitrary precision calculation utility,
◊command{bc} offers many of the facilities of a programming
language. It has a syntax vaguely resembling ◊code{C}.

Since it is a fairly well-behaved UNIX utility, and may therefore be
used in a pipe, ◊command{bc} comes in handy in scripts.

Here is a simple template for using ◊command{bc} to calculate a script
variable. This uses command substitution.

◊example{
variable=$(echo "OPTIONS; OPERATIONS" | bc)
}

◊anchored-example[#:anchor "bc_mortg1"]{Monthly Payment on a Mortgage}

◊example{
#!/bin/bash
# monthlypmt.sh: Calculates monthly payment on a mortgage.


#  This is a modification of code in the
#+ "mcalc" (mortgage calculator) package,
#+ by Jeff Schmidt
#+ and
#+ Mendel Cooper (yours truly, the ABS Guide author).
#   http://www.ibiblio.org/pub/Linux/apps/financial/mcalc-1.6.tar.gz

echo
echo "Given the principal, interest rate, and term of a mortgage,"
echo "calculate the monthly payment."

bottom=1.0

echo
echo -n "Enter principal (no commas) "
read principal
echo -n "Enter interest rate (percent) "  # If 12%, enter "12", not ".12".
read interest_r
echo -n "Enter term (months) "
read term


interest_r=$(echo "scale=9; $interest_r/100.0" | bc) # Convert to decimal.
                #           ^^^^^^^^^^^^^^^^^  Divide by 100. 
                # "scale" determines how many decimal places.

interest_rate=$(echo "scale=9; $interest_r/12 + 1.0" | bc)


top=$(echo "scale=9; $principal*$interest_rate^$term" | bc)
         #           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
         #           Standard formula for figuring interest.

echo; echo "Please be patient. This may take a while."

let "months = $term - 1"
# ==================================================================== 
for ((x=$months; x > 0; x--))
do
  bot=$(echo "scale=9; $interest_rate^$x" | bc)
  bottom=$(echo "scale=9; $bottom+$bot" | bc)
#  bottom = $(($bottom + $bot"))
done
# ==================================================================== 

# -------------------------------------------------------------------- 
#  Rick Boivie pointed out a more efficient implementation
#+ of the above loop, which decreases computation time by 2/3.

# for ((x=1; x <= $months; x++))
# do
#   bottom=$(echo "scale=9; $bottom * $interest_rate + 1" | bc)
# done


#  And then he came up with an even more efficient alternative,
#+ one that cuts down the run time by about 95%!

# bottom=`{
#     echo "scale=9; bottom=$bottom; interest_rate=$interest_rate"
#     for ((x=1; x <= $months; x++))
#     do
#          echo 'bottom = bottom * interest_rate + 1'
#     done
#     echo 'bottom'
#     } | bc`       # Embeds a 'for loop' within command substitution.
# --------------------------------------------------------------------------
#  On the other hand, Frank Wang suggests:
#  bottom=$(echo "scale=9; ($interest_rate^$term-1)/($interest_rate-1)" | bc)

#  Because . . .
#  The algorithm behind the loop
#+ is actually a sum of geometric proportion series.
#  The sum formula is e0(1-q^n)/(1-q),
#+ where e0 is the first element and q=e(n+1)/e(n)
#+ and n is the number of elements.
# --------------------------------------------------------------------------


# let "payment = $top/$bottom"
payment=$(echo "scale=2; $top/$bottom" | bc)
# Use two decimal places for dollars and cents.

echo
echo "monthly payment = \$$payment"  # Echo a dollar sign in front of amount.
echo


exit 0


# Exercises:
#   1) Filter input to permit commas in principal amount.
#   2) Filter input to permit interest to be entered as percent or decimal.
#   3) If you are really ambitious,
#+     expand this script to print complete amortization tables.
}

◊anchored-example[#:anchor "bc_base_conv1"]{Base Conversion}

◊example{
#!/bin/bash
###########################################################################
# Shellscript:	base.sh - print number to different bases (Bourne Shell)
# Author     :	Heiner Steven (heiner.steven@odn.de)
# Date       :	07-03-95
# Category   :	Desktop
# $Id: base.sh,v 1.2 2000/02/06 19:55:35 heiner Exp $
# ==> Above line is RCS ID info.
###########################################################################
# Description
#
# Changes
# 21-03-95 stv	fixed error occuring with 0xb as input (0.2)
###########################################################################

# ==> Used in ABS Guide with the script author's permission.
# ==> Comments added by ABS Guide author.

NOARGS=85
PN=`basename "$0"`			       # Program name
VER=`echo '$Revision: 1.2 $' | cut -d' ' -f2`  # ==> VER=1.2

Usage () {
    echo "$PN - print number to different bases, $VER (stv '95)
usage: $PN [number ...]

If no number is given, the numbers are read from standard input.
A number may be
    binary (base 2)		starting with 0b (i.e. 0b1100)
    octal (base 8)		starting with 0  (i.e. 014)
    hexadecimal (base 16)	starting with 0x (i.e. 0xc)
    decimal			otherwise (i.e. 12)" >&2
    exit $NOARGS 
}   # ==> Prints usage message.

Msg () {
    for i   # ==> in [list] missing. Why?
    do echo "$PN: $i" >&2
    done
}

Fatal () { Msg "$@"; exit 66; }

PrintBases () {
    # Determine base of the number
    for i      # ==> in [list] missing...
    do         # ==> so operates on command-line arg(s).
	case "$i" in
	    0b*)		ibase=2;;	# binary
	    0x*|[a-f]*|[A-F]*)	ibase=16;;	# hexadecimal
	    0*)			ibase=8;;	# octal
	    [1-9]*)		ibase=10;;	# decimal
	    *)
		Msg "illegal number $i - ignored"
		continue;;
	esac

	# Remove prefix, convert hex digits to uppercase (bc needs this).
	number=`echo "$i" | sed -e 's:^0[bBxX]::' | tr '[a-f]' '[A-F]'`
	# ==> Uses ":" as sed separator, rather than "/".

	# Convert number to decimal
	dec=`echo "ibase=$ibase; $number" | bc`  # ==> 'bc' is calculator utility.
	case "$dec" in
	    [0-9]*)	;;			 # number ok
	    *)		continue;;		 # error: ignore
	esac

	# Print all conversions in one line.
	# ==> 'here document' feeds command list to 'bc'.
	echo `bc <<!
	    obase=16; "hex="; $dec
	    obase=10; "dec="; $dec
	    obase=8;  "oct="; $dec
	    obase=2;  "bin="; $dec
!
    ` | sed -e 's: :	:g'

    done
}

while [ $# -gt 0 ]
# ==>  Is a "while loop" really necessary here,
# ==>+ since all the cases either break out of the loop
# ==>+ or terminate the script.
# ==> (Above comment by Paulo Marcel Coelho Aragao.)
do
    case "$1" in
	--)     shift; break;;
	-h)     Usage;;                 # ==> Help message.
	-*)     Usage;;
     *)     break;;                 # First number
    esac   # ==> Error checking for illegal input might be appropriate.
    shift
done

if [ $# -gt 0 ]
then
    PrintBases "$@"
else					# Read from stdin.
    while read line
    do
	PrintBases $line
    done
fi


exit
}

An alternate method of invoking ◊command{bc} involves using a here
document embedded within a command substitution block. This is
especially appropriate when a script needs to pass a list of options
and commands to ◊command{bc}.

◊example{
variable=`bc << LIMIT_STRING
options
statements
operations
LIMIT_STRING
`

...or...


variable=$(bc << LIMIT_STRING
options
statements
operations
LIMIT_STRING
)

}

◊anchored-example[#:anchor "bc_heredoc1"]{Invoking bc using a here
document}

◊example{
#!/bin/bash
# Invoking 'bc' using command substitution
# in combination with a 'here document'.


var1=`bc << EOF
18.33 * 19.78
EOF
`
echo $var1       # 362.56


#  $( ... ) notation also works.
v1=23.53
v2=17.881
v3=83.501
v4=171.63

var2=$(bc << EOF
scale = 4
a = ( $v1 + $v2 )
b = ( $v3 * $v4 )
a * b + 15.35
EOF
)
echo $var2       # 593487.8452


var3=$(bc -l << EOF
scale = 9
s ( 1.7 )
EOF
)
# Returns the sine of 1.7 radians.
# The "-l" option calls the 'bc' math library.
echo $var3       # .991664810


# Now, try it in a function...
hypotenuse ()    # Calculate hypotenuse of a right triangle.
{                # c = sqrt( a^2 + b^2 )
hyp=$(bc -l << EOF
scale = 9
sqrt ( $1 * $1 + $2 * $2 )
EOF
)
# Can't directly return floating point values from a Bash function.
# But, can echo-and-capture:
echo "$hyp"
}

hyp=$(hypotenuse 3.68 7.31)
echo "hypotenuse = $hyp"    # 8.184039344


exit 0
}

◊anchored-example[#:anchor "bc_calcpi1"]{Calculating PI}

◊example{
#!/bin/bash
# cannon.sh: Approximating PI by firing cannonballs.

# Author: Mendel Cooper
# License: Public Domain
# Version 2.2, reldate 13oct08.

# This is a very simple instance of a "Monte Carlo" simulation:
#+ a mathematical model of a real-life event,
#+ using pseudorandom numbers to emulate random chance.

#  Consider a perfectly square plot of land, 10000 units on a side.
#  This land has a perfectly circular lake in its center,
#+ with a diameter of 10000 units.
#  The plot is actually mostly water, except for land in the four corners.
#  (Think of it as a square with an inscribed circle.)
#
#  We will fire iron cannonballs from an old-style cannon
#+ at the square.
#  All the shots impact somewhere on the square,
#+ either in the lake or on the dry corners.
#  Since the lake takes up most of the area,
#+ most of the shots will SPLASH! into the water.
#  Just a few shots will THUD! into solid ground
#+ in the four corners of the square.
#
#  If we take enough random, unaimed shots at the square,
#+ Then the ratio of SPLASHES to total shots will approximate
#+ the value of PI/4.
#
#  The simplified explanation is that the cannon is actually
#+ shooting only at the upper right-hand quadrant of the square,
#+ i.e., Quadrant I of the Cartesian coordinate plane.
#
#
#  Theoretically, the more shots taken, the better the fit.
#  However, a shell script, as opposed to a compiled language
#+ with floating-point math built in, requires some compromises.
#  This decreases the accuracy of the simulation.


DIMENSION=10000  # Length of each side of the plot.
                 # Also sets ceiling for random integers generated.

MAXSHOTS=1000    # Fire this many shots.
                 # 10000 or more would be better, but would take too long.
PMULTIPLIER=4.0  # Scaling factor.

declare -r M_PI=3.141592654
                 # Actual 9-place value of PI, for comparison purposes.

get_random ()
{
SEED=$(head -n 1 /dev/urandom | od -N 1 | awk '{ print $2 }')
RANDOM=$SEED                                  #  From "seeding-random.sh"
                                              #+ example script.
let "rnum = $RANDOM % $DIMENSION"             #  Range less than 10000.
echo $rnum
}

distance=        # Declare global variable.
hypotenuse ()    # Calculate hypotenuse of a right triangle.
{                # From "alt-bc.sh" example.
distance=$(bc -l << EOF
scale = 0
sqrt ( $1 * $1 + $2 * $2 )
EOF
)
#  Setting "scale" to zero rounds down result to integer value,
#+ a necessary compromise in this script.
#  It decreases the accuracy of this simulation.
}


# ==========================================================
# main() {
# "Main" code block, mimicking a C-language main() function.

# Initialize variables.
shots=0
splashes=0
thuds=0
Pi=0
error=0

while [ "$shots" -lt  "$MAXSHOTS" ]           # Main loop.
do

  xCoord=$(get_random)                        # Get random X and Y coords.
  yCoord=$(get_random)
  hypotenuse $xCoord $yCoord                  #  Hypotenuse of
                                              #+ right-triangle = distance.
  ((shots++))

  printf "#%4d   " $shots
  printf "Xc = %4d  " $xCoord
  printf "Yc = %4d  " $yCoord
  printf "Distance = %5d  " $distance         #   Distance from
                                              #+  center of lake
                                              #+  -- the "origin" --
                                              #+  coordinate (0,0).

  if [ "$distance" -le "$DIMENSION" ]
  then
    echo -n "SPLASH!  "
    ((splashes++))
  else
    echo -n "THUD!    "
    ((thuds++))
  fi

  Pi=$(echo "scale=9; $PMULTIPLIER*$splashes/$shots" | bc)
  # Multiply ratio by 4.0.
  echo -n "PI ~ $Pi"
  echo

done

echo
echo "After $shots shots, PI looks like approximately   $Pi"
#  Tends to run a bit high,
#+ possibly due to round-off error and imperfect randomness of $RANDOM.
#  But still usually within plus-or-minus 5% . . .
#+ a pretty fair rough approximation.
error=$(echo "scale=9; $Pi - $M_PI" | bc)
pct_error=$(echo "scale=2; 100.0 * $error / $M_PI" | bc)
echo -n "Deviation from mathematical value of PI =        $error"
echo " ($pct_error% error)"
echo

# End of "main" code block.
# }
# ==========================================================

exit 0

#  One might well wonder whether a shell script is appropriate for
#+ an application as complex and computation-intensive as a simulation.
#
#  There are at least two justifications.
#  1) As a proof of concept: to show it can be done.
#  2) To prototype and test the algorithms before rewriting
#+    it in a compiled high-level language.
}

See also TODO Example A-37.

}

}

