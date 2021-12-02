#lang pollen

◊page-init{}
◊define-meta[page-title]{Optimizations}
◊define-meta[page-description]{Optimizations, Tests, Recursion}

◊section{Optimizations}

Most shell scripts are quick 'n dirty solutions to non-complex
problems. As such, optimizing them for speed is not much of an
issue. Consider the case, though, where a script carries out an
important task, does it well, but runs too slowly. Rewriting it in a
compiled language may not be a palatable option. The simplest fix
would be to rewrite the parts of the script that slow it down. Is it
possible to apply principles of code optimization even to a lowly
shell script?

Check the loops in the script. Time consumed by repetitive operations
adds up quickly. If at all possible, remove time-consuming operations
from within loops.

Use builtin commands in preference to system commands. Builtins
execute faster and usually do not launch a subshell when invoked.

Avoid unnecessary commands, particularly in a pipe.

◊example{
cat "$file" | grep "$word"

grep "$word" "$file"

#  The above command-lines have an identical effect,
#+ but the second runs faster since it launches one fewer subprocess.
}

The ◊command{cat} command seems especially prone to overuse in
scripts.

Disabling certain Bash options can speed up scripts.

If you don't need Unicode support, you can get potentially a 2x or more improvement in speed by simply setting the LC_ALL variable.

◊example{
export LC_ALL=C

[specifies the locale as ANSI C,
thereby disabling Unicode support]

[In an example script ...]

Without [Unicode support]:
erik@erik-desktop:~/capture$ time ./cap-ngrep.sh
live2.pcap > out.txt

  real        0m20.483s
  user        1m34.470s
  sys         0m12.869s

With [Unicode support]:
erik@erik-desktop:~/capture$ time ./cap-ngrep.sh
live2.pcap > out.txt

  real        0m50.232s
  user        3m51.118s
  sys         0m11.221s

A large part of the overhead that is optimized is, I believe,
regex match using [[ string =~ REGEX ]],
but it may help with other portions of the code as well.
I hadn't [seen it] mentioned that this optimization helped
with Bash, but I had seen it helped with "grep,"
so why not try?
}

Note: Certain operators, notably ◊command{expr}, are very inefficient
and might be replaced by double parentheses arithmetic expansion. See
TODO Example A-59.

◊example{
Math tests

math via $(( ))
real          0m0.294s
user          0m0.288s
sys           0m0.008s

math via expr:
real          1m17.879s   # Much slower!
user          0m3.600s
sys           0m8.765s

math via let:
real          0m0.364s
user          0m0.372s
sys           0m0.000s
}

Condition testing constructs in scripts deserve close
scrutiny. Substitute ◊command{case} for ◊command{if-then} constructs
and combine tests when possible, to minimize script execution
time. Again, refer to TODO Example A-59.

◊example{
Assignment tests

Assigning a simple variable
real          0m0.418s
user          0m0.416s
sys           0m0.004s

Assigning a numeric index array entry
real          0m0.582s
user          0m0.564s
sys           0m0.016s

Overwriting a numeric index array entry
real          0m21.931s
user          0m21.913s
sys           0m0.016s

Linear reading of numeric index array
real          0m0.422s
user          0m0.416s
sys           0m0.004s

Assigning an associative array entry
real          0m1.800s
user          0m1.796s
sys           0m0.004s

Overwriting an associative array entry
real          0m1.798s
user          0m1.784s
sys           0m0.012s

Linear reading an associative array entry
real          0m0.420s
user          0m0.420s
sys           0m0.000s

Assigning a random number to a simple variable
real          0m0.402s
user          0m0.388s
sys           0m0.016s

Assigning a sparse numeric index array entry randomly into 64k cells
real          0m12.678s
user          0m12.649s
sys           0m0.028s

Reading sparse numeric index array entry
real          0m0.087s
user          0m0.084s
sys           0m0.000s

Assigning a sparse associative array entry randomly into 64k cells
real          0m0.698s
user          0m0.696s
sys           0m0.004s

Reading sparse associative index array entry
real          0m0.083s
user          0m0.084s
sys           0m0.000s
}

Use the ◊command{time} and ◊command{times} tools to profile
computation-intensive commands. Consider rewriting time-critical code
sections in C, or even in assembler.

Try to minimize file I/O. Bash is not particularly efficient at
handling files, so consider using more appropriate tools for this
within the script, such as ◊command{awk} or ◊command{perl}.

Write your scripts in a modular and coherent form (this usually means
liberal use of functions), so they can be reorganized and tightened up
as necessary. Some of the optimization techniques applicable to
high-level languages may work for scripts, but others, such as loop
unrolling, are mostly irrelevant. Above all, use common sense.

For an excellent demonstration of how optimization can dramatically
reduce the execution time of a script, see Example TODO 16-47.

◊section{Tests}

For tests, the ◊commnd{[[ ]]} construct may be more appropriate than
◊command{[ ]}. Likewise, arithmetic comparisons might benefit from the
◊command{(( ))} construct.

◊example{
a=8

# All of the comparisons below are equivalent.
test "$a" -lt 16 && echo "yes, $a < 16"         # "and list"
/bin/test "$a" -lt 16 && echo "yes, $a < 16" 
[ "$a" -lt 16 ] && echo "yes, $a < 16" 
[[ $a -lt 16 ]] && echo "yes, $a < 16"          # Quoting variables within
(( a < 16 )) && echo "yes, $a < 16"             # [[ ]] and (( )) not necessary.

city="New York"
# Again, all of the comparisons below are equivalent.
test "$city" \< Paris && echo "Yes, Paris is greater than $city"
                                  # Greater ASCII order.
/bin/test "$city" \< Paris && echo "Yes, Paris is greater than $city" 
[ "$city" \< Paris ] && echo "Yes, Paris is greater than $city" 
[[ $city < Paris ]] && echo "Yes, Paris is greater than $city"
                                  # Need not quote $city.
}

◊section{Recursion: a script calling itself}

Can a script recursively call itself? Indeed.

◊anchored-example[#:anchor "recr1"]{A (useless) script that
recursively calls itself}

◊example{
#!/bin/bash
# recurse.sh

#  Can a script recursively call itself?
#  Yes, but is this of any practical use?
#  (See the following.)

RANGE=10
MAXVAL=9

i=$RANDOM
let "i %= $RANGE"  # Generate a random number between 0 and $RANGE - 1.

if [ "$i" -lt "$MAXVAL" ]
then
  echo "i = $i"
  ./$0             #  Script recursively spawns a new instance of itself.
fi                 #  Each child script does the same, until
                   #+ a generated $i equals $MAXVAL.

#  Using a "while" loop instead of an "if/then" test causes problems.
#  Explain why.

exit 0

# Note:
# ----
# This script must have execute permission for it to work properly.
# This is the case even if it is invoked by an "sh" command.
# Explain why.
}

◊anchored-example[#:anchor "recr2"]{A (useful) script that recursively
calls itself}

◊example{
#!/bin/bash
# pb.sh: phone book

# Written by Rick Boivie, and used with permission.
# Modifications by ABS Guide author.

MINARGS=1     #  Script needs at least one argument.
DATAFILE=./phonebook
              #  A data file in current working directory
              #+ named "phonebook" must exist.
PROGNAME=$0
E_NOARGS=70   #  No arguments error.

if [ $# -lt $MINARGS ]; then
      echo "Usage: "$PROGNAME" data-to-look-up"
      exit $E_NOARGS
fi      


if [ $# -eq $MINARGS ]; then
      grep $1 "$DATAFILE"
      # 'grep' prints an error message if $DATAFILE not present.
else
      ( shift; "$PROGNAME" $* ) | grep $1
      # Script recursively calls itself.
fi

exit 0        #  Script exits here.
              #  Therefore, it's o.k. to put
              #+ non-hashmarked comments and data after this point.

# ------------------------------------------------------------------------
Sample "phonebook" datafile:

John Doe        1555 Main St., Baltimore, MD 21228          (410) 222-3333
Mary Moe        9899 Jones Blvd., Warren, NH 03787          (603) 898-3232
Richard Roe     856 E. 7th St., New York, NY 10009          (212) 333-4567
Sam Roe         956 E. 8th St., New York, NY 10009          (212) 444-5678
Zoe Zenobia     4481 N. Baker St., San Francisco, SF 94338  (415) 501-1631
# ------------------------------------------------------------------------

$bash pb.sh Roe
Richard Roe     856 E. 7th St., New York, NY 10009          (212) 333-4567
Sam Roe         956 E. 8th St., New York, NY 10009          (212) 444-5678

$bash pb.sh Roe Sam
Sam Roe         956 E. 8th St., New York, NY 10009          (212) 444-5678

#  When more than one argument is passed to this script,
#+ it prints *only* the line(s) containing all the arguments.
}

◊anchored-example[#:anchor "recr3"]{Another (useful) script that
recursively calls itself}

◊example{
#!/bin/bash
# usrmnt.sh, written by Anthony Richardson
# Used in ABS Guide with permission.

# usage:       usrmnt.sh
# description: mount device, invoking user must be listed in the
#              MNTUSERS group in the /etc/sudoers file.

# ----------------------------------------------------------
#  This is a usermount script that reruns itself using sudo.
#  A user with the proper permissions only has to type

#   usermount /dev/fd0 /mnt/floppy

# instead of

#   sudo usermount /dev/fd0 /mnt/floppy

#  I use this same technique for all of my
#+ sudo scripts, because I find it convenient.
# ----------------------------------------------------------

#  If SUDO_COMMAND variable is not set we are not being run through
#+ sudo, so rerun ourselves. Pass the user's real and group id . . .

if [ -z "$SUDO_COMMAND" ]
then
   mntusr=$(id -u) grpusr=$(id -g) sudo $0 $*
   exit 0
fi

# We will only get here if we are being run by sudo.
/bin/mount $* -o uid=$mntusr,gid=$grpusr

exit 0

# Additional notes (from the author of this script): 
# -------------------------------------------------

# 1) Linux allows the "users" option in the /etc/fstab
#    file so that any user can mount removable media.
#    But, on a server, I like to allow only a few
#    individuals access to removable media.
#    I find using sudo gives me more control.

# 2) I also find sudo to be more convenient than
#    accomplishing this task through groups.

# 3) This method gives anyone with proper permissions
#    root access to the mount command, so be careful
#    about who you allow access.
#    You can get finer control over which access can be mounted
#    by using this same technique in separate mntfloppy, mntcdrom,
#    and mntsamba scripts.
}

Caution: Too many levels of recursion can exhaust the script's stack
space, causing a segfault.


