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

◊definition-entry[#:name "infocmp"]{
This command prints out extensive information about the current
terminal. It references the terminfo database.

◊example{
bash$ infocmp
#       Reconstructed via infocmp from file:
 /usr/share/terminfo/r/rxvt
 rxvt|rxvt terminal emulator (X Window System), 
         am, bce, eo, km, mir, msgr, xenl, xon, 
         colors#8, cols#80, it#8, lines#24, pairs#64, 
         acsc=``aaffggjjkkllmmnnooppqqrrssttuuvvwwxxyyzz{{||}}~~, 
         bel=^G, blink=\E[5m, bold=\E[1m,
         civis=\E[?25l, 
         clear=\E[H\E[2J, cnorm=\E[?25h, cr=^M, 
         ...
}

}

◊definition-entry[#:name "reset"]{
Reset terminal parameters and clear text screen. As with
◊command{clear}, the cursor and prompt reappear in the upper lefthand
corner of the terminal.

}

◊definition-entry[#:name "clear"]{
The ◊command{clear} command simply clears the text screen at the
console or in an xterm. The prompt and cursor reappear at the upper
lefthand corner of the screen or xterm window. This command may be
used either at the command line or in a script. See TODO Example
11-26.

}

◊definition-entry[#:name "resize"]{
Echoes commands necessary to set ◊code{$TERM} and ◊code{$TERMCAP} to
duplicate the size (dimensions) of the current terminal.

◊example{
bash$ resize
set noglob;
setenv COLUMNS '80';
setenv LINES '24';
unset noglob;

}

}

◊definition-entry[#:name "script"]{
This utility records (saves to a file) all the user keystrokes at the
command-line in a console or an xterm window. This, in effect, creates
a record of a session.

}

}

