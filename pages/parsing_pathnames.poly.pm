#lang pollen

◊page-init{}
◊define-meta[page-title]{Parsing Pathnames}
◊define-meta[page-description]{Parsing and Managing Pathnames}

This is an example of parsing and transforming filenames and, in
particular, pathnames. It draws heavily on the functionality of
◊command{sed}.

◊example{
#!/usr/bin/env bash
#-----------------------------------------------------------
# Management of PATH, LD_LIBRARY_PATH, MANPATH variables...
# By Emmanuel Rouat <no-email>
# (Inspired by the bash documentation 'pathfuncs' and on
# discussions found on stackoverflow:
# http://stackoverflow.com/questions/370047/
# http://stackoverflow.com/questions/273909/#346860 )
# Last modified: Sat Sep 22 12:01:55 CEST 2012
#
# The following functions handle spaces correctly.
# These functions belong in .bash_profile rather than in
# .bashrc, I guess.
#
# The modular aspect of these functions should make it easy
# to expand them to handle path substitutions instead
# of path removal etc....
#
# See http://www.catonmat.net/blog/awk-one-liners-explained-part-two/
# (item 43) for an explanation of the 'duplicate-entries' removal
# (it's a nice trick!)
#-----------------------------------------------------------

# Show $@ (usually PATH) as list.
function p_show() { local p="$@" && for p; do [[ ${!p} ]] &&
echo -e ${!p//:/\\n}; done }

# Filter out empty lines, multiple/trailing slashes, and duplicate entries.
function p_filter()
{ awk '/^[ \t]*$/ {next} {sub(/\/+$/, "");gsub(/\/+/, "/")}!x[$0]++' ;}

# Rebuild list of items into ':' separated word (PATH-like).
function p_build() { paste -sd: ;}

# Clean $1 (typically PATH) and rebuild it
function p_clean()
{ local p=${1} && eval ${p}='$(p_show ${p} | p_filter | p_build)' ;}

# Remove $1 from $2 (found on stackoverflow, with modifications).
function p_rm()
{ local d=$(echo $1 | p_filter) p=${2} &&
  eval ${p}='$(p_show ${p} | p_filter | grep -xv "${d}" | p_build)' ;}

#  Same as previous, but filters on a pattern (dangerous...
#+ don't use 'bin' or '/' as pattern!).
function p_rmpat()
{ local d=$(echo $1 | p_filter) p=${2} && eval ${p}='$(p_show ${p} |
  p_filter | grep -v "${d}" | p_build)' ;}

# Delete $1 from $2 and append it cleanly.
function p_append()
{ local d=$(echo $1 | p_filter) p=${2} && p_rm "${d}" ${p} &&
  eval ${p}='$(p_show ${p} d | p_build)' ;}

# Delete $1 from $2 and prepend it cleanly.
function p_prepend()
{ local d=$(echo $1 | p_filter) p=${2} && p_rm "${d}" ${p} &&
  eval ${p}='$(p_show d ${p} | p_build)' ;}

# Some tests:
echo
MYPATH="/bin:/usr/bin/:/bin://bin/"
p_append "/project//my project/bin" MYPATH
echo "Append '/project//my project/bin' to '/bin:/usr/bin/:/bin://bin/'"
echo "(result should be: /bin:/usr/bin:/project/my project/bin)"
echo $MYPATH

echo
MYOTHERPATH="/bin:/usr/bin/:/bin:/project//my project/bin"
p_prepend "/project//my project/bin" MYOTHERPATH
echo "Prepend '/project//my project/bin' \
to '/bin:/usr/bin/:/bin:/project//my project/bin/'"
echo "(result should be: /project/my project/bin:/bin:/usr/bin)"
echo $MYOTHERPATH

echo
p_prepend "/project//my project/bin" FOOPATH  # FOOPATH doesn't exist.
echo "Prepend '/project//my project/bin' to an unset variable"
echo "(result should be: /project/my project/bin)"
echo $FOOPATH

echo
BARPATH="/a:/b/://b c://a:/my local pub"
p_clean BARPATH
echo "Clean BARPATH='/a:/b/://b c://a:/my local pub'"
echo "(result should be: /a:/b:/b c:/my local pub)"
echo $BARPATH
}

How can you process filenames correctly in shell?

◊example{
Doing it correctly: A quick summary
by David Wheeler
http://www.dwheeler.com/essays/filenames-in-shell.html

So, how can you process filenames correctly in shell? Here's a quick
summary about how to do it correctly, for the impatient who "just want the
answer". In short: Double-quote to use "$variable" instead of $variable,
set IFS to just newline and tab, prefix all globs/filenames so they cannot
begin with "-" when expanded, and use one of a few templates that work
correctly. Here are some of those templates that work correctly:


 IFS="$(printf '\n\t')"
 # Remove SPACE, so filenames with spaces work well.

 #  Correct glob use:
 #+ always use "for" loop, prefix glob, check for existence:
 for file in ./* ; do          # Use "./*" ... NEVER bare "*" ...
   if [ -e "$file" ] ; then    # Make sure it isn't an empty match.
     COMMAND ... "$file" ...
   fi
 done



 # Correct glob use, but requires nonstandard bash extension.
 shopt -s nullglob  #  Bash extension,
                    #+ so that empty glob matches will work.
 for file in ./* ; do        # Use "./*", NEVER bare "*"
   COMMAND ... "$file" ...
 done



 #  These handle all filenames correctly;
 #+ can be unwieldy if COMMAND is large:
 find ... -exec COMMAND... {} \;
 find ... -exec COMMAND... {} \+ # If multiple files are okay for COMMAND.



 #  This skips filenames with control characters
 #+ (including tab and newline).
 IFS="$(printf '\n\t')"
 controlchars="$(printf '*[\001-\037\177]*')"
 for file in $(find . ! -name "$controlchars"') ; do
   COMMAND "$file" ...
 done



 #  Okay if filenames can't contain tabs or newlines --
 #+ beware the assumption.
 IFS="$(printf '\n\t')"
 for file in $(find .) ; do
   COMMAND "$file" ...
 done



 # Requires nonstandard but common extensions in find and xargs:
 find . -print0 | xargs -0 COMMAND

 # Requires nonstandard extensions to find and to shell (bash works).
 # variables might not stay set once the loop ends:
 find . -print0 | while IFS="" read -r -d "" file ; do ...
   COMMAND "$file" # Use quoted "$file", not $file, everywhere.
 done



 #  Requires nonstandard extensions to find and to shell (bash works).
 #  Underlying system must include named pipes (FIFOs)
 #+ or the /dev/fd mechanism.
 #  In this version, variables *do* stay set after the loop ends,
 #  and you can read from stdin.
 #+ (Change the 4 to another number if fd 4 is needed.)

 while IFS="" read -r -d "" file <&4 ; do
   COMMAND "$file"   # Use quoted "$file" -- not $file, everywhere.
 done 4< <(find . -print0)


 #  Named pipe version.
 #  Requires nonstandard extensions to find and to shell's read (bash ok).
 #  Underlying system must include named pipes (FIFOs).
 #  Again, in this version, variables *do* stay set after the loop ends,
 #  and you can read from stdin.
 # (Change the 4 to something else if fd 4 needed).

 mkfifo mypipe

 find . -print0 > mypipe &
 while IFS="" read -r -d "" file <&4 ; do
   COMMAND "$file" # Use quoted "$file", not $file, everywhere.
 done 4< mypipe
}
