#lang pollen

◊page-init{}
◊define-meta[page-title]{I/O Redirection Detailed}
◊define-meta[page-description]{A Detailed Introduction to I/O and I/O Redirection}

written by Stéphane Chazelas, and revised by the document author

A command expects the first three file descriptors to be
available. The first, ◊code{fd 0} (standard input, stdin), is for
reading. The other two (◊code{fd 1}, stdout and ◊code{fd 2}, stderr) are for
writing.

There is a stdin, stdout, and a stderr associated with each
command. ◊command{ls 2>&1} means temporarily connecting the stderr of
the ◊command{ls} command to the same "resource" as the shell's stdout.

By convention, a command reads its input from ◊code{fd 0} (stdin),
prints normal output to ◊code{fd 1} (stdout), and error ouput to
◊code{fd 2} (stderr). If one of those three fd's is not open, you may
encounter problems:

◊example{
bash$ cat /etc/passwd >&-
cat: standard output: Bad file descriptor
}

For example, when ◊command{xterm} runs, it first initializes
itself. Before running the user's shell, ◊command{xterm} opens the
terminal device (◊fname{/dev/pts/<n>} or something similar) three
times.

At this point, Bash inherits these three file descriptors, and each
command (child process) run by Bash inherits them in turn, except when
you redirect the command. Redirection means reassigning one of the
file descriptors to another file (or a pipe, or anything
permissible). File descriptors may be reassigned locally (for a
command, a command group, a subshell, a while or if or case or for
loop...), or globally, for the remainder of the shell (using
◊command{exec}).

◊command{ls > /dev/null} means running ◊command{ls} with its ◊code{fd
1} connected to ◊fname{/dev/null}.

◊example{
bash$ lsof -a -p $$ -d0,1,2
COMMAND PID     USER   FD   TYPE DEVICE SIZE NODE NAME
bash    363 bozo        0u   CHR  136,1         3 /dev/pts/1
bash    363 bozo        1u   CHR  136,1         3 /dev/pts/1
bash    363 bozo        2u   CHR  136,1         3 /dev/pts/1


bash$ exec 2> /dev/null
bash$ lsof -a -p $$ -d0,1,2
COMMAND PID     USER   FD   TYPE DEVICE SIZE NODE NAME
bash    371 bozo        0u   CHR  136,1         3 /dev/pts/1
bash    371 bozo        1u   CHR  136,1         3 /dev/pts/1
bash    371 bozo        2w   CHR    1,3       120 /dev/null


bash$ bash -c 'lsof -a -p $$ -d0,1,2' | cat
COMMAND PID USER   FD   TYPE DEVICE SIZE NODE NAME
lsof    379 root    0u   CHR  136,1         3 /dev/pts/1
lsof    379 root    1w  FIFO    0,0      7118 pipe
lsof    379 root    2u   CHR  136,1         3 /dev/pts/1


bash$ echo "$(bash -c 'lsof -a -p $$ -d0,1,2' 2>&1)"
COMMAND PID USER   FD   TYPE DEVICE SIZE NODE NAME
lsof    426 root    0u   CHR  136,1         3 /dev/pts/1
lsof    426 root    1w  FIFO    0,0      7520 pipe
lsof    426 root    2w  FIFO    0,0      7520 pipe
}

This works for different types of redirection.

Exercise: Analyze the following script.

◊example{
#! /usr/bin/env bash

mkfifo /tmp/fifo1 /tmp/fifo2
while read a; do echo "FIFO1: $a"; done < /tmp/fifo1 & exec 7> /tmp/fifo1
exec 8> >(while read a; do echo "FD8: $a, to fd7"; done >&7)

exec 3>&1
(
 (
  (
   while read a; do echo "FIFO2: $a"; done < /tmp/fifo2 | tee /dev/stderr \
   | tee /dev/fd/4 | tee /dev/fd/5 | tee /dev/fd/6 >&7 & exec 3> /tmp/fifo2

   echo 1st, to stdout
   sleep 1
   echo 2nd, to stderr >&2
   sleep 1
   echo 3rd, to fd 3 >&3
   sleep 1
   echo 4th, to fd 4 >&4
   sleep 1
   echo 5th, to fd 5 >&5
   sleep 1
   echo 6th, through a pipe | sed 's/.*/PIPE: &, to fd 5/' >&5
   sleep 1
   echo 7th, to fd 6 >&6
   sleep 1
   echo 8th, to fd 7 >&7
   sleep 1
   echo 9th, to fd 8 >&8

  ) 4>&1 >&3 3>&- | while read a; do echo "FD4: $a"; done 1>&3 5>&- 6>&-
 ) 5>&1 >&3 | while read a; do echo "FD5: $a"; done 1>&3 6>&-
) 6>&1 >&3 | while read a; do echo "FD6: $a"; done 3>&-

rm -f /tmp/fifo1 /tmp/fifo2


# For each command and subshell, figure out which fd points to what.
# Good luck!

exit 0
}
