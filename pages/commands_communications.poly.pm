#lang pollen

◊; This is free software released into the public domain
◊; See LICENSE.txt

◊page-init{}
◊define-meta[page-title]{Communications Commands}
◊define-meta[page-description]{Communications Commands}


◊section{Information and Statistics}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "host"]{
Searches for information about an Internet host by name or IP address,
using DNS.

◊example{
bash$ host surfacemail.com
surfacemail.com. has address 202.92.42.236

}

}

◊definition-entry[#:name "ipcalc"]{
Displays IP information for a host. With the ◊code{-h} option,
◊command{ipcalc} does a reverse DNS lookup, finding the name of the
host (server) from the IP address.

◊example{
bash$ ipcalc -h 202.92.42.236
HOSTNAME=surfacemail.com
}

}

◊definition-entry[#:name "nslookup"]{
Do an Internet "name server lookup" on a host by IP address. This is
essentially equivalent to ◊command{ipcalc -h} or ◊command{dig -x}. The
command may be run either interactively or noninteractively, i.e.,
from within a script.

◊example{
bash$ nslookup -sil 66.97.104.180
nslookup kuhleersparnis.ch
Server:         135.116.137.2
Address:        135.116.137.2#53

Non-authoritative answer:
Name:   kuhleersparnis.ch
}

}

◊definition-entry[#:name "nslookup"]{
Domain Information Groper. Similar to ◊command{nslookup},
◊command{dig} does an Internet name server lookup on a host. May be
run from the command-line or from within a script.

Some interesting options to dig are ◊code{+time=N} for setting a query
timeout to N seconds, ◊code{+nofail} for continuing to query servers
until a reply is received, and ◊code{-x} for doing a reverse address
lookup.

Compare the output of ◊command{dig -x} with ◊command{ipcalc -h} and
◊command{nslookup}.

◊example{
bash$ dig -x 81.9.6.2
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 11649
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 0

;; QUESTION SECTION:
;2.6.9.81.in-addr.arpa.         IN      PTR

;; AUTHORITY SECTION:
6.9.81.in-addr.arpa.    3600    IN      SOA     ns.eltel.net. noc.eltel.net.
2002031705 900 600 86400 3600

;; Query time: 537 msec
;; SERVER: 135.116.137.2#53(135.116.137.2)
;; WHEN: Wed Jun 26 08:35:24 2002
;; MSG SIZE  rcvd: 91
}

◊anchored-example[#:anchor "dig_spam1"]{Finding out where to report a
spammer}

◊example{
#!/bin/bash
# spam-lookup.sh: Look up abuse contact to report a spammer.
# Thanks, Michael Zick.

# Check for command-line arg.
ARGCOUNT=1
E_WRONGARGS=85
if [ $# -ne "$ARGCOUNT" ]
then
  echo "Usage: `basename $0` domain-name"
  exit $E_WRONGARGS
fi


dig +short $1.contacts.abuse.net -c in -t txt
# Also try:
#     dig +nssearch $1
#     Tries to find "authoritative name servers" and display SOA records.

# The following also works:
#     whois -h whois.abuse.net $1
#           ^^ ^^^^^^^^^^^^^^^  Specify host.
#     Can even lookup multiple spammers with this, i.e."
#     whois -h whois.abuse.net $spamdomain1 $spamdomain2 . . .


#  Exercise:
#  --------
#  Expand the functionality of this script
#+ so that it automatically e-mails a notification
#+ to the responsible ISP's contact address(es).
#  Hint: use the "mail" command.

exit $?

# spam-lookup.sh chinatietong.com
#                A known spam domain.

# "crnet_mgr@chinatietong.com"
# "crnet_tec@chinatietong.com"
# "postmaster@chinatietong.com"


#  For a more elaborate version of this script,
#+ see the SpamViz home page, http://www.spamviz.net/index.html.
}


◊anchored-example[#:anchor "dig_spam2"]{Analyzing a spam domain}

◊example{
#! /bin/bash
# is-spammer.sh: Identifying spam domains

# $Id: is-spammer, v 1.4 2004/09/01 19:37:52 mszick Exp $
# Above line is RCS ID info.
#
#  This is a simplified version of the "is_spammer.bash
#+ script in the Contributed Scripts appendix.

# is-spammer <domain.name>

# Uses an external program: 'dig'
# Tested with version: 9.2.4rc5

# Uses functions.
# Uses IFS to parse strings by assignment into arrays.
# And even does something useful: checks e-mail blacklists.

# Use the domain.name(s) from the text body:
# http://www.good_stuff.spammer.biz/just_ignore_everything_else
#                       ^^^^^^^^^^^
# Or the domain.name(s) from any e-mail address:
# Really_Good_Offer@spammer.biz
#
# as the only argument to this script.
#(PS: have your Inet connection running)
#
# So, to invoke this script in the above two instances:
#       is-spammer.sh spammer.biz


# Whitespace == :Space:Tab:Line Feed:Carriage Return:
WSP_IFS=$'\x20'$'\x09'$'\x0A'$'\x0D'

# No Whitespace == Line Feed:Carriage Return
No_WSP=$'\x0A'$'\x0D'

# Field separator for dotted decimal ip addresses
ADR_IFS=${No_WSP}'.'

# Get the dns text resource record.
# get_txt <error_code> <list_query>
get_txt() {

    # Parse $1 by assignment at the dots.
    local -a dns
    IFS=$ADR_IFS
    dns=( $1 )
    IFS=$WSP_IFS
    if [ "${dns[0]}" == '127' ]
    then
        # See if there is a reason.
        echo $(dig +short $2 -t txt)
    fi
}

# Get the dns address resource record.
# chk_adr <rev_dns> <list_server>
chk_adr() {
    local reply
    local server
    local reason

    server=${1}${2}
    reply=$( dig +short ${server} )

    # If reply might be an error code . . .
    if [ ${#reply} -gt 6 ]
    then
        reason=$(get_txt ${reply} ${server} )
        reason=${reason:-${reply}}
    fi
    echo ${reason:-' not blacklisted.'}
}

# Need to get the IP address from the name.
echo 'Get address of: '$1
ip_adr=$(dig +short $1)
dns_reply=${ip_adr:-' no answer '}
echo ' Found address: '${dns_reply}

# A valid reply is at least 4 digits plus 3 dots.
if [ ${#ip_adr} -gt 6 ]
then
    echo
    declare query

    # Parse by assignment at the dots.
    declare -a dns
    IFS=$ADR_IFS
    dns=( ${ip_adr} )
    IFS=$WSP_IFS

    # Reorder octets into dns query order.
    rev_dns="${dns[3]}"'.'"${dns[2]}"'.'"${dns[1]}"'.'"${dns[0]}"'.'

# See: http://www.spamhaus.org (Conservative, well maintained)
    echo -n 'spamhaus.org says: '
    echo $(chk_adr ${rev_dns} 'sbl-xbl.spamhaus.org')

# See: http://ordb.org (Open mail relays)
    echo -n '   ordb.org  says: '
    echo $(chk_adr ${rev_dns} 'relays.ordb.org')

# See: http://www.spamcop.net/ (You can report spammers here)
    echo -n ' spamcop.net says: '
    echo $(chk_adr ${rev_dns} 'bl.spamcop.net')

# # # other blacklist operations # # #

# See: http://cbl.abuseat.org.
    echo -n ' abuseat.org says: '
    echo $(chk_adr ${rev_dns} 'cbl.abuseat.org')

# See: http://dsbl.org/usage (Various mail relays)
    echo
    echo 'Distributed Server Listings'
    echo -n '       list.dsbl.org says: '
    echo $(chk_adr ${rev_dns} 'list.dsbl.org')

    echo -n '   multihop.dsbl.org says: '
    echo $(chk_adr ${rev_dns} 'multihop.dsbl.org')

    echo -n 'unconfirmed.dsbl.org says: '
    echo $(chk_adr ${rev_dns} 'unconfirmed.dsbl.org')

else
    echo
    echo 'Could not use that address.'
fi

exit 0

# Exercises:
# --------

# 1) Check arguments to script,
#    and exit with appropriate error message if necessary.

# 2) Check if on-line at invocation of script,
#    and exit with appropriate error message if necessary.

# 3) Substitute generic variables for "hard-coded" BHL domains.

# 4) Set a time-out for the script using the "+time=" option
     to the 'dig' command.
}

For a much more elaborate version of the above script, see Example
TODO A-28.
}

◊definition-entry[#:name "traceroute"]{
Trace the route taken by packets sent to a remote host. This command
works within a LAN, WAN, or over the Internet. The remote host may be
specified by an IP address. The output of this command may be filtered
by ◊command{grep} or ◊command{sed} in a pipe.

◊example{
bash$ traceroute 81.9.6.2
traceroute to 81.9.6.2 (81.9.6.2), 30 hops max, 38 byte packets
1  tc43.xjbnnbrb.com (136.30.178.8)  191.303 ms  179.400 ms  179.767 ms
2  or0.xjbnnbrb.com (136.30.178.1)  179.536 ms  179.534 ms  169.685 ms
3  192.168.11.101 (192.168.11.101)  189.471 ms  189.556 ms *
...
}

}

◊definition-entry[#:name "ping"]{
Broadcast an ICMP ECHO_REQUEST packet to another machine, either on a
local or remote network.

◊example{
bash$ ping localhost
PING localhost.localdomain (127.0.0.1) from 127.0.0.1 : 56(84) bytes of data.
64 bytes from localhost.localdomain (127.0.0.1): icmp_seq=0 ttl=255 time=709 usec
64 bytes from localhost.localdomain (127.0.0.1): icmp_seq=1 ttl=255 time=286 usec

--- localhost.localdomain ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max/mdev = 0.286/0.497/0.709/0.212 ms
}

A successful ◊command{ping} returns an exit status of 0. This can be
tested for in a script.

◊example{
HNAME=news-15.net  # Notorious spammer.
# HNAME=$HOST     # Debug: test for localhost.
count=2  # Send only two pings.

if [[ `ping -c $count "$HNAME"` ]]
then
  echo ""$HNAME" still up and broadcasting spam your way."
else
  echo ""$HNAME" seems to be down. Pity."
fi
}

}

◊definition-entry[#:name "whois"]{
Perform a DNS (Domain Name System) lookup. The ◊code{-h} option permits
specifying which particular whois server to query. See TODO Example 4-6 and
Example 16-40.

}

◊definition-entry[#:name "finger"]{
Retrieve information about users on a network. Optionally, this
command can display a user's ◊fname{~/.plan}, ◊fname{~/.project}, and
◊fname{~/.forward} files, if present.

◊example{
bash$ finger
Login  Name           Tty      Idle  Login Time   Office     Office Phone
bozo   Bozo Bozeman   tty1        8  Jun 25 16:59                (:0)
bozo   Bozo Bozeman   ttyp0          Jun 25 16:59                (:0.0)
bozo   Bozo Bozeman   ttyp1          Jun 25 17:07                (:0.0)


bash$ finger bozo
Login: bozo                             Name: Bozo Bozeman
Directory: /home/bozo                   Shell: /bin/bash
Office: 2355 Clown St., 543-1234
On since Fri Aug 31 20:13 (MST) on tty1    1 hour 38 minutes idle
On since Fri Aug 31 20:13 (MST) on pts/0   12 seconds idle
On since Fri Aug 31 20:13 (MST) on pts/1
On since Fri Aug 31 20:31 (MST) on pts/2   1 hour 16 minutes idle
Mail last read Tue Jul  3 10:08 2007 (MST)
No Plan.
}

Out of security considerations, many networks disable finger and its
associated daemon. ◊footnote{A daemon is a background process not
attached to a terminal session. Daemons perform designated services
either at specified times or explicitly triggered by certain events.

The word "daemon" means ghost in Greek, and there is certainly
something mysterious, almost supernatural, about the way UNIX daemons
wander about behind the scenes, silently carrying out their appointed
tasks.}

}

◊definition-entry[#:name "chfn"]{
Change information disclosed by the ◊command{finger} command.

}

◊definition-entry[#:name "vrfy"]{
Verify an Internet e-mail address.

This command seems to be missing from newer Linux distros.

}

}

◊section{Remote Host Access}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "sx, rx"]{
The ◊command{sx} and ◊command{rx} command set serves to transfer files
to and from a remote host using the xmodem protocol. These are
generally part of a communications package, such as minicom.

}

◊definition-entry[#:name "sz, rz"]{
The ◊command{sz} and ◊command{rz} command set serves to transfer files
to and from a remote host using the zmodem protocol. Zmodem has
certain advantages over xmodem, such as faster transmission rate and
resumption of interrupted file transfers. Like ◊command{sx} and
◊command{rx}, these are generally part of a communications package.

}

◊definition-entry[#:name "ftp"]{
Utility and protocol for uploading / downloading files to or from a
remote host. An ◊command{ftp} session can be automated in a script
(see Example TODO 19-6 and Example A-4).

}

◊definition-entry[#:name "uucp, uux, cu"]{
◊command{uucp}: UNIX to UNIX copy. This is a communications package
for transferring files between UNIX servers. A shell script is an
effective way to handle a ◊command{uucp} command sequence.

Since the advent of the Internet and e-mail, ◊command{uucp} seems to
have faded into obscurity, but it still exists and remains perfectly
workable in situations where an Internet connection is not available
or appropriate. The advantage of ◊command{uucp} is that it is
fault-tolerant, so even if there is a service interruption the copy
operation will resume where it left off when the connection is
restored.

◊command{uux}: UNIX to UNIX execute. Execute a command on a remote
system. This command is part of the uucp package.

◊command{cu}: Call Up a remote system and connect as a simple
terminal. It is a sort of dumbed-down version of
◊command{telnet}. This command is part of the uucp package.

}

◊definition-entry[#:name "telnet"]{
Utility and protocol for connecting to a remote host.

Caution: The ◊command{telnet} protocol contains security holes and
should therefore probably be avoided. Its use within a shell script is
not recommended.

}

◊definition-entry[#:name "wget"]{
The ◊command{wget} utility noninteractively retrieves or downloads
files from a Web or ftp site. It works well in a script.

◊example{
wget -p http://www.xyz23.com/file01.html
#  The -p or --page-requisite option causes wget to fetch all files
#+ required to display the specified page.

wget -r ftp://ftp.xyz24.net/~bozo/project_files/ -O $SAVEFILE
#  The -r option recursively follows and retrieves all links
#+ on the specified site.

wget -c ftp://ftp.xyz25.net/bozofiles/filename.tar.bz2
#  The -c option lets wget resume an interrupted download.
#  This works with ftp servers and many HTTP sites.

}

◊anchored-example[#:anchor "wget_quote1"]{Getting a stock quote}

◊example{
#!/bin/bash
# quote-fetch.sh: Download a stock quote.


E_NOPARAMS=86

if [ -z "$1" ]  # Must specify a stock (symbol) to fetch.
  then echo "Usage: `basename $0` stock-symbol"
  exit $E_NOPARAMS
fi

stock_symbol=$1

file_suffix=.html
# Fetches an HTML file, so name it appropriately.
URL='http://finance.yahoo.com/q?s='
# Yahoo finance board, with stock query suffix.

# -----------------------------------------------------------
wget -O ${stock_symbol}${file_suffix} "${URL}${stock_symbol}"
# -----------------------------------------------------------


# To look up stuff on http://search.yahoo.com:
# -----------------------------------------------------------
# URL="http://search.yahoo.com/search?fr=ush-news&p=${query}"
# wget -O "$savefilename" "${URL}"
# -----------------------------------------------------------
# Saves a list of relevant URLs.

exit $?

# Exercises:
# ---------
#
# 1) Add a test to ensure the user running the script is on-line.
#    (Hint: parse the output of 'ps -ax' for "ppp" or "connect."
#
# 2) Modify this script to fetch the local weather report,
#+   taking the user's zip code as an argument.
}

See also Example TODO A-30 and Example A-31.

}

◊definition-entry[#:name "lynx"]{
The ◊command{lynx} Web and file browser can be used inside a script
(with the ◊code{-dump} option) to retrieve a file from a Web or ftp
site noninteractively.

◊example{
lynx -dump http://www.xyz23.com/file01.html >$SAVEFILE
}

With the ◊code{-traversal} option, ◊command{lynx} starts at the HTTP
URL specified as an argument, then "crawls" through all links located
on that particular server. Used together with the ◊code{-crawl}
option, outputs page text to a log file.

}

◊definition-entry[#:name "rlogin"]{
Remote login, initates a session on a remote host. This command has
security issues, so use ◊command{ssh} instead.

}

◊definition-entry[#:name "rsh"]{
Remote shell, executes command(s) on a remote host. This has security
issues, so use ◊command{ssh} instead.

}

◊definition-entry[#:name "rcp"]{
Remote copy, copies files between two different networked
machines. Use ◊command{scp} instead.

}

◊definition-entry[#:name "rsync"]{
Remote synchronize, updates (synchronizes) files between two different
networked machines.

◊example{
bash$ rsync -a ~/sourcedir/*txt /node1/subdirectory/
}

◊anchored-example[#:anchor "rsync_udatefc1"]{Updating FC4}

◊example{
#!/bin/bash
# fc4upd.sh

# Script author: Frank Wang.
# Slight stylistic modifications by ABS Guide author.
# Used in ABS Guide with permission.


#  Download Fedora Core 4 update from mirror site using rsync. 
#  Should also work for newer Fedora Cores -- 5, 6, . . .
#  Only download latest package if multiple versions exist,
#+ to save space.

URL=rsync://distro.ibiblio.org/fedora-linux-core/updates/
# URL=rsync://ftp.kddilabs.jp/fedora/core/updates/
# URL=rsync://rsync.planetmirror.com/fedora-linux-core/updates/

DEST=${1:-/var/www/html/fedora/updates/}
LOG=/tmp/repo-update-$(/bin/date +%Y-%m-%d).txt
PID_FILE=/var/run/${0##*/}.pid

E_RETURN=85        # Something unexpected happened.


# General rsync options
# -r: recursive download
# -t: reserve time
# -v: verbose

OPTS="-rtv --delete-excluded --delete-after --partial"

# rsync include pattern
# Leading slash causes absolute path name match.
INCLUDE=(
    "/4/i386/kde-i18n-Chinese*" 
#   ^                         ^
# Quoting is necessary to prevent globbing.
) 


# rsync exclude pattern
# Temporarily comment out unwanted pkgs using "#" . . .
EXCLUDE=(
    /1
    /2
    /3
    /testing
    /4/SRPMS
    /4/ppc
    /4/x86_64
    /4/i386/debug
   "/4/i386/kde-i18n-*"
   "/4/i386/openoffice.org-langpack-*"
   "/4/i386/*i586.rpm"
   "/4/i386/GFS-*"
   "/4/i386/cman-*"
   "/4/i386/dlm-*"
   "/4/i386/gnbd-*"
   "/4/i386/kernel-smp*"
#  "/4/i386/kernel-xen*" 
#  "/4/i386/xen-*" 
)


init () {
    # Let pipe command return possible rsync error, e.g., stalled network.
    set -o pipefail                  # Newly introduced in Bash, version 3.

    TMP=${TMPDIR:-/tmp}/${0##*/}.$$  # Store refined download list.
    trap "{
        rm -f $TMP 2>/dev/null
    }" EXIT                          # Clear temporary file on exit.
}


check_pid () {
# Check if process exists.
    if [ -s "$PID_FILE" ]; then
        echo "PID file exists. Checking ..."
        PID=$(/bin/egrep -o "^[[:digit:]]+" $PID_FILE)
        if /bin/ps --pid $PID &>/dev/null; then
            echo "Process $PID found. ${0##*/} seems to be running!"
           /usr/bin/logger -t ${0##*/} \
                 "Process $PID found. ${0##*/} seems to be running!"
            exit $E_RETURN
        fi
        echo "Process $PID not found. Start new process . . ."
    fi
}


#  Set overall file update range starting from root or $URL,
#+ according to above patterns.
set_range () {
    include=
    exclude=
    for p in "${INCLUDE[@]}"; do
        include="$include --include \"$p\""
    done

    for p in "${EXCLUDE[@]}"; do
        exclude="$exclude --exclude \"$p\""
    done
}


# Retrieve and refine rsync update list.
get_list () {
    echo $$ > $PID_FILE || {
        echo "Can't write to pid file $PID_FILE"
        exit $E_RETURN
    }

    echo -n "Retrieving and refining update list . . ."

    # Retrieve list -- 'eval' is needed to run rsync as a single command.
    # $3 and $4 is the date and time of file creation.
    # $5 is the full package name.
    previous=
    pre_file=
    pre_date=0
    eval /bin/nice /usr/bin/rsync \
        -r $include $exclude $URL | \
        egrep '^dr.x|^-r' | \
        awk '{print $3, $4, $5}' | \
        sort -k3 | \
        { while read line; do
            # Get seconds since epoch, to filter out obsolete pkgs.
            cur_date=$(date -d "$(echo $line | awk '{print $1, $2}')" +%s)
            #  echo $cur_date

            # Get file name.
            cur_file=$(echo $line | awk '{print $3}')
            #  echo $cur_file

            # Get rpm pkg name from file name, if possible.
            if [[ $cur_file == *rpm ]]; then
                pkg_name=$(echo $cur_file | sed -r -e \
                    's/(^([^_-]+[_-])+)[[:digit:]]+\..*[_-].*$/\1/')
            else
                pkg_name=
            fi
            # echo $pkg_name

            if [ -z "$pkg_name" ]; then   #  If not a rpm file,
                echo $cur_file >> $TMP    #+ then append to download list.
            elif [ "$pkg_name" != "$previous" ]; then   # A new pkg found.
                echo $pre_file >> $TMP                  # Output latest file.
                previous=$pkg_name                      # Save current.
                pre_date=$cur_date
                pre_file=$cur_file
            elif [ "$cur_date" -gt "$pre_date" ]; then
                                                #  If same pkg, but newer,
                pre_date=$cur_date              #+ then update latest pointer.
                pre_file=$cur_file
            fi
            done
            echo $pre_file >> $TMP              #  TMP contains ALL
                                                #+ of refined list now.
            # echo "subshell=$BASH_SUBSHELL"

    }       # Bracket required here to let final "echo $pre_file >> $TMP" 
            # Remained in the same subshell ( 1 ) with the entire loop.

    RET=$?  # Get return code of the pipe command.

    [ "$RET" -ne 0 ] && {
        echo "List retrieving failed with code $RET"
        exit $E_RETURN
    }

    echo "done"; echo
}

# Real rsync download part.
get_file () {

    echo "Downloading..."
    /bin/nice /usr/bin/rsync \
        $OPTS \
        --filter "merge,+/ $TMP" \
        --exclude '*'  \
        $URL $DEST     \
        | /usr/bin/tee $LOG

    RET=$?

   #  --filter merge,+/ is crucial for the intention. 
   #  + modifier means include and / means absolute path.
   #  Then sorted list in $TMP will contain ascending dir name and 
   #+ prevent the following --exclude '*' from "shortcutting the circuit." 

    echo "Done"

    rm -f $PID_FILE 2>/dev/null

    return $RET
}

# -------
# Main
init
check_pid
set_range
get_list
get_file
RET=$?
# -------

if [ "$RET" -eq 0 ]; then
    /usr/bin/logger -t ${0##*/} "Fedora update mirrored successfully."
else
    /usr/bin/logger -t ${0##*/} \
    "Fedora update mirrored with failure code: $RET"
fi

exit $RET
}

See also TODO Example A-32.

Note: Using ◊command{rcp}, ◊command{rsync}, and similar utilities with
security implications in a shell script may not be
advisable. Consider, instead, using ◊command{ssh}, ◊command{scp}, or
an ◊command{expect} script.

}


}
