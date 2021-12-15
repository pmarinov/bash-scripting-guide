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

}
