#lang pollen

◊; This is free and unencumbered software released into the public domain
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

}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
