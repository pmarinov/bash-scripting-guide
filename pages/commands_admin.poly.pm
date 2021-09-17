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
Runs a program or script as a substitute user. ◊command{su rjones}
starts a shell as user rjones. A naked ◊command{su} defaults to
root. See TODO Example A-14.

}

◊definition-entry[#:name "sudo"]{
Runs a command as root (or another user). This may be used in a
script, thus permitting a regular user to run the script.

◊example{
#!/bin/bash

# Some commands.
sudo cp /root/secretfile /home/bozo/secret
# Some more commands.
}

The file ◊fname{/etc/sudoers} holds the names of users permitted to
invoke sudo.

}

◊definition-entry[#:name "passwd"]{
Sets, changes, or manages a user's password.

The ◊command{passwd} command can be used in a script, but probably
should not be.

◊example{
#!/bin/bash
#  setnew-password.sh: For demonstration purposes only.
#                      Not a good idea to actually run this script.
#  This script must be run as root.

ROOT_UID=0         # Root has $UID 0.
E_WRONG_USER=65    # Not root?

E_NOSUCHUSER=70
SUCCESS=0


if [ "$UID" -ne "$ROOT_UID" ]
then
  echo; echo "Only root can run this script."; echo
  exit $E_WRONG_USER
else
  echo
  echo "You should know better than to run this script, root."
  echo "Even root users get the blues... "
  echo
fi


username=bozo
NEWPASSWORD=security_violation

# Check if bozo lives here.
grep -q "$username" /etc/passwd
if [ $? -ne $SUCCESS ]
then
  echo "User $username does not exist."
  echo "No password changed."
  exit $E_NOSUCHUSER
fi

echo "$NEWPASSWORD" | passwd --stdin "$username"
#  The '--stdin' option to 'passwd' permits
#+ getting a new password from stdin (or a pipe).

echo; echo "User $username's password changed!"

# Using the 'passwd' command in a script is dangerous.

exit 0
}

The passwd command's ◊code{-l}, ◊code{-u}, and ◊code{-d} options
permit locking, unlocking, and deleting a user's password. Only root
may use these options.

}

◊definition-entry[#:name "ac"]{
Show users' logged in time, as read from ◊fname{/var/log/wtmp}. This
is one of the GNU accounting utilities.

◊example{
bash$ ac
total       68.08
}

}

◊definition-entry[#:name "last"]{
List last logged in users, as read from ◊fname{/var/log/wtmp}. This
command can also show remote logins.

For example, to show the last few times the system rebooted:

◊example{
bash$ last reboot
reboot   system boot  2.6.9-1.667      Fri Feb  4 18:18          (00:02)
reboot   system boot  2.6.9-1.667      Fri Feb  4 15:20          (01:27)
reboot   system boot  2.6.9-1.667      Fri Feb  4 12:56          (00:49)
reboot   system boot  2.6.9-1.667      Thu Feb  3 21:08          (02:17)
. . .

wtmp begins Tue Feb  1 12:50:09 2005
}

}

◊definition-entry[#:name "newgrp"]{
Change user's group ID without logging out. This permits access to the
new group's files. Since users may be members of multiple groups
simultaneously, this command finds only limited use.

Note: The newgrp command could prove helpful in setting the default
group permissions for files a user writes. However, the
◊command{chgrp} command might be more convenient for this purpose.

}

}

◊section{Terminals}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "tty"]{
Echoes the name (filename) of the current user's terminal. Note that
each separate xterm window counts as a different terminal.

◊example{
bash$ tty
/dev/pts/1
}

}

◊definition-entry[#:name "stty"]{

Shows and/or changes terminal settings. This complex command, used in
a script, can control terminal behavior and the way output
displays. See the info page, and study it carefully

◊example{
bash$ info stty
}

◊anchored-example[#:anchor "stty_erase1"]{Setting an erase character}

◊example{
#!/bin/bash
# erase.sh: Using "stty" to set an erase character when reading input.

echo -n "What is your name? "
read name                      #  Try to backspace
                               #+ to erase characters of input.
                               #  Problems?
echo "Your name is $name."

stty erase '#'                 #  Set "hashmark" (#) as erase character.
echo -n "What is your name? "
read name                      #  Use # to erase last character typed.
echo "Your name is $name."

exit 0

# Even after the script exits, the new key value remains set.
# Exercise: How would you reset the erase character to the default value?
}

◊anchored-example[#:anchor "stty_noecho1"]{secret password: Turning
off terminal echoing}

◊example{
#!/bin/bash
# secret-pw.sh: secret password

echo
echo -n "Enter password "
read passwd
echo "password is $passwd"
echo -n "If someone had been looking over your shoulder, "
echo "your password would have been compromised."

echo && echo  # Two line-feeds in an "and list."


stty -echo    # Turns off screen echo.
#   May also be done with
#   read -sp passwd
#   A big Thank You to Leigh James for pointing this out.

echo -n "Enter password again "
read passwd
echo
echo "password is $passwd"
echo

stty echo     # Restores screen echo.

exit 0

# Do an 'info stty' for more on this useful-but-tricky command.
}

◊anchored-example[#:anchor "stty_kbd"]{Keypress detection}

A creative use of ◊command{stty} is detecting a user keypress (without
hitting ENTER).

◊example{
#!/bin/bash
# keypress.sh: Detect a user keypress ("hot keys").

echo

old_tty_settings=$(stty -g)   # Save old settings (why?).
stty -icanon
Keypress=$(head -c1)          # or $(dd bs=1 count=1 2> /dev/null)
                              # on non-GNU systems

echo
echo "Key pressed was \""$Keypress"\"."
echo

stty "$old_tty_settings"      # Restore old settings.

# Thanks, Stephane Chazelas.

exit 0
}

Also see TODO Example 9-3 and Example A-43.

Normally, a terminal works in the canonical mode. When a user hits a
key, the resulting character does not immediately go to the program
actually running in this terminal. A buffer local to the terminal
stores keystrokes. When the user hits the ENTER key, this sends all
the stored keystrokes to the program running. There is even a basic
line editor inside the terminal.

◊example{
bash$ stty -a
speed 9600 baud; rows 36; columns 96; line = 0;
intr = ^C; quit = ^\; erase = ^H; kill = ^U; eof = ^D; eol = <undef>; eol2 = <undef>;
start = ^Q; stop = ^S; susp = ^Z; rprnt = ^R; werase = ^W; lnext = ^V; flush = ^O;
...
isig icanon iexten echo echoe echok -echonl -noflsh -xcase -tostop -echoprt
}

Using canonical mode, it is possible to redefine the special keys for
the local terminal line editor.

◊example{
bash$ cat > filexxx
wha<ctl-W>I<ctl-H>foo bar<ctl-U>hello world<ENTER>
<ctl-D>
bash$ cat filexxx
hello world
bash$ wc -c < filexxx
12
}


The process controlling the terminal receives only 12 characters (11
alphabetic ones, plus a newline), although the user hit 26 keys.

In non-canonical ("raw") mode, every key hit (including special
editing keys such as ◊kbd{ctl-H}) sends a character immediately to the
controlling process.

The Bash prompt disables both ◊code{icanon} and ◊code{echo}, since it
replaces the basic terminal line editor with its own more elaborate
one. For example, when you hit ◊kbd{ctl-A} at the Bash prompt, there's
no ^A echoed by the terminal, but Bash gets a \1 character, interprets
it, and moves the cursor to the begining of the line.

}

◊definition-entry[#:name "setterm"]{
Set certain terminal attributes. This command writes to its terminal's
stdout a string that changes the behavior of that terminal.

◊example{
bash$ setterm -cursor off
bash$
}

The ◊command{setterm} command can be used within a script to change the
appearance of text written to stdout, although there are certainly
better tools available for this purpose.

◊example{
setterm -bold on
echo bold hello

setterm -bold off
echo normal hello
}

}

◊definition-entry[#:name "tset"]{
Show or initialize terminal settings. This is a less capable version
of ◊command{stty}.

◊example{
bash$ tset -r
Terminal type is xterm-xfree86.
Kill is control-U (^U).
Interrupt is control-C (^C).
}

}

◊definition-entry[#:name "setserial"]{
Set or display serial port parameters. This command must be run by
root and is usually found in a system setup script.

◊example{
# From /etc/pcmcia/serial script:

IRQ=`setserial /dev/$DEVICE | sed -e 's/.*IRQ: //'`
setserial /dev/$DEVICE irq 0 ; setserial /dev/$DEVICE irq $IRQ
}

}

◊definition-entry[#:name "getty, agetty"]{
The initialization process for a terminal uses ◊command{getty} or
◊command{agetty} to set it up for login by a user. These commands are
not used within user shell scripts. Their scripting counterpart is
◊command{stty}.

}

◊definition-entry[#:name "mesg"]{
Enables or disables write access to the current user's
terminal. Disabling access would prevent another user on the network
to write to the terminal.

Tip: It can be quite annoying to have a message about ordering pizza
suddenly appear in the middle of the text file you are editing. On a
multi-user network, you might therefore wish to disable write access
to your terminal when you need to avoid interruptions.

}

◊definition-entry[#:name "wall"]{
This is an acronym for "write all," i.e., sending a message to all
users at every terminal logged into the network. It is primarily a
system administrator's tool, useful, for example, when warning
everyone that the system will shortly go down due to a problem (see
TODO Example 19-1).

◊example{
bash$ wall System going down for maintenance in 5 minutes!
Broadcast message from bozo (pts/1) Sun Jul  8 13:53:27 2001...

System going down for maintenance in 5 minutes!
}

Note: If write access to a particular terminal has been disabled with
◊command{mesg}, then wall cannot send a message to that terminal.

}

}

◊section{Information and Statistics}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "uname"]{
Output system specifications (OS, kernel version, etc.) to
stdout. Invoked with the ◊code{-a} option, gives verbose system info
(see TODO Example 16-5). The ◊code{-s} option shows only the OS type.

◊example{
bash$ uname
Linux

bash$ uname -s
Linux


bash$ uname -a
Linux iron.bozo 2.6.15-1.2054_FC5 #1 Tue Mar 14 15:48:33 EST 2006
i686 i686 i386 GNU/Linux
}

}

◊definition-entry[#:name "arch"]{
Show system architecture. Equivalent to ◊code{uname -m}. See TODO
Example 11-27.

}

◊definition-entry[#:name "lastcomm"]{
Gives information about previous commands, as stored in the
◊fname{/var/account/pacct} file. Command name and user name can be
specified by options. This is one of the GNU accounting utilities.

}

◊definition-entry[#:name "lastlog"]{
List the last login time of all system users. This references the
◊fname{/var/log/lastlog} file.

◊example{
bash$ lastlog
root          tty1                      Fri Dec  7 18:43:21 -0700 2001
bin                                     **Never logged in**
daemon                                  **Never logged in**
...
bozo          tty1                      Sat Dec  8 21:14:29 -0700 2001


bash$ lastlog | grep root
root          tty1                      Fri Dec  7 18:43:21 -0700 2001
}

Caution: This command will fail if the user invoking it does not have
read permission for the ◊fname{/var/log/lastlog} file.

}

◊definition-entry[#:name "lsof"]{
List open files. This command outputs a detailed table of all
currently open files and gives information about their owner, size,
the processes associated with them, and more. Of course,
◊command{lsof} may be piped to ◊command{grep} and/or ◊command{awk} to
parse and analyze its results.

◊example{
bash$ lsof
COMMAND    PID    USER   FD   TYPE     DEVICE    SIZE     NODE NAME
init         1    root  mem    REG        3,5   30748    30303 /sbin/init
init         1    root  mem    REG        3,5   73120     8069 /lib/ld-2.1.3.so
init         1    root  mem    REG        3,5  931668     8075 /lib/libc-2.1.3.so
cardmgr    213    root  mem    REG        3,5   36956    30357 /sbin/cardmgr
...
}

The ◊command{lsof} command is a useful, if complex administrative
tool. If you are unable to dismount a filesystem and get an error
message that it is still in use, then running ◊command{lsof} helps
determine which files are still open on that filesystem. The ◊code{-i}
option lists open network socket files, and this can help trace
intrusion or hack attempts.

◊example{
bash$ lsof -an -i tcp
COMMAND  PID USER  FD  TYPE DEVICE SIZE NODE NAME
firefox 2330 bozo  32u IPv4   9956       TCP 66.0.118.137:57596->67.112.7.104:http ...
firefox 2330 bozo  38u IPv4  10535       TCP 66.0.118.137:57708->216.79.48.24:http ...
}

See TODO Example 30-2 for an effective use of lsof.

}

◊definition-entry[#:name "strace"]{
System trace: diagnostic and debugging tool for tracing system calls
and signals. This command and ◊command{ltrace}, following, are useful
for diagnosing why a given program or package fails to run
. . . perhaps due to missing libraries or related causes.

◊example{
bash$ strace df
execve("/bin/df", ["df"], [/* 45 vars */]) = 0
uname({sys="Linux", node="bozo.localdomain", ...}) = 0
brk(0)                                  = 0x804f5e4

...
}

This is the Linux equivalent of the Solaris ◊command{truss} command.

}

◊definition-entry[#:name "strace"]{
Library trace: diagnostic and debugging tool that traces library calls
invoked by a given command.

◊example{
bash$ ltrace df
__libc_start_main(0x804a910, 1, 0xbfb589a4, 0x804fb70, 0x804fb68 <unfinished ...>:
 setlocale(6, "")                                 = "en_US.UTF-8"
bindtextdomain("coreutils", "/usr/share/locale") = "/usr/share/locale"
textdomain("coreutils")                          = "coreutils"
__cxa_atexit(0x804b650, 0, 0, 0x8052bf0, 0xbfb58908) = 0
getenv("DF_BLOCK_SIZE")                          = NULL

...
}

}

◊definition-entry[#:name "nc"]{
The ◊command{nc} (netcat) utility is a complete toolkit for connecting
to and listening to TCP and UDP ports. It is useful as a diagnostic
and testing tool and as a component in simple script-based HTTP
clients and servers.

◊example{
bash$ nc localhost.localdomain 25
220 localhost.localdomain ESMTP Sendmail 8.13.1/8.13.1;
Thu, 31 Mar 2005 15:41:35 -0700
}

◊anchored-example[#:anchor "nc_identd"]{Checking a remote server for
identd}

◊example{
#! /bin/sh
## Duplicate DaveG's ident-scan thingie using netcat. Oooh, he'll be p*ssed.
## Args: target port [port port port ...]
## Hose stdout _and_ stderr together.
##
##  Advantages: runs slower than ident-scan, giving remote inetd less cause
##+ for alarm, and only hits the few known daemon ports you specify.
##  Disadvantages: requires numeric-only port args, the output sleazitude,
##+ and won't work for r-services when coming from high source ports.
# Script author: Hobbit <hobbit@avian.org>
# Used in ABS Guide with permission.

# ---------------------------------------------------
E_BADARGS=65       # Need at least two args.
TWO_WINKS=2        # How long to sleep.
THREE_WINKS=3
IDPORT=113         # Authentication "tap ident" port.
RAND1=999
RAND2=31337
TIMEOUT0=9
TIMEOUT1=8
TIMEOUT2=4
# ---------------------------------------------------

case "${2}" in
  "" ) echo "Need HOST and at least one PORT." ; exit $E_BADARGS ;;
esac

# Ping 'em once and see if they *are* running identd.
nc -z -w $TIMEOUT0 "$1" $IDPORT || \
{ echo "Oops, $1 isn't running identd." ; exit 0 ; }
#  -z scans for listening daemons.
#     -w $TIMEOUT = How long to try to connect.

# Generate a randomish base port.
RP=`expr $$ % $RAND1 + $RAND2`

TRG="$1"
shift

while test "$1" ; do
  nc -v -w $TIMEOUT1 -p ${RP} "$TRG" ${1} < /dev/null > /dev/null &
  PROC=$!
  sleep $THREE_WINKS
  echo "${1},${RP}" | nc -w $TIMEOUT2 -r "$TRG" $IDPORT 2>&1
  sleep $TWO_WINKS

# Does this look like a lamer script or what . . . ?
# ABS Guide author comments: "Ain't really all that bad . . .
#+                            kinda clever, actually."

  kill -HUP $PROC
  RP=`expr ${RP} + 1`
  shift
done

exit $?

#  Notes:
#  -----

#  Try commenting out line 30 and running this script
#+ with "localhost.localdomain 25" as arguments.

#  For more of Hobbit's 'nc' example scripts,
#+ look in the documentation:
#+ the /usr/share/doc/nc-X.XX/scripts directory.
}

And, of course, there's Dr. Andrew Tridgell's notorious one-line
script in the BitKeeper Affair:

◊example{
echo clone | nc thunk.org 5000 > e2fsprogs.dat
}

}

◊definition-entry[#:name "free"]{
Shows memory and cache usage in tabular form. The output of this
command lends itself to parsing, using ◊command{grep}, ◊command{awk}
or ◊command{Perl}. The ◊command{procinfo} command shows all the
information that free does, and much more.

◊example{
bash$ free
             total       used       free     shared    buffers     cached
Mem:         30504      28624       1880      15820       1608       16376
-/+ buffers/cache:      10640      19864
Swap:        68540       3128      65412
}

}

◊definition-entry[#:name "procinfo"]{
Extract and list information and statistics from the ◊fname{/proc}
pseudo-filesystem. This gives a very extensive and detailed listing.

◊example{
bash$ procinfo | grep Bootup
Bootup: Wed Mar 21 15:15:50 2001    Load average: 0.04 0.21 0.34 3/47 6829
}

}

◊definition-entry[#:name "lsdev"]{
List devices, that is, show installed hardware.

◊example{
bash$ lsdev
Device            DMA   IRQ  I/O Ports
------------------------------------------------
cascade             4     2
dma                          0080-008f
dma1                         0000-001f
dma2                         00c0-00df
fpu                          00f0-00ff
ide0                     14  01f0-01f7 03f6-03f6
...
}

}

◊definition-entry[#:name "du"]{
Show (disk) file usage, recursively. Defaults to current working
directory, unless otherwise specified.

◊example{
bash$ du -ach
1.0k    ./wi.sh
1.0k    ./tst.sh
1.0k    ./random.file
6.0k    .
6.0k    total
}

}

◊definition-entry[#:name "df"]{
Shows filesystem usage in tabular form.

◊example{
bash$ df
Filesystem           1k-blocks      Used Available Use% Mounted on
/dev/hda5               273262     92607    166547  36% /
/dev/hda8               222525    123951     87085  59% /home
/dev/hda7              1408796   1075744    261488  80% /usr
}

}

◊definition-entry[#:name "dmesg"]{
Lists all system bootup messages to stdout. Handy for debugging and
ascertaining which device drivers were installed and which system
interrupts in use. The output of ◊command{dmesg} may, of course, be
parsed with ◊command{grep}, ◊command{sed}, or ◊command{awk} from
within a script.

◊example{
bash$ dmesg | grep hda
Kernel command line: ro root=/dev/hda2
hda: IBM-DLGA-23080, ATA DISK drive
hda: 6015744 sectors (3080 MB) w/96KiB Cache, CHS=746/128/63
hda: hda1 hda2 hda3 < hda5 hda6 hda7 > hda4
}

}

◊definition-entry[#:name "stat"]{
Gives detailed and verbose statistics on a given file (even a
directory or device file) or set of files.

◊example{
bash$ stat test.cru
 File: "test.cru"
 Size: 49970        Allocated Blocks: 100          Filetype: Regular File
 Mode: (0664/-rw-rw-r--)         Uid: (  501/ bozo)  Gid: (  501/ bozo)
Device:  3,8   Inode: 18185     Links: 1
Access: Sat Jun  2 16:40:24 2001
Modify: Sat Jun  2 16:40:24 2001
Change: Sat Jun  2 16:40:24 2001

}

In a script, you can use stat to extract information about files (and
filesystems) and set variables accordingly.

◊example{
#!/bin/bash
# fileinfo2.sh

# Per suggestion of Joël Bourquard and . . .
# http://www.linuxquestions.org/questions/showthread.php?t=410766


FILENAME=testfile.txt
file_name=$(stat -c%n "$FILENAME")   # Same as "$FILENAME" of course.
file_owner=$(stat -c%U "$FILENAME")
file_size=$(stat -c%s "$FILENAME")
#  Certainly easier than using "ls -l $FILENAME"
#+ and then parsing with sed.
file_inode=$(stat -c%i "$FILENAME")
file_type=$(stat -c%F "$FILENAME")
file_access_rights=$(stat -c%A "$FILENAME")

echo "File name:          $file_name"
echo "File owner:         $file_owner"
echo "File size:          $file_size"
echo "File inode:         $file_inode"
echo "File type:          $file_type"
echo "File access rights: $file_access_rights"

exit 0

sh fileinfo2.sh

File name:          testfile.txt
File owner:         bozo
File size:          418
File inode:         1730378
File type:          regular file
File access rights: -rw-rw-r--
}

}

◊definition-entry[#:name "vmstat"]{
Display virtual memory statistics.

◊example{
bash$ vmstat
  procs                      memory    swap          io system         cpu
r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy id
0  0  0      0  11040   2636  38952   0   0    33     7  271    88   8   3 89

}

}

◊definition-entry[#:name "uptime"]{
Shows how long the system has been running, along with associated statistics.

◊example{
bash$ uptime
10:28pm  up  1:57,  3 users,  load average: 0.17, 0.34, 0.27
}

}

◊definition-entry[#:name "hostname"]{
Lists the system's host name. This command sets the host name in an
◊fname{/etc/rc.d} setup script (◊fname{/etc/rc.d/rc.sysinit} or
similar). It is equivalent to ◊command{uname -n}, and a counterpart to
the $HOSTNAME internal variable.

◊example{
bash$ hostname
localhost.localdomain

bash$ echo $HOSTNAME
localhost.localdomain
}

Similar to the ◊command{hostname} command are the
◊command{domainname}, ◊command{dnsdomainname},
◊command{nisdomainname}, and ◊command{ypdomainname} commands. Use
these to display or set the system DNS or NIS/YP domain name. Various
options to ◊command{hostname} also perform these functions.

}

◊definition-entry[#:name "hostid"]{
Echo a 32-bit hexadecimal numerical identifier for the host machine.

◊example{
bash$ hostid
7f0100
}

Note: This command allegedly fetches a "unique" serial number for a
particular system. Certain product registration procedures use this
number to brand a particular user license. Unfortunately,
◊command{hostid} only returns the machine network address in
hexadecimal, with pairs of bytes transposed.

The network address of a typical non-networked Linux machine, is found
in ◊fname{/etc/hosts}.

◊example{
bash$ cat /etc/hosts
127.0.0.1               localhost.localdomain localhost
}

As it happens, transposing the bytes of 127.0.0.1, we get 0.127.1.0,
which translates in hex to 007f0100, the exact equivalent of what
◊command{hostid} returns, above. There exist only a few million other Linux
machines with this identical ◊command{hostid}.

}

◊definition-entry[#:name "sar"]{
Invoking ◊command{sar} (System Activity Reporter) gives a very
detailed rundown on system statistics. The Santa Cruz Operation ("Old"
SCO) released sar as Open Source in June, 1999.

This command is not part of the base Linux distribution, but may be
obtained as part of the ◊code{sysstat} utilities package, written by
Sebastien Godard.

◊example{
bash$ sar
Linux 2.4.9 (brooks.seringas.fr) 	09/26/03

10:30:00          CPU     %user     %nice   %system   %iowait     %idle
10:40:00          all      2.21     10.90     65.48      0.00     21.41
10:50:00          all      3.36      0.00     72.36      0.00     24.28
11:00:00          all      1.12      0.00     80.77      0.00     18.11
Average:          all      2.23      3.63     72.87      0.00     21.27

14:32:30          LINUX RESTART

15:00:00          CPU     %user     %nice   %system   %iowait     %idle
15:10:00          all      8.59      2.40     17.47      0.00     71.54
15:20:00          all      4.07      1.00     11.95      0.00     82.98
15:30:00          all      0.79      2.94      7.56      0.00     88.71
Average:          all      6.33      1.70     14.71      0.00     77.26
}

}

◊definition-entry[#:name "readelf"]{
Show information and statistics about a designated elf binary. This is
part of the binutils package.

◊example{
bash$ readelf -h /bin/bash
ELF Header:
   Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00
   Class:                             ELF32
   Data:                              2's complement, little endian
   Version:                           1 (current)
   OS/ABI:                            UNIX - System V
   ABI Version:                       0
   Type:                              EXEC (Executable file)
   . . .
}

}

◊definition-entry[#:name "size"]{
The ◊command{size [/path/to/binary]} command gives the segment sizes
of a binary executable or archive file. This is mainly of use to
programmers.

◊example{
bash$ size /bin/bash
   text    data     bss     dec     hex filename
  495971   22496   17392  535859   82d33 /bin/bash
}

}

}

◊section{System Logs}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "logger"]{
Appends a user-generated message to the system log
(◊fname{/var/log/messages}). You do not have to be root to invoke
logger.

◊example{
logger Experiencing instability in network connection at 23:10, 05/21.
# Now, do a 'tail /var/log/messages'.
}

By embedding a logger command in a script, it is possible to write
debugging information to ◊fname{/var/log/messages}.

◊example{
logger -t $0 -i Logging at line "$LINENO".
# The "-t" option specifies the tag for the logger entry.
# The "-i" option records the process ID.

# tail /var/log/message
# ...
# Jul  7 20:48:58 localhost ./test.sh[1712]: Logging at line 3.
}

On a Linux with systemd, use ◊command{journalctl} to access the system
log:

◊example{
bash$ logger "Zzz"

bash$ journalctl | tail
...
Aug 24 21:44:50 bongo-vm bongo-user[196586]: Zzz

}

}

◊definition-entry[#:name "logrotate"]{
This utility manages the system log files, rotating, compressing,
deleting, and/or e-mailing them, as appropriate. This keeps the
◊fname{/var/log} from getting cluttered with old log files. Usually
◊command{cron} runs ◊command{logrotate} on a daily basis.

Adding an appropriate entry to ◊fname{/etc/logrotate.conf} makes it
possible to manage personal log files, as well as system-wide ones.

Note: Stefano Falsetto has created ◊command{rottlog}, which he
considers to be an improved version of ◊command{logrotate}.

}

}

◊section{Job Control}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "ps"]{

Process Statistics: lists currently executing processes by owner and
PID (process ID). This is usually invoked with ax or aux options, and
may be piped to grep or sed to search for a specific process (see
TODO Example 15-14 and Example 29-3).

◊example{
bash$  ps ax | grep sendmail
295 ?  S  0:00 sendmail: accepting connections on port 25
}

To display system processes in graphical "tree" format: ◊command{ps
afjx} or ◊command{ps ax --forest.}

}

◊definition-entry[#:name "pgrep, pkill"]{
Combining the ◊command{ps} command with ◊command{grep} or
◊command{kill}.

bash$ ps a | grep mingetty
2212 tty2     Ss+    0:00 /sbin/mingetty tty2
2213 tty3     Ss+    0:00 /sbin/mingetty tty3
2214 tty4     Ss+    0:00 /sbin/mingetty tty4
2215 tty5     Ss+    0:00 /sbin/mingetty tty5
2216 tty6     Ss+    0:00 /sbin/mingetty tty6
4849 pts/2    S+     0:00 grep mingetty

bash$ pgrep mingetty
2212 mingetty
2213 mingetty
2214 mingetty
2215 mingetty
2216 mingetty

Compare the action of ◊command{pkill} with ◊command{killall}.

}

◊definition-entry[#:name "pstree"]{
Lists currently executing processes in "tree" format. The ◊code{-p}
option shows the PIDs, as well as the process names.

}

◊definition-entry[#:name "top"]{
Continuously updated display of most cpu-intensive processes. The
◊code{-b} option displays in text mode, so that the output may be
parsed or accessed from a script.

◊example{
bash$ top -b
8:30pm  up 3 min,  3 users,  load average: 0.49, 0.32, 0.13
45 processes: 44 sleeping, 1 running, 0 zombie, 0 stopped
CPU states: 13.6% user,  7.3% system,  0.0% nice, 78.9% idle
Mem:    78396K av,   65468K used,   12928K free,       0K shrd,    2352K buff
Swap:  157208K av,       0K used,  157208K free                   37244K cached

PID USER     PRI  NI  SIZE  RSS SHARE STAT %CPU %MEM   TIME COMMAND
848 bozo      17   0   996  996   800 R     5.6  1.2   0:00 top
  1 root       8   0   512  512   444 S     0.0  0.6   0:04 init
  2 root       9   0     0    0     0 SW    0.0  0.0   0:00 keventd
...
}

}

◊definition-entry[#:name "nice"]{
Run a background job with an altered priority. Priorities run from 19
(lowest) to -20 (highest). Only root may set the negative (higher)
priorities. Related commands are ◊command{renice} and ◊command{snice},
which change the priority of a running process or processes, and
◊command{skill}, which sends a kill signal to a process or processes.

}

◊definition-entry[#:name "nohup"]{
Keeps a command running even after user logs off. The command will run
as a foreground process unless followed by ◊code{&}. If you use
◊command{nohup} within a script, consider coupling it with a
◊command{wait} to avoid creating an orphan or zombie process.

}

◊definition-entry[#:name "pidof"]{
Identifies process ID (PID) of a running job. Since job control
commands, such as ◊command{kill} and ◊command{renice} act on the PID
of a process (not its name), it is sometimes necessary to identify
that PID. The pidof command is the approximate counterpart to the
$PPID internal variable.

◊example{
bash$ pidof xclock
880
}

◊anchored-example[#:anchor "pid_kill1"]{pidof helps kill a process}

◊example{
#!/bin/bash
# kill-process.sh

NOPROCESS=2

process=xxxyyyzzz  # Use nonexistent process.
# For demo purposes only...
# ... don't want to actually kill any actual process with this script.
#
# If, for example, you wanted to use this script to logoff the Internet,
#     process=pppd

t=`pidof $process`       # Find pid (process id) of $process.
# The pid is needed by 'kill' (can't 'kill' by program name).

if [ -z "$t" ]           # If process not present, 'pidof' returns null.
then
  echo "Process $process was not running."
  echo "Nothing killed."
  exit $NOPROCESS
fi

kill $t                  # May need 'kill -9' for stubborn process.

# Need a check here to see if process allowed itself to be killed.
# Perhaps another " t=`pidof $process` " or ...


# This entire script could be replaced by
#        kill $(pidof -x process_name)
# or
#        killall process_name
# but it would not be as instructive.

exit 0
}

}

◊definition-entry[#:name "fuser"]{
Identifies the processes (by PID) that are accessing a given file, set
of files, or directory. May also be invoked with the ◊code{-k} option,
which kills those processes. This has interesting implications for
system security, especially in scripts preventing unauthorized users
from accessing system services.

◊example{
bash$ fuser -u /usr/bin/vim
/usr/bin/vim:         3207e(bozo)

bash$ fuser -u /dev/null
/dev/null:            3009(bozo)  3010(bozo)  3197(bozo)  3199(bozo)
}

One important application for ◊command{fuser} is when physically
inserting or removing storage media, such as CD ROM disks or USB flash
drives. Sometimes trying a ◊command{umount} fails with a device is
busy error message. This means that some user(s) and/or process(es)
are accessing the device. An ◊command{fuser -um /dev/device_name} will
clear up the mystery, so you can kill any relevant processes.

◊example{
bash$ umount /mnt/usbdrive
umount: /mnt/usbdrive: device is busy

bash$ fuser -um /dev/usbdrive
/mnt/usbdrive:        1772c(bozo)

bash$ kill -9 1772
bash$ umount /mnt/usbdrive
}

The ◊command{fuser} command, invoked with the ◊code{-n} option
identifies the processes accessing a port. This is especially useful
in combination with ◊command{nmap}.

◊example{
root# nmap localhost.localdomain
PORT     STATE SERVICE
25/tcp   open  smtp

root# fuser -un tcp 25
25/tcp:               2095(root)

root# ps ax | grep 2095 | grep -v grep
2095 ?        Ss     0:00 sendmail: accepting connections
}

}

◊definition-entry[#:name "cron"]{
Administrative program scheduler, performing such duties as cleaning
up and deleting system log files and updating the slocate
database. This is the superuser version of ◊command{at} (although each
user may have their own ◊fname{crontab} file which can be changed with
the ◊command{crontab} command). It runs as a daemon and executes
scheduled entries from ◊fname{/etc/crontab}.

Note: Some flavors of Linux run ◊command{crond}, Matthew Dillon's
version of ◊command{cron}.

}

}

◊section{Process Control and Booting}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "init"]{
The ◊command{init} command is the parent of all processes. Called in
the final step of a bootup, ◊command{init} determines the runlevel of
the system from ◊fname{/etc/inittab}. Invoked by its alias
◊command{telinit}, and by root only.

}

◊definition-entry[#:name "telinit"]{
Symlinked to ◊command{init}, this is a means of changing the system
runlevel, usually done for system maintenance or emergency filesystem
repairs. Invoked only by root. This command can be dangerous -- be
certain you understand it well before using!

}

◊definition-entry[#:name "runlevel"]{
Shows the current and last runlevel, that is, whether the system is
halted (runlevel 0), in single-user mode (1), in multi-user mode (2 or
3), in X Windows (5), or rebooting (6). This command accesses the
◊fname{/var/run/utmp} file.

}

◊definition-entry[#:name "halt, shutdown, reboot"]{
Command set to shut the system down, usually just prior to a power
down.

Warning: On some Linux distros, the ◊command{halt} command has 755
permissions, so it can be invoked by a non-root user. A careless halt
in a terminal or a script may shut down the system!

}

◊definition-entry[#:name "service"]{
Starts or stops a system service. The startup scripts in
◊fname{/etc/init.d} and ◊fname{/etc/rc.d} use this command to start
services at bootup.

◊example{
root# /sbin/service iptables stop
Flushing firewall rules:                                   [  OK  ]
Setting chains to policy ACCEPT: filter                    [  OK  ]
Unloading iptables modules:                                [  OK  ]
}

}

}

◊section{Network}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "nmap"]{
Network mapper and port scanner. This command scans a server to locate
open ports and the services associated with those ports. It can also
report information about packet filters and firewalls. This is an
important security tool for locking down a network against hacking
attempts.

◊example{
#!/bin/bash

SERVER=$HOST                           # localhost.localdomain (127.0.0.1).
PORT_NUMBER=25                         # SMTP port.

nmap $SERVER | grep -w "$PORT_NUMBER"  # Is that particular port open?
#              grep -w matches whole words only,
#+             so this wouldn't match port 1025, for example.

exit 0

# 25/tcp     open        smtp
}

}

◊definition-entry[#:name "ifconfig"]{
Network interface configuration and tuning utility.

◊example{
bash$ ifconfig -a
lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:10 errors:0 dropped:0 overruns:0 frame:0
          TX packets:10 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:700 (700.0 b)  TX bytes:700 (700.0 b)
}

The ◊command{ifconfig} command is most often used at bootup to set up
the interfaces, or to shut them down when rebooting.

◊example{
# Code snippets from /etc/rc.d/init.d/network

# ...

# Check that networking is up.
[ ${NETWORKING} = "no" ] && exit 0

[ -x /sbin/ifconfig ] || exit 0

# ...

for i in $interfaces ; do
  if ifconfig $i 2>/dev/null | grep -q "UP" >/dev/null 2>&1 ; then
    action "Shutting down interface $i: " ./ifdown $i boot
  fi
#  The GNU-specific "-q" option to "grep" means "quiet", i.e.,
#+ producing no output.
#  Redirecting output to /dev/null is therefore not strictly necessary.

# ...

echo "Currently active devices:"
echo `/sbin/ifconfig | grep ^[a-z] | awk '{print $1}'`
#                            ^^^^^  should be quoted to prevent globbing.
#  The following also work.
#    echo $(/sbin/ifconfig | awk '/^[a-z]/ { print $1 })'
#    echo $(/sbin/ifconfig | sed -e 's/ .*//')
#  Thanks, S.C., for additional comments
}

See also TODO  Example 32-6.

}

◊definition-entry[#:name "netstat"]{
Show current network statistics and information, such as routing
tables and active connections. This utility accesses information in
◊fname{/proc/net} (TODO Chapter 29). See TODO Example 29-4.

◊command{netstat -r} is equivalent to ◊command{route}.

◊example{
bash$ netstat
Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
Active UNIX domain sockets (w/o servers)
Proto RefCnt Flags       Type       State         I-Node Path
unix  11     [ ]         DGRAM                    906    /dev/log
unix  3      [ ]         STREAM     CONNECTED     4514   /tmp/.X11-unix/X0
unix  3      [ ]         STREAM     CONNECTED     4513
. . .
}

Note: A ◊command{netstat -lptu} shows sockets that are listening to
ports, and the associated processes. This can be useful for
determining whether a computer has been hacked or compromised.

}

◊definition-entry[#:name "iwconfig"]{
This is the command set for configuring a wireless network. It is the
wireless equivalent of ◊command{ifconfig}, above.

}

◊definition-entry[#:name "ip"]{
General purpose utility for setting up, changing, and analyzing IP
(Internet Protocol) networks and attached devices. This command is
part of the iproute2 package.

◊example{
bash$ ip link show
1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:d0:59:ce:af:da brd ff:ff:ff:ff:ff:ff
3: sit0: <NOARP> mtu 1480 qdisc noop
    link/sit 0.0.0.0 brd 0.0.0.0


bash$ ip route list
169.254.0.0/16 dev lo  scope link
}

Or, in a script:

◊example{
#!/bin/bash
# Script by Juan Nicolas Ruiz
# Used with his kind permission.

# Setting up (and stopping) a GRE tunnel.


# --- start-tunnel.sh ---

LOCAL_IP="192.168.1.17"
REMOTE_IP="10.0.5.33"
OTHER_IFACE="192.168.0.100"
REMOTE_NET="192.168.3.0/24"

/sbin/ip tunnel add netb mode gre remote $REMOTE_IP \
  local $LOCAL_IP ttl 255
/sbin/ip addr add $OTHER_IFACE dev netb
/sbin/ip link set netb up
/sbin/ip route add $REMOTE_NET dev netb

exit 0  #############################################

# --- stop-tunnel.sh ---

REMOTE_NET="192.168.3.0/24"

/sbin/ip route del $REMOTE_NET dev netb
/sbin/ip link set netb down
/sbin/ip tunnel del netb

exit 0
}

}

◊definition-entry[#:name "route"]{
Show info about or make changes to the kernel routing table.

◊example{
bash$ route
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
pm3-67.bozosisp *               255.255.255.255 UH       40 0          0 ppp0
127.0.0.0       *               255.0.0.0       U        40 0          0 lo
default         pm3-67.bozosisp 0.0.0.0         UG       40 0          0 ppp0
}

}

◊definition-entry[#:name "iptables"]{
The ◊command{iptables} command set is a packet filtering tool used mainly for
such security purposes as setting up network firewalls. This is a
complex tool, and a detailed explanation of its use is beyond the
scope of this document. Oskar Andreasson's tutorial is a reasonable
starting point.

See also shutting down iptables and TODO Example 30-2.

}

◊definition-entry[#:name "chkconfig"]{
Check network and system configuration. This command lists and manages
the network and system services started at bootup in the
◊command{/etc/rc?.d} directory.

Originally a port from IRIX to Red Hat Linux, ◊command{chkconfig} may
not be part of the core installation of some Linux flavors.

◊example{
bash$ chkconfig --list
atd             0:off   1:off   2:off   3:on    4:on    5:on    6:off
rwhod           0:off   1:off   2:off   3:off   4:off   5:off   6:off
...
}

}

◊definition-entry[#:name "tcpdump"]{
Network packet "sniffer." This is a tool for analyzing and
troubleshooting traffic on a network by dumping packet headers that
match specified criteria.

Dump ip packet traffic between hosts bozoville and caduceus:

◊example{
bash$ tcpdump ip host bozoville and caduceus
}

Of course, the output of tcpdump can be parsed with certain of the
previously discussed text processing utilities.

}

}

◊section{Filesystem}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "mount"]{
Mount a filesystem, usually on an external device, such as a floppy or
CDROM. The file ◊fname{/etc/fstab} provides a handy listing of
available filesystems, partitions, and devices, including options,
that may be automatically or manually mounted. The file
◊fname{/etc/mtab} shows the currently mounted filesystems and
partitions (including the virtual ones, such as ◊fname{/proc}).

◊command{mount -a} mounts all filesystems and partitions listed in
◊fname{/etc/fstab}, except those with a ◊code{noauto} option. At
bootup, a startup script in ◊fname{/etc/rc.d} (◊code{rc.sysinit} or
something similar) invokes this to get everything mounted.

◊example{
mount -t iso9660 /dev/cdrom /mnt/cdrom
# Mounts CD ROM. ISO 9660 is a standard CD ROM filesystem.
mount /mnt/cdrom
# Shortcut, if /mnt/cdrom listed in /etc/fstab
}

◊anchored-example[#:anchor "mount_cd1"]{Checking a CD image}
The versatile ◊command{mount} command can even mount an ordinary file
on a block device, and the file will act as if it were a
filesystem. Mount accomplishes that by associating the file with a
loopback device. One application of this is to mount and examine an
ISO9660 filesystem image before burning it onto a CD-R. [3]

◊example{
# As root...

mkdir /mnt/cdtest  # Prepare a mount point, if not already there.

mount -r -t iso9660 -o loop cd-image.iso /mnt/cdtest   # Mount the image.
#                  "-o loop" option equivalent to "losetup /dev/loop0"
cd /mnt/cdtest     # Now, check the image.
ls -alR            # List the files in the directory tree there.
                   # And so forth.
}

}

◊definition-entry[#:name "umount"]{
Unmount a currently mounted filesystem. Before physically removing a
previously mounted floppy or CDROM disk, the device must be umounted,
else filesystem corruption may result.

◊example{
umount /mnt/cdrom
# You may now press the eject button and safely remove the disk.
}

Note: The ◊command{automount} utility, if properly installed, can mount and
unmount floppies or CDROM disks as they are accessed or removed. On
"multispindle" laptops with swappable floppy and optical drives, this
can cause problems, however.

}

◊definition-entry[#:name "gnome-mount"]{
The newer Linux distros have deprecated ◊command{mount} and
◊command{umount}. The successor, for command-line mounting of
removable storage devices, is ◊command{gnome-mount}. It can take the
◊code{-d} option to mount a device file by its listing in
◊fname{/dev}.

For example, to mount a USB flash drive:

◊example{
bash$ gnome-mount -d /dev/sda1
gnome-mount 0.4

bash$ df
. . .
/dev/sda1                63584     12034     51550  19% /media/disk
}

}

◊definition-entry[#:name "sync"]{
Forces an immediate write of all updated data from buffers to hard
drive (synchronize drive with buffers). While not strictly necessary,
a ◊command{sync} assures the sys admin or user that the data just
changed will survive a sudden power failure. In the olden days, a
◊command{sync; sync} (twice, just to make absolutely sure) was a
useful precautionary measure before a system reboot.

At times, you may wish to force an immediate buffer flush, as when
securely deleting a file (see Example 16-61) or when the lights begin
to flicker.

}

◊definition-entry[#:name "losetup"]{
Sets up and configures loopback devices.

◊anchored-example[#:anchor "mount_lpback1"]{Creating a filesystem in a file}

◊example{
SIZE=1000000  # 1 meg

head -c $SIZE < /dev/zero > file  # Set up file of designated size.
losetup /dev/loop0 file           # Set it up as loopback device.
mke2fs /dev/loop0                 # Create filesystem.
mount -o loop /dev/loop0 /mnt     # Mount it.
}

}

◊definition-entry[#:name "mkswap"]{
Creates a swap partition or file. The swap area must subsequently be
enabled with ◊command{swapon}.

}

◊definition-entry[#:name "swapon, swapoff"]{
Enable / disable swap partitition or file. These commands usually take
effect at bootup and shutdown.

}

◊definition-entry[#:name "mke2fs"]{
Create a Linux ext2 filesystem. This command must be invoked as root.

◊anchored-example[#:anchor "mkfs_hdd1"]{Adding a new hard drive}

◊example{
#!/bin/bash

# Adding a second hard drive to system.
# Software configuration. Assumes hardware already mounted.
# From an article by the author of the ABS Guide.
# In issue #38 of _Linux Gazette_, http://www.linuxgazette.com.

ROOT_UID=0     # This script must be run as root.
E_NOTROOT=67   # Non-root exit error.

if [ "$UID" -ne "$ROOT_UID" ]
then
  echo "Must be root to run this script."
  exit $E_NOTROOT
fi

# Use with extreme caution!
# If something goes wrong, you may wipe out your current filesystem.


NEWDISK=/dev/hdb         # Assumes /dev/hdb vacant. Check!
MOUNTPOINT=/mnt/newdisk  # Or choose another mount point.


fdisk $NEWDISK
mke2fs -cv $NEWDISK1   # Check for bad blocks (verbose output).
#  Note:           ^     /dev/hdb1, *not* /dev/hdb!
mkdir $MOUNTPOINT
chmod 777 $MOUNTPOINT  # Makes new drive accessible to all users.


# Now, test ...
# mount -t ext2 /dev/hdb1 /mnt/newdisk
# Try creating a directory.
# If it works, umount it, and proceed.

# Final step:
# Add the following line to /etc/fstab.
# /dev/hdb1  /mnt/newdisk  ext2  defaults  1 1

exit
}

See also TODO Example 17-8 and Example 31-3.

}

◊definition-entry[#:name "mkdosfs"]{
Create a DOS FAT filesystem.

}

◊definition-entry[#:name "tune2fs"]{
Tune ext2 filesystem. May be used to change filesystem parameters,
such as maximum mount count. This must be invoked as root.

Warning: This is an extremely dangerous command. Use it at your own
risk, as you may inadvertently destroy your filesystem.

}

◊definition-entry[#:name "dumpe2fs"]{
Dump (list to stdout) very verbose filesystem info. This must be
invoked as root.

◊example{
root# dumpe2fs /dev/hda7 | grep 'ount count'
dumpe2fs 1.19, 13-Jul-2000 for EXT2 FS 0.5b, 95/08/09
Mount count:              6
Maximum mount count:      20
}

}

◊definition-entry[#:name "hdparm"]{
List or change hard disk parameters. This command must be invoked as
root, and it may be dangerous if misused.

}

◊definition-entry[#:name "fdisk"]{
Create or change a partition table on a storage device, usually a hard
drive. This command must be invoked as root.

Warning: Use this command with extreme caution. If something goes
wrong, you may destroy an existing filesystem.

}

◊definition-entry[#:name "fsck, e2fsck, debugfs"]{
Filesystem check, repair, and debug command set.

◊command{fsck}: a front end for checking a UNIX filesystem (may invoke
other utilities). The actual filesystem type generally defaults to
ext2.

◊command{e2fsck}: ext2 filesystem checker.

◊command{debugfs}: ext2 filesystem debugger. One of the uses of this
versatile, but dangerous command is to (attempt to) recover deleted
files. For advanced users only!

Caution: All of these should be invoked as root, and they can damage
or destroy a filesystem if misused.

}

◊definition-entry[#:name "badblocks"]{
Checks for bad blocks (physical media flaws) on a storage device. This
command finds use when formatting a newly installed hard drive or
testing the integrity of backup media. [4] As an example, badblocks
◊fname{/dev/fd0} tests a floppy disk.

The ◊command{badblocks} command may be invoked destructively
(overwrite all data) or in non-destructive read-only mode. If root
user owns the device to be tested, as is generally the case, then root
must invoke this command.

}

◊definition-entry[#:name "lsusb, usbmodules"]{
The ◊command{lsusb} command lists all USB (Universal Serial Bus) buses
and the devices hooked up to them.

The ◊command{usbmodules} command outputs information about the driver
modules for connected USB devices.

◊example{
bash$ lsusb
Bus 001 Device 001: ID 0000:0000
 Device Descriptor:
   bLength                18
   bDescriptorType         1
   bcdUSB               1.00
   bDeviceClass            9 Hub
   bDeviceSubClass         0
   bDeviceProtocol         0
   bMaxPacketSize0         8
   idVendor           0x0000
   idProduct          0x0000

   . . .
}

}

◊definition-entry[#:name "lspci"]{
Lists pci busses present.

◊example{
bash$ lspci
00:00.0 Host bridge: Intel Corporation 82845 845
(Brookdale) Chipset Host Bridge (rev 04)
00:01.0 PCI bridge: Intel Corporation 82845 845
(Brookdale) Chipset AGP Bridge (rev 04)
00:1d.0 USB Controller: Intel Corporation 82801CA/CAM USB (Hub #1) (rev 02)
00:1d.1 USB Controller: Intel Corporation 82801CA/CAM USB (Hub #2) (rev 02)
00:1d.2 USB Controller: Intel Corporation 82801CA/CAM USB (Hub #3) (rev 02)
00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev 42)

. . .
}

}

◊definition-entry[#:name "mkbootdisk"]{
Creates a boot floppy which can be used to bring up the system if, for
example, the MBR (master boot record) becomes corrupted. Of special
interest is the ◊code{--iso} option, which uses ◊command{mkisofs} to
create a bootable ISO9660 filesystem image suitable for burning a
bootable CDR.

The ◊command{mkbootdisk} command is actually a Bash script, written by
Erik Troan, in the ◊command{/sbin} directory.

}

◊definition-entry[#:name "mkisofs"]{
Creates an ISO9660 filesystem suitable for a CDR image.

}

◊definition-entry[#:name "chroot"]{
CHange ROOT directory. Normally commands are fetched from $PATH,
relative to ◊fname{/}, the default root directory. This changes the
root directory to a different one (and also changes the working
directory to there). This is useful for security purposes, for
instance when the system administrator wishes to restrict certain
users, such as those telnetting in, to a secured portion of the
filesystem (this is sometimes referred to as confining a guest user to
a "chroot jail"). Note that after a ◊command{chroot}, the execution
path for system binaries is no longer valid.

A ◊command{chroot /opt} would cause references to ◊fname{/usr/bin} to
be translated to ◊fname{/opt/usr/bin}. Likewise, ◊command{chroot
/aaa/bbb /bin/ls} would redirect future instances of ◊command{ls} to
◊fname{/aaa/bbb} as the base directory, rather than ◊fname{/} as is
normally the case. An ◊command{alias XX 'chroot /aaa/bbb ls'} in a
user's ◊fname{~/.bashrc} effectively restricts which portion of the
filesystem she may run command "XX" on.

The ◊command{chroot} command is also handy when running from an
emergency boot floppy (◊command{chroot} to ◊fname{/dev/fd0}), or as an
option to lilo when recovering from a system crash. Other uses include
installation from a different filesystem (an rpm option) or running a
readonly filesystem from a CD ROM. Invoke only as root, and use with
care.

Caution: It might be necessary to copy certain system files to a
chrooted directory, since the normal $PATH can no longer be relied
upon.
}

◊definition-entry[#:name "lockfile"]{
This utility is part of the procmail package (www.procmail.org). It
creates a lock file, a semaphore that controls access to a file,
device, or resource.

Definition: A semaphore is a flag or signal. (The usage originated in
railroading, where a colored flag, lantern, or striped movable arm
semaphore indicated whether a particular track was in use and
therefore unavailable for another train.) A UNIX process can check the
appropriate semaphore to determine whether a particular resource is
available/accessible.

The lock file serves as a flag that this particular file, device, or
resource is in use by a process (and is therefore "busy"). The
presence of a lock file permits only restricted access (or no access)
to other processes.

◊example{
lockfile /home/bozo/lockfiles/$0.lock
# Creates a write-protected lockfile prefixed with the name of the script.

lockfile /home/bozo/lockfiles/${0##*/}.lock
# A safer version of the above, as pointed out by E. Choroba.
}

Lock files are used in such applications as protecting system mail
folders from simultaneously being changed by multiple users,
indicating that a modem port is being accessed, and showing that an
instance of Firefox is using its cache. Scripts may check for the
existence of a lock file created by a certain process to check if that
process is running. Note that if a script attempts to create a lock
file that already exists, the script will likely hang.

Normally, applications create and check for lock files in the
◊fname{/var/lock} directory. A script can test for the presence of a
lock file by something like the following. Since only root has write
permission in the ◊fname{/var/lock} directory, a user script cannot
set a lock file there.

◊example{
appname=xyzip
# Application "xyzip" created lock file "/var/lock/xyzip.lock".

if [ -e "/var/lock/$appname.lock" ]
then   #+ Prevent other programs & scripts
       #  from accessing files/resources used by xyzip.
  ...
}

}

◊definition-entry[#:name "flock"]{
Much less useful than the ◊command{lockfile} command is flock. It sets
an "advisory" lock on a file and then executes a command while the
lock is on. This is to prevent any other process from setting a lock
on that file until completion of the specified command.

◊example{
flock $0 cat $0 > lockfile__$0
#  Set a lock on the script the above line appears in,
#+ while listing the script to stdout.
}

Note: Unlike ◊command{lockfile}, ◊command{flock} does not
automatically create a lock file.

}

◊definition-entry[#:name "mknod"]{
Creates block or character device files (may be necessary when
installing new hardware on the system). The MAKEDEV utility has
virtually all of the functionality of mknod, and is easier to use.

}

◊definition-entry[#:name "MAKEDEV"]{
Utility for creating device files. It must be run as root, and in the
◊fname{/dev} directory. It is a sort of advanced version of
◊command{mknod}.

}

◊definition-entry[#:name "tmpwatch"]{
Automatically deletes files which have not been accessed within a
specified period of time. Usually invoked by ◊command{cron} to remove
stale log files.

}

}

◊section{Backup}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "dump, restore"]{
The ◊command{dump} command is an elaborate filesystem backup utility,
generally used on larger installations and
networks. ◊footnote{Operators of single-user Linux systems generally
prefer something simpler for backups, such as ◊command{tar}.} It reads
raw disk partitions and writes a backup file in a binary format. Files
to be backed up may be saved to a variety of storage media, including
disks and tape drives. The ◊command{restore} command restores backups
made with ◊command{dump}.

}

◊definition-entry[#:name "fdformat"]{
Perform a low-level format on a floppy disk, such as ◊fname{/dev/fd0*}.

}

}

◊section{System Resources}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "ulimit"]{
Sets an upper limit on use of system resources. Usually invoked with
the ◊code{-f} option, which sets a limit on file size (◊command{ulimit
-f 1000} limits files to 1 meg maximum). The ◊code{-t} option limits
the coredump size (◊command{ulimit -c 0} eliminates
coredumps). Normally, the value of ulimit would be set in
◊fname{/etc/profile} and/or ◊fname{~/.bash_profile} (see TODO Appendix
H).

As of the version 4 update of Bash, the ◊code{-f} and ◊code{-c}
options take a block size of 512 when in POSIX mode. Additionally,
there are two new options: ◊code{-b} for socket buffer size, and
◊code{-T} for the limit on the number of threads.

Important: Judicious use of ulimit can protect a system against the
dreaded fork bomb.

◊example{
#!/bin/bash
# This script is for illustrative purposes only.
# Run it at your own peril -- it WILL freeze your system.

while true  #  Endless loop.
do
  $0 &      #  This script invokes itself . . .
            #+ forks an infinite number of times . . .
            #+ until the system freezes up because all resources exhausted.
done        #  This is the notorious "sorcerer's appentice" scenario.

exit 0      #  Will not exit here, because this script will never terminate.
}

A ◊command{ulimit -Hu XX} (where XX is the user process limit) in
◊fname{/etc/profile} would abort this script when it exceeded the
preset limit.

}

◊definition-entry[#:name "quota"]{
Display user or group disk quotas.

}

◊definition-entry[#:name "setquota"]{
Set user or group disk quotas from the command-line.

}

◊definition-entry[#:name "umask"]{
User file creation permissions mask. Limit the default file attributes
for a particular user. All files created by that user take on the
attributes specified by ◊command{umask}. The (octal) value passed to
umask defines the file permissions disabled. For example,
◊command{umask 022} ensures that new files will have at most 755
permissions (777 NAND 022). ◊footnote{NAND is the logical not-and
operator. Its effect is somewhat similar to subtraction.} Of course,
the user may later change the attributes of particular files with
◊command{chmod}. The usual practice is to set the value of
◊command{umask} in ◊fname{/etc/profile} and/or ◊fname{~/.bash_profile}
(see TODO Appendix H).

◊anchored-example[#:anchor "umask_hide1"]{Using umask to hide an
output file from prying eyes}

◊example{
#!/bin/bash
# rot13a.sh: Same as "rot13.sh" script, but writes output to "secure" file.

# Usage: ./rot13a.sh filename
# or     ./rot13a.sh <filename
# or     ./rot13a.sh and supply keyboard input (stdin)

umask 177               #  File creation mask.
                        #  Files created by this script
                        #+ will have 600 permissions.

OUTFILE=decrypted.txt   #  Results output to file "decrypted.txt"
                        #+ which can only be read/written
                        #  by invoker of script (or root).

cat "$@" | tr 'a-zA-Z' 'n-za-mN-ZA-M' > $OUTFILE 
#    ^^ Input from stdin or a file.   ^^^^^^^^^^ Output redirected to file. 

exit 0
}

}

◊definition-entry[#:name "rdev"]{
Get info about or make changes to root device, swap space, or video
mode. The functionality of ◊command{rdev} has generally been taken
over by ◊command{lilo}, but ◊command{rdev} remains useful for setting
up a ram disk. This is a dangerous command, if misused.

}

}

◊section{Modules}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "lsmod"]{
List installed kernel modules.

◊example{
bash$ lsmod
Module                  Size  Used by
autofs                  9456   2 (autoclean)
opl3                   11376   0
serial_cs               5456   0 (unused)
sb                     34752   0
uart401                 6384   0 [sb]
sound                  58368   0 [opl3 sb uart401]
soundlow                 464   0 [sound]
soundcore               2800   6 [sb sound]
ds                      6448   2 [serial_cs]
i82365                 22928   2
pcmcia_core            45984   0 [serial_cs ds i82365]

}

Note: Doing a ◊command{cat /proc/modules} gives the same information.

}

◊definition-entry[#:name "insmod"]{
Force installation of a kernel module (use modprobe instead, when
possible). Must be invoked as root.

}

◊definition-entry[#:name "rmmod"]{
Force unloading of a kernel module. Must be invoked as root.

}

◊definition-entry[#:name "modprobe"]{
Module loader that is normally invoked automatically in a startup
script. Must be invoked as root.

}

◊definition-entry[#:name "depmod"]{
Creates module dependency file. Usually invoked from a startup script.

}

◊definition-entry[#:name "modinfo"]{

Output information about a loadable module.

◊example{
bash$ modinfo hid
filename:    /lib/modules/2.4.20-6/kernel/drivers/usb/hid.o
description: "USB HID support drivers"
author:      "Andreas Gal, Vojtech Pavlik <vojtech@suse.cz>"
license:     "GPL"
}

}

}

◊section{Miscellaneous}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "env"]{
}

}
