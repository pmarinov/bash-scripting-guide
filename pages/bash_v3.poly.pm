#lang pollen

◊page-init{}
◊define-meta[page-title]{Version 3}
◊define-meta[page-description]{Bash, version 3}

◊section{Bash, version 3.0}

On July 27, 2004, Chet Ramey released version 3 of Bash. This update
fixed quite a number of bugs and added new features.

Some of the more important added features:

◊list-block[#:type "bullet"]{

◊list-entry{A new, more generalized
◊code{◊escaped{◊"{"}a..z◊escaped{◊"}"}} brace expansion operator.

◊example{
#!/bin/bash

for i in {1..10}
#  Simpler and more straightforward than
#+ for i in $(seq 10)
do
  echo -n "$i "
done

echo

# 1 2 3 4 5 6 7 8 9 10



# Or just . . .

echo {a..z}    #  a b c d e f g h i j k l m n o p q r s t u v w x y z
echo {e..m}    #  e f g h i j k l m
echo {z..a}    #  z y x w v u t s r q p o n m l k j i h g f e d c b a
               #  Works backwards, too.
echo {25..30}  #  25 26 27 28 29 30
echo {3..-2}   #  3 2 1 0 -1 -2
echo {X..d}    #  X Y Z [  ] ^ _ ` a b c d
               #  Shows (some of) the ASCII characters between Z and a,
               #+ but don't rely on this type of behavior because . . .
echo {]..a}    #  {]..a}
               #  Why?


# You can tack on prefixes and suffixes.
echo "Number #"{1..4}, "..."
     # Number #1, Number #2, Number #3, Number #4, ...


# You can concatenate brace-expansion sets.
echo {1..3}{x..z}" +" "..."
     # 1x + 1y + 1z + 2x + 2y + 2z + 3x + 3y + 3z + ...
     # Generates an algebraic expression.
     # This could be used to find permutations.

# You can nest brace-expansion sets.
echo {{a..c},{1..3}}
     # a b c 1 2 3
     # The "comma operator" splices together strings.

# ########## ######### ############ ########### ######### ###############
# Unfortunately, brace expansion does not lend itself to parameterization.
var1=1
var2=5
echo {$var1..$var2}   # {1..5}


# Yet, as Emiliano G. points out, using "eval" overcomes this limitation.

start=0
end=10
for index in $(eval echo {$start..$end})
do
  echo -n "$index "   # 0 1 2 3 4 5 6 7 8 9 10 
done

echo
}

}

◊list-entry{The
$◊escaped{◊"{"}!array[◊escaped{◊"@"}]◊escaped{◊"}"} operator,
which expands to all the indices of a given array.

◊example{
#!/bin/bash

Array=(element-zero element-one element-two element-three)

echo ${Array[0]}   # element-zero
                   # First element of array.

echo ${!Array[@]}  # 0 1 2 3
                   # All the indices of Array.

for i in ${!Array[@]}
do
  echo ${Array[i]} # element-zero
                   # element-one
                   # element-two
                   # element-three
                   #
                   # All the elements in Array.
done
}

}


◊list-entry{The ◊code{=~} Regular Expression matching operator within a
double brackets test expression. (Perl has a similar operator.)

◊example{
#!/bin/bash

variable="This is a fine mess."

echo "$variable"

# Regex matching with =~ operator within [[ double brackets ]].
if [[ "$variable" =~ T.........fin*es* ]]
# NOTE: As of version 3.2 of Bash, expression to match no longer quoted.
then
  echo "match found"
      # match found
fi
}

Or, more usefully:

◊example{
#!/bin/bash

input=$1


if [[ "$input" =~ "[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]" ]]
#                 ^ NOTE: Quoting not necessary, as of version 3.2 of Bash.
# NNN-NN-NNNN (where each N is a digit).
then
  echo "Social Security number."
  # Process SSN.
else
  echo "Not a Social Security number!"
  # Or, ask for corrected input.
fi
}

For additional examples of using the ◊code{=~} operator, see TODO
Example A-29, Example 19-14, Example A-35, and Example A-24.

}

◊list-entry{The new ◊command{set -o pipefail} option is useful for
debugging pipes. If this option is set, then the exit status of a pipe
is the exit status of the last command in the pipe to fail (return a
non-zero value), rather than the actual final command in the pipe.

See TODO Example 16-43.

Caution: The update to version 3 of Bash breaks a few scripts that
worked under earlier versions. Test critical legacy scripts to make
sure they still work!

As it happens, a couple of the scripts in the Advanced Bash Scripting
Guide had to be fixed up (see TODO Example 9-4, for instance).

}

}

◊section{Bash, version 3.1}

The version 3.1 update of Bash introduces a number of bugfixes and a
few minor changes.

◊list-block[#:type "bullet"]{

◊list-entry{The += operator is now permitted in in places where
previously only the = assignment operator was recognized.

◊example{
=1
echo $a        # 1

a+=5           # Won't work under versions of Bash earlier than 3.1.
echo $a        # 15

a+=Hello
echo $a        # 15Hello
}

Here, += functions as a string concatenation operator. Note that its
behavior in this particular context is different than within a let
construct.

◊example{
a=1
echo $a        # 1

let a+=5       # Integer arithmetic, rather than string concatenation.
echo $a        # 6

let a+=Hello   # Doesn't "add" anything to a.
echo $a        # 6
}

Jeffrey Haemer points out that this concatenation operator can be
quite useful. In this instance, we append a directory to the $PATH.

◊example{
bash$ echo $PATH
/usr/bin:/bin:/usr/local/bin:/usr/X11R6/bin/:/usr/games

bash$ PATH+=:/opt/bin

bash$ echo $PATH
/usr/bin:/bin:/usr/local/bin:/usr/X11R6/bin/:/usr/games:/opt/bin
}


}


}

◊section{Bash, version 3.2}

This is pretty much a bugfix update.

◊list-block[#:type "bullet"]{

◊list-entry{In global parameter substitutions, the pattern no longer
anchors at the start of the string.}

◊list-entry{The ◊code{--wordexp} option disables process
substitution.}

◊list-entry{The ◊code{=~} Regular Expression match operator no longer
requires quoting of the pattern within ◊code{[[ ... ]]}.

Caution: In fact, quoting in this context is not advisable as it may
cause regex evaluation to fail. Chet Ramey states in the Bash FAQ that
quoting explicitly disables regex evaluation. See also the Ubuntu Bug
List and Wikinerds on Bash syntax.

Setting shopt -s compat31 in a script causes reversion to the original behavior.

See ◊url[#:link "https://tiswww.case.edu/php/chet/bash/FAQ"]{} -- Bash FAQ

}

}
