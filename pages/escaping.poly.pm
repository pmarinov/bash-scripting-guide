#lang pollen

◊define-meta[page-title]{Escaping}
◊define-meta[page-description]{Quoting single characters}

◊emphasize{Escaping} is a method of quoting single characters. The
escape (◊code{\}) preceding a character tells the shell to interpret that
character literally.

Caution: With certain commands and utilities, such as ◊code{echo} and
◊code{sed}, escaping a character may have the opposite effect - it can
toggle on a special meaning for that character.

◊section["Special meanings of certain escaped characters"]

(used with ◊code{echo} and ◊code{sed})

◊definition-block[#:type "variables"]{
◊definition-entry[#:name "\\n"]{
means newline
}

◊definition-entry[#:name "\\r"]{
means return
}

◊definition-entry[#:name "\\t"]{
means tab
}

◊definition-entry[#:name "\\v"]{
means vertical tab
}

◊definition-entry[#:name "\\b"]{
means backspace
}

◊definition-entry[#:name "\\a"]{
means ◊emphasize{alert} (beep or flash)
}

}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
