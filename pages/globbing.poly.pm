#lang pollen

◊page-init{}
◊define-meta[page-title]{Globbing}
◊define-meta[page-description]{Globbing}

Bash itself cannot recognize Regular Expressions. Inside scripts, it
is commands and utilities -- such as ◊command{sed} and ◊command{awk}
-- that interpret RE's.

Bash does carry out filename expansion ◊footnote{Filename expansion
means expanding filename patterns or templates containing special
characters. For example, ◊fname{example.???} might expand to
◊fname{example.001} and/or ◊fname{example.txt}.} -- a process known as
globbing -- but this does not use the standard RE set. Instead,
globbing recognizes and expands wild cards. Globbing interprets the
standard wild card characters ◊footnote{A wild card character,
analogous to a wild card in poker, can represent (almost) any other
character.} -- ◊fname{*} and ◊fname{?}, character lists in square
brackets, and certain other special characters (such as ◊fname{^} for
negating the sense of a match). There are important limitations on
wild card characters in globbing, however. Strings containing
◊fname{*} will not match filenames that start with a dot, as, for
example, ◊fname{.bashrc}. Likewise, the ◊fname{?} has a different
meaning in globbing than as part of an RE.

Filename expansion can match dotfiles, but only if the pattern
explicitly includes the dot as a literal character.

◊example{
~/[.]bashrc    #  Will not expand to ~/.bashrc
~/?bashrc      #  Neither will this.
               #  Wild cards and metacharacters will NOT
               #+ expand to a dot in globbing.

~/.[b]ashrc    #  Will expand to ~/.bashrc
~/.ba?hrc      #  Likewise.
~/.bashr*      #  Likewise.

# Setting the "dotglob" option turns this off.
}