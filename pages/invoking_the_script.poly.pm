#lang pollen

◊define-meta[page-title]{Invoking the script}
◊define-meta[page-description]{Inoking a script from the command line}

Having written the script, you can invoke it by ◊command{sh
scriptname}, ◊footnote{Caution: invoking a Bash script by ◊command{sh
scriptname} turns off Bash-specific extensions, and the script may
therefore fail to execute.} or alternatively ◊command{bash
scriptname}. (Not recommended is using ◊command{sh <scriptname}, since
this effectively disables reading from ◊code{stdin} within the
script.) Much more convenient is to make the script itself directly
executable with a ◊command{chmod}.

Either: ◊command{chmod 555 scriptname} (gives everyone read/execute
permission) ◊footnote{A script needs ◊emphasize{read}, as well as
◊emphasize{execute} permission for it to run, since the shell needs to
be able to read it.}

Or ◊command{chmod +rx scriptname} (gives everyone read/execute
permission), ◊command{chmod u+rx scriptname} (gives only the script
owner read/execute permission).

Having made the script executable, you may now test it by
◊command{./scriptname}. If it begins with a "sha-bang" line, invoking the
script calls the correct command interpreter to run it.

Why not simply invoke the script with ◊command{scriptname}? If the
directory you are in (◊code{$PWD}) is where ◊command{scriptname} is
located, why doesn't this work?  This fails because, for security
reasons, the current directory (◊fname{./}) is not by default included
in a user's ◊code{$PATH}. It is therefore necessary to explicitly
invoke the script in the current directory with a
◊command{./scriptname.}

As a final step, after testing and debugging, you would likely want to
move it to ◊fname{/usr/local/bin} (as ◊code{root}, of course), to make
the script available to yourself and all other users as a systemwide
executable. The script could then be invoked by simply typing
◊command{scriptname [ENTER]} from the command-line.

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
