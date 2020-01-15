#lang pollen

◊define-meta[page-title]{Escaping}
◊define-meta[page-description]{Quoting single characters}

◊emphasize{Escaping} is a method of quoting single characters. The
escape (◊code{\}) preceding a character tells the shell to interpret that
character literally.

Caution: With certain commands and utilities, such as ◊code{echo} and
◊code{sed}, escaping a character may have the opposite effect - it can
toggle on a special meaning for that character.

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
