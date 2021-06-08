#lang pollen

◊; This is free software released into the public domain
◊; See LICENSE.txt

◊page-init{}
◊define-meta[page-title]{Terminal Control Commands}
◊define-meta[page-description]{Terminal Control Commands}

◊section{Commands affecting the console or terminal}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "tput"]{

Initialize terminal and/or fetch information about it from terminfo
data. Various options permit certain terminal operations:
◊command{tput clear} is the equivalent of ◊command{clear};
◊command{tput reset} is the equivalent of ◊command{reset}.

◊example{
bash$ tput longname
xterm terminal emulator (X Window System)

}

Issuing a ◊command{tput cup X Y} moves the cursor to the (X,Y)
coordinates in the current terminal. A ◊command{clear} to erase the
terminal screen would normally precede this.

Some interesting options to ◊command{tput} are:

◊code{bold} for high-intensity text, ◊code{smul} to underline text in
the terminal, ◊code{smso} to render text in reverse, ◊code{sgr0} to
reset the terminal parameters (to normal), without clearing the screen

Example scripts using ◊command{tput}, TODO Example 36-15, Example
36-13, Example A-44, Example A-42, Example 27-2

Note that ◊command{stty} offers a more powerful command set for
controlling a terminal.

}

}

