#lang pollen

◊; This is free software released into the public domain
◊; See LICENSE.txt

◊page-init{}
◊define-meta[page-title]{Admin Commands}
◊define-meta[page-description]{System and Administrative Commands}

The startup and shutdown scripts in ◊fname{/etc/rc.d} illustrate the uses (and
usefulness) of many of these comands. These are usually invoked by
root and used for system maintenance or emergency filesystem
repairs. Use with caution, as some of these commands may damage your
system if misused.

◊section{"Users and Groups"}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "users"]{
Show all logged on users. This is the approximate equivalent of
◊command{who -q}.

}

◊definition-entry[#:name "groups"]{
Lists the current user and the groups she belongs to. This corresponds
to the ◊code{$GROUPS} internal variable, but gives the group names,
rather than the numbers.

◊example{
bash$ groups
bozita cdrom cdwriter audio xgrp

bash$ echo $GROUPS
501
}

}

◊definition-entry[#:name "chown, chgrp"]{
The ◊command{chown} command changes the ownership of a file or
files. This command is a useful method that root can use to shift file
ownership from one user to another. An ordinary user may not change
the ownership of files, not even her own files.

◊example{
root# chown bozo *.txt
}

The ◊command{chgrp} command changes the group ownership of a file or
files. You must be owner of the file(s) as well as a member of the
destination group (or root) to use this operation.

◊example{
chgrp --recursive dunderheads *.data
#  The "dunderheads" group will now own all the "*.data" files
#+ all the way down the $PWD directory tree (that's what "recursive" means).
}

}

◊definition-entry[#:name "useradd, userdel"]{
The ◊command{useradd} administrative command adds a user account to
the system and creates a home directory for that particular user, if
so specified. The corresponding ◊command{userdel} command removes a
user account from the system and deletes associated files.

}

◊definition-entry[#:name "usermod"]{
Modify a user account. Changes may be made to the password, group
membership, expiration date, and other attributes of a given user's
account. With this command, a user's password may be locked, which has
the effect of disabling the account.

}

◊definition-entry[#:name "groupmod"]{
Modify a given group. The group name and/or ID number may be changed
using this command.

}


◊definition-entry[#:name "id"]{
The ◊command{id} command lists the real and effective user IDs and the
group IDs of the user associated with the current process. This is the
counterpart to the ◊code{$UID}, ◊code{$EUID}, and ◊code{$GROUPS}
internal Bash variables.

◊example{
bash$ id
uid=501(bozo) gid=501(bozo) groups=501(bozo),22(cdrom),80(cdwriter),81(audio)

bash$ echo $UID
501
}

Note: The ◊command{id} command shows the effective IDs only when they
differ from the real ones.

Also see TODO Example 9-5.

}

◊definition-entry[#:name "lid"]{
The ◊command{lid} (list ID) command shows the group(s) that a given
user belongs to, or alternately, the users belonging to a given
group. May be invoked only by root.

◊example{
root# lid bozo
bozo(gid=500)


root# lid daemon
bin(gid=1)
daemon(gid=2)
adm(gid=4)
lp(gid=7)
}

}

◊definition-entry[#:name "who"]{
Show all users logged on to the system.

◊example{
bash$ who
bozo  tty1     Apr 27 17:45
bozo  pts/0    Apr 27 17:46
bozo  pts/1    Apr 27 17:47
bozo  pts/2    Apr 27 17:49
}

The ◊code{-m} gives detailed information about only the current
user. Passing any two arguments to ◊command{who} is the equivalent of
◊command{who -m}, as in ◊command{who am i} or ◊command{who The Man}.

◊example{
bash$ who -m
localhost.localdomain!bozo  pts/2    Apr 27 17:49
}

◊command{whoami} is similar to ◊command{who -m}, but only lists the
user name.

◊example{
bash$ whoami
bozo
}

}

◊definition-entry[#:name "w"]{
Show all logged on users and the processes belonging to them. This is
an extended version of ◊command{who}. The output of ◊command{w} may be
piped to ◊command{grep} to find a specific user and/or process.

◊example{
bash$ w | grep startx
bozo  tty1     -                 4:22pm  6:41   4.47s  0.45s  startx
}

}

◊definition-entry[#:name "logname"]{
Show current user's login name (as found in
◊fname{/var/run/utmp}). This is a near-equivalent to ◊command{whoami},
above.

◊example{
bash$ logname
bozo

bash$ whoami
bozo
}

However . . .

◊example{
bash$ su
Password: ......

bash# whoami
root
bash# logname
bozo
}

Note: While ◊command{logname} prints the name of the logged in user,
◊command{whoami} gives the name of the user attached to the current
process. As we have just seen, sometimes these are not the same.

}

◊definition-entry[#:name "su"]{
}

}
