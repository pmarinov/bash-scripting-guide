#lang pollen

◊page-init{}
◊define-meta[page-title]{Version 4}
◊define-meta[page-description]{Bash, version 4}

◊section{Bash, version 4.0}

Chet Ramey announced Version 4 of Bash on the 20th of February,
2009. This release has a number of significant new features, as well
as some important bugfixes.

Among the new goodies:
◊list-block[#:type "bullet"]{

◊list-entry{Associative arrays.

An associative array can be thought of as a set of two linked arrays
-- one holding the data, and the other the keys that index the
individual elements of the data array.

To be more specific, Bash 4+ has limited support for associative
arrays. It's a bare-bones implementation, and it lacks the much of the
functionality of such arrays in other programming languages. Note,
however, that associative arrays in Bash seem to execute faster and
more efficiently than numerically-indexed arrays.

◊anchored-example[#:anchor "address_b1"]{A simple address database}

◊example{
#!/bin/bash4
# fetch_address.sh

declare -A address
#       -A option declares associative array.

address[Charles]="414 W. 10th Ave., Baltimore, MD 21236"
address[John]="202 E. 3rd St., New York, NY 10009"
address[Wilma]="1854 Vermont Ave, Los Angeles, CA 90023"


echo "Charles's address is ${address[Charles]}."
# Charles's address is 414 W. 10th Ave., Baltimore, MD 21236.
echo "Wilma's address is ${address[Wilma]}."
# Wilma's address is 1854 Vermont Ave, Los Angeles, CA 90023.
echo "John's address is ${address[John]}."
# John's address is 202 E. 3rd St., New York, NY 10009.

echo

echo "${!address[*]}"   # The array indices ...
# Charles John Wilma
}

◊anchored-example[#:anchor "address_b2"]{A somewhat more elaborate
address database}

◊example{
#!/bin/bash4
# fetch_address-2.sh
# A more elaborate version of fetch_address.sh.

SUCCESS=0
E_DB=99    # Error code for missing entry.

declare -A address
#       -A option declares associative array.


store_address ()
{
  address[$1]="$2"
  return $?
}


fetch_address ()
{
  if [[ -z "${address[$1]}" ]]
  then
    echo "$1's address is not in database."
    return $E_DB
  fi

  echo "$1's address is ${address[$1]}."
  return $?
}


store_address "Lucas Fayne" "414 W. 13th Ave., Baltimore, MD 21236"
store_address "Arvid Boyce" "202 E. 3rd St., New York, NY 10009"
store_address "Velma Winston" "1854 Vermont Ave, Los Angeles, CA 90023"
#  Exercise:
#  Rewrite the above store_address calls to read data from a file,
#+ then assign field 1 to name, field 2 to address in the array.
#  Each line in the file would have a format corresponding to the above.
#  Use a while-read loop to read from file, sed or awk to parse the fields.

fetch_address "Lucas Fayne"
# Lucas Fayne's address is 414 W. 13th Ave., Baltimore, MD 21236.
fetch_address "Velma Winston"
# Velma Winston's address is 1854 Vermont Ave, Los Angeles, CA 90023.
fetch_address "Arvid Boyce"
# Arvid Boyce's address is 202 E. 3rd St., New York, NY 10009.
fetch_address "Bozo Bozeman"
# Bozo Bozeman's address is not in database.

exit $?   # In this case, exit code = 99, since that is function return.
}

See TODO Example A-53 for an interesting usage of an associative array.

Caution: Elements of the index array may include embedded space
characters, or even leading and/or trailing space characters. However,
index array elements containing only whitespace are not permitted.

◊example{
address[   ]="Blank"   # Error!

}

}

◊list-entry{Enhancements to the case construct: the ◊code{;;&} and
◊code{;&} terminators.

◊example{
#!/bin/bash4

test_char ()
{
  case "$1" in
    [[:print:]] )  echo "$1 is a printable character.";;&       # |
    # The ;;& terminator continues to the next pattern test.      |
    [[:alnum:]] )  echo "$1 is an alpha/numeric character.";;&  # v
    [[:alpha:]] )  echo "$1 is an alphabetic character.";;&     # v
    [[:lower:]] )  echo "$1 is a lowercase alphabetic character.";;&
    [[:digit:]] )  echo "$1 is an numeric character.";&         # |
    # The ;& terminator executes the next statement ...         # |
    %%%@@@@@    )  echo "********************************";;    # v
#   ^^^^^^^^  ... even with a dummy pattern.
  esac
}

echo

test_char 3
# 3 is a printable character.
# 3 is an alpha/numeric character.
# 3 is an numeric character.
# ********************************
echo

test_char m
# m is a printable character.
# m is an alpha/numeric character.
# m is an alphabetic character.
# m is a lowercase alphabetic character.
echo

test_char /
# / is a printable character.

echo

# The ;;& terminator can save complex if/then conditions.
# The ;& is somewhat less useful.
}

}

◊list-entry{The new ◊command{coproc} builtin enables two parallel
processes to communicate and interact. As Chet Ramey states in the
Bash FAQ, ver. 4.01:

There is a new 'coproc' reserved word that specifies a coprocess: an
asynchronous command run with two pipes connected to the creating
shell. Coprocs can be named. The input and output file descriptors and
the PID of the coprocess are available to the calling shell in
variables with coproc-specific names.

George Dimitriu explains,
"... coproc ... is a feature used in Bash process substitution,
which now is made publicly available."
This means it can be explicitly invoked in a script, rather than
just being a behind-the-scenes mechanism used by Bash.

(Copyright 1995-2009 by Chester Ramey.)

Coprocesses use file descriptors. File descriptors enable processes
and pipes to communicate.

◊example{
#!/bin/bash4
# A coprocess communicates with a while-read loop.


coproc { cat mx_data.txt; sleep 2; }
#                         ^^^^^^^
# Try running this without "sleep 2" and see what happens.

while read -u ${COPROC[0]} line    #  ${COPROC[0]} is the
do                                 #+ file descriptor of the coprocess.
  echo "$line" | sed -e 's/line/NOT-ORIGINAL-TEXT/'
done

kill $COPROC_PID                   #  No longer need the coprocess,
                                   #+ so kill its PID.
}

But, be careful!

◊example{
#!/bin/bash4

echo; echo
a=aaa
b=bbb
c=ccc

coproc echo "one two three"
while read -u ${COPROC[0]} a b c;  #  Note that this loop
do                                 #+ runs in a subshell.
  echo "Inside while-read loop: ";
  echo "a = $a"; echo "b = $b"; echo "c = $c"
  echo "coproc file descriptor: ${COPROC[0]}"
done 

# a = one
# b = two
# c = three
# So far, so good, but ...

echo "-----------------"
echo "Outside while-read loop: "
echo "a = $a"  # a =
echo "b = $b"  # b =
echo "c = $c"  # c =
echo "coproc file descriptor: ${COPROC[0]}"
echo
#  The coproc is still running, but ...
#+ it still doesn't enable the parent process
#+ to "inherit" variables from the child process, the while-read loop.

#  Compare this to the "badread.sh" script.
}

Caution: The coprocess is asynchronous, and this might cause a
problem. It may terminate before another process has finished
communicating with it.

◊example{
#!/bin/bash4

coproc cpname { for i in {0..10}; do echo "index = $i"; done; }
#      ^^^^^^ This is a *named* coprocess.
read -u ${cpname[0]}
echo $REPLY         #  index = 0
echo ${COPROC[0]}   #+ No output ... the coprocess timed out
#  after the first loop iteration.



# However, George Dimitriu has a partial fix.

coproc cpname { for i in {0..10}; do echo "index = $i"; done; sleep 1;
echo hi > myo; cat - >> myo; }
#       ^^^^^ This is a *named* coprocess.

echo "I am main"$'\04' >&${cpname[1]}
myfd=${cpname[0]}
echo myfd=$myfd

### while read -u $myfd
### do
###   echo $REPLY;
### done

echo $cpname_PID

#  Run this with and without the commented-out while-loop, and it is
#+ apparent that each process, the executing shell and the coprocess,
#+ waits for the other to finish writing in its own write-enabled pipe.
}

}

◊list-entry{The new ◊code{mapfile} builtin makes it possible to load
an array with the contents of a text file without using a loop or
command substitution.

◊example{
#!/bin/bash4

mapfile Arr1 < $0
# Same result as     Arr1=( $(cat $0) )
echo "${Arr1[@]}"  # Copies this entire script out to stdout.

echo "--"; echo

# But, not the same as   read -a   !!!
read -a Arr2 < $0
echo "${Arr2[@]}"  # Reads only first line of script into the array.

exit
}

}

◊list-entry{The read builtin got a minor facelift. The ◊code{-t
timeout} option now accepts (decimal) fractional values and the
◊code{-i} option permits preloading the edit buffer. Unfortunately,
these enhancements are still a work in progress and not (yet) usable
in scripts.

This only works with pipes and certain other special files. But only
in conjunction with ◊command{readline}, i.e., from the command-line.

}

◊list-entry{Parameter substitution gets case-modification operators.

◊example{
#!/bin/bash4

var=veryMixedUpVariable
echo ${var}            # veryMixedUpVariable
echo ${var^}           # VeryMixedUpVariable
#         *              First char --> uppercase.
echo ${var^^}          # VERYMIXEDUPVARIABLE
#         **             All chars  --> uppercase.
echo ${var,}           # veryMixedUpVariable
#         *              First char --> lowercase.
echo ${var,,}          # verymixedupvariable
#         **             All chars  --> lowercase.
}

}

◊list-entry{The ◊command{declare} builtin now accepts the ◊code{-l}
lowercase and ◊code{-c} capitalize options.

◊example{
#!/bin/bash4

declare -l var1            # Will change to lowercase
var1=MixedCaseVARIABLE
echo "$var1"               # mixedcasevariable
# Same effect as             echo $var1 | tr A-Z a-z

declare -c var2            # Changes only initial char to uppercase.
var2=originally_lowercase
echo "$var2"               # Originally_lowercase
# NOT the same effect as     echo $var2 | tr a-z A-Z
}

}

◊list-entry{Brace expansion has more options.

Increment/decrement, specified in the final term within braces.

◊example{
#!/bin/bash4

echo {40..60..2}
# 40 42 44 46 48 50 52 54 56 58 60
# All the even numbers, between 40 and 60.

echo {60..40..2}
# 60 58 56 54 52 50 48 46 44 42 40
# All the even numbers, between 40 and 60, counting backwards.
# In effect, a decrement.
echo {60..40..-2}
# The same output. The minus sign is not necessary.

# But, what about letters and symbols?
echo {X..d}
# X Y Z [  ] ^ _ ` a b c d
# Does not echo the \ which escapes a space.
}

Zero-padding, specified in the first term within braces, prefixes each
term in the output with the same number of zeroes.

◊example{
bash4$ echo {010..15}
010 011 012 013 014 015


bash4$ echo {000..10}
000 001 002 003 004 005 006 007 008 009 010
}

}

◊list-entry{Substring extraction on positional parameters now starts
with ◊code{$0} as the zero-index. (This corrects an inconsistency in
the treatment of positional parameters.)

◊example{
#!/bin/bash
# show-params.bash
# Requires version 4+ of Bash.

# Invoke this scripts with at least one positional parameter.

E_BADPARAMS=99

if [ -z "$1" ]
then
  echo "Usage $0 param1 ..."
  exit $E_BADPARAMS
fi

echo ${@:0}

# bash3 show-params.bash4 one two three
# one two three

# bash4 show-params.bash4 one two three
# show-params.bash4 one two three

# $0                $1  $2  $3
}

}

◊list-entry{The new ◊code{**} globbing operator matches filenames and
directories recursively.

◊example{
#!/bin/bash4
# filelist.bash4

shopt -s globstar  # Must enable globstar, otherwise ** doesn't work.
                   # The globstar shell option is new to version 4 of Bash.

echo "Using *"; echo
for filename in *
do
  echo "$filename"
done   # Lists only files in current directory ($PWD).

echo; echo "--------------"; echo

echo "Using **"
for filename in **
do
  echo "$filename"
done   # Lists complete file tree, recursively.

exit

Using *

allmyfiles
filelist.bash4

--------------

Using **

allmyfiles
allmyfiles/file.index.txt
allmyfiles/my_music
allmyfiles/my_music/me-singing-60s-folksongs.ogg
allmyfiles/my_music/me-singing-opera.ogg
allmyfiles/my_music/piano-lesson.1.ogg
allmyfiles/my_pictures
allmyfiles/my_pictures/at-beach-with-Jade.png
allmyfiles/my_pictures/picnic-with-Melissa.png
filelist.bash4
}

}

◊list-entry{The new $BASHPID internal variable.
}

◊list-entry{There is a new builtin error-handling function named
◊code{command_not_found_handle}.

◊example{
#!/bin/bash4

command_not_found_handle ()
{ # Accepts implicit parameters.
  echo "The following command is not valid: \""$1\"""
  echo "With the following argument(s): \""$2\"" \""$3\"""   # $4, $5 ...
} # $1, $2, etc. are not explicitly passed to the function.

bad_command arg1 arg2

# The following command is not valid: "bad_command"
# With the following argument(s): "arg1" "arg2"
}

}

}

◊section{Editorial comment}

Associative arrays? Coprocesses? Whatever happened to the lean and
mean Bash we have come to know and love? Could it be suffering from
(horrors!) "feature creep"? Or perhaps even Korn shell envy?

Note to Chet Ramey: Please add only essential features in future Bash
releases -- perhaps for-each loops and support for multi-dimensional
arrays. ◊footnote{And while you're at it, consider fixing the
notorious piped read problem.} Most Bash users won't need, won't use,
and likely won't greatly appreciate complex "features" like built-in
debuggers, Perl interfaces, and bolt-on rocket boosters.


◊section{Bash, version 4.1}

Version 4.1 of Bash, released in May, 2010, was primarily a bugfix
update.

◊list-block[#:type "bullet"]{

◊list-entry{The ◊command{printf} command now accepts a ◊code{-v}
option for setting array indices.

}

◊list-entry{Within double brackets, the ◊code{>} and ◊code{<} string
comparison operators now conform to the locale. Since the locale
setting may affect the sorting order of string expressions, this has
side-effects on comparison tests within ◊code{[[ ... ]]} expressions.

}

◊list-entry{The ◊command{read} builtin now takes a ◊code{-N} option
(◊command{read -N chars}), which causes the read to terminate after
◊code{chars} characters.

◊anchored-example[#:anchor "read_n1"]{Reading N characters}

◊example{
#!/bin/bash
# Requires Bash version -ge 4.1 ...

num_chars=61

read -N $num_chars var < $0   # Read first 61 characters of script!
echo "$var"
exit

####### Output of Script #######

#!/bin/bash
# Requires Bash version -ge 4.1 ...

num_chars=61
}

}

◊list-entry{Here documents embedded in ◊command{$( ... )} command
substitution constructs may terminate with a simple ◊code{)}.

◊anchored-example[#:anchor "hdoc_var1"]{Using a here document to set a
variable}

◊example{
#!/bin/bash
# here-commsub.sh
# Requires Bash version -ge 4.1 ...

multi_line_var=$( cat <<ENDxxx
------------------------------
This is line 1 of the variable
This is line 2 of the variable
This is line 3 of the variable
------------------------------
ENDxxx)

#  Rather than what Bash 4.0 requires:
#+ that the terminating limit string and
#+ the terminating close-parenthesis be on separate lines.

# ENDxxx
# )


echo "$multi_line_var"

#  Bash still emits a warning, though.
#  warning: here-document at line 10 delimited
#+ by end-of-file (wanted `ENDxxx')
}

}

}

◊section{Bash, version 4.2}

Version 4.2 of Bash, released in February, 2011, contains a number of
new features and enhancements, in addition to bugfixes.


◊list-block[#:type "bullet"]{

◊list-entry{Bash now supports the the ◊code{\u} and ◊code{\U} Unicode
escape.

◊example{
echo -e '\u2630'   # Horizontal triple bar character.
# Equivalent to the more roundabout:
echo -e "\xE2\x98\xB0"
                   # Recognized by earlier Bash versions.

echo -e '\u220F'   # PI (Greek letter and mathematical symbol)
echo -e '\u0416'   # Capital "ZHE" (Cyrillic letter)
echo -e '\u2708'   # Airplane (Dingbat font) symbol
echo -e '\u2622'   # Radioactivity trefoil

echo -e "The amplifier circuit requires a 100 \u2126 pull-up resistor."


unicode_var='\u2640'
echo -e $unicode_var      # Female symbol
printf "$unicode_var \n"  # Female symbol, with newline


#  And for something a bit more elaborate . . .

#  We can store Unicode symbols in an associative array,
#+ then retrieve them by name.
#  Run this in a gnome-terminal or a terminal with a large, bold font
#+ for better legibility.

declare -A symbol  # Associative array.

symbol[script_E]='\u2130'
symbol[script_F]='\u2131'
symbol[script_J]='\u2110'
symbol[script_M]='\u2133'
symbol[Rx]='\u211E'
symbol[TEL]='\u2121'
symbol[FAX]='\u213B'
symbol[care_of]='\u2105'
symbol[account]='\u2100'
symbol[trademark]='\u2122'


echo -ne "${symbol[script_E]}   "
echo -ne "${symbol[script_F]}   "
echo -ne "${symbol[script_J]}   "
echo -ne "${symbol[script_M]}   "
echo -ne "${symbol[Rx]}   "
echo -ne "${symbol[TEL]}   "
echo -ne "${symbol[FAX]}   "
echo -ne "${symbol[care_of]}   "
echo -ne "${symbol[account]}   "
echo -ne "${symbol[trademark]}   "
echo
}

Note: The above example uses the ◊command{$' ... '} string-expansion
construct.

}

◊list-entry{When the ◊code{lastpipe} shell option is set, the last
command in a pipe doesn't run in a subshell.

◊anchored-example[#:anchor "pipe_read1"]{Piping input to a read}

◊example{
!/bin/bash
# lastpipe-option.sh

line=''                   # Null value.
echo "\$line = "$line""   # $line =

echo

shopt -s lastpipe         # Error on Bash version -lt 4.2.
echo "Exit status of attempting to set \"lastpipe\" option is $?"
#     1 if Bash version -lt 4.2, 0 otherwise.

echo

head -1 $0 | read line    # Pipe the first line of the script to read.
#            ^^^^^^^^^      Not in a subshell!!!

echo "\$line = "$line""
# Older Bash releases       $line =
# Bash version 4.2          $line = #!/bin/bash
}

This option offers possible "fixups" for these example scripts:
TODO Example 34-3 and Example 15-8.

}

◊list-entry{Negative array indices permit counting backwards from the
end of an array.

◊anchored-example[#:anchor "neg_array1"]{Negative array indices}

◊example{
#!/bin/bash
# neg-array.sh
# Requires Bash, version -ge 4.2.

array=( zero one two three four five )   # Six-element array.
#         0    1   2    3    4    5
#        -6   -5  -4   -3   -2   -1

# Negative array indices now permitted.
echo ${array[-1]}   # five
echo ${array[-2]}   # four
# ...
echo ${array[-6]}   # zero
# Negative array indices count backward from the last element+1.

# But, you cannot index past the beginning of the array.
echo ${array[-7]}   # array: bad array subscript


# So, what is this new feature good for?

echo "The last element in the array is "${array[-1]}""
# Which is quite a bit more straightforward than:
echo "The last element in the array is "${array[${#array[*]}-1]}""
echo

# And ...

index=0
let "neg_element_count = 0 - ${#array[*]}"
# Number of elements, converted to a negative number.

while [ $index -gt $neg_element_count ]; do
  ((index--)); echo -n "${array[index]} "
done  # Lists the elements in the array, backwards.
      # We have just simulated the "tac" command on this array.

echo

# See also neg-offset.sh.
}

}

◊list-entry{Substring extraction uses a negative length parameter to
specify an offset from the end of the target string.

◊anchored-example[#:anchor "neg-str1"]{Negative parameter in
string-extraction construct}

◊example{
#!/bin/bash
# Bash, version -ge 4.2
# Negative length-index in substring extraction.
# Important: It changes the interpretation of this construct!

stringZ=abcABC123ABCabc

echo ${stringZ}                              # abcABC123ABCabc
#                   Position within string:    0123456789.....
echo ${stringZ:2:3}                          #   cAB
#  Count 2 chars forward from string beginning, and extract 3 chars.
#  ${string:position:length}

#  So far, nothing new, but now ...

                                             # abcABC123ABCabc
#                   Position within string:    0123....6543210
echo ${stringZ:3:-6}                         #    ABC123
#                ^
#  Index 3 chars forward from beginning and 6 chars backward from end,
#+ and extract everything in between.
#  ${string:offset-from-front:offset-from-end}
#  When the "length" parameter is negative, 
#+ it serves as an offset-from-end parameter.

#  See also neg-array.sh.
}

}


}