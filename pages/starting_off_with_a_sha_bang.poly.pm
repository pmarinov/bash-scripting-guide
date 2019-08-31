#lang pollen

◊define-meta[page-title]{The Sha-Bang}
◊define-meta[page-description]{Starting Off With a Sha-Bang}

◊quotation[#:author "Larry Wall"]{
Shell programming is a 1950s juke box ...
}

In the simplest case, a script is nothing more than a list of system
commands stored in a file. At the very least, this saves the effort of
retyping that particular sequence of commands each time it is invoked.

◊section-example[#:anchor "cleanup_step1"]{◊term{cleanup}: A script to
clean up log files in ◊fname{/var/log}}

◊example{
# Cleanup
# Run as root, of course.

cd /var/log
cat /dev/null > messages
cat /dev/null > wtmp
echo "Log files cleaned up."
}

There is nothing unusual here, only a set of commands that could just
as easily have been invoked one by one from the command-line on the
console or in a terminal window. The advantages of placing the
commands in a script go far beyond not having to retype them time and
again. The script becomes a program -- a tool -- and it can easily be
modified or customized for a particular application.

◊section-example[#:anchor "cleanup_step2"]{◊term{cleanup}: An improved
clean-up script}

◊example{
#!/bin/bash
# Proper header for a Bash script.

# Cleanup, version 2

# Run as root, of course.
# Insert code here to print error message and exit if not root.

LOG_DIR=/var/log
# Variables are better than hard-coded values.
cd $LOG_DIR

cat /dev/null > messages
cat /dev/null > wtmp


echo "Logs cleaned up."

exit #  The right and proper method of "exiting" from a script.
     #  A bare "exit" (no parameter) returns the exit status
     #+ of the preceding command.
}

Now ◊emphasize{that's} beginning to look like a real script. But we
can go even farther ...
