#lang pollen

◊; This is free and unencumbered software released into the public domain
◊; See LICENSE.txt

◊page-init{}
◊define-meta[page-title]{Internal Commands}
◊define-meta[page-description]{Internal Commands and Builtins}

A builtin is a command contained within the Bash tool set, literally
built in. This is either for performance reasons -- builtins execute
faster than external commands, which usually require forking off a
separate process -- or because a particular builtin needs direct
access to the shell internals. ◊footnote{While forking a process is a
low-cost operation, executing a new program in the newly-forked child
process adds more overhead.}

A builtin may be a synonym to a system command of the same name, but
Bash reimplements it internally. For example, the Bash echo command is
not the same as ◊code{/bin/echo}, although their behavior is almost
identical.

◊example{
#!/bin/bash

echo "This line uses the \"echo\" builtin."
/bin/echo "This line uses the /bin/echo system command."
}

◊section{I/O}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "echo"]{
prints (to stdout) an expression or variable (TODO see Example 4-1).

◊example{
echo Hello
echo $a
}

An ◊code{echo} requires the ◊code{-e} option to print escaped
characters. See TODO Example 5-2.

Normally, each ◊code{echo} command prints a terminal newline, but the
◊code{-n} option suppresses this.

Note: An ◊code{echo} can be used to feed a sequence of commands down a
pipe.

◊example{
if echo "$VAR" | grep -q txt   # if [[ $VAR = *txt* ]]
then
  echo "$VAR contains the substring sequence \"txt\""
fi
}

Note: An ◊code{echo}, in combination with command substitution can set
a variable.

◊example{
a=$(echo "HELLO" | tr A-Z a-z)
}

See TODO also Example 16-22, Example 16-3, Example 16-47, and Example
16-48.

Be aware that ◊code{echo} `command` deletes any linefeeds that the
output of command generates.

The ◊code{$IFS} (internal field separator) variable normally contains
◊code{\n} (linefeed) as one of its set of whitespace characters. Bash
therefore splits the output of command at linefeeds into arguments to
◊code{echo}. Then ◊code{echo} outputs these arguments, separated by
spaces.

◊example{
bash$ ls -l /usr/share/apps/kjezz/sounds
-rw-r--r--    1 root     root         1407 Nov  7  2000 reflect.au
-rw-r--r--    1 root     root          362 Nov  7  2000 seconds.au

bash$ echo $(ls -l /usr/share/apps/kjezz/sounds)
total 40 -rw-r--r-- 1 root root 716 Nov 7 2000 reflect.au -rw-r--r-- 1 root root ...
}

So, how can we embed a linefeed within an echoed character string?

◊example{
# Embedding a linefeed?
echo "Why doesn't this string \n split on two lines?"
# Doesn't split.

# Let's try something else.

echo
	     
echo $"A line of text containing
a linefeed."
# Prints as two distinct lines (embedded linefeed).
# But, is the "$" variable prefix really necessary?

echo

echo "This string splits
on two lines."
# No, the "$" is not needed.

echo
echo "---------------"
echo

echo -n $"Another line of text containing
a linefeed."
# Prints as two distinct lines (embedded linefeed).
# Even the -n option fails to suppress the linefeed here.

echo
echo
echo "---------------"
echo
echo

# However, the following doesn't work as expected.
# Why not? Hint: Assignment to a variable.
string1=$"Yet another line of text containing
a linefeed (maybe)."

echo $string1
# Yet another line of text containing a linefeed (maybe).
#                                    ^
# Linefeed becomes a space.

# Thanks, Steve Parker, for pointing this out.
}

Note: This command is a shell builtin, and not the same as
◊fname{/bin/echo}, although its behavior is similar.

◊example{
bash$ type -a echo
echo is a shell builtin
echo is /bin/echo
}

}

}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
