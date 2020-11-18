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

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
