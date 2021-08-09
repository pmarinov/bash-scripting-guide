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

}
