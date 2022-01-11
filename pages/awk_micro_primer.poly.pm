#lang pollen

◊page-init{}
◊define-meta[page-title]{Awk Micro-Primer}
◊define-meta[page-description]{Awk Micro-Primer}

Awk is a full-featured text processing language with a syntax
reminiscent of C. While it possesses an extensive set of operators and
capabilities, we will cover only a few of these here - the ones most
useful in shell scripts. ◊footnote{Its name derives from the initials
of its authors, Aho, Weinberg, and Kernighan.}

Awk breaks each line of input passed to it into fields. By default, a
field is a string of consecutive characters delimited by whitespace,
though there are options for changing this. Awk parses and operates on
each separate field. This makes it ideal for handling structured text
files -- especially tables -- data organized into consistent chunks,
such as rows and columns.

Strong quoting and curly brackets enclose blocks of ◊command{awk} code
within a shell script.

◊example{
# $1 is field #1, $2 is field #2, etc.

echo one two | awk '{print $1}'
# one

echo one two | awk '{print $2}'
# two

# But what is field #0 ($0)?
echo one two | awk '{print $0}'
# one two
# All the fields!


awk '{print $3}' $filename
# Prints field #3 of file $filename to stdout.

awk '{print $1 $5 $6}' $filename
# Prints fields #1, #5, and #6 of file $filename.

awk '{print $0}' $filename
# Prints the entire file!
# Same effect as:   cat $filename . . . or . . . sed '' $filename
}

We have just seen the ◊command{awk} print command in action. The only
other feature of ◊command{awk} we need to deal with here is
variables. Awk handles variables similarly to shell scripts, though a
bit more flexibly.

◊example{
{ total += ${column_number} }
}

This adds the value of ◊ode{column_number} to the running total of
◊code{total}. Finally, to ◊code{print "total"}, there is an ◊code{END}
command block, executed after the script has processed all its input.

◊example{
END { print total }
}

Corresponding to the END, there is a BEGIN, for a code block to be
performed before awk starts processing its input.

◊anchored-example[#:anchor "awk_cnt1"]{Counting Letter Occurrences}

The following example illustrates how awk can add text-parsing tools
to a shell script.

◊example{
#! /bin/sh
# letter-count2.sh: Counting letter occurrences in a text file.
#
# Script by nyal [nyal@voila.fr].
# Used in ABS Guide with permission.
# Recommented and reformatted by ABS Guide author.
# Version 1.1: Modified to work with gawk 3.1.3.
#              (Will still work with earlier versions.)


INIT_TAB_AWK=""
# Parameter to initialize awk script.
count_case=0
FILE_PARSE=$1

E_PARAMERR=85

usage()
{
    echo "Usage: letter-count.sh file letters" 2>&1
    # For example:   ./letter-count2.sh filename.txt a b c
    exit $E_PARAMERR  # Too few arguments passed to script.
}

if [ ! -f "$1" ] ; then
    echo "$1: No such file." 2>&1
    usage                 # Print usage message and exit.
fi 

if [ -z "$2" ] ; then
    echo "$2: No letters specified." 2>&1
    usage
fi 

shift                      # Letters specified.
for letter in `echo $@`    # For each one . . .
  do
  INIT_TAB_AWK="$INIT_TAB_AWK tab_search[${count_case}] = \
  \"$letter\"; final_tab[${count_case}] = 0; " 
  # Pass as parameter to awk script below.
  count_case=`expr $count_case + 1`
done

# DEBUG:
# echo $INIT_TAB_AWK;

cat $FILE_PARSE |
# Pipe the target file to the following awk script.

# ---------------------------------------------------------------------
# Earlier version of script:
# awk -v tab_search=0 -v final_tab=0 -v tab=0 -v \
# nb_letter=0 -v chara=0 -v chara2=0 \

awk \
"BEGIN { $INIT_TAB_AWK } \
{ split(\$0, tab, \"\"); \
for (chara in tab) \
{ for (chara2 in tab_search) \
{ if (tab_search[chara2] == tab[chara]) { final_tab[chara2]++ } } } } \
END { for (chara in final_tab) \
{ print tab_search[chara] \" => \" final_tab[chara] } }"
# ---------------------------------------------------------------------
#  Nothing all that complicated, just . . .
#+ for-loops, if-tests, and a couple of specialized functions.

exit $?

# Compare this script to letter-count.sh.
}
