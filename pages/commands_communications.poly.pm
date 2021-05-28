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

}


}

