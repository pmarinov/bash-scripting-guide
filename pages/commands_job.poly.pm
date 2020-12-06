#lang pollen

◊; This is free software released into the public domain
◊; See LICENSE.txt

◊page-init{}
◊define-meta[page-title]{Job Control}
◊define-meta[page-description]{Job Control}

Certain of the following job control commands take a job identifier as
an argument. See the table at end of the chapter.

◊definition-block[#:type "code"]{

◊definition-entry[#:name "jobs"]{
Lists the jobs running in the background, giving the job number. Not
as useful as ◊command{ps}.

Note: It is all too easy to confuse jobs and processes. Certain
builtins, such as ◊command{kill}, ◊command{disown}, and ◊command{wait}
accept either a job number or a process number as an argument. The
◊command{fg}, ◊command{bg} and ◊command{jobs} commands accept only a
job number.

◊example{
bash$ sleep 100 &
[1] 1384

bash$ jobs
[1]+  Running                 sleep 100 &
}

"1" is the job number (jobs are maintained by the current
shell). "1384" is the PID or process ID number (processes are
maintained by the system).

To kill this job/process, invoke ◊command{kill} with one of the two
possible arguments:

◊example{
bash$ kill %1
}

or

◊example{
bash$ kill 1384
}

}

◊definition-entry[#:name "disown"]{
Remove job(s) from the shell's table of active jobs.

}

◊definition-entry[#:name "fg, bg"]{
The ◊command{fg} command switches a job running in the background into
the foreground. The ◊command{bg} command restarts a suspended job, and
runs it in the background. If no job number is specified, then the
◊command{fg} or ◊command{bg} command acts upon the currently running
job.

}

◊definition-entry[#:name "wait"]{
Suspend script execution until all jobs running in background have
terminated, or until the job number or process ID specified as an
option terminates. Returns the exit status of waited-for command.

You may use the ◊command{wait} command to prevent a script from
exiting before a background job finishes executing (this would create
a dreaded orphan process).

◊example{
#!/bin/bash

ROOT_UID=0   # Only users with $UID 0 have root privileges.
E_NOTROOT=65
E_NOPARAMS=66

if [ "$UID" -ne "$ROOT_UID" ]
then
  echo "Must be root to run this script."
  # "Run along kid, it's past your bedtime."
  exit $E_NOTROOT
fi

if [ -z "$1" ]
then
  echo "Usage: `basename $0` find-string"
  exit $E_NOPARAMS
fi


echo "Updating 'locate' database..."
echo "This may take a while."
updatedb /usr &     # Must be run as root.

wait
# Don't run the rest of the script until 'updatedb' finished.
# You want the the database updated before looking up the file name.

locate $1

#  Without the 'wait' command, in the worse case scenario,
#+ the script would exit while 'updatedb' was still running,
#+ leaving it as an orphan process.

exit 0
}

Optionally, ◊command{wait} can take a job identifier (of a child
process) as an argument, for example, ◊command{wait %1} or
◊command{wait $PPID}. See the job id table at the end of this page.

}

◊definition-entry[#:name "suspend"]{
This has a similar effect to ◊kbd{Control-Z}, but it suspends the
shell (the shell's parent process should resume it at an appropriate
time).

}

◊definition-entry[#:name "logout"]{
Exit a login shell, optionally specifying an exit status.

}

◊definition-entry[#:name "times"]{
Gives statistics on the system time elapsed when executing commands,
in the following form:

◊example{
0m0.011s 0m0.005s
0m0.046s 0m0.015s
}

This capability is of relatively limited value, since it is not common
to profile and benchmark shell scripts.

}

◊definition-entry[#:name "kill"]{
Forcibly terminate a process by sending it an appropriate terminate
signal (see TODO Example 17-6).

◊example{
#!/bin/bash
# self-destruct.sh

kill $$  # Script kills its own process here.
         # Recall that "$$" is the script's PID.

echo "This line will not echo."
# Instead, the shell sends a "Terminated" message to stdout.

exit 0   # Normal exit? No!

#  After this script terminates prematurely,
#+ what exit status does it return?
#
# sh self-destruct.sh
# echo $?
# 143
#
# 143 = 128 + 15
#             TERM signal
}

Note: ◊command{kill -l} lists all the signals (as does the file
◊fname{/usr/include/asm/signal.h}). A ◊command{kill -9} is a sure
kill, which will usually terminate a process that stubbornly refuses
to die with a plain ◊command{kill}. Sometimes, a ◊command{kill -15}
works. A zombie process, that is, a child process that has terminated,
but that the parent process has not (yet) killed, cannot be killed by
a logged-on user -- you can't kill something that is already dead --
but init will generally clean it up sooner or later.

}

}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
