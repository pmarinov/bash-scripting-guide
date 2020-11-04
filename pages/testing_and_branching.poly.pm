#lang pollen

◊page-init{}
◊define-meta[page-title]{Branching}
◊define-meta[page-description]{Testing and Branching}

The ◊code{case} and ◊code{select} constructs are technically not
loops, since they do not iterate the execution of a code block. Like
loops, however, they direct program flow according to conditions at
the top or bottom of the block.

◊definition-block[#:type "code"]{
◊definition-entry[#:name "case (in) / esac"]{
The ◊code{case} construct is the shell scripting analog to
◊code{switch} in C/C++. It permits branching to one of a number of
code blocks, depending on condition tests. It serves as a kind of
shorthand for multiple if/then/else statements and is an appropriate
tool for creating menus.

◊example{
case "$variable" in

  "$condition1" )
  command...
  ;;

  "$condition2" )
  command...
  ;;

esac
}

◊list-block[#:type "bullet"]{

◊list-entry{Quoting the variables is not mandatory, since word
splitting does not take place.}

◊list-entry{Each test line ends with a right paren ◊code{)}.}

◊list-entry{Each condition block ends with a double semicolon
◊code{;;}.}

◊list-entry{If a condition tests true, then the associated commands
execute and the ◊code{case} block terminates.}

◊list-entry{The entire ◊code{case} block ends with an ◊code{esac}
(◊code{case} spelled backwards).}

}

Note: Pattern-match lines may also start with a ◊code{(} left paren to give
the layout a more structured appearance.

◊example{
case $( arch ) in   # $( arch ) returns machine architecture.
  ( i386 ) echo "80386-based machine";;
# ^      ^
  ( i486 ) echo "80486-based machine";;
  ( i586 ) echo "Pentium-based machine";;
  ( i686 ) echo "Pentium2+-based machine";;
  (    * ) echo "Other type of machine";;
esac
}

}

} ◊;definition-block

◊definition-block[#:type "code"]{
◊definition-entry[#:name "select"]{

}

} ◊;definition-block

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
