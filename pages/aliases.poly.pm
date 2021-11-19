#lang pollen

◊page-init{}
◊define-meta[page-title]{Aliases}
◊define-meta[page-description]{Aliases}

A Bash alias is essentially nothing more than a keyboard shortcut, an
abbreviation, a means of avoiding typing a long command sequence. If,
for example, we include ◊command{alias lm="ls -l | more"} in the
◊fname{~/.bashrc} file, then each ◊command{lm} ◊footnote{... as the
first word of a command string. Obviously, an alias is only meaningful
at the beginning of a command.} typed at the command-line will
automatically be replaced by a ◊command{ls -l | more}. This can save a
great deal of typing at the command-line and avoid having to remember
complex combinations of commands and options. Setting ◊command{alias
rm="rm -i"} (interactive mode delete) may save a good deal of grief,
since it can prevent inadvertently deleting important files.

In a script, aliases have very limited usefulness. It would be nice if
aliases could assume some of the functionality of the C preprocessor,
such as macro expansion, but unfortunately Bash does not expand
arguments within the alias body. ◊footnote{However, aliases do seem to
expand positional parameters.} Moreover, a script fails to expand an
alias itself within "compound constructs," such as ◊command{if/then}
statements, loops, and functions. An added limitation is that an alias
will not expand recursively. Almost invariably, whatever we would like
an alias to do could be accomplished much more effectively with a
function.

◊anchored-example[#:anchor "alias_func1"]{Aliases within a script}

◊example{
#!/bin/bash
# alias.sh

shopt -s expand_aliases
# Must set this option, else script will not expand aliases.


# First, some fun.
alias Jesse_James='echo "\"Alias Jesse James\" was a 1959 comedy starring Bob Hope."'
Jesse_James

echo; echo; echo;

alias ll="ls -l"
# May use either single (') or double (") quotes to define an alias.

echo "Trying aliased \"ll\":"
ll /usr/X11R6/bin/mk*   #* Alias works.

echo

directory=/usr/X11R6/bin/
prefix=mk*  # See if wild card causes problems.
echo "Variables \"directory\" + \"prefix\" = $directory$prefix"
echo

alias lll="ls -l $directory$prefix"

echo "Trying aliased \"lll\":"
lll         # Long listing of all files in /usr/X11R6/bin stating with mk.
# An alias can handle concatenated variables -- including wild card -- o.k.




TRUE=1

echo

if [ TRUE ]
then
  alias rr="ls -l"
  echo "Trying aliased \"rr\" within if/then statement:"
  rr /usr/X11R6/bin/mk*   #* Error message results!
  # Aliases not expanded within compound statements.
  echo "However, previously expanded alias still recognized:"
  ll /usr/X11R6/bin/mk*
fi

echo

count=0
while [ $count -lt 3 ]
do
  alias rrr="ls -l"
  echo "Trying aliased \"rrr\" within \"while\" loop:"
  rrr /usr/X11R6/bin/mk*   #* Alias will not expand here either.
                           #  alias.sh: line 57: rrr: command not found
  let count+=1
done

echo; echo

alias xyz='cat $0'   # Script lists itself.
                     # Note strong quotes.
xyz
#  This seems to work,
#+ although the Bash documentation suggests that it shouldn't.
#
#  However, as Steve Jacobson points out,
#+ the "$0" parameter expands immediately upon declaration of the alias.

exit 0
}

The ◊command{unalias} command removes a previously set alias.

◊example{
#!/bin/bash
# unalias.sh

shopt -s expand_aliases  # Enables alias expansion.

alias llm='ls -al | more'
llm

echo

unalias llm              # Unset alias.
llm
# Error message results, since 'llm' no longer recognized.

exit 0

bash$ ./unalias.sh
total 6
drwxrwxr-x    2 bozo     bozo         3072 Feb  6 14:04 .
drwxr-xr-x   40 bozo     bozo         2048 Feb  6 14:04 ..
-rwxr-xr-x    1 bozo     bozo          199 Feb  6 14:04 unalias.sh

./unalias.sh: llm: command not found
}
