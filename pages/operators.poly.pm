#lang pollen

◊define-meta[page-title]{Operators}
◊define-meta[page-description]{Operations and Related Topics}

The way to calculate expressions in the first shell was via the external program ◊code{expr}. It is still there:

◊example{
$ expr 2 + 2
4
}

Bash has builtin operators to offers the arithmetic operations of ◊code{expr}

◊(node-menu "pages/operators.poly.pm")

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
