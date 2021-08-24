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
