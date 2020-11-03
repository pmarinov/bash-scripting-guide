#lang pollen

◊page-init{}
◊define-meta[page-title]{Loop control}
◊define-meta[page-description]{Loop control, nested loops}

◊section{Loop Control}

Commands affecting loop behavior

◊definition-block[#:type "code"]{
◊definition-entry[#:name "break, continue"]{

The ◊code{break} and ◊code{continue} loop control commands
correspond exactly to their counterparts in other programming
languages. The ◊code{break} command terminates the loop (breaks out of
it), while ◊code{continue} causes a jump to the next iteration of the
loop, skipping all the remaining commands in that particular loop
cycle.

Note: ◊code{break} and ◊code{continue} are shell builtins, whereas other
loop commands, such as ◊code{while} and ◊code{case}, are keywords.

}

} ◊;definition-block

◊section-example[#:anchor "loop_break_efct1"]{Effects of break and
continue in a loop}

◊example{
#!/bin/bash

LIMIT=19  # Upper limit

echo
echo "Printing Numbers 1 through 20 (but not 3 and 11)."

a=0

while [ $a -le "$LIMIT" ]
do
 a=$(($a+1))

 if [ "$a" -eq 3 ] || [ "$a" -eq 11 ]  # Excludes 3 and 11.
 then
   continue      # Skip rest of this particular loop iteration.
 fi

 echo -n "$a "   # This will not execute for 3 and 11.
done

# Exercise:
# Why does the loop print up to 20?

echo; echo

echo Printing Numbers 1 through 20, but something happens after 2.

##################################################################

# Same loop, but substituting 'break' for 'continue'.

a=0

while [ "$a" -le "$LIMIT" ]
do
 a=$(($a+1))

 if [ "$a" -gt 2 ]
 then
   break  # Skip entire rest of loop.
 fi

 echo -n "$a "
done

echo; echo; echo

exit 0
}

◊section-example[#:anchor "loop_break_multi1"]{Breaking out of
multiple loop levels}

The ◊code{break} command may optionally take a parameter. A plain
◊code{break} terminates only the innermost loop in which it is
embedded, but a ◊code{break N} breaks out of N levels of loop.

◊example{
#!/bin/bash
# break-levels.sh: Breaking out of loops.

# "break N" breaks out of N level loops.

for outerloop in 1 2 3 4 5
do
  echo -n "Group $outerloop:   "

  # --------------------------------------------------------
  for innerloop in 1 2 3 4 5
  do
    echo -n "$innerloop "

    if [ "$innerloop" -eq 3 ]
    then
      break  # Try   break 2   to see what happens.
             # ("Breaks" out of both inner and outer loops.)
    fi
  done
  # --------------------------------------------------------

  echo
done

echo

exit 0
}

◊section-example[#:anchor "loop_cont1"]{Continuing at a higher loop
level}

The ◊code{continue} command, similar to ◊code{break}, optionally takes
a parameter. A plain ◊code{continue} cuts short the current iteration
within its loop and begins the next. A ◊continue{continue N}
terminates all remaining iterations at its loop level and continues
with the next iteration at the loop, N levels above.

◊example{
#!/bin/bash
# The "continue N" command, continuing at the Nth level loop.

for outer in I II III IV V           # outer loop
do
  echo; echo -n "Group $outer: "

  # --------------------------------------------------------------------
  for inner in 1 2 3 4 5 6 7 8 9 10  # inner loop
  do

    if [[ "$inner" -eq 7 && "$outer" = "III" ]]
    then
      continue 2  # Continue at loop on 2nd level, that is "outer loop".
                  # Replace above line with a simple "continue"
                  # to see normal loop behavior.
    fi

    echo -n "$inner "  # 7 8 9 10 will not echo on "Group III."
  done
  # --------------------------------------------------------------------

done

echo; echo

# Exercise:
# Come up with a meaningful use for "continue N" in a script.

exit 0
}

◊section-example[#:anchor "loop_cont2"]{Using continue N in an actual
task}

◊example{
# Albert Reiner gives an example of how to use "continue N":
# ---------------------------------------------------------

#  Suppose I have a large number of jobs that need to be run, with
#+ any data that is to be treated in files of a given name pattern
#+ in a directory. There are several machines that access
#+ this directory, and I want to distribute the work over these
#+ different boxen.
#  Then I usually nohup something like the following on every box:

while true
do
  for n in .iso.*
  do
    [ "$n" = ".iso.opts" ] && continue
    beta=${n#.iso.}
    [ -r .Iso.$beta ] && continue
    [ -r .lock.$beta ] && sleep 10 && continue
    lockfile -r0 .lock.$beta || continue
    echo -n "$beta: " `date`
    run-isotherm $beta
    date
    ls -alF .Iso.$beta
    [ -r .Iso.$beta ] && rm -f .lock.$beta
    continue 2
  done
  break
done

exit 0

#  The details, in particular the sleep N, are particular to my
#+ application, but the general pattern is:

while true
do
  for job in {pattern}
  do
    {job already done or running} && continue
    {mark job as running, do job, mark job as done}
    continue 2
  done
  break        # Or something like `sleep 600' to avoid termination.
done

#  This way the script will stop only when there are no more jobs to do
#+ (including jobs that were added during runtime). Through the use
#+ of appropriate lockfiles it can be run on several machines
#+ concurrently without duplication of calculations [which run a couple
#+ of hours in my case, so I really want to avoid this]. Also, as search
#+ always starts again from the beginning, one can encode priorities in
#+ the file names. Of course, one could also do this without `continue 2',
#+ but then one would have to actually check whether or not some job
#+ was done (so that we should immediately look for the next job) or not
#+ (in which case we terminate or sleep for a long time before checking
#+ for a new job).
}

Caution: The ◊code{continue N} construct is difficult to understand and
tricky to use in any meaningful context. It is probably best avoided.

◊section{Nested Loops}

A nested loop is a loop within a loop, an inner loop within the body
of an outer one. How this works is that the first pass of the outer
loop triggers the inner loop, which executes to completion. Then the
second pass of the outer loop triggers the inner loop again. This
repeats until the outer loop finishes. Of course, a break within
either the inner or outer loop would interrupt this process.

◊example{
#!/bin/bash
# nested-loop.sh: Nested "for" loops.

outer=1             # Set outer loop counter.

# Beginning of outer loop.
for a in 1 2 3 4 5
do
  echo "Pass $outer in outer loop."
  echo "---------------------"
  inner=1           # Reset inner loop counter.

  # ===============================================
  # Beginning of inner loop.
  for b in 1 2 3 4 5
  do
    echo "Pass $inner in inner loop."
    let "inner+=1"  # Increment inner loop counter.
  done
  # End of inner loop.
  # ===============================================

  let "outer+=1"    # Increment outer loop counter.
  echo              # Space between output blocks in pass of outer loop.
done
# End of outer loop.

exit 0
}

See TODO Example 27-11 for an illustration of nested ◊code{while}
loops, and TODO Example 27-13 to see a ◊code{while} loop nested inside
an ◊code{until} loop.

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
