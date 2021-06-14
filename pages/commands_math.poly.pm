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

}

}

