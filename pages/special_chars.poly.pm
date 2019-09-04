#lang pollen

◊define-meta[page-title]{Special Characters}
◊define-meta[page-description]{Special Characters}

What makes a character special? If it has a meaning beyond its
◊emphasize{literal meaning}, a meta-meaning, then we refer to it as a
special character. Along with commands and keywords,
◊emphasize{special characters} are building blocks of Bash scripts.

◊section{Special Characters Found In Scripts and Elsewhere}

◊definition-block[#:type "variables"]{
◊definition-entry[#:name "#"]{
◊strong{Comments}. Lines beginning with a # (with the exception of #!)
are comments and will ◊emphasize{not} be executed.

◊example{# This line is a comment.}

Comments may also occur following the end of a command.

◊example{echo "A comment will follow." # Comment here.
#                            ^ Note whitespace before #
}
}
}
